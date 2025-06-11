public with sharing class Bundle {
    public ID Id;
    public ID opportunityId;
    public ID invoiceId;
    public ID appliedBundleId;
    public String name;
    public String type;
    public Decimal listPrice;
    public Decimal listPriceAtQuantity;
    public Decimal finalPrice; //List price minus sales and marketing discounts
    public Decimal bundleMembersListPriceTotal; //total list price at current quantity
    public List < Product > bundledProducts;
    public Date validFrom;
    public Date validTo;
    public Integer quantity;
    public Decimal marketingDiscountApplied; //via a code
    public Decimal salesDiscountApplied; //via the sales person
    public Decimal combinedDiscounts;
    public Decimal bundleSavings; //the difference between the bundle line items total and the bundle list price
    public Decimal bundleSavingsAtQuantity; 
    public Decimal totalListPriceDiscountableProducts = 0; //the total of just the included products (at base quantity) which are not exempt from discounting - used in discount proportion calculations
    public String storageType; //used for single product bundles to indicate the storage type.  Used in Order Builder to select automated discounts

    public Bundle(){}

    // Loading the basic bundle from defining metadata - not specific to any order
    public Bundle (Bundle__c bundle, Bundle_Pricebook_Entry__c bundlePricebookEntry, Map < ID, Decimal > productListPricesMap, Map < ID, List < Product_Relationship__c >> productsWithRelatedMap) {
        this.Id = bundle.Id;
        this.name = bundle.Name;
        this.type = bundle.Type__c;
        this.storageType = bundle.Storage_Type__c;
        this.listPrice = bundlePricebookEntry.List_Price__c;
        this.listPriceAtQuantity = this.listPrice;
        this.validFrom = bundle.Valid_From_Date__c;
        this.validTo = bundle.Valid_To_Date__c;
        this.marketingDiscountApplied = 0;
        this.salesDiscountApplied = 0;
        this.combinedDiscounts = 0;
        this.finalPrice = this.listPriceAtQuantity + this.combinedDiscounts;
        this.quantity = 1;
        this.bundledProducts = new List < Product >();

        Decimal listPriceAllProductsAtStartingQuantity = 0;
        Decimal listPriceDiscountableProductsAtStartingQuantity = 0;
        for (Bundle_Member__c bundleMember: bundle.Bundle_Members__r) {
            Product product = new Product(bundleMember, productListPricesMap, productsWithRelatedMap);
            listPriceAllProductsAtStartingQuantity += product.listPriceAtQuantity;
            if (product.isDiscountable()) {
                listPriceDiscountableProductsAtStartingQuantity+=product.listPriceAtQuantity;
            }

            this.bundledProducts.add(product);
        }
        this.bundleMembersListPriceTotal = listPriceAllProductsAtStartingQuantity;
        this.totalListPriceDiscountableProducts = listPriceDiscountableProductsAtStartingQuantity;

        // Calculate the implied bundle savings
        this.bundleSavings = this.listPrice - listPriceAllProductsAtStartingQuantity;
        this.bundleSavingsAtQuantity = this.bundleSavings;
        this.updateDiscounts();
        
    }


    // Load a particular bundle given the applied bundle, opportunityLineItems and bundlePricebookEntry
    public Bundle (Applied_Bundle__c appliedBundle, List < SObject > lineItems, Bundle_Pricebook_Entry__c bundlePricebookEntry) {
        this.loadValuesFromAppliedBundle(appliedBundle);
        this.listPrice = bundlePricebookEntry.List_Price__c;
        this.listPriceAtQuantity = this.listPrice * appliedBundle.Quantity__c;

        Decimal listPriceAllProductsAtCurrentQuantity = 0;
        Decimal listPriceAllProductsAtBaseQuantity = 0; //some bundles will include multiples of a given product.

        List < Bundle_Member__c > bundleMembers = [SELECT ID, Product__c, Quantity__c FROM Bundle_Member__c WHERE Bundle__c =:appliedBundle.Bundle__c];
        Map < ID, Bundle_Member__c > bundleMembersByProductId = new Map < ID, Bundle_Member__c >();
        for (Bundle_Member__c mem: bundleMembers) {
            bundleMembersByProductId.put(mem.Product__c, mem);
        }

        // Line items passed in may be either Opportunity Line Items or Invoice Line Items.  The Product constructor works with either
        for (SObject li: lineItems) {
            Product bundleMemberProduct = new Product(li);
            bundleMemberProduct.startingQuantityInBundle = Integer.valueOf(bundleMembersByProductId.get(bundleMemberProduct.Id).Quantity__c);
            this.bundledProducts.add(bundleMemberProduct);
            listPriceAllProductsAtCurrentQuantity+=bundleMemberProduct.listPrice*bundleMemberProduct.quantity;
            listPriceAllProductsAtBaseQuantity+=bundleMemberProduct.listPrice*bundleMemberProduct.startingQuantityInBundle;
            if (bundleMemberProduct.isDiscountable()) {
                this.totalListPriceDiscountableProducts+=(bundleMemberProduct.listPrice*bundleMemberProduct.startingQuantityInBundle);
            }
        }

        this.bundleMembersListPriceTotal = listPriceAllProductsAtCurrentQuantity;
        this.bundleSavings = this.listPrice - listPriceAllProductsAtBaseQuantity;
        this.bundleSavingsAtQuantity = this.listPriceAtQuantity - listPriceAllProductsAtCurrentQuantity;
        this.finalPrice = this.listPriceAtQuantity + this.combinedDiscounts;
        this.updateDiscounts();

    }

    private void loadValuesFromAppliedBundle(Applied_Bundle__c appliedBundle) {
        this.Id = appliedBundle.Bundle__c;
        this.opportunityId = appliedBundle.Opportunity__c;
        this.invoiceId = appliedBundle.Invoice__c;
        this.appliedBundleId = appliedBundle.Id;
        this.name = appliedBundle.Bundle__r.Name;
        this.type = appliedBundle.Bundle__r.Type__c;
        this.storageType = appliedBundle.Bundle__r.Storage_Type__c;
        this.validFrom = appliedBundle.Bundle__r.Valid_From_Date__c;
        this.validTo = appliedBundle.Bundle__r.Valid_To_Date__c;
        this.marketingDiscountApplied = appliedBundle.Marketing_Discount__c;
        this.salesDiscountApplied = appliedBundle.Sales_Discount__c;
        this.combinedDiscounts = this.marketingDiscountApplied + this.salesDiscountApplied;
        this.finalPrice = appliedBundle.Total_Price__c;
        this.quantity = Integer.valueOf(appliedBundle.Quantity__c);
        this.bundledProducts = new List < Product >();
    }

    public void updateDiscounts() {
        Decimal listPriceDiscountableProductsCurrentQuantity = this.totalListPriceDiscountableProducts * this.quantity;
        System.debug('this.quantity: '+this.quantity);
        System.debug('listPriceDiscountableProductsCurrentQuantity: '+listPriceDiscountableProductsCurrentQuantity);
        

        for (Product product: this.bundledProducts) {
            if (product.isDiscountable()) {
                product.proportionOfDiscountableBundleTotal = 0; 
                if (listPriceDiscountableProductsCurrentQuantity!=0) product.proportionOfDiscountableBundleTotal = product.listPriceAtQuantity/listPriceDiscountableProductsCurrentQuantity;
                product.bundleSavingsAtQuantity = product.proportionOfDiscountableBundleTotal * this.bundleSavingsAtQuantity;
                System.debug('this.bundleSavingsAtQuantity: '+this.bundleSavingsAtQuantity);
                System.debug('product.proportionOfDiscountableBundleTotal: '+product.proportionOfDiscountableBundleTotal);
                // Bundle savings at quantity is tricky when the bundle has a different quantity than the products. For example, a Twins bundle where the quantity is one and it contains 2 of a given product.  In this case, the bundlesavings is just the relative proportion of the overall bundle savings, we don't want to inflate it
                product.marketingDiscountApplied = product.proportionOfDiscountableBundleTotal * this.marketingDiscountApplied;
                product.salesDiscountApplied = product.proportionOfDiscountableBundleTotal * this.salesDiscountApplied;
            }
        }
    }

    public void updateSobjs(String orderContext) {
        System.debug('orderContext: '+orderContext);
        List < SObject > sobjsToUpdate = new List < SObject >();
        
        for (Product product: this.bundledProducts) {
            if (orderContext=='Opportunity') {
                OpportunityLineItem oli = product.asOppLineItem();
                sobjsToUpdate.add(oli);
            } else {
                sobjsToUpdate.add(product.asInvoiceLineItem());
            }
        }
        sobjsToUpdate.add(this.asAppliedBundle(orderContext));
        System.debug('sobjsToUpdate: '+JSON.serialize(sobjsToUpdate));
        update sobjsToUpdate;

    }

    public void applyDiscount(Discount discount) {
        // figure out the percentage if a whole-dollar discount
        Decimal totalDiscountAmount;
        if (discount.method=='Amount') {
            totalDiscountAmount = discount.amount * this.quantity;
        } else {
            totalDiscountAmount = discount.percentage * this.listPrice; //list price will have already been adjusted for quantity & bundle savings
            discount.amount = totalDiscountAmount;
        }

        totalDiscountAmount = totalDiscountAmount * -1;

        // put it in the correct field, sales or marketing
        if (String.isBlank(discount.marketingCode)) {
            this.salesDiscountApplied = totalDiscountAmount;
        } else {
            this.marketingDiscountApplied = totalDiscountAmount;
        }

        this.updateDiscounts(); //updates the individual product line items with discount data

    }

    public void clearDiscountAmounts() {
        this.salesDiscountApplied = 0;
        this.marketingDiscountApplied = 0;
        for (Product product: this.bundledProducts) {
            product.clearDiscountAmounts();
        }
    }

    public Applied_Bundle__c asAppliedBundle (String orderContext) {
        Applied_Bundle__c appliedBundle = new Applied_Bundle__c (
            Id = this.appliedBundleId,
            Bundle__c = this.Id,
            Marketing_Discount__c = this.marketingDiscountApplied,
            Sales_Discount__c = this.salesDiscountApplied,
            Total_Price__c = this.finalPrice,
            Quantity__c = this.quantity
        );

        if (orderContext=='Opportunity') {
            appliedBundle.Opportunity__c = this.opportunityId;
        } else {
            appliedBundle.Invoice__c = this.invoiceId;
        }

        return appliedBundle;
        
    }
}