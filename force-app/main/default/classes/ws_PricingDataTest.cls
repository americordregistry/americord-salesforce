@isTest
private class ws_PricingDataTest {
    
    // @TestSetup
    // static void makeData(){

    //     //create flex pricebook
    //     Pricebook2 pbFlex = new Pricebook2(
    //         Name='Ameriflex 1.0',
    //         Pricing_Version__c = 1.0,
    //         IsActive=true
    //     );
    //     insert pbFlex;

    //     //Create default pricebook structures
    //     AmericordTestDataFactory testFactory = new AmericordTestDataFactory();

    //     List < Product2 > allProducts = [SELECT ID, ProductCode FROM Product2];

    //     Map < string, sObject > productMap = Toolkit.indexedSObjectMap ( allProducts, 'ProductCode' );        

    //     // Create Pricebook Entries
    //     List < PricebookEntry > pricebookEntriesForInsert = new List < PricebookEntry > ();

    //     PricebookEntry standardPrice = new PricebookEntry (Pricebook2Id = pbFlex.Id, 
    //                                                        Product2Id = (Id) productMap.get ( 'CB2.0' ).get ( 'Id' ),
    //                                                        UnitPrice = 1499, 
    //                                                        IsActive = true);
    //     pricebookEntriesForInsert.add ( standardPrice );

    //     standardPrice = new PricebookEntry (Pricebook2Id = pbFlex.Id, 
    //                         Product2Id = (Id) productMap.get ( 'CT' ).get ( 'Id' ),
    //                         UnitPrice = 1499, 
    //                         IsActive = true);
        
    //     pricebookEntriesForInsert.add ( standardPrice );

    //     standardPrice = new PricebookEntry (Pricebook2Id = pbFlex.Id, 
    //                         Product2Id = (Id) productMap.get ( 'PAM' ).get ( 'Id' ),
    //                         UnitPrice = 1499, 
    //                         IsActive = true);
        
    //     pricebookEntriesForInsert.add ( standardPrice );
        
        				
    //     standardPrice = new PricebookEntry (Pricebook2Id = pbFlex.Id, 
    //                         Product2Id = (Id) productMap.get ( '20YPP' ).get ( 'Id' ),
    //                         UnitPrice = 2000, 
    //                         IsActive = true);
        
    //     pricebookEntriesForInsert.add ( standardPrice );
    
        
    //     standardPrice = new PricebookEntry (Pricebook2Id = pbFlex.Id, 
    //                                         Product2Id = (Id) productMap.get ( 'LTS' ).get ( 'Id' ),
    //                                         UnitPrice = 4250, 
    //                                         IsActive = true);
        
    //     pricebookEntriesForInsert.add ( standardPrice );

    //     insert pricebookEntriesForInsert;
        
    // }
    
    // @isTest
    // static void getTest() {
    //     // Set up a test request
    //     RestRequest req = new RestRequest(); 
    //     RestResponse res = new RestResponse();
    //     RestContext.request = req;
    //     RestContext.response = res;
     
    //     req.requestURI = '/services/apexrest/PricingData'; 
    //     req.httpMethod = 'GET';

    //     // Call the method to test
    //     ws_PricingData.getPricingTable();
    //     // Verify results
    //     string resBody = res.responseBody.toString();
    //     SliderPricing twentyYearPricing = (SliderPricing) JSON.deserialize(resBody, SliderPricing.class);

    //     System.assertEquals('20YPP', twentyYearPricing.storageTerm);
    // }

    // @isTest
    // static void getTestVariant() {
    //     // Set up a test request
    //     RestRequest req = new RestRequest(); 
    //     RestResponse res = new RestResponse();
    //     RestContext.request = req;
    //     RestContext.response = res;
     
    //     req.requestURI = '/services/apexrest/PricingData'; 
    //     req.addParameter('version', '1.0');
    //     req.addParameter('storage-term', '20YPP');
    //     req.httpMethod = 'GET';

    //     // Call the method to test
    //     ws_PricingData.getPricingTable();
    //     // Verify results
    //     string resBody = res.responseBody.toString();
    //     SliderPricing twentyYearPricing = (SliderPricing) JSON.deserialize(resBody, SliderPricing.class);

    //     System.assertEquals('20YPP', twentyYearPricing.storageTerm);
    // }
}