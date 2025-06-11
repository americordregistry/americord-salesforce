@isTest
public class OrderBuilderTestFactory {
    
    
    public static void createProductSuite() {
        System.debug('createProductSuite: ');
        
        // Setup PriceBooks
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        System.debug('updated standardPricebook: '+standardPricebook.Id);

        Id standardPriceBookId = Test.getStandardPricebookId();
        System.debug('standardPriceBookId: '+standardPriceBookId);
        // Pricebook2 customPriceBook = new Pricebook2 (Name = 'Test PB', 
        //                                              Description = 'Test', 
        //                                              IsActive = true );
        // insert customPriceBook;
        // Id customPriceBookId = customPriceBook.Id;

        List < Product2 > productsToInsert = new List < Product2 > ();
        for (Integer i = 0; i < 10; i++) {
            Product2 product = Test_ProductFactory.start()
                .overrideName('Test Product ' + i)
                .asBiobanking()
                .asEligibleForVolumeDiscounting()
                .build();
            productsToInsert.add(product);

            Product2 storageProduct = Test_ProductFactory.start()
                .overrideName('Test Product ' + i + ' Storage')
                .asStorage()
                .build();
            productsToInsert.add(storageProduct);
        }

        //Specifically add CB 20 and CT20
        Product2 cbp = Test_ProductFactory.start()
            .overrideName('Cord Blood Processing')
            .asBiobanking()
            .asEligibleForVolumeDiscounting()
            .build();
        productsToInsert.add(cbp);

        Product2 cbStorage = Test_ProductFactory.start()
            .overrideName('Cord Blood 20yr Storage')
            .asStorage()
            .build();
        productsToInsert.add(cbStorage);

        Product2 ctp = Test_ProductFactory.start()
            .overrideName('Cord Tissue Processing')
            .asBiobanking()
            .asEligibleForVolumeDiscounting()
            .build();
        productsToInsert.add(ctp);

        Product2 ctStorage = Test_ProductFactory.start()
            .overrideName('Cord Tissue 20yr Storage')
            .asStorage()
            .build();
        productsToInsert.add(ctStorage);

        Product2 shippingProduct = Test_ProductFactory.start()
            .overrideName('Standard Shipping')
            .asShipping()
            .build();
        productsToInsert.add(shippingProduct);

        Product2 kitProduct = Test_ProductFactory.start()
            .asKit()
            .build();
        productsToInsert.add(kitProduct);

        Product2 dueAtCheckout = Test_ProductFactory.start()
            .asDueAtCheckout()
            .build();
        productsToInsert.add(dueAtCheckout);

        Product2 partialDueAtCheckout = Test_ProductFactory.start()
            .withPartialAmtDueAtCheckout(50)
            .build();
        productsToInsert.add(partialDueAtCheckout);

        Product2 interestFeeProduct12 = Test_ProductFactory.start()
            .asFee()
            .overrideName('Total Monthly Fees - 12M')
            .build();
        productsToInsert.add(interestFeeProduct12);

        Product2 interestFeeProduct24 = Test_ProductFactory.start()
            .asFee()
            .overrideName('Total Monthly Fees - 24M')
            .build();
        productsToInsert.add(interestFeeProduct24);
        
        Product2 interestFeeProduct36 = Test_ProductFactory.start()
            .asFee()
            .overrideName('Total Monthly Fees - 36M')
            .build();
        productsToInsert.add(interestFeeProduct36);

        Product2 interestFeeProduct48 = Test_ProductFactory.start()
            .asFee()
            .overrideName('Total Monthly Fees - 48M')
            .build();
        productsToInsert.add(interestFeeProduct48);

        insert productsToInsert;      
        
        //Pull out kit and shipping products with ids to create related product relationships
        Product2 kit;
        Product2 shipping;
        for (Product2 product: productsToInsert) {
            if (product.Family == 'Add-on') {
                kit = product;
            }
            if (product.Family == 'Shipping') {
                shipping = product;
            }
        }

        //add related required
        List <Product_Relationship__c> productRelationships = new List <Product_Relationship__c> ();
        for (Product2 product: productsToInsert) {
            if (product.Family == 'Product' && product.Is_Biobanking_Product__c == true) {
                Product_Relationship__c productRelationship = new Product_Relationship__c(
                    Primary_Product__c = product.Id,
                    Related_Product__c = kit.Id,
                    Relationship__c = 'Required Add-On'
                );
                productRelationships.add(productRelationship);

                Product_Relationship__c productRelationship2 = new Product_Relationship__c(
                    Primary_Product__c = product.Id,
                    Related_Product__c = shipping.Id,
                    Relationship__c = 'Required Add-On'
                );
                productRelationships.add(productRelationship2);
            }
        }
        insert productRelationships;


        // Create Pricebook Entries
        List < PricebookEntry > pricebookEntriesForInsert = new List < PricebookEntry > ();

        for (Product2 product: productsToInsert) {
            PricebookEntry standardPricebookEntry = new PricebookEntry(
                Pricebook2Id = standardPriceBookId,
                Product2Id = product.Id,
                UnitPrice = 100,
                IsActive = true
            );
            pricebookEntriesForInsert.add(standardPricebookEntry);
        }

        //Make one of the products order-builder visible on its own
        pricebookEntriesForInsert[0].Order_Builder_Visible__c = true;
        insert pricebookEntriesForInsert;
        System.debug('inserted pricebook entries: '+JSON.serialize(pricebookEntriesForInsert));

        // Create Bundles
        //Get a list of products to add to a Single Product bundle
        List < Product2 > productsForCBBundle = new List < Product2 > ();
        for (Product2 product: productsToInsert) {
            if (product.name == 'Cord Blood Processing' || product.name == 'Cord Blood 20yr Storage') {
                productsForCBBundle.add(product);
            }
        }

        Bundle__c singleProductBundle = Test_BundleFactory.start()
            .asSingleProduct()
            .createWithBundleMembers(productsForCBBundle, 150.0);

        //Get a list of products to add to a Multi Product bundle
        List < Product2 > productsForMultiBundle = new List < Product2 > ();
        for (Product2 product: productsToInsert) {
            if (product.name == 'Cord Blood Processing' || product.name == 'Cord Blood 20yr Storage' || product.name == 'Cord Tissue Processing' || product.name == 'Cord Tissue 20yr Storage') {
                productsForMultiBundle.add(product);
            }
        }

        Bundle__c multiProductBundle = Test_BundleFactory.start()
            .asMultiProduct()
            .createWithBundleMembers(productsForMultiBundle, 300.0);

        // create a Discount of type sales  
        List < Discount__c > discountsToInsert = new List < Discount__c > ();

        Discount__c wholeOrderAmountSales = Test_DiscountFactory.start()
            .amountBased(10.0)
            .asWholeOrder()
            .asSales()
            .build();
        discountsToInsert.add(wholeOrderAmountSales);

        Discount__c wholeOrderPercentageSales = Test_DiscountFactory.start()
            .percentageBased(.1)
            .asWholeOrder()
            .asSales()
            .build();
        discountsToInsert.add(wholeOrderPercentageSales);

        Discount__c wholeOrderAmountMarketing = Test_DiscountFactory.start()
            .amountBased(10.0)
            .asWholeOrder()
            .withCode('TestCode')
            .build();
        discountsToInsert.add(wholeOrderAmountMarketing);

        Discount__c wholeOrderPercentageMarketing = Test_DiscountFactory.start()
            .percentageBased(.1)
            .asWholeOrder()
            .withCode('TestCode')
            .build();
        discountsToInsert.add(wholeOrderPercentageMarketing);

        Discount__c productSpecificAmountSales = Test_DiscountFactory.start()
            .amountBased(10.0)
            .asProductSpecific(productsToInsert[0].Id)
            .build();
        discountsToInsert.add(productSpecificAmountSales);

        Discount__c productSpecificPercentageSales = Test_DiscountFactory.start()
            .percentageBased(.1)
            .asProductSpecific(productsToInsert[0].Id)
            .build();   
        discountsToInsert.add(productSpecificPercentageSales);

        Discount__c bundleSpecificAmountSales = Test_DiscountFactory.start()
            .amountBased(10.0)
            .asBundleSpecific(multiProductBundle.Id)
            .build();   
        discountsToInsert.add(bundleSpecificAmountSales);

        Discount__c bundleSpecificPercentageSales = Test_DiscountFactory.start()
            .percentageBased(.1)
            .asBundleSpecific(multiProductBundle.Id)
            .build();
        discountsToInsert.add(bundleSpecificPercentageSales);

        Discount__c multiBiobankingDiscount = Test_DiscountFactory.start()
            .amountBased(10.0)
            .asMultiBiobanking(2)
            .setApplicableStorageType('20YPP')
            .build();   
        discountsToInsert.add(multiBiobankingDiscount);

        insert discountsToInsert;

    }


}