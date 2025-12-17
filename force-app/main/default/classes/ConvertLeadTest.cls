@IsTest
private class ConvertLeadTest {

    @TestSetup
    static void setupData() {

        // Create a valid owner for test leads
        User owner = new User(
            FirstName = 'Lou',
            LastName  = 'Leadowner',
            Email = 'lou.leadowner@example.com',
            Username = 'lou.leadowner_' + System.currentTimeMillis() + '@example.com',
            Alias = 'loulo',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey   = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            Division = ConvertLead.SALES_DIVISION
        );
        insert owner;

        // ❗ DO NOT INSERT LeadStatus — this is prohibited and unnecessary
        // ConvertLead.run() will query the org's existing converted status
    }


    // ---------------------------------------------------------
    // Test 1 — Normal conversion (no match)
    // ---------------------------------------------------------
    @IsTest
    static void test_existing_account_creates_direct_opportunity() {
        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = UserInfo.getUserId();

        User owner = [SELECT Id FROM User WHERE LastName = 'Leadowner' LIMIT 1];

        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = owner.Id;

        Lead lead = new Lead(
            FirstName = 'Norm',
            LastName  = 'Convert',
            Email = 'norm@example.com',
            Phone = '1231231234',
            Status = 'New',
            OwnerId = owner.Id
        );
        insert lead;

        ConvertLead.run();

        Lead updatedLead = [
            SELECT IsConverted FROM Lead WHERE Id = :lead.Id
        ];
        System.assertEquals(true, updatedLead.IsConverted, 'Normal lead should be converted.');
    }


    // ---------------------------------------------------------
    // Test 2 — Email match → direct opp
    // ---------------------------------------------------------
    @IsTest
    static void test_email_match_direct_opp() {

        User owner = [SELECT Id FROM User WHERE LastName = 'Leadowner' LIMIT 1];

        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = owner.Id;

        Account acc = new Account(
            Name = 'Email Family',
            Phone = '5552224444',
            OwnerId = owner.Id
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'Email',
            LastName  = 'Match',
            Email = 'emailmatch@example.com',
            AccountId = acc.Id
        );
        insert con;

        Lead lead = new Lead(
            FirstName = 'Lead',
            LastName  = 'EmailMatch',
            Email = 'emailmatch@example.com',
            Phone = '7778889999',
            Status = 'New',
            OwnerId = owner.Id
        );
        insert lead;

        ConvertLead.run();

        Opportunity opp = [
            SELECT Id, Contact__c, AccountId
            FROM Opportunity
            WHERE AccountId = :acc.Id
            LIMIT 1
        ];

        System.assertNotEquals(null, opp, 'Expected direct opp.');
        System.assertEquals(con.Id, opp.Contact__c, 'Should attach to matched Contact.');
    }


    // ---------------------------------------------------------
    // Test 3 — Phone match → direct opp
    // ---------------------------------------------------------
    @IsTest
    static void test_phone_match_direct_opp() {

        User owner = [SELECT Id FROM User WHERE LastName = 'Leadowner' LIMIT 1];

        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = owner.Id;

        Account acc = new Account(
            Name = 'Phone Family',
            Phone = '+19998887777',
            OwnerId = owner.Id
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'Phone',
            LastName  = 'Match',
            Email = 'phonematch@example.com',
            AccountId = acc.Id
        );
        insert con;

        Lead lead = new Lead(
            FirstName = 'Lead',
            LastName  = 'PhoneMatch',
            Email = 'other@example.com',
            Phone = '+19998887777',  // normalized match
            Status = 'New',
            OwnerId = owner.Id
        );
        insert lead;

        ConvertLead.run();

        Opportunity opp = [
            SELECT Id, Contact__c, AccountId
            FROM Opportunity
            WHERE AccountId = :acc.Id
            LIMIT 1
        ];

        System.assertNotEquals(null, opp, 'Expected direct opp.');
        System.assertEquals(con.Id, opp.Contact__c, 'Should attach to phone-matched Contact.');
    }
}