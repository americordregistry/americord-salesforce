@IsTest
private class ConvertLeadTest {

    // ------------------------------------------------------
    // Utility: Reset tunables before each scenario
    // ------------------------------------------------------
    private static void resetTunables() {
        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 50;
        ConvertLead.OWNER_ID = UserInfo.getUserId();
        ConvertLead.OPP_RECORD_TYPE_DEVELOPERNAME = null;
        ConvertLead.OPP_RECORD_TYPE_ID = null;

        ConvertLead.LAST_ERRORS.clear();
        ConvertLead.LAST_ATTEMPTED = 0;
        ConvertLead.LAST_QUERIED = 0;
        ConvertLead.LAST_SUCCEEDED = 0;
    }


    // ------------------------------------------------------
    // Scenario 1 — Normal Salesforce lead conversion
    // ------------------------------------------------------
    @IsTest
    static void test_normal_conversion() {

        resetTunables();
        Id me = UserInfo.getUserId();

        Lead l = new Lead(
            FirstName='Normal',
            LastName='Lead',
            Email='normal@example.com',
            Phone='555-9000',
            Company='Normal Co',
            Status='New',
            OwnerId=me
        );
        insert l;

        ConvertLead.run();

        Account a = [
            SELECT Id FROM Account WHERE Name='Normal Co' LIMIT 1
        ];
        System.assertNotEquals(null, a, 'Account should be created.');

        Contact c = [
            SELECT Id FROM Contact WHERE Email='normal@example.com' LIMIT 1
        ];
        System.assertNotEquals(null, c, 'Contact should be created.');

        Opportunity opp = [
            SELECT Id FROM Opportunity WHERE AccountId=:a.Id LIMIT 1
        ];
        System.assertNotEquals(null, opp, 'Opportunity should be created.');
    }


    // ------------------------------------------------------
    // Scenario 2 — Email match should create direct Opp WITH Contact
    // ------------------------------------------------------
    @IsTest
    static void test_email_match_direct_opp() {

        resetTunables();
        Id me = UserInfo.getUserId();

        // Step 1: initial lead → convert
        Lead l1 = new Lead(
            FirstName='Email',
            LastName='Base',
            Company='Email Base Co',
            Email='match@example.com',
            Phone='555-1000',
            Status='New',
            OwnerId=me
        );
        insert l1;

        ConvertLead.run();

        Contact baseCon = [
            SELECT Id, AccountId 
            FROM Contact 
            WHERE Email='match@example.com' LIMIT 1
        ];
        Account acc = [
            SELECT Id FROM Account WHERE Id=:baseCon.AccountId LIMIT 1
        ];

        // Step 2: second lead → match email
        Lead l2 = new Lead(
            FirstName='Email',
            LastName='Match',
            Company='Match Co',
            Email='match@example.com',
            Phone='555-2000',
            Status='New',
            OwnerId=me
        );
        insert l2;

        ConvertLead.run();

        Opportunity opp = [
            SELECT Id, AccountId, Contact__c 
            FROM Opportunity
            WHERE AccountId=:acc.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        System.assertEquals(acc.Id, opp.AccountId, 'Opp should be created under the same Account.');
        System.assertEquals(baseCon.Id, opp.Contact__c, 'Email match should assign Contact.');
    }


    // ------------------------------------------------------
    // Scenario 3 — Phone match only → direct Opp WITHOUT Contact (Option A)
    // ------------------------------------------------------
    @IsTest
    static void test_phone_match_direct_opp() {

        resetTunables();
        Id me = UserInfo.getUserId();

        // Step 1: first lead → convert to create Account
        Lead l1 = new Lead(
            FirstName='Phone',
            LastName='Base',
            Company='Phone Base Co',
            Email='base@example.com',
            Phone='555-3000',
            Status='New',
            OwnerId=me
        );
        insert l1;

        ConvertLead.run();

        Account acc = [
            SELECT Id FROM Account 
            WHERE Name='Phone Base Co' LIMIT 1
        ];

        // Step 2: second lead matches *only phone*
        Lead l2 = new Lead(
            FirstName='Phone',
            LastName='Match',
            Company='Phone Match Co',
            Email='different@example.com',  // different email
            Phone='555-3000',               // same phone → match
            Status='New',
            OwnerId=me
        );
        insert l2;

        ConvertLead.run();

        Opportunity opp = [
            SELECT Id, AccountId, Contact__c 
            FROM Opportunity
            WHERE AccountId=:acc.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        System.assertEquals(acc.Id, opp.AccountId, 'Phone match should create Opp under Account.');
        System.assertEquals(null, opp.Contact__c, 'Phone match should NOT assign Contact (Option A).');
    }


    // ------------------------------------------------------
    // Scenario 4 — Duplicate Accounts should not create multiple Opps
    // ------------------------------------------------------
    @IsTest
    static void test_duplicate_accounts_protected() {

        resetTunables();
        Id me = UserInfo.getUserId();

        Account a1 = new Account(Name='DupA', Phone='555-9999', OwnerId=me);
        Account a2 = new Account(Name='DupB', Phone='555-9999', OwnerId=me);
        insert new List<Account>{a1, a2};

        Contact c1 = new Contact(FirstName='A', LastName='One', Email='dup@example.com', AccountId=a1.Id);
        Contact c2 = new Contact(FirstName='B', LastName='Two', Email='dup@example.com', AccountId=a2.Id);
        insert new List<Contact>{c1, c2};

        Lead l = new Lead(
            FirstName='Dup',
            LastName='Lead',
            Company='Dup Co',
            Email='dup@example.com',
            Phone='555-9999',
            Status='New',
            OwnerId=me
        );
        insert l;

        ConvertLead.run();

        List<Opportunity> opps = [
            SELECT Id 
            FROM Opportunity
            WHERE Email__c='dup@example.com'
        ];

        System.assert(opps.size() <= 1, 'Should create at most one Opp for duplicates.');
    }

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

    // ------------------------------------------------------
    // Scenario 5 — Record Type logic executes without exception
    // ------------------------------------------------------
    @IsTest
    static void test_record_type_resolution() {

        resetTunables();
        Id me = UserInfo.getUserId();

        List<RecordType> rts = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE SobjectType='Opportunity'
            LIMIT 1
        ];
        if (!rts.isEmpty()) {
            ConvertLead.OPP_RECORD_TYPE_DEVELOPERNAME = rts[0].DeveloperName;
        }

        Lead l = new Lead(
            LastName='RT Lead',
            Company='RT Co',
            Email='rt@example.com',
            Status='New',
            OwnerId=me
        );
        insert l;

        ConvertLead.run();

        System.assert(ConvertLead.LAST_ATTEMPTED > 0, 'Record type resolution path executed.');
    }
}