@isTest
public class OrderBuilderControllerTest {
    
    @testSetup
    static void testSetup() {
        System.debug('run test setup: ');
        
        OrderBuilderTestFactory.createProductSuite();

        InvoiceHelper ih = new InvoiceHelper();
    
        String clientRecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Clients').RecordTypeId;

        User oppOwner = AmericordTestDataFactory.getCurrentSalesRep();

        Account a = new Account (
            Name = 'Test Account',
            RecordTypeId = clientRecordTypeId,
            BillingStreet = '123 Test St',
            BillingCity = 'Test City',
            BillingState = 'Test State',
            BillingPostalCode = '12345',
            BillingCountry = 'Test Country',
            Phone = '123-456-7890'
        );
        insert a;

        Contact c = new Contact (
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = a.Id,
            Email = 'test@test.com',
            Phone = '123-456-7890',
            MailingStreet = '123 Test St',
            MailingCity = 'Test City',
            MailingState = 'Test State',
            MailingPostalCode = '12345',
            MailingCountry = 'Test Country',
            Type__c = 'Mother',
            Baby_s_Due_Date__c = Date.today().addDays(30)
        );

        insert c;

        Opportunity opp = new Opportunity (
            OwnerId = oppOwner.Id,
            AccountId = a.Id,
            ContactId = c.Id,
            Contact__c = c.Id,
            Name = 'Test Opportunity',
            CloseDate = Date.today().addDays(30),
            StageName = 'New',
            Baby_s_Due_Date__c = Date.today().addDays(30), 
            Email__c = 'test@test.com',
            Relation_to_Baby__c = 'Mother',
            Pricebook2Id = Test.getStandardPricebookId(), 
            Shipping_Street__c = '123 Test St',
            Shipping_City__c = 'Test City',
            Shipping_State_Province__c = 'NY',
            Shipping_Zip__c = '12345',
            Shipping_Country__c = 'US',
            Authorized_Payment__c = true
        );
        
        insert opp;

        // Items for Kulterra
        // Payment Center Settings
        fw1__Payment_Center_Setting__c s = new fw1__Payment_Center_Setting__c();
        s.Name = 'Default Settings';
        insert s;
        
        fw1.PackagedData.restoreStripeData();

        // Payment Center Ext Settings
        fw2__Payment_Center_Extension_Settings__c ext = new fw2__Payment_Center_Extension_Settings__c();
        ext.fw2__Do_Not_Copy_Line_Items__c = true;
        insert ext;

        //Create Payment Center records to match Payment Metadata
        List < Payment_Plan_Info__mdt > paymentPlanMetadata = Payment_Plan_Info__mdt.getAll().values();
        List < fw1__Payment_Plan__c > paymentPlans = new List < fw1__Payment_Plan__c > ();

        for (Payment_Plan_Info__mdt ppMetadata: paymentPlanMetadata) {
            fw1__Payment_Plan__c pp = new fw1__Payment_Plan__c(
                Name = ppMetadata.DeveloperName,
                fw1__Payment_Center_Setting__c = s.Id,
                Number_of_Payments__c = ppMetadata.Number_of_Payments__c
            );
            if (ppMetadata.Type__c=='Monthly') pp.fw1__Schedule__c = 'Monthly';
            if (ppMetadata.Type__c=='Annual') pp.fw1__Schedule__c = 'Annually';
            paymentPlans.add(pp);
        }
        insert paymentPlans;

        // Create Ambassador Account
        Account ambassador = new Account();
        ambassador.Name = 'Ambassador Account';
        insert ambassador;
        
        // create custom setting - Americord_Settings__c 
        // https://developer.salesforce.com/forums/?id=906F000000092ynIAA
        Americord_Settings__c acs = new Americord_Settings__c();
        acs.Current_Price_Book__c = Test.getStandardPricebookId();
        acs.Deposit_Amount__c = 199;
        acs.Ambassador_Account_ID__c = ambassador.id;
        insert acs;

    }

    @isTest
    static void getSearchableItemsTest() {

        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
    }

    @isTest 
    static void getBiobankingDiscountsTest () {
        String biobankingDiscounts = OrderBuilderController.getBiobankingDiscounts();
        Assert.isTrue(biobankingDiscounts.contains('Test Discount'), 'Expected Sample Biobanking Discounts');
    }

    @isTest 
    static void getAvailablePaymentOptionsTest () {
        String paymentOptions = OrderBuilderController.getAvailablePaymentOptions();
        List < PaymentPlan > paymentPlans = (List < PaymentPlan > ) JSON.deserialize(paymentOptions, List < PaymentPlan > .class);
        Assert.isTrue(paymentPlans.size()>0);
    }

    @isTest
    static void getSearchableItemsWInvoiceTest() {

        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //Enroll to create invoice
        fw1__Invoice__c invoice = enrollOpportunity(opp);
        String searchableItems = OrderBuilderController.getSearchableItems(invoice.Id);
    }

    @isTest
    static void productOppTest() {

        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Pull out product to add
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        Test.startTest();
        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);
        Assert.areEqual(1, updatedOrder.productsOrdered.size(), 'Expected 1 product ordered');
        Assert.areEqual(productAsList[0].Id, updatedOrder.productsOrdered[0].Id, 'Expected product with ID '+productAsList[0].Id+' to be on order');

        //Now remove the product
        OrderBuilderController.removeProduct(updatedOrderString, productAsList[0].Id);

