/**
* ws_PortalUserEmailValidateTest
* ------------------
* @author jseibert
*/
@isTest
public with sharing class ws_PortalUserEmailValidateTest {
    @isTest
    static void sendPortalUserEmailTest() {

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 

        ws_PortalUserEmailValidate.PortalEmailValidate wrapReq = new ws_PortalUserEmailValidate.PortalEmailValidate();
        wrapReq.email = 'someemail@americordblood.com';
        wrapReq.subject = 'Test Subject';
        wrapReq.body = 'This is a placeholder test body';
     
        req.requestURI = '/services/apexrest/portalUserEmailValidate';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serializePretty(wrapReq));

        //Must set context
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ws_PortalUserEmailValidate.sendPortalEmailValidate();           
        Test.stopTest();        
        //TODO: Code an assert for here
    }
}