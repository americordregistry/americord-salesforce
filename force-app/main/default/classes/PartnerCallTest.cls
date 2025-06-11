@isTest
private class PartnerCallTest {
    @TestSetup
    static void makeData(){

        Account acct = new Account();
        acct.name = 'Test Account';
        insert acct;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp';
        opp.accountid = acct.id;
        opp.CloseDate = System.today();
        opp.StageName = 'New';
        opp.Impact_Partner_Id__c = '1111';
        insert opp;
        
        Contact cont = new Contact();
        cont.AccountId = acct.id;
        cont.firstname = 'Testor';
        cont.lastname = 'Williamson';
        insert cont;
          
    }

    @isTest
    private static void verifyCallLog_Success() {

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:ImpactLogCallData/calldata/logCallData', 'ImpactCallResponseSuccess');
        multimock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, multimock);

        Contact cont = [SELECT id from Contact limit 1];
        Opportunity opp = [SELECT id from Opportunity Limit 1];

        Test.startTest();        
        Task tsk = new Task();
        tsk.whoid = cont.id;
        tsk.Subject = 'test task';
        tsk.whatid = opp.id;
        tsk.CallType ='Inbound';
        tsk.Type = 'Call';     
        tsk.aircall__External_contact_phone_number__c = '+13035551212';
        tsk.aircall__Phone_number__c = '+14045551212'; 
        insert tsk;               
        Test.stopTest();

        // Asserts
    }

    @isTest
    private static void verifyCallLog_Explicit_Success() {
        List<String> lstTaskIDs = new List<String>();
        List<List<String>> lstTaskIDs2 = new List<List<String>> ();        

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:ImpactLogCallData/calldata/logCallData', 'ImpactCallResponseSuccess');
        multimock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, multimock);

        Contact cont = [SELECT id from Contact limit 1];
        Opportunity opp = [SELECT id from Opportunity Limit 1];

        Test.startTest();        
        Task tsk = new Task();
        tsk.whoid = cont.id;
        tsk.Subject = 'test task';
        tsk.whatid = opp.id;
        tsk.CallType ='Inbound';
        tsk.Type = 'Call';     
        tsk.aircall__External_contact_phone_number__c = '+13035551212';
        tsk.aircall__Phone_number__c = '+14045551212'; 
        insert tsk;           
        
        lstTaskIDs.add(tsk.Id);
        lstTaskIDs2.add(lstTaskIDs);

        PartnerCall.sendCallToImpact(lstTaskIDs2);

        Test.stopTest();

        // Asserts
    }    

}