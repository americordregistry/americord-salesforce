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
    // Entry
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
        // 2) Query Leads
        // ------------------------------------------------
        List<Lead> leads = [
            SELECT Id, Name, Company, FirstName, LastName,
                   Email, Phone, LeadSource,
                   Status, IsConverted, Babys_Due_Date__c
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
        // 3) Converted status
        // ------------------------------------------------
        LeadStatus ls = [
            SELECT MasterLabel
            FROM LeadStatus
            WHERE IsConverted = TRUE
            LIMIT 1
        ];
        String convertedStatus = ls.MasterLabel;

        // ------------------------------------------------
        // 4) Collect Lead identifiers
        // ------------------------------------------------
        Set<String> leadEmails = new Set<String>();
        Set<String> leadPhones = new Set<String>();

        for (Lead l : leads) {
            if (!String.isBlank(l.Email)) leadEmails.add(l.Email);
            if (!String.isBlank(l.Phone)) leadPhones.add(l.Phone);
        }

        // ------------------------------------------------
        // 5) Find matching Contacts (BOUNDED)
        // ------------------------------------------------
        Map<Id, Contact> contactByAccountId = new Map<Id, Contact>();

        if (!leadEmails.isEmpty() || !leadPhones.isEmpty()) {

            for (Contact c : [
                SELECT Id, AccountId, Email, Phone
                FROM Contact
                WHERE AccountId != null
                AND (
                    Email IN :leadEmails
                    OR Phone IN :leadPhones
                )
            ]) {
                // First contact wins per account
                if (!contactByAccountId.containsKey(c.AccountId)) {
                    contactByAccountId.put(c.AccountId, c);
                }
            }
        }

        // ------------------------------------------------
        // 6) Load matching Accounts
        // ------------------------------------------------
        Map<Id, Account> accountsById = new Map<Id, Account>();

        if (!contactByAccountId.isEmpty()) {
            accountsById = new Map<Id, Account>([
                SELECT Id, OwnerId
                FROM Account
                WHERE Id IN :contactByAccountId.keySet()
            ]);
        }

        // ------------------------------------------------
        // 7) Work lists
        // ------------------------------------------------
        List<Database.LeadConvert> conversions = new List<Database.LeadConvert>();
        List<Opportunity> directOpps = new List<Opportunity>();
        List<Lead> leadsToMarkConverted = new List<Lead>();

        // ------------------------------------------------
        // 8) Process Leads
        // ------------------------------------------------
        for (Lead l : leads) {

            Account matchedAcc;
            Contact matchedCon;

            // Match via Contact
            for (Id accId : contactByAccountId.keySet()) {
                Contact c = contactByAccountId.get(accId);
                if (
                    (l.Email != null && c.Email == l.Email) ||
                    (l.Phone != null && c.Phone == l.Phone)
                ) {
                    matchedAcc = accountsById.get(accId);
                    matchedCon = c;
                    break;
                }
            }

            // --------------------------------------------
            // Direct Opp path
            // --------------------------------------------
            if (matchedAcc != null) {

                String oppName = l.Name;
                if (l.Babys_Due_Date__c != null) {
                    oppName += ' - ' +
                        Datetime.newInstance(
                            l.Babys_Due_Date__c,
                            Time.newInstance(0,0,0,0)
                        ).format('M/d/yyyy');
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

            // --------------------------------------------
            // Standard conversion
            // --------------------------------------------
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

        if (!leadsToMarkConverted.isEmpty()) {
            update leadsToMarkConverted;
        }
    }
}