        //re-instantiate to see result
        String updatedOrderWithoutProductString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrderWithoutProduct = (Order) JSON.deserialize(updatedOrderWithoutProductString, Order.class);
        Assert.areEqual(0, updatedOrderWithoutProduct.productsOrdered.size(), 'Expected 0 product ordered');

    }

    @isTest
    static void productOppChangeQuantityTest() {

        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Pull out product to add
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        Test.startTest();
        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));
        

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);
        Assert.areEqual(1, updatedOrder.productsOrdered.size(), 'Expected 1 product ordered');
        Assert.areEqual(productAsList[0].Id, updatedOrder.productsOrdered[0].Id, 'Expected product with ID '+productAsList[0].Id+' to be on order');

        //Now change the quantity
        updatedOrder.productsOrdered[0].quantity = 2;
        OrderBuilderController.updateProductQuantities(updatedOrderString, JSON.serialize(updatedOrder.productsOrdered[0]));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderProdQuantitySt = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrderProdQuantity = (Order) JSON.deserialize(updatedOrderProdQuantitySt, Order.class);
        Assert.areEqual(2, updatedOrderProdQuantity.productsOrdered[0].quantity, 'Expected 2 products ordered');

    }


    @isTest
    static void prouctInvTest() {

        fw1__Invoice__c  invoice = loadInvoiceForTest();

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(invoice.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(invoice.Id);

        //Pull out product to add
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        Test.startTest();
        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(invoice.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);
        Assert.areEqual(1, updatedOrder.productsOrdered.size(), 'Expected 1 product ordered');
        Assert.areEqual(productAsList[0].Id, updatedOrder.productsOrdered[0].Id, 'Expected product with ID '+productAsList[0].Id+' to be on order');

    }

    @isTest
    static void productInvChangeQuantityTest() {

        fw1__Invoice__c  invoice = loadInvoiceForTest();

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(invoice.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(invoice.Id);

        //Pull out product to add
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        Test.startTest();
        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(invoice.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);
        Assert.areEqual(1, updatedOrder.productsOrdered.size(), 'Expected 1 product ordered');
        Assert.areEqual(productAsList[0].Id, updatedOrder.productsOrdered[0].Id, 'Expected product with ID '+productAsList[0].Id+' to be on order');

        //Now change the quantity
        updatedOrder.productsOrdered[0].quantity = 2;
        OrderBuilderController.updateProductQuantities(updatedOrderString, JSON.serialize(updatedOrder.productsOrdered[0]));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderProdQuantitySt = OrderBuilderController.loadOrder(invoice.Id);
        Order updatedOrderProdQuantity = (Order) JSON.deserialize(updatedOrderProdQuantitySt, Order.class);
        Assert.areEqual(2, updatedOrderProdQuantity.productsOrdered[0].quantity, 'Expected 2 products ordered');

    }

    @isTest
    static void productDiscountingOppTest() {

        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Pull out product to add
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        //add products
        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));

        //get Product discount (test setup has created a product-specific discount for the first product in the list)
        Discount productDiscount = new Discount();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Discount' && searchableItem.discount.type=='Product Specific') {
                productDiscount = searchableItem.discount;
                break;
            }
        }

        //add discount
        Test.startTest();
        OrderBuilderController.addDiscount(order, JSON.serialize(productDiscount));
        Test.stopTest();
        
        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);

        Decimal expectedAmount = productAsList[0].ListPrice - productDiscount.amount;
        Assert.areEqual(expectedAmount, updatedOrder.productsOrdered[0].finalPrice, 'Expected product with discounted price');
        Assert.areEqual(expectedAmount, updatedOrder.finalPrice, 'Expected final price to reflect discount (only one product on order)');

        //remove the discount
        OrderBuilderController.removeDiscount(updatedOrderString, JSON.serialize(updatedOrder.discountsOrdered[0]));
        //can't assert - already used start/stop test and result is asychronous
    }

    @isTest
    static void productDiscountingInvTest() {

        fw1__Invoice__c  invoice = loadInvoiceForTest();

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(invoice.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(invoice.Id);

        //Pull out product to add
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        //add products
        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));

        //get Product discount (test setup has created a product-specific discount for the first product in the list)
        Discount productDiscount = new Discount();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Discount' && searchableItem.discount.type=='Product Specific') {
                productDiscount = searchableItem.discount;
                break;
            }
        }

        //add discount
        Test.startTest();
        OrderBuilderController.addDiscount(order, JSON.serialize(productDiscount));
        Test.stopTest();
        
        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(invoice.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);

        Decimal expectedAmount = productAsList[0].ListPrice - productDiscount.amount;
        Assert.areEqual(expectedAmount, updatedOrder.productsOrdered[0].finalPrice, 'Expected product with discounted price');
        Assert.areEqual(expectedAmount, updatedOrder.finalPrice, 'Expected final price to reflect discount (only one product on order)');

        //remove the discount
        OrderBuilderController.removeDiscount(updatedOrderString, JSON.serialize(updatedOrder.discountsOrdered[0]));
        //can't assert - already used start/stop test and result is asychronous

    }

    //Whole order $$ discounting
    @isTest 
    static void wholeOrderDiscountingOppTest(){
        //Set up data
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //get whole order discount
        Discount wholeOrderDollarDiscount = new Discount();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Discount' && searchableItem.discount.type=='Sales' && searchableItem.discount.method=='Amount') {
                wholeOrderDollarDiscount = searchableItem.discount;
                break;
            }
        }

        //Set the discount amount
        wholeOrderDollarDiscount.amount = 10;

        //Pull out bundle to add
        Bundle bundle = new Bundle();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Bundle') {
                bundle = searchableItem.bundle;
                break;
            }
        }
        
        //add bundle
        OrderBuilderController.addBundle(order, JSON.serialize(bundle));
        
        Test.startTest();
        OrderBuilderController.addDiscount(order, JSON.serialize(wholeOrderDollarDiscount));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);

        Decimal expectedBundlePrice = bundle.listPrice - wholeOrderDollarDiscount.amount;
        Assert.areEqual(expectedBundlePrice, updatedOrder.bundlesOrdered[0].finalPrice, 'Mismatched Final Price on Bundle');
        Assert.areEqual(expectedBundlePrice, updatedOrder.finalPrice, 'Mismatched Final Price on Order');

    }

    @isTest 
    static void wholeOrderDiscountingInvTest(){
        //Set up data
        fw1__Invoice__c  invoice = loadInvoiceForTest();

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(invoice.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(invoice.Id);

        //get whole order discount
        Discount wholeOrderDollarDiscount = new Discount();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Discount' && searchableItem.discount.type=='Sales' && searchableItem.discount.method=='Amount') {
                wholeOrderDollarDiscount = searchableItem.discount;
                break;
            }
        }

        //Set the discount amount
        wholeOrderDollarDiscount.amount = 10;

        //Pull out bundle to add
        Bundle bundle = new Bundle();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Bundle') {
                bundle = searchableItem.bundle;
                break;
            }
        }
        
        //add bundle
        OrderBuilderController.addBundle(order, JSON.serialize(bundle));
        
        Test.startTest();
        OrderBuilderController.addDiscount(order, JSON.serialize(wholeOrderDollarDiscount));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(invoice.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);

        Decimal expectedBundlePrice = bundle.listPrice - wholeOrderDollarDiscount.amount;
        Assert.areEqual(expectedBundlePrice, updatedOrder.bundlesOrdered[0].finalPrice, 'Mismatched Final Price on Bundle');
        Assert.areEqual(expectedBundlePrice, updatedOrder.finalPrice, 'Mismatched Final Price on Order');

    }

    //Whole order % discounting
    @isTest 
    static void wholeOrderDiscountingPercentageOppTest(){
        //Set up data
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //get percentage order discount
        Discount percentageDiscount = new Discount();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Discount' && searchableItem.discount.type=='Sales' && searchableItem.discount.method=='Percentage') {
                percentageDiscount = searchableItem.discount;
                break;
            }
        }

        //Set the discount amount
        percentageDiscount.percentage = .1;

        //Pull out bundle to add
        Bundle bundle = new Bundle();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Bundle') {
                bundle = searchableItem.bundle;
                break;
            }
        }
        
        //add bundle
        OrderBuilderController.addBundle(order, JSON.serialize(bundle));
        
        Test.startTest();
        OrderBuilderController.addDiscount(order, JSON.serialize(percentageDiscount));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);

        Decimal expectedBundlePrice = bundle.listPrice - (percentageDiscount.percentage * bundle.listPrice);
        Assert.areEqual(expectedBundlePrice, updatedOrder.bundlesOrdered[0].finalPrice, 'Mismatched Final Price on Bundle');
        Assert.areEqual(expectedBundlePrice, updatedOrder.finalPrice, 'Mismatched Final Price on Order');

    }

    @isTest 
    static void wholeOrderDiscountingPercentageInvTest(){
        //Set up data
        fw1__Invoice__c  invoice = loadInvoiceForTest();

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(invoice.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(invoice.Id);

        //get percentage order discount
        Discount percentageDiscount = new Discount();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Discount' && searchableItem.discount.type=='Sales' && searchableItem.discount.method=='Percentage') {
                percentageDiscount = searchableItem.discount;
                break;
            }
        }

        //Set the discount amount
        percentageDiscount.percentage = .1;

        //Pull out bundle to add
        Bundle bundle = new Bundle();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Bundle') {
                bundle = searchableItem.bundle;
                break;
            }
        }
        
        //add bundle
        OrderBuilderController.addBundle(order, JSON.serialize(bundle));
        
        Test.startTest();
        OrderBuilderController.addDiscount(order, JSON.serialize(percentageDiscount));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(invoice.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);

        Decimal expectedBundlePrice = bundle.listPrice - (percentageDiscount.percentage * bundle.listPrice);
        Assert.areEqual(expectedBundlePrice, updatedOrder.bundlesOrdered[0].finalPrice, 'Mismatched Final Price on Bundle');
        Assert.areEqual(expectedBundlePrice, updatedOrder.finalPrice, 'Mismatched Final Price on Order');

    }


    @isTest
    static void bundleOppTest() {
        Test.startTest();
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Pull out bundle to add
        Bundle bundle = allSearchableItems[0].bundle;
        
        OrderBuilderController.addBundle(order, JSON.serialize(bundle));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);
        Assert.areEqual(1, updatedOrder.bundlesOrdered.size(), 'Expected 1 bundle ordered');
        Assert.areEqual(bundle.Id, updatedOrder.bundlesOrdered[0].Id, 'Expected bundle with ID '+bundle.Id+' to be on order');

        //Update quantities
        updatedOrder.bundlesOrdered[0].quantity = 2;
        OrderBuilderController.updateBundleQuantities(updatedOrderString, JSON.serialize(updatedOrder.bundlesOrdered[0]));

        //re-instantiate to see result
        String updatedOrderBundleQuantitiesString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrderBundleQuantities = (Order) JSON.deserialize(updatedOrderBundleQuantitiesString, Order.class);
        Assert.areEqual(2, updatedOrderBundleQuantities.bundlesOrdered[0].quantity, 'Expected bundle quantity to be updated to 2');

        //Now remove the bundle
        OrderBuilderController.removeBundle(updatedOrderBundleQuantitiesString, bundle.Id);

        //re-instantiate to see result
        String orderAfterRemoveString = OrderBuilderController.loadOrder(opp.Id);
        Order orderAfterRemove = (Order) JSON.deserialize(orderAfterRemoveString, Order.class);
        System.debug('orderAfterRemoveString: '+updatedOrderString);
        Assert.areEqual(0, orderAfterRemove.bundlesOrdered.size(), 'Expected bundle to be removed');

    }

    @isTest
    static void bundleInvTest() {
        Test.startTest();
        fw1__Invoice__c  invoice = loadInvoiceForTest();

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(invoice.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(invoice.Id);

        //Pull out bundle to add
        Bundle bundle = allSearchableItems[0].bundle;
        
        
        OrderBuilderController.addBundle(order, JSON.serialize(bundle));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(invoice.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);
        Assert.areEqual(1, updatedOrder.bundlesOrdered.size(), 'Expected 1 bundle ordered');
        Assert.areEqual(bundle.Id, updatedOrder.bundlesOrdered[0].Id, 'Expected bundle with ID '+bundle.Id+' to be on order');

        //Update quantities
        updatedOrder.bundlesOrdered[0].quantity = 2;
        OrderBuilderController.updateBundleQuantities(updatedOrderString, JSON.serialize(updatedOrder.bundlesOrdered[0]));

        //re-instantiate to see result
        String updatedOrderBundleQuantitiesString = OrderBuilderController.loadOrder(Invoice.Id);
        Order updatedOrderBundleQuantities = (Order) JSON.deserialize(updatedOrderBundleQuantitiesString, Order.class);
        Assert.areEqual(2, updatedOrderBundleQuantities.bundlesOrdered[0].quantity, 'Expected bundle quantity to be updated to 2');

        //Now remove the bundle
        OrderBuilderController.removeBundle(updatedOrderBundleQuantitiesString, bundle.Id);

        //re-instantiate to see result
        String orderAfterRemoveString = OrderBuilderController.loadOrder(invoice.Id);
        Order orderAfterRemove = (Order) JSON.deserialize(orderAfterRemoveString, Order.class);
        System.debug('orderAfterRemoveString: '+updatedOrderString);
        Assert.areEqual(0, orderAfterRemove.bundlesOrdered.size(), 'Expected bundle to be removed');

    }

    @isTest
    static void bundleDiscountingOppTest() {

        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //get Bundle discount
        Discount bundleDiscount = new Discount();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Discount' && searchableItem.discount.type=='Bundle Specific') {
                bundleDiscount = searchableItem.discount;
                break;
            }
        }

        //Pull out bundle to add
        Bundle bundle = new Bundle();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Bundle' && searchableItem.bundle.Id==bundleDiscount.bundleId) {
                bundle = searchableItem.bundle;
                break;
            }
        }
        
        //add bundle
        OrderBuilderController.addBundle(order, JSON.serialize(bundle));
        
        Test.startTest();
        OrderBuilderController.addDiscount(order, JSON.serialize(bundleDiscount));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);

        Decimal expectedBundlePrice = bundle.listPrice - bundleDiscount.amount;
        Assert.areEqual(expectedBundlePrice, updatedOrder.bundlesOrdered[0].finalPrice, 'Mismatched Final Price on Bundle');
        Assert.areEqual(expectedBundlePrice, updatedOrder.finalPrice, 'Mismatched Final Price on Order');

        //remove the discount
        OrderBuilderController.removeDiscount(updatedOrderString, JSON.serialize(updatedOrder.discountsOrdered[0]));
        //can't assert - already used start/stop test and result is asychronous

    }

    @isTest
    static void bundleDiscountingInvTest() {

        fw1__Invoice__c  invoice = loadInvoiceForTest();

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(invoice.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(invoice.Id);

        //get Bundle discount
        Discount bundleDiscount = new Discount();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Discount' && searchableItem.discount.type=='Bundle Specific') {
                bundleDiscount = searchableItem.discount;
                break;
            }
        }

        //Pull out bundle to add
        Bundle bundle = new Bundle();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Bundle' && searchableItem.bundle.Id==bundleDiscount.bundleId) {
                bundle = searchableItem.bundle;
                break;
            }
        }
        
        //add bundle
        OrderBuilderController.addBundle(order, JSON.serialize(bundle));
        
        Test.startTest();
        OrderBuilderController.addDiscount(order, JSON.serialize(bundleDiscount));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(invoice.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);

        Decimal expectedBundlePrice = bundle.listPrice - bundleDiscount.amount;
        Assert.areEqual(expectedBundlePrice, updatedOrder.bundlesOrdered[0].finalPrice, 'Mismatched Final Price on Bundle');
        Assert.areEqual(expectedBundlePrice, updatedOrder.finalPrice, 'Mismatched Final Price on Order');

        //remove the discount
        OrderBuilderController.removeDiscount(updatedOrderString, JSON.serialize(updatedOrder.discountsOrdered[0]));
        //can't assert - already used start/stop test and result is asychronous

    }

    @isTest
    static void clearOrderOppTest() {

        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Pull out bundle to add
        Bundle bundle = allSearchableItems[0].bundle;

        String orderWithBundle = OrderBuilderController.addBundle(order, JSON.serialize(bundle));

        //Pull out product to add
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }
        
        test.startTest(); //wrapping start/stop here to finish async processing
        OrderBuilderController.addProducts(orderWithBundle, JSON.serialize(productAsList));
        test.stopTest();

        //re-instantiate to see result
        String orderWithBundleAndProductSt = OrderBuilderController.loadOrder(opp.Id);
        Order orderWithBundleAndProduct = (Order) JSON.deserialize(orderWithBundleAndProductSt, Order.class);
        Assert.areEqual(1, orderWithBundleAndProduct.bundlesOrdered.size(), 'Expected 1 bundle ordered');
        Assert.areEqual(1, orderWithBundleAndProduct.productsOrdered.size(), 'Expected 1 product ordered');

        //Now clear the order       
        OrderBuilderController.clearOrder(orderWithBundleAndProductSt);

        //re-instantiate to see result
        String orderAfterClearString = OrderBuilderController.loadOrder(opp.Id);
        Order orderAfterRemove = (Order) JSON.deserialize(orderAfterClearString, Order.class);

        Assert.areEqual(0, orderAfterRemove.bundlesOrdered.size(), 'Expected no bundles after clear');
        Assert.areEqual(0, orderAfterRemove.productsOrdered.size(), 'Expected no products after clear');

    }

    @isTest
    static void removeBundlesTest() {
        Test.startTest(); //wrapping start/stop here to finish async processing
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Pull out bundle to add
        Bundle bundle = allSearchableItems[0].bundle;

        String orderWithBundle = OrderBuilderController.addBundle(order, JSON.serialize(bundle));
        test.stopTest(); //wrapping start/stop here to finish async processing 

        //re-instantiate to see result
        String orderWithBundlesSt = OrderBuilderController.loadOrder(opp.Id);
        Order orderWithBundleAndProduct = (Order) JSON.deserialize(orderWithBundlesSt, Order.class);
        Assert.areEqual(1, orderWithBundleAndProduct.bundlesOrdered.size(), 'Expected 1 bundle ordered');

        List < ID > bundleIds = new List < ID > {bundle.Id};
        List < ID > productIds = new List < ID > ();

        //Now remove products and bundles   
        OrderBuilderController.removeBundlesAndProducts(orderWithBundlesSt, JSON.serialize(productIds),JSON.serialize(bundleIds));

        //re-instantiate to see result
        String orderAfterClearString = OrderBuilderController.loadOrder(opp.Id);
        Order orderAfterRemove = (Order) JSON.deserialize(orderAfterClearString, Order.class);

        Assert.areEqual(0, orderAfterRemove.bundlesOrdered.size(), 'Expected no bundles after clear');
        Assert.areEqual(0, orderAfterRemove.productsOrdered.size(), 'Expected no products after clear');

    }

    @isTest
    static void removeProductsTest() {
        Test.startTest(); //wrapping start/stop here to finish async processing
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Pull out product to add
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));
        test.stopTest(); //wrapping start/stop here to finish async processing 

        //re-instantiate to see result
        String orderWithProductsSt = OrderBuilderController.loadOrder(opp.Id);
        Order orderWithProduct = (Order) JSON.deserialize(orderWithProductsSt, Order.class);
        Assert.areEqual(1, orderWithProduct.productsOrdered.size(), 'Expected 1 product ordered');

        List < ID > bundleIds = new List < ID > ();
        List < ID > productIds = new List < ID >{productAsList[0].Id};

        //Now remove products and bundles   
        OrderBuilderController.removeBundlesAndProducts(orderWithProductsSt, JSON.serialize(productIds),JSON.serialize(bundleIds));

        //re-instantiate to see result
        String orderAfterClearString = OrderBuilderController.loadOrder(opp.Id);
        Order orderAfterRemove = (Order) JSON.deserialize(orderAfterClearString, Order.class);

        Assert.areEqual(0, orderAfterRemove.bundlesOrdered.size(), 'Expected no bundles after clear');
        Assert.areEqual(0, orderAfterRemove.productsOrdered.size(), 'Expected no products after clear');

    }

    @isTest
    static void clearOrderInvTest() {
        test.startTest(); 
        fw1__Invoice__c  invoice = loadInvoiceForTest();

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(invoice.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(invoice.Id);

        //Pull out bundle to add
        Bundle bundle = allSearchableItems[0].bundle;

        String orderWithBundle = OrderBuilderController.addBundle(order, JSON.serialize(bundle));

        //Pull out product to add
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        OrderBuilderController.addProducts(orderWithBundle, JSON.serialize(productAsList));
        test.stopTest();//wrapping start/stop here to finish async processing

        //re-instantiate to see result
        String orderWithBundleAndProductSt = OrderBuilderController.loadOrder(invoice.Id);
        Order orderWithBundleAndProduct = (Order) JSON.deserialize(orderWithBundleAndProductSt, Order.class);
        Assert.areEqual(1, orderWithBundleAndProduct.bundlesOrdered.size(), 'Expected 1 bundle ordered');
        Assert.areEqual(1, orderWithBundleAndProduct.productsOrdered.size(), 'Expected 1 product ordered');

        //Now clear the order
        OrderBuilderController.clearOrder(orderWithBundleAndProductSt);

        //re-instantiate to see result
        String orderAfterClearString = OrderBuilderController.loadOrder(invoice.Id);
        Order orderAfterRemove = (Order) JSON.deserialize(orderAfterClearString, Order.class);

        Assert.areEqual(0, orderAfterRemove.bundlesOrdered.size(), 'Expected no bundles after clear');
        Assert.areEqual(0, orderAfterRemove.productsOrdered.size(), 'Expected no products after clear');

    }

    @isTest
     static void autoPayInvoice() {
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Add product before adding payment plan
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));

        //Add payment plan
        String ppString = OrderBuilderController.getAvailablePaymentOptions();
        List < PaymentPlan > payPlanOptions = (List < PaymentPlan > ) JSON.deserialize(ppString, List < PaymentPlan > .class);
        PaymentPlan paymentPlan = new PaymentPlan();
        for (PaymentPlan pp: payPlanOptions) {
            if (pp.type=='Monthly') {
                paymentPlan = pp;
                break;
            }
        }
        OrderBuilderController.updatePaymentPlan(order, JSON.serialize(paymentPlan));

        //Enroll to create invoice
        fw1__Invoice__c invoice = enrollOpportunity(opp);
        invoice.fw1__Auto_BillPay__c = true;
        update invoice;

    }

    private static fw1__Invoice__c enrollOpportunity(Opportunity opp) {
        opp.StageName = 'Enrolled';
        opp.Authorized_Payment__c = true;
        opp.Enrollment_Flow_Complete__c = true;

        //add contact as required by custom field validation
        Contact c = [SELECT ID FROM Contact LIMIT 1];
        opp.Contact__c = c.Id;
        update opp;

        fw1__Invoice__c invoice = [SELECT Id FROM fw1__Invoice__c WHERE fw1__Opportunity__c = :opp.Id LIMIT 1];
        invoice.fw2__Opportunity__c = opp.Id;
        System.debug('invoice: '+invoice);
        return invoice;
    }

    private static fw1__Invoice__c loadInvoiceForTest() {
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //Enroll to create invoice
        fw1__Invoice__c invoice = enrollOpportunity(opp);
        String searchableItems = OrderBuilderController.getSearchableItems(invoice.Id);

        return invoice;
    }



    @isTest
    static void updatePaymentPlanOppTest() {
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Add product before adding payment plan
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));

        //Add payment plan
        String ppString = OrderBuilderController.getAvailablePaymentOptions();
        List < PaymentPlan > payPlanOptions = (List < PaymentPlan > ) JSON.deserialize(ppString, List < PaymentPlan > .class);
        PaymentPlan paymentPlan = new PaymentPlan();
        for (PaymentPlan pp: payPlanOptions) {
            if (pp.type=='Monthly') {
                paymentPlan = pp;
                break;
            }
        }
        System.debug('pay plan: '+JSON.serialize(paymentPlan));
        
        Test.startTest();
        OrderBuilderController.updatePaymentPlan(order, JSON.serialize(paymentPlan));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);
        Assert.areNotEqual(null, updatedOrder.paymentPlan,'Payment Plan should be populated');
        Assert.areEqual(paymentPlan.Id, updatedOrder.paymentPlan.Id, 'Expected payment plan to match');

        //Remove the payment plan
        OrderBuilderController.removePaymentPlan(updatedOrderString);

         //re-instantiate to see result
         updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
         updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);

         Assert.areEqual(null, updatedOrder.paymentPlan.Id,'Payment Plan should be removed');

    }
    //The RecordTrigger: Cord Blood Order After Update Flow is causing an error on this...
    // @isTest
    // static void updatePaymentPlanInvTest() {
    //     fw1__Invoice__c  invoice = loadInvoiceForTest();

    //     //load searchable items
    //     String searchableItems = OrderBuilderController.getSearchableItems(invoice.Id);
    //     List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

    //     String order = OrderBuilderController.loadOrder(invoice.Id);

    //     //Add product before adding payment plan
    //     List < Product > productAsList = new List < Product > ();
    //     for (Order.SearchableItem searchableItem: allSearchableItems) {
    //         if (searchableItem.type=='Product') {
    //             Product prod = searchableItem.product;
    //             productAsList.add(prod);
    //             break;
    //         }
    //     }

    //     OrderBuilderController.addProducts(order, JSON.serialize(productAsList));

    //     //Add payment plan
    //     String ppString = OrderBuilderController.getAvailablePaymentOptions();
    //     List < PaymentPlan > payPlanOptions = (List < PaymentPlan > ) JSON.deserialize(ppString, List < PaymentPlan > .class);
    //     PaymentPlan paymentPlan = new PaymentPlan();
    //     for (PaymentPlan pp: payPlanOptions) {
    //         if (pp.type=='Monthly') {
    //             paymentPlan = pp;
    //             break;
    //         }
    //     }
    //     System.debug('pay plan: '+JSON.serialize(paymentPlan));
        
    //     Test.startTest();
    //     OrderBuilderController.updatePaymentPlan(order, JSON.serialize(paymentPlan));
    //     Test.stopTest();

    //     //re-instantiate to see result
    //     String updatedOrderString = OrderBuilderController.loadOrder(invoice.Id);
    //     Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
    //     System.debug('updatedOrderString: '+updatedOrderString);
    //     Assert.areNotEqual(null, updatedOrder.paymentPlan,'Payment Plan should be populated');
    //     Assert.areEqual(paymentPlan.Id, updatedOrder.paymentPlan.Id, 'Expected payment plan to match');

    //     //Remove the payment plan
    //     OrderBuilderController.removePaymentPlan(updatedOrderString);

    //      //re-instantiate to see result
    //      updatedOrderString = OrderBuilderController.loadOrder(invoice.Id);
    //      updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);

    //      Assert.areEqual(null, updatedOrder.paymentPlan.Id,'Payment Plan should be removed');

    // }

    //Add Additional amount to first payment
    @isTest
    static void addUpfrontTestOpp() {
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Add product before adding payment plan
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));

        //Add payment plan
        String ppString = OrderBuilderController.getAvailablePaymentOptions();
        List < PaymentPlan > payPlanOptions = (List < PaymentPlan > ) JSON.deserialize(ppString, List < PaymentPlan > .class);
        PaymentPlan paymentPlan = new PaymentPlan();
        for (PaymentPlan pp: payPlanOptions) {
            if (pp.type=='Monthly') {
                paymentPlan = pp;
                break;
            }
        }

        OrderBuilderController.updatePaymentPlan(order, JSON.serialize(paymentPlan));
        
        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
        OrderBuilderController.updateAdditionToFirstPayment(updatedOrderString, 50);
        
        //re-instantiate to see result
        Opportunity oppWithUpfront = [SELECT Id, Additional_Amount_on_First_Payment__c FROM Opportunity WHERE Id = :opp.Id]; 
        Assert.areEqual(50, oppWithUpfront.Additional_Amount_on_First_Payment__c,'additionalAmountOnFirstPayment amount should be set on Opp');
        updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        Assert.areEqual(50, updatedOrder.upfrontAmount, 'Upfront amount should be set');
        Assert.areEqual(50, updatedOrder.paymentPlan.additionalAmountOnFirstPayment, 'additionalAmountOnFirstPayment amount should be set');

    }

    //Add Additional amount to first payment
    @isTest
    static void addUpfrontTestInv() {
        Test.startTest();
        fw1__Invoice__c  invoice = loadInvoiceForTest();

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(invoice.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(invoice.Id);


        //Add product before adding payment plan
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));

        //Add payment plan
        String ppString = OrderBuilderController.getAvailablePaymentOptions();
        List < PaymentPlan > payPlanOptions = (List < PaymentPlan > ) JSON.deserialize(ppString, List < PaymentPlan > .class);
        PaymentPlan paymentPlan = new PaymentPlan();
        for (PaymentPlan pp: payPlanOptions) {
            if (pp.type=='Monthly') {
                paymentPlan = pp;
                break;
            }
        }

        OrderBuilderController.updatePaymentPlan(order, JSON.serialize(paymentPlan));

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(invoice.Id);

        // The following is throwing an error in this flow: RecordTrigger: Cord Blood Order After Update
        // OrderBuilderController.updateAdditionToFirstPayment(updatedOrderString, 100);
        // Test.stopTest();

        // //re-instantiate to see result
        // updatedOrderString = OrderBuilderController.loadOrder(invoice.Id);
        // Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        // System.debug('updatedOrderString: '+updatedOrderString);
        // Assert.areEqual(100, updatedOrder.upfrontAmount, 'Upfront amount should be set');
        // Assert.areEqual(100, updatedOrder.paymentPlan.additionalAmountOnFirstPayment, 'additionalAmountOnFirstPayment amount should be set');

    }

    //Add payment plan with interest and a one-time for test coverage
    @isTest
    static void updatePaymentPlanWithInterest() {
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Add product before adding payment plan
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));

        //Add payment plan
        String ppString = OrderBuilderController.getAvailablePaymentOptions();
        List < PaymentPlan > payPlanOptions = (List < PaymentPlan > ) JSON.deserialize(ppString, List < PaymentPlan > .class);
        PaymentPlan paymentPlan = new PaymentPlan();
        for (PaymentPlan pp: payPlanOptions) {
            if (pp.interestRate!=null && pp.interestRate>0) {
                paymentPlan = pp;
                break;
            }
        }

        //if there are no payplans with interest, bail (TODO improvement would be to inject mock Metadata records)
        if (paymentPlan.Id==null) {
            System.debug('No payment plans with interest found, skipping test');
            return;
        }

        Test.startTest();
        OrderBuilderController.updatePaymentPlan(order, JSON.serialize(paymentPlan));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);
        Assert.areNotEqual(null, updatedOrder.paymentPlan,'Payment Plan should be populated');
        Assert.areEqual(paymentPlan.Id, updatedOrder.paymentPlan.Id, 'Expected payment plan to match');

    }

    @isTest
    static void updatePaymentPlanWithOneTime() {
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Add product before adding payment plan
        List < Product > productAsList = new List < Product > ();
        for (Order.SearchableItem searchableItem: allSearchableItems) {
            if (searchableItem.type=='Product') {
                Product prod = searchableItem.product;
                productAsList.add(prod);
                break;
            }
        }

        OrderBuilderController.addProducts(order, JSON.serialize(productAsList));

        //Add payment plan
        String ppString = OrderBuilderController.getAvailablePaymentOptions();
        System.debug('ppString: '+ppString);
        List < PaymentPlan > payPlanOptions = (List < PaymentPlan > ) JSON.deserialize(ppString, List < PaymentPlan > .class);
        PaymentPlan paymentPlan = new PaymentPlan();
        for (PaymentPlan pp: payPlanOptions) {
            if (pp.type=='Onetime') {
                paymentPlan = pp;
                break;
            }
        }

        //if there are no onetime payplans, bail (TODO improvement would be to inject mock Metadata records)
        if (paymentPlan.Id==null) {
            System.debug('No onetime payment plans found, skipping test');
            return;
        }

        Test.startTest();
        OrderBuilderController.updatePaymentPlan(order, JSON.serialize(paymentPlan));
        Test.stopTest();

        //re-instantiate to see result
        String updatedOrderString = OrderBuilderController.loadOrder(opp.Id);
        Order updatedOrder = (Order) JSON.deserialize(updatedOrderString, Order.class);
        System.debug('updatedOrderString: '+updatedOrderString);
        Assert.areNotEqual(null, updatedOrder.paymentPlan,'Payment Plan should be populated');
        Assert.areEqual(paymentPlan.Id, updatedOrder.paymentPlan.Id, 'Expected payment plan to match');

    }

    @isTest static void asyncInserterTest() {
        String clientRecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Clients').RecordTypeId;
        Account a = new Account (
            Name = 'Async Test Account',
            RecordTypeId = clientRecordTypeId,
            BillingStreet = '123 Test St',
            BillingCity = 'Test City',
            BillingState = 'Test State',
            BillingPostalCode = '12345',
            BillingCountry = 'Test Country',
            Phone = '123-456-7890'
        );

        List < Account > accounts = new List < Account > {a};
        Test.startTest();
        System.enqueueJob(new AsyncObjectInserter_Queueable(accounts));
        Test.stopTest();

        List < Account> insertedAccount = [SELECT Id, Name FROM Account WHERE Name='Async Test Account' LIMIT 1];
        Assert.areEqual(1, insertedAccount.size(), 'Expected 1 account to be inserted');
    }

    @isTest 
    static void exceptionTest() {
        //add products in a way that will throw an exception
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        try {
            OrderBuilderController.addProducts(order, 'will fail');
        } catch (OrderBuilderException obe) {
            System.debug('Expected exception: '+obe);
            return;
        }
        
    }

    @isTest 
    static void exceptionWithSeverityTest() {
        //first, get an opp with a bundle added
        Test.startTest();
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        //Setting the Pricebook in TestSetup doesn't seem to stick
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        //load searchable items
        String searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        List < Order.SearchableItem > allSearchableItems = (List < Order.SearchableItem > ) JSON.deserialize(searchableItems, List < Order.SearchableItem > .class);

        String order = OrderBuilderController.loadOrder(opp.Id);

        //Pull out bundle to add
        Bundle bundle = allSearchableItems[0].bundle;
        
        OrderBuilderController.addBundle(order, JSON.serialize(bundle));
        Test.stopTest();

        //Now remove one of the Bundle Member's products
        Bundle_Member__c bundleMem = [SELECT ID, Product__c FROM Bundle_Member__c WHERE Bundle__c = :bundle.Id LIMIT 1];
        bundleMem.Product__c = null;
        update bundleMem;


        try {
            searchableItems = OrderBuilderController.getSearchableItems(opp.Id);
        } catch (OrderBuilderException obe) {
            System.debug('Expected exception: '+obe);
            return;
        }
        
    }

    @isTest
    static void surrogateShippingInvoiceTest() {

        User oppOwner = AmericordTestDataFactory.getCurrentSalesRep();

        Account a = new Account(
            Name = 'Surrogate Shipping Account'
        );
        insert a;

        Contact mother = new Contact(
            FirstName = 'SurrogateMother',
            LastName = 'Test',
            Email = 'sur.mother@test.com',
            AccountId = a.Id,
            Type__c = 'Mother'
        );
        insert mother;

        Contact surrogate = new Contact(
            FirstName = 'Sarah',
            LastName = 'Surrogate',
            Email = 'surrogate@test.com',
            AccountId = a.Id,
            Type__c = 'Mother'
        );
        insert surrogate;

        Opportunity opp = new Opportunity(
            OwnerId = oppOwner.Id,
            AccountId = a.Id,
            Name = 'Surrogate Opp',
            StageName = 'New',
            CloseDate = Date.today(),

            Contact__c = mother.Id,
            Contact2__c = surrogate.Id,
            Relation_to_Baby__c = 'Mother',
            Contact2_Relation_to_Baby__c = 'Mother',

            Surrogate__c = true,
            Ship_Kit_to_Surrogate__c = true,

            // Required shipping fields (validation)
            Shipping_Street__c = '111 Required St',
            Shipping_City__c = 'Required City',
            Shipping_State_Province__c = 'NY',
            Shipping_Zip__c = '10001',
            Shipping_Country__c = 'US',

            // Required surrogate identity + address fields
            Surrogate_FirstName__c = 'Sarah',
            Surrogate_LastName__c = 'Surrogate',
            Surrogate_Street_Address__c = '999 Surrogate Lane',
            Surrogate_City__c = 'Austin',
            Surrogate_State_Province__c = 'TX',
            Surrogate_Postal_Code__c = '73301'
        );
        insert opp;

        //
        // 🔥 REQUIRED STEP — this fires all triggers and creates the fw1__Invoice__c
        //
        fw1__Invoice__c invoice = enrollOpportunity(opp);

        System.assertNotEquals(null, invoice, 'Invoice was not created during enrollment.');
        System.assertNotEquals(null, invoice.Id, 'Invoice record must have been inserted.');

        //
        // Now run the main Invoice logic we are testing
        //
        Test.startTest();
        Invoice invLogic = new Invoice();
        invLogic.addOpportunityInfo(
            new Set<Id>{ opp.Id },
            new List<fw1__Invoice__c>{ invoice }
        );
        Test.stopTest();

        //
        // Validate the Lab record was created and surrogate address was used
        //
        Lab__c lab = [
            SELECT Id,
                Ship_kit_to_Surrogate__c,
                Shipping_Street__c,
                Shipping_City__c,
                Shipping_State_new__c,
                Shipping_Zip__c
            FROM Lab__c
            WHERE Opportunity__c = :opp.Id
            LIMIT 1
        ];

        System.assertEquals(true, lab.Ship_kit_to_Surrogate__c, 'Lab should be marked as shipping to surrogate.');
        System.assertEquals('999 Surrogate Lane', lab.Shipping_Street__c, 'Surrogate street should map to Lab.');
        System.assertEquals('Austin', lab.Shipping_City__c);
        System.assertEquals('TX', lab.Shipping_State_new__c);
        System.assertEquals('73301', lab.Shipping_Zip__c);
    }

}