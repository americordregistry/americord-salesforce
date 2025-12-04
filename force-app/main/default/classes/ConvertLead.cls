public class ConvertLead {
    // ------------
    // apex that will schedule/unschedule apex batch jobs
    //LeadAutoConvertInstaller.install(true);
    //
    //LeadAutoConvertInstaller.uninstall();
    // ------------

    // ---- Tunables / test hooks ----
    @TestVisible static Datetime CREATED_AFTER = Datetime.newInstanceGmt(2018, 6, 1, 0, 0, 0);
    @TestVisible static Integer  LIMIT_N       = 5;
    @TestVisible static Id       OWNER_ID      = null;
    @TestVisible static String   OWNER_NAME    = 'Hubspot Service';
    @TestVisible static String   OWNER_NAME2   = 'Americord Registry';
    @TestVisible static String   SALES_DIVISION = 'Inside Sales';
    @TestVisible static String   SERVICE_DIVISION = 'Client Services';

    // Optional: choose an Opportunity Record Type (either set the Id directly OR its DeveloperName)
    @TestVisible static Id     OPP_RECORD_TYPE_ID            = null;
    @TestVisible static String OPP_RECORD_TYPE_DEVELOPERNAME = null;

    // ---- Lightweight instrumentation ----
    @TestVisible static Integer        LAST_QUERIED   = 0;
    @TestVisible static Integer        LAST_ATTEMPTED = 0;
    @TestVisible static Integer        LAST_SUCCEEDED = 0;
    @TestVisible static List<String>   LAST_ERRORS    = new List<String>();

    public static void run() {
        LAST_QUERIED = 0; LAST_ATTEMPTED = 0; LAST_SUCCEEDED = 0; LAST_ERRORS.clear();

        // --- Determine eligible owners ---
        Set<Id> eligibleOwnerIds = new Set<Id>();
        if (OWNER_ID != null) {
            eligibleOwnerIds.add(OWNER_ID);
        } else {
            for (User u : [
                SELECT Id
                FROM User
                WHERE 
                (Name IN :new List<String>{ OWNER_NAME, OWNER_NAME2 }
                OR Division IN :new List<String>{ SALES_DIVISION, SERVICE_DIVISION }
                ) AND ISACTIVE = TRUE
                
            ]) {
                eligibleOwnerIds.add(u.Id);
            }
        }

        if (eligibleOwnerIds.isEmpty()) {
            LAST_ERRORS.add('No eligible users found for Hubspot Service or Inside/Client Services.');
            return;
        }

        // --- Query eligible leads ---
        List<Lead> leads = [
            SELECT Id, Name, LeadSource, Email, Company, FirstName, LastName, Phone,
                IsConverted, Status, Owner.Name, Babys_Due_Date__c,
                Discount_percent__c, Ecomm_Status__c, Product1__c,
                Lead_Qualification_new__c, Lead_Type__c, Number_of_Babies__c,
                Relation_to_Baby__c, Shipping_Street__c, Shipping_City__c,
                Shipping_State__c, Shipping_Zip__c, Shipping_Country__c,
                Touchpoint_Campaign_I__c, Touchpoint_Content_I__c,
                Touchpoint_Medium_I__c, Touchpoint_Source_I__c,
                Touchpoint_Term_I__c,
                Authorization_Id__c,Surrogate__c, Billing_Zip_Code__c,
                Birth_Plan_Choices__c, Call_Status__c,
                Consumer_Affairs_UUID__c,
                Coupon_Code__c, CreatedDate,
                Donation_Reconsider__c,Explain_Other__c,
                Gift_Card__c,How_did_you_hear_about_Americord__c,
                I_would_like_to_speak_with_a_Specialist__c,
                Impact_Partner_Id__c,Incoming_Source__c,
                knowledgeaboutcordbloodbanking__c,
                OBGYN__c,Father_s_First_Name__c,
                Father_s_Name__c,Alt_Phone__c,Alt_Email__c,
                relation__c,Referrer_Email__c,Referrer_First_Name__c,
                Referrer_Last_Name__c,Referred_By_Relationship__c
            FROM Lead
            WHERE IsConverted = FALSE
            AND (Status IN ('New', 'Open', 'Working'))            // Only active stages
            AND CreatedDate > :CREATED_AFTER
            AND (NOT (Company LIKE 'QA %'))
            AND (NOT (Company LIKE '%test%'))
            AND (NOT (Company LIKE '%Unknown%'))
            AND (Email != 'unknown@example.com')
            AND OwnerId IN :eligibleOwnerIds
            LIMIT :LIMIT_N
        ];
        LAST_QUERIED = leads.size();
        if (leads.isEmpty()) return;

        // --- Get converted LeadStatus label ---
        List<LeadStatus> ls = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        if (ls.isEmpty()) {
            LAST_ERRORS.add('CONFIG: No converted LeadStatus configured.');
            return;
        }
        String convStatus = ls[0].MasterLabel;

        // --- Gather identifiers ---
        Set<String> emails = new Set<String>();
        Set<String> phones = new Set<String>();
        for (Lead l : leads) {
            if (!String.isBlank(l.Email)) emails.add(l.Email.trim().toLowerCase());
            if (!String.isBlank(l.Phone)) phones.add(l.Phone.replaceAll('[^0-9]', ''));
        }

        // --- Find Accounts by phone and email (split queries to avoid semi-join OR) ---
        Map<Id, Account> matchedAccounts = new Map<Id, Account>();

        // 1️⃣ Match by phone
        if (!phones.isEmpty()) {
            for (Account a : [
                SELECT Id, Name, Phone, OwnerId,
                       (SELECT Id, Email FROM Contacts WHERE Email != null)
                FROM Account
                WHERE Phone != null AND Phone IN :phones
            ]) {
                matchedAccounts.put(a.Id, a);
            }
        }

        // 2️⃣ Match by contact email (no LOWER function)
        if (!emails.isEmpty()) {
            Set<Id> accountIdsFromContacts = new Set<Id>();
            for (Contact c : [
                SELECT AccountId, Email, Id
                FROM Contact
                WHERE Email IN :emails
                  AND AccountId != null
            ]) {
                accountIdsFromContacts.add(c.AccountId);
            }

            if (!accountIdsFromContacts.isEmpty()) {
                for (Account a : [
                    SELECT Id, Name, Phone, OwnerId,
                           (SELECT Id, Email FROM Contacts WHERE Email != null)
                    FROM Account
                    WHERE Id IN :accountIdsFromContacts
                ]) {
                    matchedAccounts.put(a.Id, a);
                }
            }
        }

        // --- Prepare conversions & direct Opps ---
        List<Database.LeadConvert> conversions = new List<Database.LeadConvert>();
        List<Opportunity> directOpps = new List<Opportunity>();
        List<Lead> leadsToMarkConverted = new List<Lead>();

        for (Lead l : leads) {
            Boolean foundMatch = false;
            Account matchedAcc;
            Contact matchedContact;

            // Match by phone
            if (!String.isBlank(l.Phone)) {
                String clean = l.Phone.replaceAll('[^0-9]', '');
                for (Account a : matchedAccounts.values()) {
                    if (!String.isBlank(a.Phone) && a.Phone.replaceAll('[^0-9]', '') == clean) {
                        matchedAcc = a;
                        foundMatch = true;
                        break;
                    }
                }
            }

            // Match by email (case-insensitive check in Apex)
            if (!foundMatch && !String.isBlank(l.Email)) {
                String emailLower = l.Email.trim().toLowerCase();
                for (Account a : matchedAccounts.values()) {
                    for (Contact c : a.Contacts) {
                        if (c.Email != null && c.Email.trim().toLowerCase() == emailLower) {
                            matchedAcc = a;
                            foundMatch = true;
                            matchedContact = c;
                            break;
                        }
                    }
                    if (foundMatch) break;
                }
            }

            if (foundMatch && matchedAcc != null) {
                // Create Opp under Account with Account Owner
                String base = String.isBlank(l.Company) ? l.LastName : l.Company;
                Opportunity opp = new Opportunity(
                    Name = l.Name + (
                        l.Babys_Due_Date__c != null
                            ? ' - '+ Datetime.newInstance(l.Babys_Due_Date__c, Time.newInstance(0,0,0,0)).format('MM/dd/yyyy')
                            : ''
                    ),
                    AccountId = matchedAcc.Id,
                    StageName = 'New',
                    CloseDate = l.Babys_Due_Date__c != null ? l.Babys_Due_Date__c : Date.today().addDays(270),
                    Baby_s_Due_Date__c = l.Babys_Due_Date__c,
                    Contact__c = matchedContact != null ? matchedContact.Id : null,
                    Email__c = l.Email, 
                    FirstName__c = l.Firstname, 
                    LastName__c = l.Lastname, 
                    Phone__c = l.Phone, 
                    Authorization_Id__c = l.Authorization_Id__c,
                    Ecomm_Status__c = l.Ecomm_STatus__c,
                    Number_of_Births__c = l.Number_of_Babies__c, 
                    Relation_to_Baby__c = l.Relation_to_Baby__c, 
                    Shipping_Street__c = l.Shipping_Street__c, 
                    Shipping_City__c = l.Shipping_City__c,
                    Shipping_State_Province__c = l.Shipping_State__c, 
                    Shipping_Zip__c = l.Shipping_Zip__c, 
                    Shipping_Country__c = l.Shipping_Country__c, 
                    Touchpoint_Campaign_I__c =l.Touchpoint_Campaign_I__c, 
                    Touchpoint_Content_I__c = l.Touchpoint_Content_I__c, 
                    Touchpoint_Medium_I__c = l.Touchpoint_Medium_I__c, 
                    Touchpoint_Source_I__c = l.Touchpoint_Source_I__c, 
                    Touchpoint_Term_I__c = l.Touchpoint_Term_I__c,
                    OwnerId = matchedAcc.OwnerId, 
                    leadsource = l.leadsource,
                    Has_Been_Distributed__c = 'Yes',
                    Surrogate__c = l.Surrogate__c,
                    Billing_Zip_Code__c = l.Billing_Zip_Code__c,
                    Birth_Plan_Choices__c = l.Birth_Plan_Choices__c,
                    Call_STatus__c = l.Call_Status__c,
                    Consumer_Affairs_UUID__c = l.Consumer_Affairs_UUID__c,
                    Coupon_Code__c = l.Coupon_Code__c,
                    Lead_Create_Date_Time__c = l.Createddate,
                    Discount_percent__c = l.Discount_percent__c,
                    Donation_Reconsider__c = l.Donation_Reconsider__c,
                    Explain_Other__c = l.Explain_Other__c,
                    Gift_Card__c = l.Gift_Card__c,
                    How_did_you_hear_about_Americord__c = l.How_did_you_hear_about_Americord__c,
                    I_would_like_to_speak_with_a_Specialist__c = l.I_would_like_to_speak_with_a_Specialist__c,
                    Impact_Partner_Id__c = l.Impact_Partner_Id__c,
                    Incoming_Source__c = l.Incoming_Source__c,
                    knowledgeaboutcordbloodbanking__c = l.knowledgeaboutcordbloodbanking__c,
                    Lead_Qualification__c = l.Lead_Qualification_new__c,
                    OBGYN__c = l.OBGYN__c,
                    Contact2_FirstName__c = l.Father_s_First_Name__c,
                    Contact2_LastName__c = l.Father_s_Name__c,
                    Contact2_Phone__C = l.Alt_Phone__c,
                    Contact2_Email__c = l.Alt_Email__c,
                    Contact2_Relation_To_Baby__c = l.relation__c,
                    Referred_by_email_address__c = l.Referrer_Email__c,
                    Referred_by_First_Name__c =l.Referrer_First_Name__c,
                    Referred_by_Last_Name__c = l.Referrer_Last_Name__c
                );
                directOpps.add(opp);

                // Mark Lead as converted (exclude next run) 
                l.Status = convStatus;
                leadsToMarkConverted.add(l);
            } else {
                // Normal conversion flow
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(l.Id);
                lc.setConvertedStatus(convStatus);
                lc.setDoNotCreateOpportunity(false);
                String base = String.isBlank(l.Company) ? l.LastName : l.Company;
                lc.setOpportunityName(base + ' - New');
                conversions.add(lc);
            }
        }

        LAST_ATTEMPTED = conversions.size() + directOpps.size();

        // --- Perform conversions ---
        List<Database.LeadConvertResult> results = new List<Database.LeadConvertResult>();
        if (!conversions.isEmpty()) {
            results = Database.convertLead(conversions, false);
        }

        // --- Update Record Type on converted Opps ---
        Id desiredRtId = resolveOppRecordTypeId();
        List<Opportunity> oppUpdates = new List<Opportunity>();
        Integer ok = 0;

        for (Database.LeadConvertResult r : results) {
            if (r.isSuccess()) {
                ok++;
                if (desiredRtId != null && r.getOpportunityId() != null) {
                    oppUpdates.add(new Opportunity(Id = r.getOpportunityId(), RecordTypeId = desiredRtId));
                }
            } else if (r.getErrors() != null) {
                for (Database.Error e : r.getErrors()) {
                    LAST_ERRORS.add(e.getStatusCode() + ': ' + e.getMessage());
                }
            }
        }

        // --- Insert directly created Opps ---
        if (!directOpps.isEmpty()) {
            try {
                insert directOpps;
                ok += directOpps.size();
                if (desiredRtId != null) {
                    for (Opportunity o : directOpps) o.RecordTypeId = desiredRtId;
                    update directOpps;
                }
            } catch (Exception e) {
                LAST_ERRORS.add('DirectOppInsert: ' + e.getMessage());
            }
        }

        // --- Mark matched leads as converted (via status only) ---
        if (!leadsToMarkConverted.isEmpty()) {
            try {
                update leadsToMarkConverted;
            } catch (Exception e) {
                LAST_ERRORS.add('LeadStatusUpdate: ' + e.getMessage());
            }
        }

        // --- Apply record type updates from converted Opps ---
        if (!oppUpdates.isEmpty()) {
            Database.SaveResult[] upd = Database.update(oppUpdates, false);
            for (Database.SaveResult sr : upd) {
                if (!sr.isSuccess()) {
                    for (Database.Error e : sr.getErrors()) {
                        LAST_ERRORS.add('OppUpdate ' + e.getStatusCode() + ': ' + e.getMessage());
                    }
                }
            }
        }

        LAST_SUCCEEDED = ok;
    }

    // --- Helper: Resolve Opportunity RecordTypeId ---
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
            return rts.isEmpty() ? null : rts[0].Id;
        }
        return null;
    }
}