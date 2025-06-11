@isTest
private class DocusignSendMHQTest {
    @testSetup static void setup() {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();   
        
        Contact testContact = new Contact();
        testContact.FirstName ='Testor';
        testContact.LastName = 'Lastname';
        testContact.Email = 'testor@someco.com';
        insert testContact;

        MHQ__c testMHQ = new MHQ__c();
        testMHQ.MHQ_Recipient__c = testContact.Id;
        insert testMHQ;

        List<Americord_Docusign_Templates__mdt> docusignTemplates = setDocusignTemplates();
        
    }     

    private static List<Americord_Docusign_Templates__mdt> setDocusignTemplates () {
    	
        List < Americord_Docusign_Templates__mdt > lstDocusignTemplates = new List <Americord_Docusign_Templates__mdt>();

        Americord_Docusign_Templates__mdt testTemplate = new Americord_Docusign_Templates__mdt();
        testTemplate.label = 'MHQ Template';
        testTemplate.developerName = 'MHQ_Template';
        testTemplate.Docusign_Template_ID__c = 'abc123';
        lstDocusignTemplates.add(testTemplate);

        CustomMetadataService.lstDocusignTemplates = lstDocusignTemplates;
        lstDocusignTemplates = CustomMetadataService.getAllDocusignTemplates(); //coverage
        return lstDocusignTemplates;
    }    

    @isTest
    private static void testSendingMHQ() {        
        // Test data setup
        MHQ__c mhq = [SELECT Id from MHQ__c LIMIT 1];

        List<ID> lstMHQIDs = new List<Id>();
        lstMHQIDs.add(mhq.Id);
        
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        User dfuser = dfsle.UserMock.createDocuSignAdministrator();
        Test.startTest();
        System.runAs(dfuser) {
            DocusignSendMHQ.sendMHQToRecipient(lstMHQIds);
        }
        Test.stopTest();

        //asserts
    }

}