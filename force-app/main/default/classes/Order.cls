public with sharing class Order {

    public ID opportunityId;
    public ID invoiceId;
    public String orderContext;
    public List < Product > productsOrdered;
    public List < Bundle > bundlesOrdered;
    public List < Discount > discountsOrdered;

    public Id pricebookId;
    public Decimal finalPrice; //the price being charged (total minus all discounts)
    // public Decimal totalMarketingPrice; //sum of the marketing prices for all included products and bundles
    public Decimal totalListPrice; //sum of the list prices for all included products and bundles (product list/marketing prices are the same, bundles will have different values)
    public Decimal totalBundleSavings;
    public Decimal totalSalesDiscount = 0;
    public Decimal totalMarketingDiscount = 0;
    public Decimal totalDueAtCheckout;
    public Decimal totalDiscount;
    public Decimal totalDiscountPercentage;
    public Decimal upfrontAmount; //some products are paid in full or in part at checkout
    public String paymentPlanSelected;
    public String opportunityStage;
    public PaymentPlan paymentPlan;
    public Boolean birthDependentOrder; //if true, then some or all parts of this order cannot be completed until a birth has occurred
    // Something to distinguish orders that involve waiting for a birth to complete, vs orderst that can be fulfilled immediately
    public Decimal totalListPriceDiscountableProducts = 0; //the total of just the included products which are not exempt from discounting - used in discount proportion calculations
    public Decimal totalListPriceBundlesAndDiscountableALaCarte = 0; 
    public Decimal totalListPriceNonDiscountableProducts = 0;
    private String TOTAL_MONTHLY_FEES = 'Total Monthly Fees';

    public Order(ID recordId) {
        // determine opp or invoice record type
        if (recordId.getsobjecttype()==Schema.Opportunity.getSObjectType()) {
            initializeFromOpportunity(recordId);
        } else if (recordId.getsobjecttype()==Schema.fw1__Invoice__c.getSObjectType()) {
            initializeFromInvoice(recordId);
        }
    }


    public void addProducts(List < Product > products) {

        if (this.orderContext=='Opportunity') {
            List < OpportunityLineItem > lineItems = new List < OpportunityLineItem >();
            for (Product prod: products) {
                OpportunityLineItem lineItem = prod.asOppLineItem();
                lineItem.OpportunityId = this.opportunityId;
                lineItems.add(lineItem);
            }
    
            insert lineItems;
            this.initializeFromOpportunity(this.opportunityId);
        } else {
            List < fw1__Invoice_Line__c > lineItems = new List < fw1__Invoice_Line__c >();
            for (Product prod: products) {
                fw1__Invoice_Line__c lineItem = prod.asInvoiceLineItem();
                lineItem.fw1__Invoice__c = this.invoiceId;
                lineItems.add(lineItem);
            }
            
            insert lineItems;
            this.initializeFromInvoice(this.invoiceId);
        }

        recalculateAllTotals();

        // ListPrice=Corresponds to the UnitPrice on the PricebookEntry that is associated with this line item, which can be in the standard price book or a custom price book. A client application can use this information to show whether the unit price (or sales price) of the line item differs from the price book entry list price.

        // UnitPrice=The unit price for the opportunity line item. In the Salesforce user interface, this field’s value is calculated by dividing the total price of the opportunity line item by the quantity listed for that line item. Label is Sales Price. This field or TotalPrice is required. You can’t specify both. If you specify Discount and Quantity, this field or TotalPrice is required. 

        // TotalPrice=This field is available only for backward compatibility. It represents the total price of the OpportunityLineItem.If you do not specify UnitPrice, this field is required. If you specify Discount and Quantity, this field or UnitPrice is required. When updating these records, you can change either this value or the UnitPrice, but not both at the same time. This field is nillable, but you can’t set both TotalPrice and UnitPrice to null in the same update request. To insert the TotalPrice via the API (given only a unit price and the quantity), calculate this field as the unit price multiplied by the quantity. This field is read-only if the opportunity line item has a revenue schedule. If the opportunity line item does not have a schedule or only has quantity schedule, this field can be updated.

        // Discount=Discount for the product as a percentage.
    } 

    public void removeProducts(List < ID > productIds) {
        // Assess any current discounts to see if they still apply

        if (this.orderContext=='Opportunity') {
            List < OpportunityLineItem > toDelete = [SELECT ID FROM OpportunityLineItem WHERE Product2Id in:productIds AND OpportunityId=:this.opportunityId];
            delete toDelete;
            this.initializeFromOpportunity(this.opportunityId);
        } else {
            List < fw1__Invoice_Line__c > toDelete = [SELECT ID FROM fw1__Invoice_Line__c WHERE fw2__Product__c in:productIds AND fw1__Invoice__c=:this.invoiceId];
            delete toDelete;
            this.initializeFromInvoice(this.invoiceId);
        }
        
        recalculateAllTotals();
    } 

    public void addBundle(Bundle bundle) {

        if (this.orderContext=='Opportunity') {
            // Apply the bundle to the Opportunity
            bundle.opportunityId = this.opportunityId;
            Applied_Bundle__c bundleSobj = new Applied_Bundle__c(
                Bundle__c = bundle.Id,
                Opportunity__c = this.opportunityId,
                Quantity__c = bundle.quantity,
                Sales_Discount__c = bundle.salesDiscountApplied,
                Marketing_Discount__c = bundle.marketingDiscountApplied,
                Total_Price__c = bundle.finalPrice
            );
            insert bundleSobj;

            // Add the associated products to the Opportunity
            List < SObject > sobjsToInsert = new List < SObject > ();

            // calculate the 
            Set < ID > orderedProductIds = getOrderedProductIDSet();
            List < Product > requiredAddOns = new List < Product >();
            for (Product prod: bundle.bundledProducts) {
                prod.opportunityId = this.opportunityId;
                prod.quantity = prod.startingQuantityInBundle * bundle.quantity;// set the quantity based on the bundle quantity and the quantity of products per bundle as specified on the bundle

                OpportunityLineItem lineItem = prod.asOppLineItem();
                // set the quantity based on the bundle quantity and the quantity of products per bundle as specified on the bundle
                lineItem.quantity = prod.startingQuantityInBundle * bundle.quantity;

                // lineItem.OpportunityId = this.opportunityId;
                lineItem.Applied_Bundle__c = bundleSobj.Id; //this might not be needed sinc the asOppLineItem fills it in if it's on the product
                sobjsToInsert.add(lineItem);
            }

            // Add any add-on products 
            for (Product prod: this.productsOrdered) {
                if (prod.opportunityLineItemId==null) {
                    OpportunityLineItem lineItem = prod.asOppLineItem();
                    lineItem.OpportunityId = this.opportunityId;
                    sobjsToInsert.add(lineItem);
                }
            }

            insert sobjsToInsert;
            this.initializeFromOpportunity(this.opportunityId);
        } else {
            // Apply the bundle to the Invoice
            bundle.invoiceId = this.invoiceId;
            //  TODO: Do invoice line items need a direct connection to bundles and discounts as well??? likely yes
            Applied_Bundle__c bundleSobj = new Applied_Bundle__c(
                Bundle__c = bundle.Id,
                Invoice__c = this.invoiceId,
                Quantity__c = bundle.quantity,
                Sales_Discount__c = bundle.salesDiscountApplied,
                Marketing_Discount__c = bundle.marketingDiscountApplied,
                Total_Price__c = bundle.finalPrice
            );
            insert bundleSobj;

            // Add the associated products to the Invoice
            List < SObject > sobjsToInsert = new List < SObject > ();

            // calculate the 
            Set < ID > orderedProductIds = getOrderedProductIDSet();
            List < Product > requiredAddOns = new List < Product >();
            for (Product prod: bundle.bundledProducts) {
                fw1__Invoice_Line__c lineItem = prod.asInvoiceLineItem();
                lineItem.fw1__Invoice__c = this.invoiceId;
                lineItem.Applied_Bundle__c = bundleSobj.Id;
                sobjsToInsert.add(lineItem);
            }
            // Add any add-on products 
            for (Product prod: this.productsOrdered) {
                if (prod.invoiceLineItemId==null) {
                    fw1__Invoice_Line__c lineItem = prod.asInvoiceLineItem();
                    lineItem.fw1__Invoice__c = this.invoiceId;
                    sobjsToInsert.add(lineItem);
                }
            }

            insert sobjsToInsert;
            this.initializeFromInvoice(this.invoiceId);
        }

        recalculateAllTotals();

    }

    //This is handled in the fron-end, leaving commented out here 
    // public void checkForBundleableProducts() {
    //     List < Bundle_Pricebook_Entry__c > bundlePricebookEntries = [SELECT ID, Bundle__c, Price_Book__c, List_Price__c FROM Bundle_Pricebook_Entry__c WHERE Order_Builder_Visible__c=true AND Price_Book__c=:pricebookId];
    //     List < ID > bundleIds = new List < ID >();
    //     for (Bundle_Pricebook_Entry__c bpbe: bundlePricebookEntries) {
    //         bundleIds.add(bpbe.Bundle__c);
    //     }

    //     // get a list of all current bundles with pricebook entries
    //     Map < ID, Bundle__c > availBundlesMap = new Map < ID, Bundle__c >([SELECT ID, Name, Description__c, Valid_From_Date__c, Valid_To_Date__c, Type__c, Storage_Type__c, (SELECT ID, Name, Quantity__c, Product__c, Product__r.Name, Product__r.Exempt_From_Discounts__c, Product__r.Description, Product__r.Partial_Amount_Due_At_Checkout__c, Product__r.Due_at_Checkout__c, Product__r.Is_Biobanking_Product__c, Product__r.Eligible_for_Volume_Discounting__c FROM Bundle_Members__r) FROM Bundle__c WHERE ID in:bundleIds AND Active__c=true]);

    //     // Create a map where the index is the bundle id and the value is a set of product names inside it
    //     Map < ID, Set < String > > bundlesWithContentsMap = new Map < ID, Set < String > >();
    //     for (Bundle__c bundle:availBundlesMap.values()) {
    //         Set < String > contents;
    //         if (bundlesWithContentsMap.containsKey(bundle.Id)) {
    //             contents = bundlesWithContentsMap.get(bundle.Id);
    //         } else {
    //             contents = new Set < String >();
    //         }
    //         for (Bundle_Member__c mem: bundle.Bundle_Members__r) {
    //             contents.add(mem.Product__r.Name);
    //         }
    //         bundlesWithContentsMap.put(bundle.Id,contents);  
    //     }

    //     // look at all the unbundled products (and products in single-product bundles) in this order and see if there is a match
    //     Set < String > unbundledProductsInOrder = new Set < String >();
    //     Set < String > singleProductBundlesInOrder = new Set < String >();
    //     for (Product prod:this.productsOrdered) {

    //         // Don't include shipping/kit
    //         if (prod.Family!='Shipping' && prod.Family!='Add-on') {
    //             unbundledProductsInOrder.add(prod.name);
    //         }
    //     }
    //     for (Bundle bundle:this.bundlesOrdered) {
    //         if (bundle.type=='Single-Product') {
    //             for (Product prod: bundle.bundledProducts) {
    //                 singleProductBundlesInOrder.add(prod.name);
    //             }
    //         }
    //     }

    //     Set < String > allSingleProductsInOrder = new Set < String >();
    //     allSingleProductsInOrder.addAll(unbundledProductsInOrder);
    //     allSingleProductsInOrder.addAll(singleProductBundlesInOrder);

    // }


    private Set < ID > getOrderedProductIDSet() {
        Set < ID > orderedProductIds = new Set < ID >();
        for (Product prod: this.productsOrdered) {
            orderedProductIds.add(prod.Id);
        }
        return orderedProductIds;
    }

    public void applyQuantityUpdates(Bundle bundle) {
        for(Product bundleProd: bundle.bundledProducts) {
            bundleProd.listPriceAtQuantity = bundleProd.listPrice * bundleProd.quantity;
        }
        bundle.updateDiscounts(); 
        bundle.updateSobjs(this.orderContext);
    }

    public void applyQuantityUpdates(Product product) {
        // update discount calculations
        Boolean hasDiscountApplied = false;
        for (Discount disc: this.discountsOrdered) {    
            if (disc.productId==product.Id) {
                hasDiscountApplied = true;
                product.applyDiscount(disc);
            }
        }
        if (this.orderContext=='Opportunity') {
            product.updateOppSobj();
        } else {
            product.updateInvSobj();
        }
    }

    public void addDiscount(Discount discount) {
        System.debug('discount: '+discount);

        // 1. First take off discounts from bundles and packages
        if (discount.type=='Bundle Specific') {
            Id bundleId = discount.bundleId;
            for (Bundle bundle: this.bundlesOrdered) {
                if (bundle.Id==bundleId) {
                    bundle.applyDiscount(discount);
                }
            }
        } else if (discount.type=='Product Specific') {
            for (Product product: this.productsOrdered) {
                if (product.Id==discount.productId) {
                    product.applyDiscount(discount);
                }
            }
        }

        // Insert applied discount SObj
        //Percentages stored as whole numbers in Salesforce
        Integer discountAsWholeNumber;
        if (discount.percentage!=null) {
            discountAsWholeNumber = Integer.valueOf(discount.percentage*100);
        }
        if (this.orderContext=='Opportunity') {
            Applied_Discount__c discSobj = new Applied_Discount__c(
                Discount__c = discount.Id,
                Opportunity__c = this.opportunityId,
                Amount__c = discount.amount,
                Percentage__c = discountAsWholeNumber
            );
            insert discSobj;
            System.debug('discount.percentage: '+discount.percentage);
            System.debug('discSobj: '+discSobj);
            this.initializeFromOpportunity(this.opportunityId);
        } else {
            Applied_Discount__c discSobj = new Applied_Discount__c(
                Discount__c = discount.Id,
                Invoice__c = this.invoiceId,
                Amount__c = discount.amount,
                Percentage__c = discountAsWholeNumber
            );
            insert discSobj;
            this.initializeFromInvoice(this.invoiceId);
        }

        recalculateAllTotals();
    } 

    public void recalculateAllTotals() {

        // 1: take off any products/bundles $$ values
        // 2: take off any percentages for bundles or products 
        // 3: take off any whole order $$ values
        // 4: take off the percentage for whole orders (if exists)
        List < Discount > bundleDiscounts = new List < Discount >();
        List < Discount > productDiscounts = new List < Discount >();
        List < Discount > wholeOrderPercentageDiscounts = new List < Discount >();
        List < Discount > wholeOrderDollarDiscounts = new List < Discount >();
        // List < Discount > bundleDiscounts = new List < Discount >();


        System.debug('this.discountsOrdered: '+JSON.serialize(this.discountsOrdered));
        for (Discount discount: this.discountsOrdered) {
            if (discount.type=='Bundle Specific') {
                bundleDiscounts.add(discount);
            } else if (discount.type=='Product Specific') {
                productDiscounts.add(discount);
            } else if (discount.type=='Whole Order' || discount.type=='Sales' || discount.type=='Multi-Biobanking Pkg') {
                if (discount.method=='Percentage') {
                    wholeOrderPercentageDiscounts.add(discount);
                } else if (discount.method=='Amount') {
                    wholeOrderDollarDiscounts.add(discount);
                }
            }
        }

        System.debug('wholeOrderPercentageDiscounts: '+JSON.serialize(wholeOrderPercentageDiscounts));
        System.debug('wholeOrderDollarDiscounts: '+JSON.serialize(wholeOrderDollarDiscounts));

        System.debug('this.totalBundleSavings before clear: '+this.totalBundleSavings);


        // clear existing discounts
        for (Bundle bundle: this.bundlesOrdered) {
            bundle.clearDiscountAmounts();
        }
        for (Product product: this.productsOrdered) {
            product.clearDiscountAmounts();
        }

        this.totalSalesDiscount = 0;
        this.totalMarketingDiscount = 0;
        this.totalDiscount = 0;

        System.debug('this.totalBundleSavings: '+this.totalBundleSavings);

        // Apply bundle-specific discounts
        Decimal discountsTaken = 0;
        for (Discount discount: bundleDiscounts) {
            for (Bundle bundle: this.bundlesOrdered) {
                if (bundle.Id==discount.bundleId) {
                    bundle.applyDiscount(discount);
                    discountsTaken+=discount.amount;
                }
            }
        }

        System.debug('After Bundle Discounts: '+discountsTaken);

        // Apply product-specific discounts
        for (Discount discount: productDiscounts) {
            for (Product product: this.productsOrdered) {
                if (product.Id==discount.productId) {
                    product.applyDiscount(discount);
                    discountsTaken+=discount.amount;
                }
            }

        }

        System.debug('After Product Discounts: '+discountsTaken);

        // Before applying whole order discounts, we need the current total (the price of all bundles, less discounts, and all discountable products, less discounts already taken)
        System.debug('totalListPriceBundlesAndDiscountableALaCarte: '+totalListPriceBundlesAndDiscountableALaCarte);
        System.debug('discountsTaken so far: '+discountsTaken);
        Decimal currentDiscountableTotal = totalListPriceBundlesAndDiscountableALaCarte-discountsTaken;
        System.debug('currentDiscountableTotal: '+currentDiscountableTotal);

        // List < Discount > wholeOrderPercentageDiscounts = new List < Discount >();
        // List < Discount > wholeOrderDollarDiscounts = new List < Discount >();

        System.debug('wholeOrderDollarDiscounts: '+JSON.serialize(wholeOrderDollarDiscounts));

        // 4: take off whole order percentages
        System.debug('currentDiscountableTotal: '+currentDiscountableTotal);

        for (Discount discount: wholeOrderPercentageDiscounts) {
            System.debug('discount.percentage: '+discount.percentage);
            // for percentages , calculate based on currentDiscountableTotal
            discount.amount = currentDiscountableTotal * discount.percentage;
            discount.amountAsNegative = discount.amount * -1;
            System.debug('discount.amount after percentage conversion: '+discount.amount);

            // apportion out the discount amount across all discountable objects
            for (Bundle bundle:this.bundlesOrdered) {
                Decimal allProductSalesDiscount = 0;
                Decimal allProductMarketingDiscount = 0;
                for (Product product: bundle.bundledProducts) {
                    if (product.isDiscountable()) {
                        System.debug('discountable product: '+product);
                        Decimal proportionOfDiscountableTotal = (product.listPrice*product.quantity)/this.totalListPriceDiscountableProducts;
                        System.debug('proportionOfDiscountableTotal: '+proportionOfDiscountableTotal);
                        Decimal proportionalDiscountAmount = proportionOfDiscountableTotal * discount.amountAsNegative;
                        System.debug('proportionalDiscountAmount: '+proportionalDiscountAmount);
                        // put it in the correct field, sales or marketing
                        if (String.isBlank(discount.marketingCode)) {
                            product.salesDiscountApplied = product.salesDiscountApplied + proportionalDiscountAmount;
                            allProductSalesDiscount+=product.salesDiscountApplied;
                        } else {
                            product.marketingDiscountApplied = product.marketingDiscountApplied + proportionalDiscountAmount;
                            allProductMarketingDiscount+=product.marketingDiscountApplied;
                        }
                    }
                }
                bundle.salesDiscountApplied = allProductSalesDiscount;
                bundle.marketingDiscountApplied = allProductMarketingDiscount;
            }

            for (Product product: this.productsOrdered) {
                if (product.isDiscountable()) {
                    Decimal proportionOfDiscountableTotal = (product.listPrice*product.quantity)/this.totalListPriceDiscountableProducts;
                    Decimal proportionalDiscountAmount = proportionOfDiscountableTotal * discount.amountAsNegative;
                    if (String.isBlank(discount.marketingCode)) {
                        product.salesDiscountApplied = product.salesDiscountApplied + proportionalDiscountAmount;
                    } else {
                        product.marketingDiscountApplied = product.marketingDiscountApplied + proportionalDiscountAmount;
                    }
                }
                
            }


        }

        // 3: Then take off any whole order $$ values
        for (Discount discount: wholeOrderDollarDiscounts) {
            currentDiscountableTotal = currentDiscountableTotal - discount.amount;
            // apportion out the discount amount across all discountable objects
            for (Bundle bundle:this.bundlesOrdered) {
                Decimal allProductSalesDiscount = 0;
                Decimal allProductMarketingDiscount = 0;
                for (Product product: bundle.bundledProducts) {
                    if (product.isDiscountable()) {
                        System.debug('discountable product: '+product);
                        Decimal proportionOfDiscountableTotal = 0; 
                        if (this.totalListPriceDiscountableProducts!=0) proportionOfDiscountableTotal = (product.listPrice*product.quantity)/this.totalListPriceDiscountableProducts;
                        System.debug('proportionOfDiscountableTotal: '+proportionOfDiscountableTotal);
                        Decimal proportionalDiscountAmount = proportionOfDiscountableTotal * discount.amountAsNegative;
                        System.debug('proportionalDiscountAmount: '+proportionalDiscountAmount);
                        // put it in the correct field, sales or marketing
                        if (String.isBlank(discount.marketingCode)) {
                            product.salesDiscountApplied = product.salesDiscountApplied + proportionalDiscountAmount;
                            allProductSalesDiscount+=product.salesDiscountApplied;
                        } else {
                            product.marketingDiscountApplied = product.marketingDiscountApplied + proportionalDiscountAmount;
                            allProductMarketingDiscount+=product.marketingDiscountApplied;
                        }
                    }
                }
                bundle.salesDiscountApplied = allProductSalesDiscount;
                bundle.marketingDiscountApplied = allProductMarketingDiscount;
            }

            for (Product product: this.productsOrdered) {
                if (product.isDiscountable()) {
                    Decimal proportionOfDiscountableTotal =0;
                    if (this.totalListPriceDiscountableProducts!=0) proportionOfDiscountableTotal = (product.listPrice*product.quantity)/this.totalListPriceDiscountableProducts;
                    Decimal proportionalDiscountAmount = proportionOfDiscountableTotal * discount.amountAsNegative;
                    if (String.isBlank(discount.marketingCode)) {
                        product.salesDiscountApplied = product.salesDiscountApplied + proportionalDiscountAmount;
                    } else {
                        product.marketingDiscountApplied = product.marketingDiscountApplied + proportionalDiscountAmount;
                    }
                }
                System.debug('product.marketingDiscountApplied: '+product.marketingDiscountApplied);
                
            }


        }

        // apply sobject saves (Separate lists at first, to avoid chunking errors)
        List < OpportunityLineItem > oppLineItemsToUpdate = new List < OpportunityLineItem > ();
        List < fw1__Invoice_Line__c > invoiceLineItemsToUpdate = new List < fw1__Invoice_Line__c > ();
        List < Opportunity > oppsToUpdate = new List < Opportunity > ();
        List < fw1__Invoice__c > invoicesToUpdate = new List < fw1__Invoice__c > ();
        List < Applied_Bundle__c > appliedBundlesToUpdate = new List < Applied_Bundle__c > ();

        
        for (Bundle bundle: this.bundlesOrdered) {
            appliedBundlesToUpdate.add(bundle.asAppliedBundle(this.orderContext));
            for (Product product: bundle.bundledProducts) {
                System.debug('product in bundle: '+JSON.serialize(product));
                if (this.orderContext=='Opportunity') {
                    oppLineItemsToUpdate.add(product.asOppLineItem());
                    System.debug('product.asOppLineItem(): '+JSON.serialize(product.asOppLineItem()));
                } else {
                    invoiceLineItemsToUpdate.add(product.asInvoiceLineItem());
                }
                
            }
        }

        System.debug('oppLineItemsToUpdate: '+JSON.serialize(oppLineItemsToUpdate));
        System.debug('invoiceLineItemsToUpdate: '+JSON.serialize(invoiceLineItemsToUpdate));

        for (Product product:this.productsOrdered) {
            if (this.orderContext=='Opportunity') {
                oppLineItemsToUpdate.add(product.asOppLineItem());
            } else {
                invoiceLineItemsToUpdate.add(product.asInvoiceLineItem());
            }
        }

        Decimal totalSalesDiscounts = 0;
        Decimal totalMarketingDiscounts = 0;
        for (Discount discount:this.discountsOrdered) {
            System.debug('discount ordered: '+JSON.serialize(discount));
            if (String.isBlank(discount.marketingCode)){
                totalSalesDiscounts-=discount.amount;
            } else {
                totalMarketingDiscounts-=discount.amount;
            }
        }

        System.debug('totalSalesDiscounts: '+totalSalesDiscounts);
        System.debug('totalMarketingDiscounts: '+totalMarketingDiscounts);

        System.debug('this.totalSalesDiscount: '+this.totalSalesDiscount);
        System.debug('this.totalMarketingDiscount: '+this.totalMarketingDiscount);

        if (this.orderContext=='Opportunity') {
            Opportunity opp = new Opportunity (
                Id=this.opportunityId,
                Marketing_Discount__c = totalMarketingDiscounts,
                Sales_Discount__c = totalSalesDiscounts
            );
            oppsToUpdate.add(opp);
        } else {
            fw1__Invoice__c invoice = new fw1__Invoice__c (
                Id=this.invoiceId,
                Marketing_Discount__c = totalMarketingDiscounts,
                Sales_Discount__c = totalSalesDiscounts
            );
            invoicesToUpdate.add(invoice);
        }

        List < SObject > sobjectsToUpdate = new List < SObject >();
        sobjectsToUpdate.addAll(oppLineItemsToUpdate);
        sobjectsToUpdate.addAll(invoiceLineItemsToUpdate);
        sobjectsToUpdate.addAll(oppsToUpdate);
        sobjectsToUpdate.addAll(invoicesToUpdate);
        sobjectsToUpdate.addAll(appliedBundlesToUpdate);

        System.debug('sobjectsToUpdate: '+JSON.serialize(sobjectsToUpdate));
        
        System.enqueueJob(new AsyncObjectUpdater_Queueable(sobjectsToUpdate));

    }
        

    public void removeDiscount(Discount discount) {
        System.debug('removeDiscount: '+JSON.serialize(discount));

        Set < ID > discountedBundleAndItemIds = new Set < ID >();
        // 1. First take off discounts from bundles and packages
        if (discount.type=='Bundle Specific') {
            Id bundleId = discount.bundleId;
            for (Bundle bundle: this.bundlesOrdered) {
                if (bundle.Id==bundleId) {
                    // put it in the correct field, sales or marketing
                    if (String.isBlank(discount.marketingCode)) {
                        bundle.salesDiscountApplied = 0;
                    } else {
                        bundle.marketingDiscountApplied = 0;
                    }
                }
                bundle.updateDiscounts(); //updates the individual product line items with discount data
            }

            // When a discount is applied this will update the underlying Opportunity Line Items.... and??
            List < SObject > objsToUpdate = new List < SObject >();
            
            for (Bundle bundle: this.bundlesOrdered) {
                if (bundle.Id==bundleId) {
                    for (Product product: bundle.bundledProducts) {
                        if (this.orderContext=='Opportunity') {
                            objsToUpdate.add(product.asOppLineItem());
                        } else {
                            objsToUpdate.add(product.asInvoiceLineItem());
                        }
                        
                    }
                }
            }

            System.enqueueJob(new AsyncObjectUpdater_Queueable(objsToUpdate));
        } else if (discount.type=='Product Specific') {
            List < SObject > objsToUpdate = new List < SObject >();
            for (Product product: this.productsOrdered) {
                if (product.Id==discount.productId) {
                    if (discount.method=='Amount') {
                        Decimal totalDiscountAmount = 0;
                        product.marketingDiscountApplied = totalDiscountAmount;
                    } else {
                        Decimal totalDiscountAmount = 0;
                        product.marketingDiscountApplied = totalDiscountAmount;
                    }

                    // UpdateCorresponding Sobjects
                    if (this.orderContext=='Opportunity') {
                        objsToUpdate.add(product.asOppLineItem());
                    } else {
                        objsToUpdate.add(product.asInvoiceLineItem());
                    }
                }
            }
            System.enqueueJob(new AsyncObjectUpdater_Queueable(objsToUpdate));
        } 

        Integer indexOfDiscountToDelete;
        for (Integer i=0;i<this.discountsOrdered.size();i++) {
            if (this.discountsOrdered[i].Id==discount.Id) {
                indexOfDiscountToDelete = i;
            }
        }
        System.debug('indexOfDiscountToDelete: '+indexOfDiscountToDelete);
        if (indexOfDiscountToDelete>=0) {
            this.discountsOrdered.remove(indexOfDiscountToDelete);
        }

        // Remove applied discount
        Applied_Discount__c discSobj = new Applied_Discount__c(
            Id = discount.appliedDiscountId
        );

        this.recalculateAllTotals();
        delete discSobj;

    } 

    public void removeBundles(List < Id > bundleIds) {
        List < SObject > sobjsToDelete = new List < SObject >();

        if (this.orderContext=='Opportunity') {
            List < Applied_Bundle__c > appliedBundles = [SELECT ID, Opportunity__c FROM Applied_Bundle__c WHERE Bundle__c in:bundleIds AND Opportunity__c =:this.opportunityId];
            sobjsToDelete.addAll(appliedBundles);
            List < OpportunityLineItem > lineItemsToDelete = [SELECT ID FROM OpportunityLineItem WHERE Applied_Bundle__c in:appliedBundles];
            sobjsToDelete.addAll(lineItemsToDelete);
            delete sobjsToDelete;
            this.initializeFromOpportunity(this.opportunityId);
        } else {
            List < Applied_Bundle__c > appliedBundles = [SELECT ID, Opportunity__c FROM Applied_Bundle__c WHERE Bundle__c in:bundleIds AND Invoice__c =:this.invoiceId];
            sobjsToDelete.addAll(appliedBundles);
            List < fw1__Invoice_Line__c > lineItemsToDelete = [SELECT ID FROM fw1__Invoice_Line__c WHERE Applied_Bundle__c in:appliedBundles];
            sobjsToDelete.addAll(lineItemsToDelete);
            delete sobjsToDelete;
            this.initializeFromInvoice(this.invoiceId);
        }

        recalculateAllTotals();
        
    }

    public void clearOrder() {
        //take off pay plan data
        this.removePaymentPlan();

        List < SObject > objectsToDelete = new List < SObject >();
        if (this.orderContext=='Opportunity') {
            objectsToDelete.addAll([SELECT ID FROM Applied_Bundle__c WHERE Opportunity__c =:this.opportunityId]);
            objectsToDelete.addAll([SELECT ID FROM OpportunityLineItem WHERE OpportunityId=:this.opportunityId]);
            objectsToDelete.addAll([SELECT ID FROM Applied_Discount__c WHERE Opportunity__c=:this.opportunityId]);
        } else {
            objectsToDelete.addAll([SELECT ID FROM Applied_Bundle__c WHERE Invoice__c =:this.invoiceId]);
            objectsToDelete.addAll([SELECT ID FROM fw1__Invoice_Line__c WHERE fw1__Invoice__c=:this.invoiceId]);
            objectsToDelete.addAll([SELECT ID FROM Applied_Discount__c WHERE Invoice__c=:this.invoiceId]);
        }

        delete objectsToDelete;
    }

    public void updateAdditionToFirstPayment(Decimal amount) {
        System.debug('amount: '+amount);
        this.paymentPlan.additionalAmountOnFirstPayment = amount;
        System.debug('this.paymentPlan.additionalAmountOnFirstPayment: '+this.paymentPlan.additionalAmountOnFirstPayment);
        this.updatePaymentPlan(this.paymentPlan);
    }

    public void updatePaymentPlan(PaymentPlan payPlan) {
        this.paymentPlan = payPlan;
        System.debug('this.finalPrice: '+this.finalPrice);
        System.debug('this.totalDueAtCheckout: '+this.totalDueAtCheckout);
        System.debug('payPlan: '+JSON.serialize(payPlan));
        System.debug('this.paymentPlan: '+this.paymentPlan);
        if (payPlan.additionalAmountOnFirstPayment==null) payPlan.additionalAmountOnFirstPayment = 0;
        if (this.finalPrice==null) this.finalPrice = 0;
        if (this.totalDueAtCheckout==null) this.totalDueAtCheckout = 0;

        this.paymentPlan.totalPrincipal = this.finalPrice - (payPlan.additionalAmountOnFirstPayment + this.totalDueAtCheckout);
        this.paymentPlan.recalculateInterest();
        
        fw1__Payment_Plan__c pp;
        if (payPlan.type=='Annual') {
            pp = [SELECT ID FROM fw1__Payment_Plan__c WHERE fw1__Schedule__c='Annually' LIMIT 1];
        } else {
            pp = [SELECT ID FROM fw1__Payment_Plan__c WHERE Number_of_Payments__c=:payPlan.totalNumberOfMonthlyPayments LIMIT 1];
        }


        if (this.orderContext=='Opportunity') {
            Opportunity opp = new Opportunity (
                Id = this.opportunityId,
                fw2__Payment_Plan__c = pp.Id, 
                Total_Monthly_Fees_new__c = this.paymentPlan.totalFees!=null ? this.paymentPlan.totalFees.setScale(2, System.RoundingMode.HALF_UP) : 0,
                Additional_Amount_on_First_Payment__c = payPlan.additionalAmountOnFirstPayment,
                Monthly_Payments_new__c = payPlan.monthlyPaymentAmount!=null ? payPlan.monthlyPaymentAmount.setScale(2, System.RoundingMode.HALF_UP) : 0
            );
    
            update opp;
        } else {
            fw1__Invoice__c inv = new fw1__Invoice__c (
                Id = this.invoiceId,
                fw1__Payment_Plan__c = pp.Id, 
                Total_Monthly_Fee_new__c = this.paymentPlan.totalFees!=null ? this.paymentPlan.totalFees.setScale(2, System.RoundingMode.HALF_UP) : 0,
                Additional_Amount_on_First_Payment__c = payPlan.additionalAmountOnFirstPayment,
                Monthly_Payments_new__c = payPlan.monthlyPaymentAmount!=null ? payPlan.monthlyPaymentAmount.setScale(2, System.RoundingMode.HALF_UP) : 0
            );
            update inv;

            List < fw1__Additional_Charge__c > existingCharges = [SELECT ID FROM fw1__Additional_Charge__c WHERE fw1__Invoice__c=:inv.Id AND Product__r.Name LIKE '%fee%'];


            List < fw1__Additional_Charge__c > chargesToDelete = new List < fw1__Additional_Charge__c >();
            if (existingCharges.size()>0) {
                chargesToDelete.addAll(existingCharges);
                delete chargesToDelete;
            } 

            if  (this.paymentPlan.totalFees>0) {
            // Invoice will also need the additional charge created/updated
                String strProductName = TOTAL_MONTHLY_FEES + ' - ' + this.paymentPlan.name;
                Product2 feeProduct = [SELECT ID FROM Product2 WHERE Name=:strProductName LIMIT 1]; //current interest fee product.  TODO: make this dynamic
                fw1__Additional_Charge__c charge = new fw1__Additional_Charge__c (
                    Name = TOTAL_MONTHLY_FEES + ' - ' + this.paymentPlan.name,
                    fw1__Invoice__c = inv.Id,
                    fw1__Fixed_Amount__c = this.paymentPlan.totalFees!=null ? this.paymentPlan.totalFees.setScale(2, System.RoundingMode.HALF_UP) : 0,
                    Product__c = feeProduct.Id
                );

                System.enqueueJob(new AsyncObjectInserter_Queueable(charge));
            }
        }
    }

    public void removePaymentPlan() {
        this.paymentPlan = null;

        if (this.orderContext=='Opportunity') {
            Opportunity opp = new Opportunity (
                Id = this.opportunityId,
                fw2__Payment_Plan__c = null,
                Total_Monthly_Fees_new__c = null
            );
            update opp;
        } else {
            fw1__Invoice__c inv = new fw1__Invoice__c (
                Id = this.invoiceId,
                fw1__Payment_Plan__c = null, 
                Total_Monthly_Fee_new__c = null
            );
            update inv;

            // Invoice will also need the additional charge created/updated
            List < Product2 > feeProduct = [SELECT ID FROM Product2 WHERE Name='Interest Fees' LIMIT 1];

            if (feeProduct.size()>0) {
                List < fw1__Additional_Charge__c > existingCharge = [SELECT ID FROM fw1__Additional_Charge__c WHERE fw1__Invoice__c=:inv.Id AND Product__c=:feeProduct[0].Id];
                if (existingCharge.size()==1) {
                    delete existingCharge;
                } 
            }
            
        }
    }

    // SUBCLASS
    public class SearchableItem {
        public ID Id;
        public String type; //Product, Bundle, Discount
        public ID productId;
        public ID bundleId;
        public ID discountId;
        public String name;
        public String description;
        public String contentsPreview;
        public Decimal bundleMembersListPrice; //total of bundle members' list prices
        public Decimal listPrice;
        public Bundle bundle;
        public Product product;
        public Discount discount;

        // Empty Constructor
        public SearchableItem () {
        }

        // Bundle Constructor
        public SearchableItem(Bundle__c bundle, Bundle_Pricebook_Entry__c bundlePricebookEntry, Map < ID, Decimal > productListPricesMap, Map < ID, List < Product_Relationship__c >> productsWithRelatedMap) {
            this.Id = bundle.Id;
            this.type = 'Bundle';
            this.bundleId = bundle.Id;
            this.name = bundle.Name;
            this.description = bundle.Description__c;
            this.listPrice = bundlePricebookEntry.List_Price__c;
            this.bundle = new Bundle(bundle,bundlePricebookEntry,productListPricesMap, productsWithRelatedMap);
            this.bundleMembersListPrice = this.bundle.bundleMembersListPriceTotal;

            for (Bundle_Member__c bundleMember: bundle.Bundle_Members__r) {
                if (this.contentsPreview==null) {
                    this.contentsPreview = bundleMember.Product__r.Name;
                } else {
                    this.contentsPreview = this.contentsPreview + ', ' + bundleMember.Product__r.Name;
                }

            }
        }

        
        // Product Constructor
        public SearchableItem(PricebookEntry pbe, Map < ID, List < Product_Relationship__c >> productsWithRelatedMap) {
            this.Id = pbe.Product2Id;
            this.type = 'Product';
            this.productId = pbe.Product2Id;
            this.name = pbe.Product2.Name;
            this.description = pbe.Product2.Description;
            // this.listPrice = pbe.UnitPrice;
            this.listPrice = pbe.UnitPrice;
            this.product = new Product(pbe, productsWithRelatedMap);
            this.contentsPreview = this.name;
        }

        // Discount Constructor
        public SearchableItem(Discount__c disc) {
            this.Id = disc.Id;
            this.type = 'Discount';
            this.discountId = disc.Id;
            this.name = disc.Name;
            this.description = disc.Description__c;
            this.discount = new Discount(disc);
        }

    }

    private void initializeFromOpportunity(ID recordId) {
        this.finalPrice = 0;
        this.totalListPriceDiscountableProducts = 0;
        this.totalListPriceNonDiscountableProducts = 0;
        this.totalListPriceBundlesAndDiscountableALaCarte = 0;
        this.upfrontAmount = 0;
        this.totalListPrice = 0;
        this.totalBundleSavings = 0;
        this.totalSalesDiscount = 0;
        this.totalMarketingDiscount = 0;
        this.totalDiscount = 0;
        this.totalDiscountPercentage = 0;
        this.paymentPlan = new PaymentPlan();
        this.productsOrdered = new List < Product >();
        this.bundlesOrdered = new List < Bundle >();
        this.discountsOrdered = new List < Discount >(); 

        String queryString =
        'SELECT '
        + Order.opportunityQueryFields()
        + ' FROM Opportunity WHERE Id = :recordId';

        Map<String, Object> bindVariables = new Map<String, Object>{'recordId' => recordId};

        Opportunity opp = Database.queryWithBinds(queryString, bindVariables, AccessLevel.USER_MODE);

        this.orderContext = 'Opportunity';
        this.opportunityId = opp.Id;
        this.pricebookId = opp.Pricebook2Id;
        this.finalPrice = opp.Amount;
        this.opportunityStage = opp.Stagename;
        this.totalSalesDiscount = opp.Sales_Discount__c==null? 0: opp.Sales_Discount__c;
        this.totalMarketingDiscount = opp.Marketing_Discount__c==null? 0: opp.Marketing_Discount__c;
        this.totalDiscount = this.totalSalesDiscount + this.totalMarketingDiscount;

        if (opp.fw2__Payment_Plan__c!=null) {
            this.paymentPlan = new PaymentPlan(opp);
            System.debug('this.paymentPlan in load: '+JSON.serialize(this.paymentPlan));
            this.upfrontAmount = this.paymentPlan.additionalAmountOnFirstPayment;
            this.paymentPlanSelected = this.paymentPlan.Id;
        }
        
        List < Bundle_Pricebook_Entry__c > bundlePricebookEntries = [SELECT ID, Bundle__c, Price_Book__c, List_Price__c FROM Bundle_Pricebook_Entry__c WHERE Order_Builder_Visible__c=true AND Price_Book__c=:this.pricebookId];
        Map < ID, Bundle_Pricebook_Entry__c > bundlePricebookEntriesByBundleId = new Map < ID, Bundle_Pricebook_Entry__c >();
        for (Bundle_Pricebook_Entry__c bpe: bundlePricebookEntries) {
            bundlePricebookEntriesByBundleId.put(bpe.Bundle__c, bpe);
        }

        List < ID > appliedBundleIdsFromOLIs = new List < ID >();
        Map < ID, List  < OpportunityLineItem > > oppLineItemsByAppliedBundleId = new Map < ID, List  < OpportunityLineItem > >();
        for (OpportunityLineItem oli: opp.OpportunityLineItems) {
            this.totalBundleSavings += oli.Bundle_Savings__c==null? 0: oli.Bundle_Savings__c;
            // Get the list price total for all products, regardless of bundled or not
            if (oli.Product2.Exempt_From_Discounts__c!=true) {
                this.totalListPriceDiscountableProducts +=(oli.ListPrice*oli.Quantity);
            }

            // separate bundled products from products ordered a la carte
            if (oli.Applied_Bundle__c!=null) {
                List < OpportunityLineItem > oppLineItems;
                
                if (oppLineItemsByAppliedBundleId.containsKey(oli.Applied_Bundle__c)) {
                    oppLineItems = oppLineItemsByAppliedBundleId.get(oli.Applied_Bundle__c);
                } else {
                    oppLineItems = new List < OpportunityLineItem >();
                }

                oppLineItems.add(oli);
                oppLineItemsByAppliedBundleId.put(oli.Applied_Bundle__c,oppLineItems);
                appliedBundleIdsFromOLIs.add(oli.Applied_Bundle__c);
            } else {
                Product prod = new Product(oli);
                this.productsOrdered.add(prod);
                this.totalListPrice += prod.listPriceAtQuantity;
                // Add up the discountable value of a la carte products
                if (oli.Product2.Exempt_From_Discounts__c!=true) {
                    this.totalListPriceBundlesAndDiscountableALaCarte+=prod.listPriceAtQuantity;
                } else {
                    this.totalListPriceNonDiscountableProducts+=prod.listPriceAtQuantity;
                }
            }
        }

        // Handle bundles
        Map < ID, Applied_Bundle__c > appliedBundleMap = getBundleData(appliedBundleIdsFromOLIs);
        if (oppLineItemsByAppliedBundleId.size()>0) {
            for (ID appliedBundleId: oppLineItemsByAppliedBundleId.keySet()) {
                Applied_Bundle__c appliedBundle = appliedBundleMap.get(appliedBundleId);
                Bundle bundle = new Bundle(appliedBundleMap.get(appliedBundleId), oppLineItemsByAppliedBundleId.get(appliedBundleId), bundlePricebookEntriesByBundleId.get(appliedBundle.Bundle__c));
                this.bundlesOrdered.add(bundle);
                this.totalListPrice += bundle.bundleMembersListPriceTotal;
                // Add up the discountable value of a bundles
                this.totalListPriceBundlesAndDiscountableALaCarte+=bundle.listPriceAtQuantity;
            }
        }

        System.debug('this.totalListPriceBundlesAndDiscountableALaCarte: '+this.totalListPriceBundlesAndDiscountableALaCarte);

        // Load applied discounts
        for (Applied_Discount__c appliedDisc: opp.Applied_Discounts__r) {
            Discount disc = new Discount (appliedDisc);
            this.discountsOrdered.add(disc);
        }
    }

    private void initializeFromInvoice(ID recordId) {
        this.finalPrice = 0;
        this.totalListPriceDiscountableProducts = 0;
        this.totalListPriceNonDiscountableProducts = 0;
        this.totalListPriceBundlesAndDiscountableALaCarte = 0;
        this.upfrontAmount = 0;
        this.totalListPrice = 0;
        this.totalBundleSavings = 0;
        this.totalSalesDiscount = 0;
        this.totalMarketingDiscount = 0;
        this.totalDiscount = 0;
        this.totalDiscountPercentage = 0;
        this.paymentPlan = new PaymentPlan();
        this.productsOrdered = new List < Product >();
        this.bundlesOrdered = new List < Bundle >();
        this.discountsOrdered = new List < Discount >(); 

        String queryString =
        'SELECT '
        + Order.invoiceQueryFields()
        + ' FROM fw1__Invoice__c WHERE Id = :recordId';

        Map<String, Object> bindVariables = new Map<String, Object>{'recordId' => recordId};

        fw1__Invoice__c invoice = Database.queryWithBinds(queryString, bindVariables, AccessLevel.USER_MODE);

        System.debug('invoice after inserting discount: '+JSON.serialize(invoice));

        this.orderContext = 'fw1__Invoice__c';
        this.opportunityId = invoice.fw1__Opportunity__c;
        this.invoiceId = invoice.Id;
        this.pricebookId = invoice.Price_Book__c;
        this.finalPrice = invoice.fw1__Net_Taxable_Amount__c;
        this.totalSalesDiscount = invoice.Sales_Discount__c==null? 0: invoice.Sales_Discount__c;
        this.totalMarketingDiscount = invoice.Marketing_Discount__c==null? 0: invoice.Marketing_Discount__c;
        this.totalDiscount = this.totalSalesDiscount + this.totalMarketingDiscount;

        System.debug('In reclaculate all: ');
        System.debug('this.totalSalesDiscount: '+this.totalSalesDiscount);
        System.debug('this.totalMarketingDiscount: '+this.totalMarketingDiscount);

        if (invoice.fw1__Payment_Plan__c!=null) {
            this.paymentPlan = new PaymentPlan(invoice);
            this.upfrontAmount = this.paymentPlan.additionalAmountOnFirstPayment;
            this.paymentPlanSelected = this.paymentPlan.Id;
        }
        
        List < Bundle_Pricebook_Entry__c > bundlePricebookEntries = [SELECT ID, Bundle__c, Price_Book__c, List_Price__c FROM Bundle_Pricebook_Entry__c WHERE Order_Builder_Visible__c=true AND Price_Book__c=:this.pricebookId];
        Map < ID, Bundle_Pricebook_Entry__c > bundlePricebookEntriesByBundleId = new Map < ID, Bundle_Pricebook_Entry__c >();
        for (Bundle_Pricebook_Entry__c bpe: bundlePricebookEntries) {
            bundlePricebookEntriesByBundleId.put(bpe.Bundle__c, bpe);
        }

        List < ID > appliedBundleIdsFromOLIs = new List < ID >();

        Map < ID, List  < fw1__Invoice_Line__c > > invoiceLineItemsByAppliedBundleId = new Map < ID, List  < fw1__Invoice_Line__c > >();

        for (fw1__Invoice_Line__c ili: invoice.fw1__Invoice_Lines__r) {
            this.totalBundleSavings += ili.Bundle_Savings__c;
            // Get the list price total for all products, regardless of bundled or not
            if (ili.fw2__Product__r.Exempt_From_Discounts__c!=true) {
                this.totalListPriceDiscountableProducts +=(ili.fw1__Unit_Price__c*ili.fw1__Quantity__c);
            }

            // separate bundled products from products ordered a la carte
            if (ili.Applied_Bundle__c!=null) {
                List < fw1__Invoice_Line__c > invoiceLineItems;
                
                if (invoiceLineItemsByAppliedBundleId.containsKey(ili.Applied_Bundle__c)) {
                    invoiceLineItems = invoiceLineItemsByAppliedBundleId.get(ili.Applied_Bundle__c);
                } else {
                    invoiceLineItems = new List < fw1__Invoice_Line__c >();
                }

                invoiceLineItems.add(ili);
                invoiceLineItemsByAppliedBundleId.put(ili.Applied_Bundle__c,invoiceLineItems);
                appliedBundleIdsFromOLIs.add(ili.Applied_Bundle__c);
            } else {
                System.debug('ili: '+JSON.serialize(ili));
                Product prod = new Product(ili);
                System.debug('prod: '+JSON.serialize(prod));
                this.productsOrdered.add(prod);
                this.totalListPrice += prod.listPriceAtQuantity;
                // Add up the discountable value of a la carte products
                if (ili.fw2__Product__r.Exempt_From_Discounts__c!=true) {
                    this.totalListPriceBundlesAndDiscountableALaCarte+=prod.listPriceAtQuantity;
                } else {
                    this.totalListPriceNonDiscountableProducts+=prod.listPriceAtQuantity;
                }
            }
        }

        // Handle bundles
        Map < ID, Applied_Bundle__c > appliedBundleMap = getBundleData(appliedBundleIdsFromOLIs);
        if (invoiceLineItemsByAppliedBundleId.size()>0) {
            for (ID appliedBundleId: invoiceLineItemsByAppliedBundleId.keySet()) {
                Applied_Bundle__c appliedBundle = appliedBundleMap.get(appliedBundleId);
                Bundle bundle = new Bundle(appliedBundleMap.get(appliedBundleId), invoiceLineItemsByAppliedBundleId.get(appliedBundleId), bundlePricebookEntriesByBundleId.get(appliedBundle.Bundle__c));
                this.bundlesOrdered.add(bundle);
                this.totalListPrice += bundle.bundleMembersListPriceTotal;
                // Add up the discountable value of a bundles
                this.totalListPriceBundlesAndDiscountableALaCarte+=bundle.listPriceAtQuantity;
            }
        }

        for (Applied_Discount__c appliedDisc: invoice.Applied_Discounts__r) {
            Discount disc = new Discount (appliedDisc);
            this.discountsOrdered.add(disc);
        }
    }

    private static Map < ID, Applied_Bundle__c > getBundleData(List < ID > appliedBundleIds) {
        return new Map < ID, Applied_Bundle__c >([SELECT ID, Bundle__c, Opportunity__c, Invoice__c, Quantity__c, Total_Price__c, Marketing_Discount__c, Sales_Discount__c, Bundle__r.Name, Bundle__r.Type__c, Bundle__r.Storage_Type__c, Bundle__r.Valid_From_Date__c, Bundle__r.Valid_To_Date__c FROM Applied_Bundle__c WHERE ID in:appliedBundleIds]);
    }

    private static string opportunityQueryFields() {
        return 'Id, Name, Stagename, CloseDate, Pricebook2Id, Amount, List_Price__c, Sales_Discount__c, Marketing_Discount__c, fw2__Payment_Plan__c, fw2__Payment_Plan__r.Name, fw2__Payment_Plan__r.Number_of_Payments__c,fw2__Payment_Plan__r.fw1__Schedule__c,Additional_Amount_on_First_Payment__c,Total_Amount_Due_at_Checkout__c,(SELECT ID, OpportunityId, Name, Applied_Bundle__c, ListPrice, Product2Id, Product2.Name, Product2.Exempt_From_Discounts__c, Product2.Description, Product2.Partial_Amount_Due_At_Checkout__c, Product2.Due_at_Checkout__c, Product2.Family, Product2.Is_Biobanking_Product__c, Product2.Eligible_for_Volume_Discounting__c, ProductCode, Quantity, UnitPrice, Subtotal, TotalPrice, Marketing_Discount__c, Sales_Discount__c, Bundle_Savings__c, Product_Code__c FROM OpportunityLineItems),(SELECT ID, Opportunity__c, Invoice__c, Amount__c, Percentage__c, Discount__r.Name, Discount__r.Active__c, Discount__r.Amount__c, Discount__r.Bundle__c, Discount__r.Description__c, Discount__r.Marketing_Code__c, Discount__r.Method__c, Discount__r.Minimum_Order_Amount__c, Discount__r.Percentage__c, Discount__r.Product__c, Discount__r.Type__c, Discount__r.Valid_From__c, Discount__r.Valid_To__c, Discount__r.System_Applied__c, Discount__r.Services_Count__c, Discount__r.Applicable_Storage_Type__c FROM Applied_Discounts__r),(SELECT Id, Opportunity__c, Bundle__c FROM Applied_Bundles__r)';
    }

    private static string invoiceQueryFields() {
        return 'Id, fw1__Opportunity__c, Name, Price_Book__c, fw1__Net_Taxable_Amount__c, Sales_Discount__c, Marketing_Discount__c, fw1__Payment_Plan__c, fw1__Payment_Plan__r.Name, fw1__Payment_Plan__r.Number_of_Payments__c,fw1__Payment_Plan__r.fw1__Schedule__c, Additional_Amount_on_First_Payment__c,fw1__Total_Paid_Amount__c, fw1__Net_Amount__c, (SELECT ID, fw1__Amount__c, fw1__Invoice__c, Name, Applied_Bundle__c, fw1__Unit_Price__c, fw2__Product__c, fw2__Product__r.Name, fw2__Product__r.Exempt_From_Discounts__c, fw2__Product__r.Description, fw2__Product__r.Partial_Amount_Due_At_Checkout__c, fw2__Product__r.Due_at_Checkout__c, fw2__Product__r.ProductCode, fw2__Product__r.Family, fw2__Product__r.Is_Biobanking_Product__c, fw2__Product__r.Eligible_for_Volume_Discounting__c, fw1__Quantity__c, Marketing_Discount__c, Sales_Discount__c, Bundle_Savings__c FROM fw1__Invoice_Lines__r),(SELECT ID, Opportunity__c, Invoice__c, Amount__c, Percentage__c, Discount__r.Name, Discount__r.Active__c, Discount__r.Amount__c, Discount__r.Bundle__c, Discount__r.Description__c, Discount__r.Marketing_Code__c, Discount__r.Method__c, Discount__r.Minimum_Order_Amount__c, Discount__r.Percentage__c, Discount__r.Product__c, Discount__r.Type__c, Discount__r.Valid_From__c, Discount__r.Valid_To__c, Discount__r.System_Applied__c, Discount__r.Services_Count__c, Discount__r.Applicable_Storage_Type__c FROM Applied_Discounts__r),(SELECT Id, Opportunity__c, Bundle__c FROM Applied_Bundles__r)';
    }


}