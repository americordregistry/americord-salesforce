@IsTest
private class ConvertLeadTest {

    // Helper: safely retrieve converted status (no DML on LeadStatus)
    private static String getConvertedStatusValue() {
        List<LeadStatus> ls = [
            SELECT MasterLabel
            FROM LeadStatus
            WHERE IsConverted = TRUE
            LIMIT 1
        ];
        System.assert(!ls.isEmpty(), 'Converted LeadStatus must exist.');
        return ls[0].MasterLabel;
    }


    // -----------------------------------------------------------------------------
    // SCENARIO 1: Normal Salesforce Conversion (no matching Account or Contact)
    // -----------------------------------------------------------------------------
    @IsTest
    static void test_normal_conversion_creates_account_contact_opp() {

        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = UserInfo.getUserId();

        String convertedStatus = getConvertedStatusValue();

        Lead lead1 = new Lead(
            LastName = 'Normal',
            Company = 'Normal Co',
            Email = 'normal1@example.com',
            Phone = '555-0001',
            Status = 'New',
            OwnerId = UserInfo.getUserId()
        );
        insert lead1;

        Test.startTest();
        ConvertLead.run();
        Test.stopTest();

        // Validate conversion created Account/Contact/Opportunity
        List<Opportunity> opps = [
            SELECT Id, AccountId, Contact__c
            FROM Opportunity
            WHERE Email__c = 'normal1@example.com'
        ];
        System.assertEquals(1, opps.size(), 'Normal conversion should create one Opp.');
        System.assertNotEquals(null, opps[0].AccountId, 'Normal conversion should create Account.');
    }


    // -----------------------------------------------------------------------------
    // SCENARIO 2: Email Match → Opp created under existing Account/Contact
    // -----------------------------------------------------------------------------
    @IsTest
static void test_email_match_creates_direct_opp() {

    ConvertLead.CREATED_AFTER = System.now().addDays(-1);
    ConvertLead.LIMIT_N = 10;
    ConvertLead.OWNER_ID = UserInfo.getUserId();

    String convertedStatus = getConvertedStatusValue();

    //
    // FIRST: Create a lead and let it convert normally
    //
    Lead firstLead = new Lead(
        LastName = 'Parent',
        Company = 'Starter Co',
        Email = 'family@example.com',
        Phone = '555-1000',
        Status = 'New',
        OwnerId = UserInfo.getUserId()
    );
    insert firstLead;

    // *** No startTest() here ***
    ConvertLead.run();   // initial conversion, allowed outside startTest()/stopTest()


    // Confirm setup conversion worked
    Opportunity baseOpp = [
        SELECT Id, AccountId
        FROM Opportunity
        WHERE Email__c = 'family@example.com'
        LIMIT 1
    ];
    Account acc = [SELECT Id FROM Account WHERE Id = :baseOpp.AccountId LIMIT 1];
    Contact con = [SELECT Id, Email FROM Contact WHERE AccountId = :acc.Id LIMIT 1];


    //
    // SECOND: Create a new lead that will match by EMAIL
    //
    Lead emailMatchLead = new Lead(
        LastName  = 'EmailMatch',
        Company   = 'Another Co',
        Email     = con.Email,
        Phone     = '555-7777',
        Status    = 'New',
        OwnerId   = UserInfo.getUserId()
    );
    insert emailMatchLead;


    // *** THIS is the real test call ***
    Test.startTest();
    ConvertLead.run();
    Test.stopTest();


    // Assertions
    List<Opportunity> directOpps = [
        SELECT Id, AccountId, Contact__c, Email__c
        FROM Opportunity
        WHERE Email__c = :con.Email
        ORDER BY CreatedDate DESC
    ];

    System.assert(directOpps.size() >= 2,
        'Second run should create a direct Opp due to email match.');

    Opportunity newOpp = directOpps[0];
    System.assertEquals(acc.Id, newOpp.AccountId, 'Direct Opp should be under existing Account.');
    System.assertEquals(con.Id, newOpp.Contact__c, 'Direct Opp should attach to matched Contact.');
}


