@isTest
private class PartnerConversionTest {
    @TestSetup
    static void makeData(){
        AmericordTestDataFactory atdf = new AmericordTestDataFactory();

        // Items for Kulterra
        // Payment Center Settings
        fw1__Payment_Center_Setting__c s = new fw1__Payment_Center_Setting__c();
        s.Name = 'Default Settings';
        insert s;
        
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
    private static void testPartnerHelperException(){
        PartnerException pe = new PartnerException();
        PartnerHelper ph = new PartnerHelper();
    }

    @isTest
    private static void testImpactCall() {

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:ImpactLogConversionData', 'ImpactConversionResponseSuccess');
        multimock.setStatusCode(200);        

        Test.setMock(HttpCalloutMock.class, multimock);        

        // Create Payment Plan and Storage
        fw1__Payment_Plan__c pp = new fw1__Payment_Plan__c(
            Name = 'Test PP - OTP',
            fw1__Schedule__c = 'Monthly',
            Number_of_Payments__c = 1
        );
        insert pp;

        Opportunity opp = [Select ID from Opportunity LIMIT 1];
        //opp.Enrollment_Flow_Complete__c = true;
        opp.Payment_Plans__c = null;
        opp.fw2__Payment_Plan__c = pp.id;
        opp.fw1__Total_Paid_Amount__c=0;
        opp.Payment_Plans__c = 'OTP'; // added to go to production
        opp.Enrollment_Flow_Complete__c = true;
        opp.StageName = 'Enrolled';
        update opp;        
        
        fw1__Invoice__c cbo = [SELECT Id FROM fw1__Invoice__c LIMIT 1];      
        
        Test.startTest();
        
        cbo.Storage_Plan_Stored__c = 'LTS';
        cbo.Payment_Plan_Stored__c = 'OTP';
        cbo.fw1__Payment_Plan__c = pp.id;
        cbo.fw1__Auto_BillPay__c = true;
        update cbo;

        Test.stopTest();

        // Asserts
    }

    @isTest
    private static void testImpactCall_Explicit() {
        List<String> lstInvoiceIDs = new List<String>();
        List<List<String>> lstInvoiceIDs2 = new List<List<String>> ();


        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:ImpactLogConversionData', 'ImpactConversionResponseSuccess');
        multimock.setStatusCode(200);        

        Test.setMock(HttpCalloutMock.class, multimock);        

        // Create Payment Plan and Storage
        fw1__Payment_Plan__c pp = new fw1__Payment_Plan__c(
            Name = 'Test PP - OTP',
            fw1__Schedule__c = 'Monthly',
            Number_of_Payments__c = 1
        );
        insert pp;

        Opportunity opp = [Select ID from Opportunity LIMIT 1];
        //opp.Enrollment_Flow_Complete__c = true;
        opp.Payment_Plans__c = null;
        opp.fw2__Payment_Plan__c = pp.id;
        opp.fw1__Total_Paid_Amount__c=0;
        opp.Payment_Plans__c = 'OTP'; // added to go to production
        opp.Enrollment_Flow_Complete__c = true;
        opp.StageName = 'Enrolled';
        update opp;        
        
        fw1__Invoice__c cbo = [SELECT Id FROM fw1__Invoice__c LIMIT 1];      
        
        Test.startTest();
        
        cbo.Storage_Plan_Stored__c = 'LTS';
        cbo.Payment_Plan_Stored__c = 'OTP';
        cbo.fw1__Payment_Plan__c = pp.id;
        cbo.fw1__Auto_BillPay__c = true;
        update cbo;

        lstInvoiceIDs.add(cbo.Id);
        lstInvoiceIDs2.add(lstInvoiceIDs);

        PartnerConversion.sendConversionToImpact(lstInvoiceIDs2);

        Test.stopTest();

        // Asserts
    }    

}