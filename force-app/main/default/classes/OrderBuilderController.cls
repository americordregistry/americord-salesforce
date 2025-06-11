public with sharing class OrderBuilderController {

    @AuraEnabled(cacheable = true)
    public static string getSearchableItems(Id recordId){
        try {

            ID pricebookId;
            System.debug('recordId.getsobjecttype(): '+recordId.getsobjecttype());
            if (recordId.getsobjecttype()==Schema.Opportunity.getSObjectType()) {
                Opportunity opp = [SELECT ID, Pricebook2Id FROM Opportunity WHERE ID=:recordId];
                pricebookId = opp.Pricebook2Id;
                System.debug('pricebookId: '+pricebookId);
                System.debug('opp: '+JSON.serialize(opp));
            } else if (recordId.getsobjecttype()==Schema.fw1__Invoice__c.getSObjectType()) {
                fw1__Invoice__c invoice = [SELECT ID, Price_Book__c FROM fw1__Invoice__c WHERE ID=:recordId];
                pricebookId = invoice.Price_Book__c;
            }

            //Get bundle pricebook entries
            List < Bundle_Pricebook_Entry__c > bundlePricebookEntries = [SELECT ID, Bundle__c, Price_Book__c, List_Price__c FROM Bundle_Pricebook_Entry__c WHERE Order_Builder_Visible__c=true AND Price_Book__c=:pricebookId];

            System.debug('bpe query pb: '+pricebookId);

            System.debug('bundlePricebookEntries: '+bundlePricebookEntries);

            List < ID > bundleIds = new List < ID >();
            for (Bundle_Pricebook_Entry__c bpbe: bundlePricebookEntries) {
                bundleIds.add(bpbe.Bundle__c);
            }

            // Get bundles and bundle members 
            Map < ID, Bundle__c > availBundlesMap = new Map < ID, Bundle__c >([SELECT ID, Name, Description__c, Valid_From_Date__c, Valid_To_Date__c, Type__c, Storage_Type__c, (SELECT ID, Name, Bundle__c, Quantity__c, Product__c, Product__r.Name, Product__r.Exempt_From_Discounts__c, Product__r.Description, Product__r.Partial_Amount_Due_At_Checkout__c, Product__r.Due_at_Checkout__c, Product__r.Family, Product__r.Is_Biobanking_Product__c, Product__r.Eligible_for_Volume_Discounting__c,Product__r.ProductCode FROM Bundle_Members__r) FROM Bundle__c WHERE ID in:bundleIds]);

            System.debug('availBundlesMap: '+availBundlesMap);

            
            // Get PricebookEntries/Products
            List < PricebookEntry > availProducts = [SELECT ID, Product2Id, UnitPrice, Product2.Name, Product2.IsActive, Product2.Exempt_From_Discounts__c, Product2.Description, Product2.Partial_Amount_Due_At_Checkout__c, Product2.Due_at_Checkout__c, Order_Builder_Visible__c, Product2.Family, Product2.Is_Biobanking_Product__c, Product2.Eligible_for_Volume_Discounting__c, ProductCode FROM PricebookEntry WHERE IsActive=true AND Pricebook2Id=:pricebookId];

            System.debug('availProducts: '+availProducts);

            List < ID > productIds = new List < ID >();
            for (PricebookEntry pbe: availProducts) {
                productIds.add(pbe.Product2Id);
            }

            // Get all products including their related product relationships
            // TODO: validation rule that related products must be in same pricebook
            List < Product2 > productsWithRelated = [SELECT ID, Name, IsActive, Exempt_From_Discounts__c, Description, Partial_Amount_Due_At_Checkout__c, Due_at_Checkout__c, Family, Is_Biobanking_Product__c, Eligible_for_Volume_Discounting__c, (SELECT ID, Related_Product__c, Related_Product__r.Name, Relationship__c FROM Related_Products__r) FROM Product2 WHERE IsActive=true AND ID in:productIds];

            Map < ID, List < Product_Relationship__c >> productsWithRelatedMap = new Map < ID, List < Product_Relationship__c >>();
            for (Product2 prod: productsWithRelated) {
                if (prod.Related_Products__r.size()>0) {
                    productsWithRelatedMap.put(prod.Id, prod.Related_Products__r);
                }
            }

            // Populate class map of all list prices
            Map < ID, Decimal > productListPricesMap = new Map < ID, Decimal >();
            for (PricebookEntry pbEntry: availProducts) {
                productListPricesMap.put(pbEntry.Product2Id,pbEntry.UnitPrice);
            }

            // Get all Valid Discounts
            List < Discount__c > currentDiscounts = [SELECT ID, Amount__c, Bundle__c, Name, Marketing_Code__c, System_Applied__c, Services_Count__c,Applicable_Storage_Type__c, Method__c, Minimum_Order_Amount__c, Percentage__c, Product__c, Type__c, Valid_From__c, Valid_To__c, Active__c, Description__c FROM Discount__c WHERE Active__c=TRUE AND System_Applied__c=false];

            // Populate final searchable items collection
            List < Order.SearchableItem > allSearchableItems = new List < Order.SearchableItem >();

            for (Bundle_Pricebook_Entry__c bpbe: bundlePricebookEntries) {
                Bundle__c bundle = availBundlesMap.get(bpbe.Bundle__c);
                allSearchableItems.add(new Order.SearchableItem(bundle, bpbe, productListPricesMap, productsWithRelatedMap));
            }

            for (PricebookEntry pbe: availProducts) {
                if (pbe.Order_Builder_Visible__c) {
                    allSearchableItems.add(new Order.SearchableItem(pbe, productsWithRelatedMap));
                } 
            }

            for (Discount__c disc: currentDiscounts) {
                allSearchableItems.add(new Order.SearchableItem(disc));
            }
            

            return JSON.serialize(allSearchableItems);


        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    @AuraEnabled
    public static string loadOrder(Id orderId){
        try {
            Order thisOrder = new Order(orderId);
            return JSON.serialize(thisOrder);
        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    // TEMPORARY
    @AuraEnabled(cacheable = true)
    public static string getBiobankingDiscounts(){
        try {
            List < Discount__c > biobankingDiscounts = [SELECT ID, Amount__c, Bundle__c, Name, Marketing_Code__c, System_Applied__c, Method__c, Minimum_Order_Amount__c, Percentage__c, Product__c, Type__c, Valid_From__c, Valid_To__c, Active__c, Description__c, Services_Count__c, Applicable_Storage_Type__c FROM Discount__c WHERE Active__c=TRUE AND System_Applied__c=true];

            List < Discount > discountWrappers = new List < Discount >();
            for (Discount__c disc: biobankingDiscounts) {
                discountWrappers.add(new Discount(disc));
            }

            String responseJSON = '{"discountRecords":'+JSON.serialize(discountWrappers)+'}';
            return responseJSON;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static string getAvailablePaymentOptions(){
        try {
            List < Payment_Plan_Info__mdt > payPlans = Payment_Plan_Info__mdt.getAll().values();
            List < PaymentPlan > payPlanOptions = new List < PaymentPlan > ();
            for (Payment_Plan_Info__mdt pp: payPlans ) {
                PaymentPlan ppWrapper = new PaymentPlan(pp);
                if (pp.Active__c==true) {
                    payPlanOptions.add(ppWrapper);
                }
            }
            return JSON.serialize(payPlanOptions);
        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    @AuraEnabled(cacheable = false)
    public static String addProducts(String orderJSON, String productJSON){

        try {
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            List < Product > products = (List < Product >) JSON.deserialize ( productJSON, List < Product >.class );
            order.addProducts(products);

            return JSON.serialize(order.productsOrdered);

        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    @AuraEnabled(cacheable = false)
    public static String addBundle(String orderJSON, String bundleJSON){
        try {
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            Bundle bundle = (Bundle) JSON.deserialize ( bundleJSON, Bundle.class );
            order.addBundle(bundle);

            return JSON.serialize(order);

        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    @AuraEnabled(cacheable = false)
    public static String addDiscount(String orderJSON, String discountJSON){
        try {
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            Discount discount = (Discount) JSON.deserialize ( discountJSON, Discount.class );
            order.addDiscount(discount);

            // return just the id of the discount added
            String appliedDiscountId;
            for (Discount disc:order.discountsOrdered) {
                if (disc.Id==discount.Id) {
                    appliedDiscountId = disc.appliedDiscountId;
                }
            }

            return appliedDiscountId;

        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    @AuraEnabled(cacheable = false)
    public static Void removeDiscount(String orderJSON, String discountJSON){
        try {
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            Discount discount = (Discount) JSON.deserialize ( discountJSON, Discount.class );
            order.removeDiscount(discount);
        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }



    @AuraEnabled(cacheable = false)
    public static void removeProduct(String orderJSON, String productId){
        try {
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            List < ID > productIdInList = new List < ID >{productId};
            order.removeProducts(productIdInList);

        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    @AuraEnabled(cacheable = false)
    public static String removeBundle(String orderJSON, String bundleId){
        try {
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            List < ID > bundleIdInList = new List < ID >{bundleId};
            order.removeBundles(bundleIdInList);
            return JSON.serialize(updatedOrderByContext(order));

        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    

    @AuraEnabled(cacheable = false)
    public static Boolean clearOrder(String orderJSON){
        try {
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            order.clearOrder();
            return true;
        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    @AuraEnabled(cacheable = false)
    public static String updateBundleQuantities(String orderJSON, String bundleJSON){
        try {
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            Bundle bundle = (Bundle) JSON.deserialize  (bundleJSON, Bundle.class) ;
            order.applyQuantityUpdates(bundle);
            return JSON.serialize(updatedOrderByContext(order));

        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    @AuraEnabled(cacheable = false)
    public static String updateProductQuantities(String orderJSON, String productJSON){
        try {
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            Product product = (Product) JSON.deserialize  (productJSON, Product.class) ;
            order.applyQuantityUpdates(product);
            return JSON.serialize(updatedOrderByContext(order));

        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    @AuraEnabled(cacheable = false)
    public static Void removePaymentPlan(String orderJSON){
        try {
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            order.removePaymentPlan();
        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    @AuraEnabled(cacheable = false)
    public static Void updatePaymentPlan(String orderJSON, String paymentJSON){
        try {
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            PaymentPlan pp = (PaymentPlan) JSON.deserialize  (paymentJSON, PaymentPlan.class) ;
            order.updatePaymentPlan(pp);
        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    @AuraEnabled(cacheable = false)
    public static Void updateAdditionToFirstPayment(String orderJSON, Decimal amount){
        try {
            if (amount==null) {
                amount = 0;
            }
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            order.updateAdditionToFirstPayment(amount);
        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    @AuraEnabled(cacheable = false)
    public static void removeBundlesAndProducts (String orderJSON, String products, String bundles){
        try {
            Order order = (Order) JSON.deserialize ( orderJSON, Order.class );
            List < ID > productIdList = (List < ID >) JSON.deserialize ( products, List < ID >.class );
            List < ID > bundleIdList = (List < ID >) JSON.deserialize ( bundles, List < ID >.class );

            if (productIdList.size()>0) {
                order.removeProducts(productIdList);
            }
            if (bundleIdList.size()>0) {
                order.removeBundles(bundleIdList);
            }
            
            

        } catch (Exception e) {
            throw new OrderBuilderException(e, 'OrderBuilderController');
        }
    }

    private static Order updatedOrderByContext(Order order) {
        Order updatedOrder;
        if (order.orderContext=='Opportunity') {
            updatedOrder = new Order(order.opportunityId);
        } else {
            updatedOrder = new Order(order.invoiceId);
        }
        return updatedOrder;
    }
}