    // -----------------------------------------------------------------------------
    // SCENARIO 3: Phone Match → Opp created under existing Account/Contact
    // -----------------------------------------------------------------------------
 @IsTest
static void test_phone_match_creates_direct_opp() {

    ConvertLead.CREATED_AFTER = System.now().addDays(-1);
    ConvertLead.LIMIT_N = 10;
    ConvertLead.OWNER_ID = UserInfo.getUserId();

    String convertedStatus = getConvertedStatusValue();

    //
    // FIRST: Create a lead and let it convert normally (PHONE: 555-2000)
    //
    Lead firstLead = new Lead(
        LastName = 'PhoneParent',
        Company  = 'Starter Co',
        Email    = 'phonematchparent@example.com',
        Phone    = '555-2000',
        Status   = 'New',
        OwnerId  = UserInfo.getUserId()
    );
    insert firstLead;

    // *** No startTest() here ***
    ConvertLead.run();  // initial conversion happens BEFORE governor reset


    // Confirm setup conversion created the Account + Contact + Opp
    Opportunity baseOpp = [
        SELECT Id, AccountId
        FROM Opportunity
        WHERE Email__c = 'phonematchparent@example.com'
        LIMIT 1
    ];
    System.assertNotEquals(null, baseOpp, 'Initial conversion should have created an Opportunity.');

    Account acc = [
        SELECT Id, OwnerId 
        FROM Account 
        WHERE Id = :baseOpp.AccountId 
        LIMIT 1
    ];

    Contact con = [
        SELECT Id, Email 
        FROM Contact 
        WHERE AccountId = :acc.Id 
        LIMIT 1
    ];

    System.assertNotEquals(null, acc, 'Expected existing Account after setup conversion.');
    System.assertNotEquals(null, con, 'Expected existing Contact after setup conversion.');


    //
    // SECOND: Create a new lead that matches *by phone* (555-2000)
    //
    Lead phoneMatchLead = new Lead(
        LastName = 'PhoneMatchChild',
        Company  = 'Another Co',
        Email    = 'noemailmatch@example.com',  // no email match
        Phone    = '555-2000',                  // 👈 PHONE MATCH triggers direct Opp
        Status   = 'New',
        OwnerId  = UserInfo.getUserId()
    );
    insert phoneMatchLead;


    //
    // REAL TEST RUN
    //
    Test.startTest();
    ConvertLead.run();
    Test.stopTest();


    //
    // ASSERTIONS
    //
    List<Opportunity> opps = [
        SELECT Id, AccountId, Contact__c, Email__c, Phone__c
        FROM Opportunity
        WHERE AccountId = :acc.Id
        ORDER BY CreatedDate DESC
    ];

    System.assert(opps.size() >= 2,
        'Should create a NEW direct Opportunity due to phone match.');

    Opportunity newestOpp = opps[0];

    System.assertEquals(acc.Id, newestOpp.AccountId,
        'Direct Opp should be created under the existing Account.');

    System.assertEquals(null, newestOpp.Contact__c,
        'Phone-only matches should NOT attach a contact (email match required).');


    System.assertEquals(phoneMatchLead.Phone, newestOpp.Phone__c,
        'Phone should transfer from lead to Opportunity.');
}


    // -----------------------------------------------------------------------------
    // RecordType resolution test
    // -----------------------------------------------------------------------------
    @IsTest
    static void test_recordtype_resolution() {

        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.OWNER_ID = UserInfo.getUserId();
        ConvertLead.LIMIT_N = 10;

        RecordType rt = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE SobjectType = 'Opportunity'
            LIMIT 1
        ];

        ConvertLead.OPP_RECORD_TYPE_DEVELOPERNAME = rt.DeveloperName;

        Lead lead = new Lead(
            LastName = 'RTUser',
            Company = 'RTC',
            Email = 'rtuser@example.com',
            Status = 'New',
            OwnerId = UserInfo.getUserId()
        );
        insert lead;

        Test.startTest();
        ConvertLead.run();
        Test.stopTest();

        System.assert(ConvertLead.LAST_ATTEMPTED > 0,
            'Should attempt at least one conversion.');
    }


    // -----------------------------------------------------------------------------
    // Duplicate account scenario
    // -----------------------------------------------------------------------------
    @IsTest
    static void test_duplicate_accounts_skipped_or_single_opp() {

        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.OWNER_ID = UserInfo.getUserId();
        ConvertLead.LIMIT_N = 10;

        Account a1 = new Account(Name = 'DupA', Phone = '5555555', OwnerId = UserInfo.getUserId());
        Account a2 = new Account(Name = 'DupB', Phone = '5555555', OwnerId = UserInfo.getUserId());
        insert new List<Account>{ a1, a2 };

        Contact c1 = new Contact(FirstName='J', LastName='One', Email='dup@example.com', AccountId=a1.Id);
        Contact c2 = new Contact(FirstName='K', LastName='Two', Email='dup@example.com', AccountId=a2.Id);
        insert new List<Contact>{ c1, c2 };

        Lead lead = new Lead(
            LastName = 'DupLead',
            Company = 'DupC',
            Email = 'dup@example.com',
            Phone = '5555555',
            Status = 'New',
            OwnerId = UserInfo.getUserId()
        );
        insert lead;

        Test.startTest();
        ConvertLead.run();
        Test.stopTest();

        List<Opportunity> opps = [
            SELECT Id FROM Opportunity WHERE Email__c = 'dup@example.com'
        ];

        System.assert(
            opps.size() <= 1,
            'Duplicate accounts should not cause multiple Opps.'
        );
    }
}