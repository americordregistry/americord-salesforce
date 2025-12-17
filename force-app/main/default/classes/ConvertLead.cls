public class ConvertLead {

    // ---- Tunables / test hooks ----
    @TestVisible static Datetime CREATED_AFTER = Datetime.newInstanceGmt(2018,6,1,0,0,0);
    @TestVisible static Integer  LIMIT_N       = 5;
    @TestVisible static Id       OWNER_ID      = null;
    @TestVisible static String   OWNER_NAME    = 'Hubspot Service';
    @TestVisible static String   OWNER_NAME2   = 'Americord Registry';
    @TestVisible static String   SALES_DIVISION = 'Inside Sales';
    @TestVisible static String   SERVICE_DIVISION = 'Client Services';

    // ---- Instrumentation ----
    @TestVisible static Integer LAST_QUERIED   = 0;
    @TestVisible static Integer LAST_ATTEMPTED = 0;
    @TestVisible static Integer LAST_SUCCEEDED = 0;
    @TestVisible static List<String> LAST_ERRORS = new List<String>();

    // ====================================================
    // MAIN ENTRY
    // ====================================================
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
            LAST_ERRORS.add('No eligible owners found.');
            return;
        }

        // ------------------------------------------------
        // 2) Lead query (SAFE SOQL)
        // ------------------------------------------------
        List<Lead> leads = [
            SELECT Id, Name, LeadSource, Email, Company, FirstName, LastName,
                   Phone, Status, IsConverted, Babys_Due_Date__c, CreatedDate
            FROM Lead
            WHERE IsConverted = FALSE
              AND Status IN ('New','Open','Working')
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
        // 3) Converted Lead Status
        // ------------------------------------------------
        String convertedStatus = [
            SELECT MasterLabel
            FROM LeadStatus
            WHERE IsConverted = TRUE
            LIMIT 1
        ].MasterLabel;

        // ------------------------------------------------
        // 4) Normalize lead identifiers
        // ------------------------------------------------
        Set<String> leadEmails = new Set<String>();
        Set<String> leadPhones10 = new Set<String>();

        for (Lead l : leads) {
            if (!String.isBlank(l.Email)) {
                leadEmails.add(l.Email.trim().toLowerCase());
            }
            String p10 = normalizePhone10(l.Phone);
            if (p10 != null) leadPhones10.add(p10);
        }

        // ------------------------------------------------
        // 5) Load candidate Accounts (NO ORs)
        // ------------------------------------------------
        Map<Id, Account> accountMap = new Map<Id, Account>();

        for (Account a : [
            SELECT Id, OwnerId, Phone, (SELECT Id, Email, Phone FROM Contacts)
            FROM Account
            WHERE Phone != null
        ]) {
            accountMap.put(a.Id, a);
        }

        // ------------------------------------------------
        // 6) Load matching Contacts by EMAIL (selective)
        // ------------------------------------------------
        Map<Id, List<Contact>> contactsByAccount = new Map<Id, List<Contact>>();

        if (!leadEmails.isEmpty()) {
            for (Contact c : [
                SELECT Id, AccountId, Email
                FROM Contact
                WHERE AccountId != null
                AND Email IN :leadEmails
            ]) {
                if (!contactsByAccount.containsKey(c.AccountId)) {
                    contactsByAccount.put(c.AccountId, new List<Contact>());
                }
                contactsByAccount.get(c.AccountId).add(c);
            }
        }

        // ------------------------------------------------
        // 7) Load matching Contacts by PHONE (Apex filter)
        // ------------------------------------------------
        if (!leadPhones10.isEmpty()) {
            for (Contact c : [
                SELECT Id, AccountId, Phone, Email
                FROM Contact
                WHERE AccountId != null
                AND Phone != null
            ]) {
                String c10 = normalizePhone10(c.Phone);
                if (c10 != null && leadPhones10.contains(c10)) {
                    if (!contactsByAccount.containsKey(c.AccountId)) {
                        contactsByAccount.put(c.AccountId, new List<Contact>());
                    }
                    contactsByAccount.get(c.AccountId).add(c);
                }
            }
        }

        // ------------------------------------------------
        // 8) Process leads
        // ------------------------------------------------
        List<Database.LeadConvert> conversions = new List<Database.LeadConvert>();
        List<Opportunity> directOpps = new List<Opportunity>();
        List<Lead> leadsToUpdate = new List<Lead>();

        for (Lead l : leads) {

            String leadEmail = l.Email != null ? l.Email.trim().toLowerCase() : null;
            String leadPhone10 = normalizePhone10(l.Phone);

            Account matchedAcc;
            Contact matchedCon;

            for (Account a : accountMap.values()) {

                Boolean phoneMatch =
                    leadPhone10 != null &&
                    normalizePhone10(a.Phone) == leadPhone10;

                Boolean emailMatch = false;

                List<Contact> cons = contactsByAccount.get(a.Id);
                if (cons != null) {
                    for (Contact c : cons) {
                        if (
                            (leadEmail != null && c.Email != null && c.Email.trim().toLowerCase() == leadEmail) ||
                            (leadPhone10 != null && normalizePhone10(c.Phone) == leadPhone10)
                        ) {
                            matchedCon = c;
                            emailMatch = true;
                            break;
                        }
                    }
                }

                if (phoneMatch || emailMatch) {
                    matchedAcc = a;
                    break;
                }
            }

            // ------------------------------------------------
            // Direct Opportunity path
            // ------------------------------------------------
            if (matchedAcc != null) {

                String oppName = l.Name;
                if (l.Babys_Due_Date__c != null) {
                    oppName += ' - ' +
                        Datetime.newInstance(
                            l.Babys_Due_Date__c,
                            Time.newInstance(0,0,0,0)
                        ).format('M/d/yyyy'); // NO leading zeros
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
                leadsToUpdate.add(l);
                continue;
            }

            // ------------------------------------------------
            // Standard Lead Conversion
            // ------------------------------------------------
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
        // 9) DML
        // ------------------------------------------------
        if (!directOpps.isEmpty()) {
            insert directOpps;
            LAST_SUCCEEDED += directOpps.size();
        }

        if (!conversions.isEmpty()) {
            Database.convertLead(conversions, false);
        }

        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }

    // ====================================================
    // Normalize phone to last 10 digits
    // ====================================================
    @TestVisible
    private static String normalizePhone10(String raw) {
        if (String.isBlank(raw)) return null;

        String digits = raw.replaceAll('[^0-9]', '');
        if (digits.length() < 10) return null;

        return digits.substring(digits.length() - 10);
    }
}