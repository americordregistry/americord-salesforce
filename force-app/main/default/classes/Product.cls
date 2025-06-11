public with sharing class Product {
    public ID Id;
    public ID opportunityId;
    public ID invoiceId;
    public String productCode;
    public ID opportunityLineItemId;
    public ID invoiceLineItemId;
    public String name;
    public Integer quantity;
    public Integer startingQuantityInBundle; //when included as part of a bundle, what is the quantity of product for each one bundle
    public Boolean exemptFromDiscount;
    public Decimal upfrontAmount; //partial amount, due at checkout
    public Boolean isDueAtCheckout; //if true, this product is paid entirely on checkout (kit fee, shipping)
    public String description;
    public Decimal listPrice;
    public Decimal listPriceAtQuantity;
    public Decimal marketingDiscountApplied = 0; //via a code
    public Decimal salesDiscountApplied = 0; //via the sales person
    public Decimal combinedDiscounts = 0;
    public Decimal finalPrice; //List price minus sales and marketing discounts
    // Bundle-related fields
    public string family; //Family of product
    public Boolean isBundled = false;
    public ID appliedBundleId; //the id of the bundle that caused this product to be added (if applicable)
    public Decimal bundleSavings = 0;
    public Decimal bundleSavingsAtQuantity = 0;
    public Decimal proportionOfDiscountableBundleTotal; //expressed as a percentage, what relative value is this of the bundle ONLY Discountable products are considered
    public Decimal priceAfterBundleSavings;
    public Boolean isBiobankingProduct; //TEMPORARY FOR MULTIBIOBANKING DISCOUNT
    public Boolean eligibleForVolumeDiscounts; //Related to multi-biobanking discount; indicates that this product qualifies for that discount

    public List < RelatedProduct > relatedProducts = new List < RelatedProduct > ();
    public List < Discount > discountsApplied = new List < Discount >();

    public Product() {}

    public Product(SObject lineItem) {

        // Determine the Line Item type.  May be an Opportunity Line item or an Invoice Line Item
        if (lineItem.Id.getSobjectType()==Schema.OpportunityLineItem.getSObjectType()) {
            OpportunityLineItem oli = (OpportunityLineItem)lineItem;
            instantiateAsOppLineItem(oli);
        } else if (lineItem.Id.getSobjectType()==Schema.fw1__Invoice_Line__c.getSObjectType()) {
            fw1__Invoice_Line__c ili = (fw1__Invoice_Line__c)lineItem;
            instantiateAsInvoiceLineItem(ili);
        } else {
            // TODO throw exception- Unexpected Object Type
        }

    }

    public Product (PricebookEntry pbe, Map < ID, List < Product_Relationship__c >> productsWithRelatedMap) {
        this.Id = pbe.Product2Id;
        this.name = pbe.Product2.Name;
        this.productCode = pbe.ProductCode;
        this.exemptFromDiscount = pbe.Product2.Exempt_From_Discounts__c;
        this.description = pbe.Product2.Description;
        this.listPrice = pbe.UnitPrice;
        this.listPriceAtQuantity = this.listPrice;
        this.upfrontAmount = pbe.Product2.Partial_Amount_Due_At_Checkout__c;
        this.isDueAtCheckout = pbe.Product2.Due_at_Checkout__c;
        this.marketingDiscountApplied = 0;
        this.salesDiscountApplied = 0;
        this.combinedDiscounts = 0;
        this.quantity = 1;
        this.finalPrice = this.listPrice;
        this.family = pbe.Product2.Family;
        this.isBiobankingProduct = pbe.Product2.Is_Biobanking_Product__c;
        this.eligibleForVolumeDiscounts = pbe.Product2.Eligible_for_Volume_Discounting__c;
        this.relatedProducts = new List < RelatedProduct >();
        if (productsWithRelatedMap.containsKey( pbe.Product2Id)) {
            List < Product_Relationship__c > relatedProductSobjs = productsWithRelatedMap.get(pbe.Product2Id);
            for (Product_Relationship__c prodRel: relatedProductSobjs) {
                this.relatedProducts.add(new RelatedProduct(prodRel));
            }
        }
        
    }
    
    public Product (Bundle_Member__c bundleMember, Map < ID, Decimal > productListPricesMap, Map < ID, List < Product_Relationship__c >> productsWithRelatedMap) {
        if (bundleMember.Product__c==null)  {
            throw new OrderBuilderException('Bundle Member '+ bundleMember.Id + ' does not have a Product__c value', OrderBuilderException.Severity.ALERT);
        }
        this.Id = bundleMember.Product__c;
        this.isBundled = true;
        this.startingQuantityInBundle = Integer.valueOf(bundleMember.Quantity__c); //this number may change if multiples of the package are ordered
        this.quantity = Integer.valueOf(bundleMember.Quantity__c); //this number may change if multiples of the package are ordered
        this.exemptFromDiscount = bundleMember.Product__r.Exempt_From_Discounts__c;
        this.name = bundleMember.Product__r.Name;
        this.productCode = bundleMember.Product__r.ProductCode;
        this.description = bundleMember.Product__r.Description;
        this.listPrice = productListPricesMap.get(this.Id);
        if (this.listPrice==null) throw new OrderBuilderException('Product List Price not found for Product: '+this.Id +' in the same pricebook as this bundle: '+bundleMember.Bundle__c, OrderBuilderException.Severity.ALERT);
        this.listPriceAtQuantity = this.listPrice * this.quantity;
        this.marketingDiscountApplied = 0;
        this.salesDiscountApplied = 0;
        this.combinedDiscounts = 0;
        this.finalPrice = this.listPrice;
        this.upfrontAmount = bundleMember.Product__r.Partial_Amount_Due_At_Checkout__c;
        this.isDueAtCheckout = bundleMember.Product__r.Due_at_Checkout__c;
        this.family = bundleMember.Product__r.Family;
        this.isBiobankingProduct = bundleMember.Product__r.Is_Biobanking_Product__c;
        this.eligibleForVolumeDiscounts = bundleMember.Product__r.Eligible_for_Volume_Discounting__c;
        this.relatedProducts = new List < RelatedProduct >();

        if (productsWithRelatedMap.containsKey(bundleMember.Product__c)) {
            List < Product_Relationship__c > relatedProductSobjs = productsWithRelatedMap.get(bundleMember.Product__c);
            for (Product_Relationship__c prodRel: relatedProductSobjs) {
                this.relatedProducts.add(new RelatedProduct(prodRel));
            }
        }
    }

    private void instantiateAsOppLineItem (OpportunityLineItem oli) {

        System.debug('oli: '+JSON.serialize(oli));

        // Initialize
        if (oli.Marketing_Discount__c==null) oli.Marketing_Discount__c = 0;
        if (oli.Sales_Discount__c==null) oli.Sales_Discount__c = 0;
        if (oli.Bundle_Savings__c==null) oli.Bundle_Savings__c = 0;
        if (oli.Quantity==null) oli.Quantity = 0;

        if (oli.Applied_Bundle__c!=null) {
            this.isBundled = true;
        }
        this.Id = oli.Product2Id;
        this.opportunityId = oli.OpportunityId;
        this.opportunityLineItemId = oli.Id;
        this.name = oli.Product2.Name;
        this.quantity = Integer.valueOf(oli.Quantity);
        this.family = oli.Product2.Family;
        this.exemptFromDiscount = oli.Product2.Exempt_From_Discounts__c;
        this.description = oli.Product2.Description;
        this.productCode = oli.Product_Code__c;
        this.listPrice = oli.ListPrice;
        this.listPriceAtQuantity = this.listPrice * this.quantity;
        this.marketingDiscountApplied = oli.Marketing_Discount__c;
        this.salesDiscountApplied = oli.Sales_Discount__c;
        this.combinedDiscounts = this.salesDiscountApplied + this.marketingDiscountApplied;
        this.appliedBundleId = oli.Applied_Bundle__c;
        this.priceAfterBundleSavings = oli.TotalPrice;
        this.bundleSavings = oli.Bundle_Savings__c/oli.Quantity;
        this.bundleSavingsAtQuantity = oli.Bundle_Savings__c;
        this.finalPrice = oli.TotalPrice;
        this.upfrontAmount = oli.Product2.Partial_Amount_Due_At_Checkout__c;
        this.isDueAtCheckout = oli.Product2.Due_at_Checkout__c;
        this.isBiobankingProduct = oli.Product2.Is_Biobanking_Product__c;
        this.eligibleForVolumeDiscounts = oli.Product2.Eligible_for_Volume_Discounting__c;
        if (this.appliedBundleId!=null) this.isBundled = true;
    }

    public void instantiateAsInvoiceLineItem (fw1__Invoice_Line__c ili) {
        System.debug('invoice line item: '+JSON.serialize(ili));
        // Initialize
        if (ili.Marketing_Discount__c==null) ili.Marketing_Discount__c = 0;
        if (ili.Sales_Discount__c==null) ili.Sales_Discount__c = 0;
        if (ili.Bundle_Savings__c==null) ili.Bundle_Savings__c = 0;
        if (ili.fw1__Quantity__c==null) ili.fw1__Quantity__c = 0;

        if (ili.Applied_Bundle__c!=null) {
            this.isBundled = true;
        }
        this.Id = ili.fw2__Product__c;
        this.invoiceId = ili.fw1__Invoice__c;
        this.invoiceLineItemId = ili.Id;
        this.name = ili.fw2__Product__r.Name;
        this.quantity = Integer.valueOf(ili.fw1__Quantity__c);
        this.exemptFromDiscount = ili.fw2__Product__r.Exempt_From_Discounts__c;
        this.description = ili.fw2__Product__r.Description;
        this.productCode = ili.fw2__Product__r.ProductCode;
        this.listPrice = ili.fw1__Unit_Price__c;
        this.listPriceAtQuantity = this.listPrice * this.quantity;
        this.marketingDiscountApplied = ili.Marketing_Discount__c;
        this.salesDiscountApplied = ili.Sales_Discount__c;
        this.combinedDiscounts = this.salesDiscountApplied + this.marketingDiscountApplied;
        this.appliedBundleId = ili.Applied_Bundle__c;
        this.priceAfterBundleSavings = ili.fw1__Amount__c;
        this.bundleSavings = ili.Bundle_Savings__c/ili.fw1__Quantity__c;
        this.bundleSavingsAtQuantity = ili.Bundle_Savings__c;
        this.finalPrice = ili.fw1__Amount__c;
        this.upfrontAmount = ili.fw2__Product__r.Partial_Amount_Due_At_Checkout__c;
        this.isDueAtCheckout = ili.fw2__Product__r.Due_at_Checkout__c;
        this.family = ili.fw2__Product__r.Family;
        this.isBiobankingProduct = ili.fw2__Product__r.Is_Biobanking_Product__c;
        this.eligibleForVolumeDiscounts = ili.fw2__Product__r.Eligible_for_Volume_Discounting__c;
        if (this.appliedBundleId!=null) this.isBundled = true;

    }

    public Boolean isDiscountable() {
        return !this.exemptFromDiscount;
    }

    public OpportunityLineItem asOppLineItem () {
        Decimal totalDiscountFromList = this.marketingDiscountApplied + this.salesDiscountApplied + this.bundleSavingsAtQuantity;
        Decimal percentageDiscount = 0; 
        Decimal decDiscountPercentage = 0;
        if(this.listPriceAtQuantity > 0) percentageDiscount = totalDiscountFromList / this.listPriceAtQuantity;

        if(math.abs(percentageDiscount)*100 > 100){
            decDiscountPercentage = 100; // set ceiling as this could be more than 100%
        } 
        else {
            decDiscountPercentage = math.abs(percentageDiscount)*100;
        }

        System.debug('totalDiscountFromList: '+totalDiscountFromList);
        System.debug('this.listPriceAtQuantity: '+this.listPriceAtQuantity);
        System.debug('percentageDiscount: '+percentageDiscount);
        System.debug('this.marketingDiscountApplied: '+this.marketingDiscountApplied);
        OpportunityLineItem oli = new OpportunityLineItem (
            Id=this.opportunityLineItemId,
            UnitPrice = this.listPrice,
            OpportunityId = this.opportunityId,
            Product2Id = this.Id,
            Quantity = this.quantity,
            Product_Code__c = this.productCode,
            Marketing_Discount__c = this.marketingDiscountApplied,
            Sales_Discount__c = this.salesDiscountApplied,
            Bundle_Savings__c = this.bundleSavingsAtQuantity,
            Applied_Bundle__c = this.appliedBundleId,
            Discount = decDiscountPercentage
        );

        System.debug('oli: '+JSON.serialize(oli));

        return oli;
    }

    public fw1__Invoice_Line__c asInvoiceLineItem () {
        Decimal totalDiscountFromList = this.marketingDiscountApplied + this.salesDiscountApplied + this.bundleSavingsAtQuantity;
        Decimal percentageDiscount =0;
        if(this.listPriceAtQuantity > 0) percentageDiscount = totalDiscountFromList / this.listPriceAtQuantity;
        System.debug('totalDiscountFromList: '+totalDiscountFromList);
        System.debug('this.listPriceAtQuantity: '+this.listPriceAtQuantity);
        System.debug('percentageDiscount: '+percentageDiscount);
        System.debug('this.marketingDiscountApplied: '+this.marketingDiscountApplied);
        System.debug('this.salesDiscountApplied: '+this.salesDiscountApplied);
        fw1__Invoice_Line__c ili = new fw1__Invoice_Line__c (
            Name=this.name,
            Id=this.invoiceLineItemId,
            fw1__Invoice__c = this.invoiceId,
            fw1__Unit_Price__c = this.listPrice,
            fw2__Product__c = this.Id,
            Applied_Bundle__c = this.appliedBundleId,
            Product_Code__c = this.productCode,
            fw1__Quantity__c = this.quantity,
            Marketing_Discount__c = this.marketingDiscountApplied*-1,
            Sales_Discount__c = this.salesDiscountApplied*-1,
            Bundle_Savings__c = this.bundleSavingsAtQuantity*-1,
            fw1__Discount_Amount__c = ((this.marketingDiscountApplied + this.salesDiscountApplied + this.bundleSavingsAtQuantity)*-1)
        );

        System.debug('ili: '+JSON.serialize(ili));

        return ili;
    }

    public void updateOppSobj() {
        System.enqueueJob(new AsyncObjectUpdater_Queueable(this.asOppLineItem()));
    }

    public void updateInvSobj() {
        System.enqueueJob(new AsyncObjectUpdater_Queueable(this.asInvoiceLineItem()));
    }

    public void applyDiscount(Discount discount) {
        Decimal totalDiscountAmount;
        if (discount.method=='Amount') {
            totalDiscountAmount = discount.amount * this.quantity;
        } else {
            totalDiscountAmount = discount.percentage * this.listPrice; //list price will have already been adjusted for quantity
            discount.amount = totalDiscountAmount;
        }

        totalDiscountAmount = totalDiscountAmount * -1; //discounts are negative

        //put it in the correct field, sales or marketing
        if (String.isBlank(discount.marketingCode)) {
            this.salesDiscountApplied = totalDiscountAmount;
        } else {
            this.marketingDiscountApplied = totalDiscountAmount;
        }

        System.debug('this.marketingDiscountApplied after: '+this.marketingDiscountApplied);
        System.debug('this.salesDiscountApplied after: '+this.salesDiscountApplied);

    }

    public void clearDiscountAmounts() {
        this.salesDiscountApplied = 0;
        this.marketingDiscountApplied = 0;
        System.debug('clearedDiscountAmounts');
    }

    // SUBCLASS
    public class RelatedProduct {
        public ID Id;
        public String name;
        public String description;
        public Decimal listPrice;
        public String relationshipType;

        public RelatedProduct(Product_Relationship__c prodRel) {
            this.Id = prodRel.Related_Product__c;
            this.name = prodRel.Related_Product__r.Name;
            this.relationshipType = prodRel.Relationship__c;
        }
    }


}