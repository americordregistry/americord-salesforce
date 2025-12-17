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

    public static void run() {

        LAST_QUERIED = 0;
        LAST_ATTEMPTED = 0;
        LAST_SUCCEEDED = 0;
        LAST_ERRORS.clear();

        // ------------------------------------------------
        // 1) Determine eligible owners
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
        // 2) Query eligible leads
        // ------------------------------------------------
        List<Lead> leads = [
            SELECT Id, Name, LeadSource, Email, Company, FirstName, LastName, Phone,
                   Status, IsConverted, Babys_Due_Date__c, CreatedDate
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
        // 4) Collect normalized identifiers from Leads
        // ------------------------------------------------
        Set<String> leadEmailsLower = new Set<String>();
        Set<String> leadPhones10   = new Set<String>();

        for (Lead l : leads) {
            if (!String.isBlank(l.Email)) {
                leadEmailsLower.add(l.Email.trim().toLowerCase());
            }
            String p10 = normalizePhone10(l.Phone);
            if (p10 != null) leadPhones10.add(p10);
        }

        // ------------------------------------------------
        // 5) Query ONLY Contacts that could match
        // ------------------------------------------------
        Map<Id, List<Contact>> contactsByAccountId = new Map<Id, List<Contact>>();

        if (!leadEmailsLower.isEmpty() || !leadPhones10.isEmpty()) {
            for (Contact c : [
                SELECT Id, AccountId, Email, Phone
                FROM Contact
                WHERE AccountId != null
                AND (
                    Email IN :leadEmailsLower
                    OR Phone != null
                )
            ]) {
                Boolean emailMatch =
                    c.Email != null &&
                    leadEmailsLower.contains(c.Email.trim().toLowerCase());

                Boolean phoneMatch = false;
                if (c.Phone != null) {
                    String c10 = normalizePhone10(c.Phone);
                    phoneMatch = (c10 != null && leadPhones10.contains(c10));
                }

                if (emailMatch || phoneMatch) {
                    if (!contactsByAccountId.containsKey(c.AccountId)) {
                        contactsByAccountId.put(c.AccountId, new List<Contact>());
                    }
                    contactsByAccountId.get(c.AccountId).add(c);
                }
            }
        }

        // ------------------------------------------------
        // 6) Load only matching Accounts
        // ------------------------------------------------
        Map<Id, Account> accountsById = new Map<Id, Account>();

        if (!contactsByAccountId.isEmpty()) {
            accountsById = new Map<Id, Account>([
                SELECT Id, OwnerId
                FROM Account
                WHERE Id IN :contactsByAccountId.keySet()
            ]);
        }

        // ------------------------------------------------
        // 7) Process Leads
        // ------------------------------------------------
        List<Database.LeadConvert> conversions = new List<Database.LeadConvert>();
        List<Opportunity> directOpps = new List<Opportunity>();
        List<Lead> leadsToMarkConverted = new List<Lead>();

        for (Lead l : leads) {

            String leadEmail = l.Email != null ? l.Email.trim().toLowerCase() : null;
            String leadPhone10 = normalizePhone10(l.Phone);

            Account matchedAcc;
            Contact matchedCon;

            for (Id acctId : contactsByAccountId.keySet()) {
                Account a = accountsById.get(acctId);
                if (a == null) continue;

                for (Contact c : contactsByAccountId.get(acctId)) {

                    Boolean emailMatch =
                        leadEmail != null &&
                        c.Email != null &&
                        c.Email.trim().toLowerCase() == leadEmail;

                    Boolean phoneMatch =
                        leadPhone10 != null &&
                        normalizePhone10(c.Phone) == leadPhone10;

                    if (emailMatch || phoneMatch) {
                        matchedAcc = a;
                        matchedCon = c;
                        break;
                    }
                }
                if (matchedAcc != null) break;
            }

            // ------------------------------------------------
            // A) Direct Opportunity path
            // ------------------------------------------------
            if (matchedAcc != null) {

                String oppName = l.Name;
                if (l.Babys_Due_Date__c != null) {
                    oppName += ' - ' +
                        Datetime.newInstance(
                            l.Babys_Due_Date__c,
                            Time.newInstance(0,0,0,0)
                        ).format('M/d/yyyy'); // no leading zeros
                }

                Opportunity opp = new Opportunity(
                    Name = oppName,
                    AccountId = matchedAcc.Id,
                    StageName = 'New',
                    CloseDate = (l.Babys_Due_Date__c != null
                        ? l.Babys_Due_Date__c
                        : Date.today().addDays(270)),
                    Baby_s_Due_Date__c = l.Babys_Due_Date__c,
                    Contact__c = (matchedCon != null ? matchedCon.Id : null),
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

            // ------------------------------------------------
            // B) Normal Lead Conversion
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
    // Phone normalization: last 10 digits
    // ------------------------------------------------
    @TestVisible
    private static String normalizePhone10(String raw) {
        if (String.isBlank(raw)) return null;
        String digits = raw.replaceAll('[^0-9]', '');
        if (digits.length() < 10) return null;
        return digits.substring(digits.length() - 10);
    }
}