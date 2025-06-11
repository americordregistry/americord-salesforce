@isTest
private class ResetPasswordTest
{
    @testSetup
    static void dataSetup()
    {
        Portal_Authentication__c portalAuthentication = new Portal_Authentication__c();
        portalAuthentication.Username__c = 'test@test.com';
        portalAuthentication.Password__c = 'test123!';
        insert portalAuthentication;

        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'User';
        contact.Portal_Authentication__c = portalAuthentication.Id;
        insert contact;
    }

    static testMethod void positiveTest()
    {
        Contact contact = [SELECT Id FROM Contact];
        system.assert(contact.Id != null);

        Portal_Authentication__c portalAuthentication = [SELECT Id FROM Portal_Authentication__c];
        system.assert(portalAuthentication.Id != null);

        ws_ResetPassword.handlePost(portalAuthentication.Id, contact.Id);
    }
}