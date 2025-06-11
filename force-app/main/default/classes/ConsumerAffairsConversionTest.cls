@isTest
private class ConsumerAffairsConversionTest {

    @TestSetup
    static void makeData(){
        AmericordTestDataFactory atdf = new AmericordTestDataFactory();

        // Items for Kulterra
        // Payment Center Settings
        fw1__Payment_Center_Setting__c s = new fw1__Payment_Center_Setting__c();
        s.Name = 'Default Settings';
        insert s;

        // create interest fees product
        Product2 productInterestFees = New Product2(Name='Interest Fees');
        insert productInterestFees;
        
        fw1.PackagedData.restoreStripeData();

        User salesRep = AmericordTestDataFactory.getCurrentSalesRep();

        Account acct = new Account();
        acct.name = 'Test Account';
        insert acct;
        
        Contact cont = new Contact();
        cont.AccountId = acct.id;
        cont.firstname = 'Mary';
        cont.lastname = 'Williamson';
        insert cont;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp';
        opp.accountid = acct.id;
        opp.Contact__c = cont.id;
        opp.Email__c = 'mary@test.com';        
        opp.FirstName__c = 'Mary';
        opp.LastName__c = 'Williamson';
        opp.Relation_to_Baby__c = 'Mother';              
        opp.CloseDate = System.today();
        opp.StageName = 'New';
        opp.Authorized_Payment__c = true;        
        opp.ownerid = salesRep.Id;
        opp.Storage_Plan__c = '20YPP';
        opp.Payment_Plans__c = 'OTP';
        opp.Number_of_Births__c = 'Single';        
        opp.Shipping_Street__c = '123 main st';
        opp.Shipping_City__c = 'Chicago';
        opp.Shipping_Country__c = 'US';
        opp.Shipping_State_Province__c = 'IL';
        opp.Shipping_Zip__c = '99999';        
        opp.Impact_Partner_Id__c = '1111';
        insert opp;               
        
    }

    @isTest
    private static void testConsumerAffairsException(){
        ConsumerAffairsException caexp = new ConsumerAffairsException();
    }

    @isTest
    private static void testConsumerAffairsCall() {

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:ConsumerAffairsConversion', 'ConsumerAffairsConversionResponseSuccess');
        multimock.setStatusCode(201);        

        Test.setMock(HttpCalloutMock.class, multimock);        

        // Create Payment Plan and Storage
        fw1__Payment_Plan__c pp = new fw1__Payment_Plan__c(
            Name = 'Test PP - OTP',
            fw1__Schedule__c = 'Monthly'//,
            //Number_of_Payments__c = 1
        );
        insert pp;

        Opportunity opp = [Select ID from Opportunity LIMIT 1];
        opp.Enrollment_Flow_Complete__c = true;
        opp.Payment_Plans__c = null;
        opp.fw2__Payment_Plan__c = pp.id;
        opp.fw1__Total_Paid_Amount__c=0;
        opp.Payment_Plans__c = 'OTP'; // added to go to production
        opp.StageName = 'Enrolled';
        opp.Consumer_Affairs_UUID__c = '123456789-0090909';
        opp.Phone__c = '+13035551212';
        update opp;        
        
        Test.startTest();
        List<String> lstCAString1 = new List<String>();
        List<List<String>> lstCAString2 = new List<List<String>>();
        lstCAString1.add(opp.Id);
        lstCAString2.add(lstCAString1);
        ConsumerAffairsConversion.sendConversionToConsumerAffairs(lstCAString2);

        Test.stopTest();

        // Asserts
    }

    @isTest
    private static void testConsumerAffairsCall_Phone2() {

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:ConsumerAffairsConversion', 'ConsumerAffairsConversionResponseSuccess');
        multimock.setStatusCode(201);        

        Test.setMock(HttpCalloutMock.class, multimock);        

        // Create Payment Plan and Storage
        fw1__Payment_Plan__c pp = new fw1__Payment_Plan__c(
            Name = 'Test PP - OTP',
            fw1__Schedule__c = 'Monthly'//,
            //Number_of_Payments__c = 1
        );
        insert pp;

        Opportunity opp = [Select ID from Opportunity LIMIT 1];
        opp.Enrollment_Flow_Complete__c = true;
        opp.Payment_Plans__c = null;
        opp.fw2__Payment_Plan__c = pp.id;
        opp.fw1__Total_Paid_Amount__c=0;
        opp.Payment_Plans__c = 'OTP'; // added to go to production
        opp.StageName = 'Enrolled';
        opp.Consumer_Affairs_UUID__c = '123456789-0090909';
        opp.Phone__c = '';
        opp.Contact2_Phone__c = '+13035551212';
        update opp;        
        
        Test.startTest();
        List<String> lstCAString1 = new List<String>();
        List<List<String>> lstCAString2 = new List<List<String>>();
        lstCAString1.add(opp.Id);
        lstCAString2.add(lstCAString1);
        ConsumerAffairsConversion.sendConversionToConsumerAffairs(lstCAString2);

        Test.stopTest();

        // Asserts
    }

    @isTest
    private static void testConsumerAffairsCallException() {

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:ConsumerAffairsConversion', 'ConsumerAffairsConversionResponseSuccess');
        multimock.setStatusCode(400);        

        Test.setMock(HttpCalloutMock.class, multimock);        

        // Create Payment Plan and Storage
        fw1__Payment_Plan__c pp = new fw1__Payment_Plan__c(
            Name = 'Test PP - OTP',
            fw1__Schedule__c = 'Monthly'//,
            //Number_of_Payments__c = 1
        );
        insert pp;

        Opportunity opp = [Select ID from Opportunity LIMIT 1];
        opp.Enrollment_Flow_Complete__c = true;
        opp.Payment_Plans__c = null;
        opp.fw2__Payment_Plan__c = pp.id;
        opp.fw1__Total_Paid_Amount__c=0;
        opp.Payment_Plans__c = 'OTP'; // added to go to production
        opp.StageName = 'Enrolled';
        opp.Consumer_Affairs_UUID__c = '123456789-0090909';
        update opp;        
        
        Test.startTest();
        List<String> lstCAString1 = new List<String>();
        List<List<String>> lstCAString2 = new List<List<String>>();
        lstCAString1.add(opp.Id);
        lstCAString2.add(lstCAString1);
        ConsumerAffairsConversion.sendConversionToConsumerAffairs(lstCAString2);

        Test.stopTest();

        // Asserts
    }
}