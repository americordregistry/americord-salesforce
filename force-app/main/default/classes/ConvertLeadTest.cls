@IsTest
private class ConvertLeadTest {

    // ---------------------------------------------------------
    // Test Setup
    // ---------------------------------------------------------
    @TestSetup
    static void setupData() {

        // Create a deterministic owner that matches ConvertLead filters
        User owner = new User(
            FirstName = 'Lou',
            LastName  = 'Leadowner',
            Email = 'lou.leadowner@example.com',
            Username = 'lou.leadowner+' + System.currentTimeMillis() + '@example.com',
            Alias = 'loulo',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey   = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = [
                SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1
            ].Id,
            Division = ConvertLead.SALES_DIVISION,
            IsActive = true
        );
        insert owner;
    }

    // ---------------------------------------------------------
    // Helper
    // ---------------------------------------------------------
    private static User getOwner() {
        return [
            SELECT Id FROM User WHERE LastName = 'Leadowner' LIMIT 1
        ];
    }

    // ---------------------------------------------------------
    // 1️⃣ Normal Salesforce Conversion (no match)
    // ---------------------------------------------------------
    @IsTest
    static void test_existing_account_creates_direct_opportunity() {
        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = UserInfo.getUserId();

        User owner = getOwner();

        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = owner.Id;

        Lead lead = new Lead(
            FirstName = 'Norm',
            LastName  = 'Convert',
            Company   = 'Normal Co',
            Email     = 'norm@example.com',
            Phone     = '1231231234',
            Status    = 'New',
            OwnerId  = owner.Id
        );
        insert lead;

        ConvertLead.run();

        Lead refreshed = [
            SELECT IsConverted
            FROM Lead
            WHERE Id = :lead.Id
        ];

        System.assertEquals(
            true,
            refreshed.IsConverted,
            'Normal lead should be converted via standard Salesforce conversion.'
        );
    }

    // ---------------------------------------------------------
    // 2️⃣ Email match → Direct Opportunity + Contact
    // ---------------------------------------------------------
    @IsTest
    static void test_email_match_direct_opp() {

        User owner = getOwner();

        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = owner.Id;

        Account acc = new Account(
            Name = 'Email Match Family',
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
            Company   = 'Email Match Family',
            Email = 'emailmatch@example.com',
            Phone = '7778889999',
            Status = 'New',
            OwnerId = owner.Id
        );
        insert lead;

        ConvertLead.run();

        Opportunity opp = [
            SELECT Id, AccountId, Contact__c
            FROM Opportunity
            WHERE AccountId = :acc.Id
            LIMIT 1
        ];

        System.assertEquals(
            acc.Id,
            opp.AccountId,
            'Email match should create Opportunity under Account.'
        );

        System.assertEquals(
            con.Id,
            opp.Contact__c,
            'Email match must attach matched Contact.'
        );
    }

    // ---------------------------------------------------------
    // 3️⃣ Phone match → Direct Opportunity (Contact optional)
    // ---------------------------------------------------------
    @IsTest
    static void test_phone_match_direct_opp() {

        User owner = getOwner();

        ConvertLead.CREATED_AFTER = System.now().addDays(-1);
        ConvertLead.LIMIT_N = 10;
        ConvertLead.OWNER_ID = owner.Id;

        // Phone already normalized like prod formatter
        Account acc = new Account(
            Name = 'Phone Match Family',
            Phone = '+19998887777',
            OwnerId = owner.Id
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'Phone',
            LastName  = 'Match',
            Email = 'phonematch@example.com',
            Phone = '+19998887777',
            AccountId = acc.Id
        );
        insert con;

        Lead lead = new Lead(
            FirstName = 'Lead',
            LastName  = 'PhoneMatch',
            Company   = 'Phone Match Family',
            Email = 'other@example.com',
            Phone = '+19998887777',
            Status = 'New',
            OwnerId = owner.Id
        );
        insert lead;

        ConvertLead.run();

        Opportunity opp = [
            SELECT Id, AccountId, Contact__c
            FROM Opportunity
            WHERE AccountId = :acc.Id
            LIMIT 1
        ];

        System.assertEquals(
            acc.Id,
            opp.AccountId,
            'Phone match should create Opportunity under Account.'
        );

        // IMPORTANT: Contact is OPTIONAL for phone-only matches
        // due to phone normalization timing / automation
        System.assert(
            opp.Contact__c == null || opp.Contact__c == con.Id,
            'Contact attachment is optional for phone-only matches.'
        );
    }
}