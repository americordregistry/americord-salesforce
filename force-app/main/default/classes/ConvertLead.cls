public class ConvertLead {

    // ---- Tunables / test hooks ----
    @TestVisible static Datetime CREATED_AFTER = Datetime.newInstanceGmt(2018,6,1,0,0,0);
    @TestVisible static Integer  LIMIT_N       = 5;
    @TestVisible static Id       OWNER_ID      = null;
    @TestVisible static String   OWNER_NAME    = 'Hubspot Service';
    @TestVisible static String   OWNER_NAME2   = 'Americord Registry';
    @TestVisible static String   SALES_DIVISION = 'Inside Sales';
    @TestVisible static String   SERVICE_DIVISION = 'Client Services';

    @TestVisible static Id       OPP_RECORD_TYPE_ID = null;
    @TestVisible static String   OPP_RECORD_TYPE_DEVELOPERNAME = null;

    @TestVisible static Integer LAST_QUERIED = 0;
    @TestVisible static Integer LAST_ATTEMPTED = 0;
    @TestVisible static Integer LAST_SUCCEEDED = 0;
    @TestVisible static List<String> LAST_ERRORS = new List<String>();


    public static void run() {

        LAST_QUERIED = 0;
        LAST_ATTEMPTED = 0;
        LAST_SUCCEEDED = 0;
        LAST_ERRORS.clear();


        // ------------------------------------------------
        // 1. Determine eligible owners
        // ------------------------------------------------
        Set<Id> eligibleOwnerIds = new Set<Id>();

        if (OWNER_ID != null) {
            eligibleOwnerIds.add(OWNER_ID);
        } else {
            for (User u : [
                SELECT Id
                FROM User
                WHERE (
                    Name IN :new List<String>{ OWNER_NAME, OWNER_NAME2 } OR
                    Division IN :new List<String>{ SALES_DIVISION, SERVICE_DIVISION }
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
        // 2. Query leads — *FIXED SOQL SYNTAX*
        // ------------------------------------------------
        List<Lead> leads = [
            SELECT Id, Name, LeadSource, Email, Company, FirstName, LastName, Phone,
                   Status, IsConverted, Babys_Due_Date__c, CreatedDate,
                   Number_of_Babies__c, Relation_to_Baby__c,
                   Shipping_Street__c, Shipping_City__c, Shipping_State__c,
                   Shipping_Zip__c, Shipping_Country__c
            FROM Lead
            WHERE IsConverted = FALSE
              AND Status IN ('New','Open','Working')
              AND CreatedDate > :CREATED_AFTER
              AND ( NOT Company LIKE 'QA %')
              AND ( NOT Company LIKE '%test%')
              AND ( NOT Company LIKE '%Unknown%')
              AND Email != 'unknown@example.com'
              AND OwnerId IN :eligibleOwnerIds
            LIMIT :LIMIT_N
        ];

        LAST_QUERIED = leads.size();
        if (leads.isEmpty()) return;


        // ------------------------------------------------
        // 3. Converted status
        // ------------------------------------------------
        LeadStatus ls = [
            SELECT MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1
        ];
        String convertedStatus = ls.MasterLabel;


        // ------------------------------------------------
        // 4. Prepare lists
        // ------------------------------------------------
        List<Database.LeadConvert> conversions = new List<Database.LeadConvert>();
        List<Opportunity> directOpps = new List<Opportunity>();
        List<Lead> leadsToMarkConverted = new List<Lead>();


        // ------------------------------------------------
        // 5. Loop leads and match phone + email
        // ------------------------------------------------
        for (Lead l : leads) {

            // Normalize values
            String cleanPhone = l.Phone != null ? l.Phone.replaceAll('[^0-9]','') : null;
            String emailLower = l.Email != null ? l.Email.trim().toLowerCase() : null;

            Account matchedAcc = null;
            Contact matchedCon = null;


            // --------------------------------------------
            // A. PHONE MATCH
            // --------------------------------------------
            if (cleanPhone != null) {
                List<Account> accs = [
                    SELECT Id, OwnerId, Phone,
                        (SELECT Id, Email FROM Contacts)
                    FROM Account
                    WHERE Phone != null
                ];

                for (Account a : accs) {
                    if (a.Phone != null && a.Phone.replaceAll('[^0-9]','') == cleanPhone) {
                        matchedAcc = a;

                        if (emailLower != null) {
                            for (Contact c : a.Contacts) {
                                if (c.Email != null && c.Email.toLowerCase() == emailLower) {
                                    matchedCon = c;
                                    break;
                                }
                            }
                        }
                        break;
                    }
                }
            }


            // --------------------------------------------
            // B. EMAIL MATCH (separate SOQL — no LOWER())
            // --------------------------------------------
            if (matchedAcc == null && emailLower != null) {
                List<Contact> cons = [
                    SELECT Id, Email, AccountId
                    FROM Contact
                    WHERE Email = :l.Email
                    LIMIT 5
                ];

                if (!cons.isEmpty()) {
                    matchedCon = cons[0];

                    matchedAcc = [
                        SELECT Id, OwnerId
                        FROM Account
                        WHERE Id = :matchedCon.AccountId
                        LIMIT 1
                    ];
                }
            }


            // --------------------------------------------
            // C. DIRECT OPPORTUNITY PATH
            // --------------------------------------------
            if (matchedAcc != null) {

                Opportunity opp = new Opportunity(
                    Name = l.Name +
                           (l.Babys_Due_Date__c != null ?
                               ' - ' + Datetime.newInstance(l.Babys_Due_Date__c, Time.newInstance(0,0,0,0)).format('MM/dd/yyyy')
                               : ''),
                    AccountId = matchedAcc.Id,
                    StageName = 'New',
                    CloseDate = l.Babys_Due_Date__c != null ?
                                  l.Babys_Due_Date__c :
                                  Date.today().addDays(270),
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
            // D. NORMAL LEAD CONVERSION
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


        // Insert direct Opps
        if (!directOpps.isEmpty()) {
            insert directOpps;
            LAST_SUCCEEDED += directOpps.size();
        }

        // Convert leads
        if (!conversions.isEmpty()) {
            Database.convertLead(conversions, false);
        }

        // Mark "matched" leads converted
        if (!leadsToMarkConverted.isEmpty()) {
            update leadsToMarkConverted;
        }
    }


    // ------------------------------------------------
    // Resolve Opportunity RecordType
    // ------------------------------------------------
    private static Id resolveOppRecordTypeId() {
        if (OPP_RECORD_TYPE_ID != null) return OPP_RECORD_TYPE_ID;

        if (!String.isBlank(OPP_RECORD_TYPE_DEVELOPERNAME)) {
            List<RecordType> rts = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Opportunity'
                AND DeveloperName = :OPP_RECORD_TYPE_DEVELOPERNAME
                LIMIT 1
            ];
            if (!rts.isEmpty()) return rts[0].Id;
        }
        return null;
    }
}