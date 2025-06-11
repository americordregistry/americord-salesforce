@isTest
private class SliderCalculatorTest {
    
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
    // static void loadPricingTest() {
    //     //20 Year
    //     String jsonMap20Yr = SliderCalculatorController.loadPricingMap('20YPP');

    //     SliderPricing twentyYearPricing = (SliderPricing) JSON.deserialize(jsonMap20Yr, SliderPricing.class);

    //     System.debug('twentyYearPricing: '+JSON.serialize(twentyYearPricing));

    //     Map < Decimal, Decimal > twentyYrInnerMap = twentyYearPricing.paymentMap.get(6);

    //     //Validate we get an amount back for 6 months and $100 downpayment and 20 year storage
    //     System.assertNotEquals(null, twentyYrInnerMap.get(100));

    //     //Lifetime
    //     String jsonMapLifetime = SliderCalculatorController.loadPricingMap('LTS');
    //     SliderPricing lifetimeStoragePricing = (SliderPricing) JSON.deserialize(jsonMapLifetime, SliderPricing.class);


    //     Map < Decimal, Decimal > ltsInnerMap = lifetimeStoragePricing.paymentMap.get(6);

    //     //Validate we get an amount back for 6 months and $100 downpayment and 20 year storage
    //     System.assertNotEquals(null, ltsInnerMap.get(100));

    //     //Validate that LTS and 20 year give different values
    //     System.assertNotEquals(twentyYrInnerMap.get(100), ltsInnerMap.get(100));

    // }

    // @isTest
    // static void testMetadataMethods() {
    //     //Get the rate for 1.0 from metadata
    //     Double rate;
    //     Decimal defaultVersion;
    //     Map<String, Pricing_Version__mdt> pricingMetadata = Pricing_Version__mdt.getAll();
    //     for (Pricing_Version__mdt ver: pricingMetadata.values()) {
    //         if (ver.Version_Number__c==1.0) {
    //             rate = ver.Rate__c;
    //         }
    //         if (ver.Is_Default__c) {
    //             defaultVersion = ver.Version_Number__c;
    //         }
    //     }

    //     Double fetchedRate = SliderCalculatorController.getRate(1.0);
    //     System.assertEquals(rate, fetchedRate);

    //     Decimal fetchedDefault = SliderCalculatorController.getDefaultVersion();
    //     System.assertEquals(defaultVersion, fetchedDefault);
    // }

    // @isTest
    // static Void pricebookMethodTests() {
    //     //Query the 1.0 pricebook
    //     Pricebook2 pbWithVersion = [SELECT ID, Name FROM Pricebook2 WHERE Pricing_Version__c=1.0];
    //     Pricebook2 pbWithoutVersion = [SELECT ID, Name FROM Pricebook2 WHERE Pricing_Version__c=null LIMIT 1];

    //     System.assertEquals(true, SliderCalculatorController.pricebookIsVersioned(pbWithVersion.Id));
    //     System.assertEquals(false, SliderCalculatorController.pricebookIsVersioned(pbWithoutVersion.Id));

    //     Pricebook2 pbFetched = SliderCalculatorController.getPricebookWithEntries(1.0);
    //     System.assertEquals(pbWithVersion.Id, pbFetched.Id);

    // }

    // @isTest
    // static Void oppUpdateTests() {

    //     //Create an Opportunity
    //     Opportunity opp = AmericordTestDataFactory.createOpportunity('Test Flex Opp', 'New', true);

    //     SliderCalculatorController.updateOpportunity('20YPP', 6, 1000, 0, opp.Id);

    //     Opportunity updatedOpp = [SELECT ID, Pricing_Version__c, Payment_Plans__c FROM Opportunity WHERE ID=:opp.Id];

    //     Decimal defaultPricebookVersion = SliderCalculatorController.getDefaultVersion();
        
    //     //Validate the opportunity is now using the default pricebook
    //     System.assertEquals(defaultPricebookVersion, updatedOpp.Pricing_Version__c);

    //     //Now we'll close out the opportunity so that a CBO is generated
    //     opp.StageName = 'Enrolled';
    //     update opp;

    //     //Get the Labs and mark them as collected
    //     Lab__c lab = [SELECT ID FROM Lab__c WHERE Opportunity__c=:opp.Id];
    //     lab.Cord_Blood_Collection_Completed__c = true;
    //     update lab;

    //     //Update the invoice
    //     fw1__Invoice__c inv = [SELECT ID, Cord_Blood_2_0_Ordered__c, Cord_Tissue_Ordered__c, Placenta_2_0_Ordered__c, Storage_Plan_Ordered__c, Payment_Plan_Ordered__c FROM fw1__Invoice__c WHERE fw1__Opportunity__c=:opp.Id];

    //     System.debug('inv should have 6 month flex: '+inv);
    //     inv.Payment_Plan_Ordered__c = 'FLEX6';
    //     inv.Cord_Blood_2_0_Stored__c = inv.Cord_Blood_2_0_Ordered__c;
    //     inv.Cord_Tissue_Stored__c = inv.Cord_Tissue_Ordered__c;
    //     inv.Placenta_2_0_Stored__c = inv.Placenta_2_0_Ordered__c;
    //     inv.Storage_Plan_Stored__c = inv.Storage_Plan_Ordered__c;
    //     inv.Payment_Plan_Stored__c = inv.Payment_Plan_Ordered__c;
    //     update inv;

    //     inv.fw1__Auto_BillPay__c = true;
    //     update inv;

    // }

    // @isTest
    // static Void oppOTPTests() {

    //     //Create an Opportunity
    //     Opportunity opp = AmericordTestDataFactory.createOpportunity('Test Flex Opp', 'New', true);

    //     //Now do lifetime and OTP
    //     SliderCalculatorController.updateOpportunity('LTS', 0, 1000, 0, opp.Id);
    //     Opportunity updatedOppLifetime = [SELECT ID, Storage_Plan__c, Payment_Plans__c FROM Opportunity WHERE ID=:opp.Id];
    //     System.assertEquals('LTS', updatedOppLifetime.Storage_Plan__c);
    //     System.assertEquals('OTP', updatedOppLifetime.Payment_Plans__c);

    //     //Now we'll close out the opportunity so that a CBO is generated
    //     opp.StageName = 'Enrolled';
    //     update opp;

    // }

    // @isTest
    // static Void webGiftTest() {

    //     //Create an Opportunity
    //     Opportunity opp = AmericordTestDataFactory.createOpportunity('Test Flex Opp', 'New', false);

    //     //set it up as an incoming web gift
    //     opp.Ecomm_Status__c = 'Enrolled';
    //     opp.Pricing_Version__c = 1.0;
    //     opp.CloseDate = System.today();
    //     opp.Baby_s_Due_Date__c = System.today().addDays(1);

    //     insert opp;

    //     System.debug('web opp: '+opp);
        

    // }

}