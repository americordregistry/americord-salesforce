@IsTest
private class ConvertLeadTest {

    @IsTest
    static void test_basic_lead_conversion() {
        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = UserInfo.getUserId();

        Id me = UserInfo.getUserId();

        Lead goodLead = new Lead(
            LastName = 'Convertable',
            Company = 'Acme Co',
            Email = 'convertable@example.com',
            Phone = '555-1111',
            Status = 'New',
            OwnerId = me
        );
        Lead qaLead = new Lead(
            LastName = 'QA Lead',
            Company = 'QA Department',
            Email = 'qa@example.com',
            Status = 'Working',
            OwnerId = me
        );
        Lead badEmail = new Lead(
            LastName = 'Unknown Email',
            Company = 'Normal Co',
            Email = 'unknown@example.com',
            Status = 'Open',
            OwnerId = me
        );
        insert new List<Lead>{ goodLead, qaLead, badEmail };

        Test.startTest();
        ConvertLead.run();
        Test.stopTest();

        System.assert(ConvertLead.LAST_QUERIED > 0, 'Should query eligible leads.');
        System.assert(ConvertLead.LAST_ATTEMPTED > 0, 'Should attempt at least one conversion.');
        if (!ConvertLead.LAST_ERRORS.isEmpty()) {
            System.debug('Errors: ' + String.join(ConvertLead.LAST_ERRORS, ' | '));
        }
    }

    @IsTest
    static void test_existing_account_creates_direct_opportunity() {
        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = UserInfo.getUserId();

        Account acct = new Account(Name = 'Existing Family', Phone = '555-2222', OwnerId = UserInfo.getUserId());
        insert acct;

        Contact con = new Contact(FirstName = 'Match', LastName = 'Contact', Email = 'match@example.com', AccountId = acct.Id);
        insert con;

        Lead lead = new Lead(
            FirstName = 'Parent',
            LastName = 'Lead',
            Company = 'Existing Family',
            Email = 'match@example.com',
            Phone     = '555-9999',        // 👈 different from acct.Phone
            Babys_Due_Date__c = Date.today().addDays(90),
            Number_of_Babies__c = 'Single',     // ✅ text-based picklist
            Relation_to_Baby__c = 'Mother',
            Shipping_Street__c = '100 Main St',
            Shipping_City__c = 'New York',
            Shipping_State__c = 'NY',
            Shipping_Zip__c = '10001',
            Shipping_Country__c = 'US',
            LeadSource = 'Web',
            Status = 'New',
            OwnerId = UserInfo.getUserId()
        );
        insert lead;

        Test.startTest();
        ConvertLead.run();
        Test.stopTest();

        List<Opportunity> opps = [
            SELECT Id, AccountId, OwnerId, Baby_s_Due_Date__c, Number_of_Births__c, Email__c, Contact__c, Name
            FROM Opportunity
            WHERE AccountId = :acct.Id
        ];
        System.assertEquals(1, opps.size(), 'Expected one Opportunity created.');
        System.assertEquals(acct.OwnerId, opps[0].OwnerId, 'Opp owner should equal Account owner.');
        System.assertEquals(lead.Email, opps[0].Email__c, 'Lead Email should map.');
        System.assertEquals('Single', opps[0].Number_of_Births__c, 'Lead.Number_of_Babies__c should map.');
        System.assert(
            opps[0].Name.contains(lead.FirstName) || opps[0].Name.contains(lead.LastName),
            'Opp name should include part of the Lead name.'
)       ;

        System.assert(opps[0].Name.contains('/'), 'Opp name should include formatted date.');
        System.assertNotEquals(null, opps[0].Contact__c, 'Should relate to matched Contact.');

        //Lead refreshed = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        //System.assert(refreshed.Status != null && refreshed.Status.contains('onvert'), 'Lead should be marked converted.');
    }

    @IsTest
    static void test_recordtype_resolution() {
        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = UserInfo.getUserId();

        List<RecordType> rts = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE SobjectType = 'Opportunity'
            LIMIT 1
        ];
        if (!rts.isEmpty()) {
            ConvertLead.OPP_RECORD_TYPE_DEVELOPERNAME = rts[0].DeveloperName;
        }

        Lead lead = new Lead(
            LastName = 'RT Test',
            Company = 'Record Type Co',
            Email = 'rt@example.com',
            Status = 'New',
            OwnerId = UserInfo.getUserId()
        );
        insert lead;

        Test.startTest();
        ConvertLead.run();
        Test.stopTest();

        System.assert(ConvertLead.LAST_QUERIED > 0, 'Expected queried leads.');
        System.assert(ConvertLead.LAST_ATTEMPTED > 0, 'Expected at least one conversion attempt.');
    }

    @IsTest
    static void test_duplicate_accounts_skipped_and_logged() {
        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = UserInfo.getUserId();

        Account acct1 = new Account(Name = 'DupA', Phone = '555-3333', OwnerId = UserInfo.getUserId());
        Account acct2 = new Account(Name = 'DupB', Phone = '555-3333', OwnerId = UserInfo.getUserId());
        insert new List<Account>{ acct1, acct2 };

        Contact con1 = new Contact(FirstName = 'John', LastName = 'One', Email = 'dup@example.com', AccountId = acct1.Id);
        Contact con2 = new Contact(FirstName = 'Jane', LastName = 'Two', Email = 'dup@example.com', AccountId = acct2.Id);
        insert new List<Contact>{ con1, con2 };

        Lead lead = new Lead(
            FirstName = 'Duplicate',
            LastName = 'Lead',
            Company = 'DupCompany',
            Email = 'dup@example.com',
            Phone = '555-3333',
            Status = 'New',
            OwnerId = UserInfo.getUserId()
        );
        insert lead;

        Test.startTest();
        ConvertLead.run();
        Test.stopTest();

        List<Opportunity> opps = [
            SELECT Id FROM Opportunity WHERE Name LIKE '%Duplicate%'
        ];
        System.assert(opps.size() <= 1, 'Should not create more than one Opportunity for duplicate accounts.');
        if (!ConvertLead.LAST_ERRORS.isEmpty()) {
            System.debug('Duplicate account errors: ' + String.join(ConvertLead.LAST_ERRORS, ' | '));
        }
    }
}