@isTest
public class CustomMetadataServiceTest {
    public static List<Americord_Docusign_Templates__mdt> lstDocusignTemplates = new List <Americord_Docusign_Templates__mdt>();
    public static List<Discount_Code__mdt> lstDiscountCodes = new List <Discount_Code__mdt>();

    @isTest
    static void testCMTNullDocsignTemplatesMeta() {
        Map<String,Americord_Docusign_Templates__mdt> mapDocuTempTest = new Map<String,Americord_Docusign_Templates__mdt>();
        List<Americord_Docusign_Templates__mdt> lstDocuTempTest = new List<Americord_Docusign_Templates__mdt>();

        CustomMetadataService.lstDocusignTemplates = null;
        lstDocuTempTest =  CustomMetadataService.getAllDocusignTemplates();        
        CustomMetadataService.lstDocusignTemplates = null;        
        mapDocuTempTest = CustomMetadataService.getMapDocusignTemplates();
    }    

    @isTest
    static void testCMTNullDiscountCodes() {
        Map<String,Discount_Code__mdt> mapDiscountCodesTest = new Map<String,Discount_Code__mdt>();
        List<Discount_Code__mdt> lstDiscCodesTest = new List<Discount_Code__mdt>();
        
        CustomMetadataService.lstDiscountCodes = null;
        lstDiscCodesTest = CustomMetadataService.getAllDiscountCodes();        
        CustomMetadataService.lstDiscountCodes = null;        
        mapDiscountCodesTest = CustomMetadataService.getMapDiscountCodes();
    }    

    @isTest
    static void testDocsignTemplatesMetaTest() {
        // Docusign Metadata
        Americord_Docusign_Templates__mdt docuTemplate = new Americord_Docusign_Templates__mdt();
        docuTemplate.Docusign_Template_ID__c = '12345';
        docuTemplate.Label = 'MHQ Template';
        docuTemplate.DeveloperName = 'MHQ_Template';
        lstDocusignTemplates.add(docuTemplate);

        List<Americord_Docusign_Templates__mdt> lstDocuTempTest = new List<Americord_Docusign_Templates__mdt>();
        Map<String,Americord_Docusign_Templates__mdt> mapDocuTempTest = new Map<String,Americord_Docusign_Templates__mdt>();
        CustomMetadataService.lstDocusignTemplates = lstDocusignTemplates;
        lstDocuTempTest =  CustomMetadataService.getAllDocusignTemplates();
        mapDocuTempTest = CustomMetadataService.getMapDocusignTemplates();
        System.assertEquals(1, lstDocuTempTest.size(), 'Number of returned documents is not correct.');
         
    }
    @isTest
    static void testDiscountCodesTest() {
        // Discount Codes
        Discount_Code__mdt discCode = new Discount_Code__mdt();
        discCode.Label = 'WTE400';
        discCode.DeveloperName = 'WTE400';
        discCode.Amount__c = 400;
        discCode.Price_Limit__c = 4000;
        discCode.Start_Date__c = System.today();
        discCode.End_Date__c = System.today()+7;
        discCode.Applicable_Bundles__c = 'Biobanking';
        lstDiscountCodes.add(discCode);

        List<Discount_Code__mdt> lstDiscCodesTest = new List<Discount_Code__mdt>();
        Map<String,Discount_Code__mdt> mapDiscountCodesTest = new Map<String,Discount_Code__mdt>();
        CustomMetadataService.lstDiscountCodes = lstDiscountCodes;
        lstDiscCodesTest = CustomMetadataService.getAllDiscountCodes();
        mapDiscountCodesTest = CustomMetadataService.getMapDiscountCodes();
        System.assertEquals(1, lstDiscCodesTest.size(), 'Number of returned discount codes is not correct.');        
    }

}