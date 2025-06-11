/**
* DocusignServices
* ------------------
* @author jseibert
*/
public with sharing class DocusignServices {
    /**
    * getCurrentIntegrationSettings
    * -------
    * returns the custom metadata values for use in by apex.
    */
    public static String getDocusignTemplateId(String strDocusignDoc){
        Americord_Docusign_Templates__mdt docusignTemplate = [
            SELECT 
            Docusign_Template_ID__c
            FROM Americord_Docusign_Templates__mdt 
            WHERE DeveloperName = :strDocusignDoc LIMIT 1];
            
            return docusignTemplate.Docusign_Template_ID__c;
    }    
}