public class ConvertLead {

    // -------------------------------
    // Tunables / test hooks
    // -------------------------------
    @TestVisible static Datetime CREATED_AFTER = Datetime.newInstanceGmt(2018, 6, 1, 0, 0, 0);
    @TestVisible static Integer  LIMIT_N       = 5;
    @TestVisible static Id       OWNER_ID      = null;
    @TestVisible static String   OWNER_NAME    = 'Hubspot Service';
    @TestVisible static String   OWNER_NAME2   = 'Americord Registry';
    @TestVisible static String   SALES_DIVISION = 'Inside Sales';
    @TestVisible static String   SERVICE_DIVISION = 'Client Services';

    // -------------------------------
    // Instrumentation
    // -------------------------------
    @TestVisible static Integer LAST_QUERIED   = 0;
    @TestVisible static Integer LAST_ATTEMPTED = 0;
    @TestVisible static Integer LAST_SUCCEEDED = 0;
    @TestVisible static List<String> LAST_ERRORS = new List<String>();

    // -------------------------------
    // Entry point
    // -------------------------------
    public static void run() {

        LAST_QUERIED = 0;
        LAST_ATTEMPTED = 0;
        LAST_SUCCEEDED = 0;
        LAST_ERRORS.clear();

        // ------------------------------------------------
        // 1) Eligible owners
        // ------------------------------------------------
        Set<Id> eligibleOwnerIds = new Set<Id>();

        if (OWNER_ID != null) {
            eligibleOwnerIds.add(OWNER_ID);
        } else {
            for (User u : [
                SELECT Id
                FROM User
                WHERE (
                    Name IN :new List<String>{ OWNER_NAME, OWNER_NAME2 }
                    OR Division IN :new List<String>{ SALES_DIVISION, SERVICE_DIVISION }
                )
                AND IsActive = TRUE
            ]) {
                eligibleOwnerIds.add(u.Id);
            }
        }

        if (eligibleOwnerIds.isEmpty()) {
            LAST_ERRORS.add('No eligible users found.');
            return;
        }

        // ------------------------------------------------
        // 2) Query eligible Leads (SOQL-safe)
        // ------------------------------------------------
        List<Lead> leads = [
            SELECT Id, Name, Company, FirstName, LastName,
                   Email, Phone, LeadSource,
                   Status, IsConverted, Babys_Due_Date__c
            FROM Lead
            WHERE IsConverted = FALSE
              AND Status IN ('New', 'Open', 'Working')
              AND CreatedDate > :CREATED_AFTER
              AND (NOT Company LIKE 'QA %')
              AND (NOT Company LIKE '%test%')
              AND (NOT Company LIKE '%Unknown%')
              AND Email != 'unknown@example.com'
              AND OwnerId IN :eligibleOwnerIds
            LIMIT :LIMIT_N
        ];

        LAST_QUERIED = leads.size();
        if (leads.isEmpty()) return;

        // ------------------------------------------------
        // 3) Converted LeadStatus
        // ------------------------------------------------
        LeadStatus ls = [
            SELECT MasterLabel
            FROM LeadStatus
            WHERE IsConverted = TRUE
            LIMIT 1
        ];
        String convertedStatus = ls.MasterLabel;

        // ------------------------------------------------
        // 4) Normalize identifiers
        // ------------------------------------------------
        Set<String> leadEmailsLower = new Set<String>();
        Set<String> leadPhones10 = new Set<String>();

        for (Lead l : leads) {
            if (!String.isBlank(l.Email)) {
                leadEmailsLower.add(l.Email.trim().toLowerCase());
            }
            String p10 = normalizePhone10(l.Phone);
            if (p10 != null) leadPhones10.add(p10);
        }

        // ------------------------------------------------
        // 5) Load candidate Accounts (bounded)
        // ------------------------------------------------
        Map<Id, Account> acctById = new Map<Id, Account>();

        // 5a) Accounts with matching phone
        if (!leadPhones10.isEmpty()) {
            for (Account a : [
                SELECT Id, OwnerId, Phone,
                       (SELECT Id, Email, Phone FROM Contacts)
                FROM Account
                WHERE Phone != null
            ]) {
                if (leadPhones10.contains(normalizePhone10(a.Phone))) {
                    acctById.put(a.Id, a);
                }
            }
        }

        // 5b) Accounts with Contacts matching email
        if (!leadEmailsLower.isEmpty()) {

            Set<Id> acctIdsFromEmail = new Set<Id>();

            for (Contact c : [
                SELECT AccountId, Email
                FROM Contact
                WHERE AccountId != null
                  AND Email != null
            ]) {
                if (leadEmailsLower.contains(c.Email.trim().toLowerCase())) {
                    acctIdsFromEmail.add(c.AccountId);
                }
            }

            if (!acctIdsFromEmail.isEmpty()) {
                for (Account a : [
                    SELECT Id, OwnerId, Phone,
                           (SELECT Id, Email, Phone FROM Contacts)
                    FROM Account
                    WHERE Id IN :acctIdsFromEmail
                ]) {
                    acctById.put(a.Id, a);
                }
            }
        }

        List<Account> candidateAccounts = acctById.values();

        // ------------------------------------------------
        // 6) Work lists
        // ------------------------------------------------
        List<Database.LeadConvert> conversions = new List<Database.LeadConvert>();
        List<Opportunity> directOpps = new List<Opportunity>();
        List<Lead> leadsToMarkConverted = new List<Lead>();

        // ------------------------------------------------
        // 7) Process Leads
        // ------------------------------------------------
        for (Lead l : leads) {

            String leadEmail = l.Email != null ? l.Email.trim().toLowerCase() : null;
            String leadPhone10 = normalizePhone10(l.Phone);

            Account matchedAcc;
            Contact matchedCon;

            // A) Phone match (Account or Contact)
            if (leadPhone10 != null) {
                for (Account a : candidateAccounts) {

                    if (normalizePhone10(a.Phone) == leadPhone10) {
                        matchedAcc = a;
                        break;
                    }

                    for (Contact c : a.Contacts) {
                        if (normalizePhone10(c.Phone) == leadPhone10) {
                            matchedAcc = a;
                            matchedCon = c;
                            break;
                        }
                    }
                    if (matchedAcc != null) break;
                }
            }

            // B) Email match
            if (matchedAcc == null && leadEmail != null) {
                for (Account a : candidateAccounts) {
                    for (Contact c : a.Contacts) {
                        if (c.Email != null && c.Email.trim().toLowerCase() == leadEmail) {
                            matchedAcc = a;
                            matchedCon = c;
                            break;
                        }
                    }
                    if (matchedAcc != null) break;
                }
            }

            // C) Direct Opportunity
            if (matchedAcc != null) {

                String oppName = l.Name;
                if (l.Babys_Due_Date__c != null) {
                    oppName += ' - ' +
                        Datetime.newInstance(l.Babys_Due_Date__c, Time.newInstance(0,0,0,0))
                                .format('MM/dd/yyyy');
                }

                Opportunity opp = new Opportunity(
                    Name = oppName,
                    AccountId = matchedAcc.Id,
                    StageName = 'New',
                    CloseDate = l.Babys_Due_Date__c != null
                        ? l.Babys_Due_Date__c
                        : Date.today().addDays(270),
                    Baby_s_Due_Date__c = l.Babys_Due_Date__c,
                    Contact__c = matchedCon != null ? matchedCon.Id : null,
                    LeadSource = l.LeadSource,
                    Email__c = l.Email,
                    FirstName__c = l.FirstName,
                    LastName__c = l.LastName,
                    Phone__c = l.Phone,
                    OwnerId = matchedAcc.OwnerId
                );

                directOpps.add(opp);

                l.Status = convertedStatus;
                leadsToMarkConverted.add(l);
                continue;
            }

            // D) Standard conversion
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(l.Id);
            lc.setConvertedStatus(convertedStatus);
            lc.setDoNotCreateOpportunity(false);
            lc.setOpportunityName(
                (String.isBlank(l.Company) ? l.LastName : l.Company) + ' - New'
            );
            conversions.add(lc);
        }

        LAST_ATTEMPTED = directOpps.size() + conversions.size();

        // ------------------------------------------------
        // 8) DML
        // ------------------------------------------------
        if (!directOpps.isEmpty()) {
            insert directOpps;
            LAST_SUCCEEDED += directOpps.size();
        }

        if (!conversions.isEmpty()) {
            Database.convertLead(conversions, false);
        }

        if (!leadsToMarkConverted.isEmpty()) {
            update leadsToMarkConverted;
        }
    }

    // ------------------------------------------------
    // Normalize phone to last 10 digits
    // ------------------------------------------------
    @TestVisible
    private static String normalizePhone10(String raw) {
        if (String.isBlank(raw)) return null;
        String digits = raw.replaceAll('[^0-9]', '');
        if (digits.length() < 10) return null;
        return digits.substring(digits.length() - 10);
    }
}