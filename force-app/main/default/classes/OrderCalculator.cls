// Order Calculator

public class OrderCalculator {

    public enum PlanType { ONETIME, MONTHLY, HYBRID }

    public static Integer sumOfStemProducts;

    public static OrderCalculator.Output calculate ( OrderCalculator.Input input ) {
        System.debug('====================================================In calculate');
        System.debug('input: '+JSON.serialize(input));

        // 0a. build list of products based in input
        Set < string > productCodes = new Set < string > ();          

        //Set nulls to zeros
        input.exosomesQuantity = input.exosomesQuantity==null ? 0 : input.exosomesQuantity;
        input.momPremiumGenomicsQuantity = input.momPremiumGenomicsQuantity==null ? 0 : input.momPremiumGenomicsQuantity;
        input.momStandardGenomicsQuantity = input.momStandardGenomicsQuantity==null ? 0 : input.momStandardGenomicsQuantity;
        input.newbornGenomeQuantity = input.newbornGenomeQuantity==null ? 0 : input.newbornGenomeQuantity;
        input.newbornPanelQuantity = input.newbornPanelQuantity==null ? 0 : input.newbornPanelQuantity;
        input.maternalExosomesQuantity = input.maternalExosomesQuantity==null ? 0 : input.maternalExosomesQuantity;

        //Collection kit if ordering stem services        
        sumOfStemProducts = input.cordBlood2Quantity + input.cordTissueQuantity + input.placenta2Quantity + input.exosomesQuantity + input.maternalExosomesQuantity;        
        if (sumOfStemProducts > 0){
            productCodes.add('CollKit');
        }  

        // 0. validate Input fields and return exception if required fields are not present and set defaults
        input.emptyFieldValidation ();
        input.fieldValueValidation ();

        // SHIPPING
        if (input.shippingType == 'Standard') {
            productCodes.add ( 'StndShip' );
        } else if (input.shippingType == 'Rush') {
            productCodes.add ( 'RushShip' );
        }
        
        // ANNUAL STORAGE - use number of products 
        if (input.storagePlan == 'ASP') {
            if(sumOfStemProducts == 1){
                productCodes.add ('ASP');
            } else if(sumOfStemProducts == 2) {
                productCodes.add ('ASP2');
            } else if(sumOfStemProducts == 3) {
                productCodes.add ('ASP3');
            } else if(sumOfStemProducts == 4) {
                productCodes.add ('ASP4');
            } 
        }

        //Process Bundles First
        //The GenSecure Family Plan
        if (input.cordBlood2Quantity > 0 && input.cordTissueQuantity > 0 && input.placenta2Quantity > 0 && input.exosomesQuantity > 0 && input.momPremiumGenomicsQuantity > 0 && input.newbornPanelQuantity >0 ) {
            System.debug('The GenSecure Family Plan SELECTED');
            productCodes.add ( 'CBCTPEXMM' );
            // add the storage plan
            if (input.storagePlan=='20YPP') {
                productCodes.add ( 'CBCTPEXMM20Yr' );
            } else if (input.storagePlan=='LTS') {
                productCodes.add ( 'CBCTPEXMMLifetime' );
            }
        }
        // Ultimate Protection Plan
        else if (input.cordBlood2Quantity > 0 && input.cordTissueQuantity > 0 && input.placenta2Quantity > 0 && input.exosomesQuantity > 0) {
            System.debug('Ultimate Protection Plan SELECTED');
            productCodes.add ( 'CBCTPEX' );
            // add the storage plan
            if (input.storagePlan=='20YPP') {
                productCodes.add ( 'CBCTPEX20Yr' );
            } else if (input.storagePlan=='LTS') {
                productCodes.add ( 'CBCTPEXLifetime' );
            }
        }
        //  The Family Safeguard Plan
        else if (input.cordBlood2Quantity > 0 && input.cordTissueQuantity > 0 && input.placenta2Quantity > 0) {
            System.debug('Family Safeguard Plan SELECTED');
            productCodes.add ( 'CBCTP' );
            // add the storage plan
            if (input.storagePlan=='20YPP') {
                productCodes.add ( 'CBCTP20Yr' );
            } else if (input.storagePlan=='LTS') {
                productCodes.add ( 'CBCTPLifetime' );
            }
        // CORD BLOOD + CORD TISSUE
        } else if (input.cordBlood2Quantity > 0 && input.cordTissueQuantity > 0 && itemCountNullOrZero(input.placenta2Quantity)) {
            System.debug('CORD BLOOD + CORD TISSUE SELECTED');
            productCodes.add ( 'CBCT' );
            // add the storage plan
            if (input.storagePlan=='20YPP') {
                productCodes.add ( 'CBCT20Yr' );
            } else if (input.storagePlan=='LTS') {
                productCodes.add ( 'CBCTLifetime' );
            }
        } 
        
        // MOM & ME (check that doesn't already have the GenSecure Family Plan which is incluseive of M&M)
        if (!productCodes.contains('CBCTPEXMM') && input.momPremiumGenomicsQuantity > 0 && input.newbornPanelQuantity > 0) {
            System.debug('MOM & ME SELECTED');
            productCodes.add ( 'MM' );
        }


        //Run through all non-bundle products, if selected and not already included via bundle, add a la carte 
        input.countOfNonBundledBiobankingProducts = 0;
        if (!productCodes.contains('CBCTPEXMM') && !productCodes.contains('CBCTPEX') && !productCodes.contains('CBCTP') && !productCodes.contains('CBCT') &&  input.cordBlood2Quantity > 0){
            System.debug('CORD BLOOD SELECTED WITH NO BUNDLE');
            productCodes.add ( 'CB' );
            input.countOfNonBundledBiobankingProducts++;
                // add the storage plan
            if (input.storagePlan=='20YPP') {
                productCodes.add ( 'CB20Yr' );
            } else if (input.storagePlan=='LTS') {
                productCodes.add ( 'CBLifetime' );
            }
        } 

        if (!productCodes.contains('CBCTPEXMM') && !productCodes.contains('CBCTPEX') && !productCodes.contains('CBCTP') && !productCodes.contains('CBCT') && input.cordTissueQuantity > 0 ){
            System.debug('CORD TISSUE SELECTED WITH NO BUNDLE');
            input.countOfNonBundledBiobankingProducts++;
            productCodes.add ( 'CT' );
                // add the storage plan
            if (input.storagePlan=='20YPP') {
                productCodes.add ( 'CT20Yr' );
            } else if (input.storagePlan=='LTS') {
                productCodes.add ( 'CTLifetime' );
            }
        }

        if (!productCodes.contains('CBCTPEXMM') && !productCodes.contains('CBCTPEX') && !productCodes.contains('CBCTP') && input.placenta2Quantity > 0 ){
            System.debug('PLACENTA SELECTED WITH NO BUNDLE');
            input.countOfNonBundledBiobankingProducts++;
            productCodes.add ( 'PT' );
                // add the storage plan
            if (input.storagePlan=='20YPP') {
                productCodes.add ( 'P20Yr' );
            } else if (input.storagePlan=='LTS') {
                productCodes.add ( 'PLifetime' );
            }
        }
        
        if (!productCodes.contains('CBCTPEXMM') && !productCodes.contains('CBCTPEX') && input.exosomesQuantity>0) {
            System.debug('Exosomes SELECTED WITH NO BUNDLE');
            productCodes.add ('EX');
            input.countOfNonBundledBiobankingProducts++;
            // add the storage plan
            if (input.storagePlan=='20YPP') {
                productCodes.add ( 'EX20Yr' );
            } else if (input.storagePlan=='LTS') {
                productCodes.add ( 'EXLifetime' );
            }
        }

        
        if (!productCodes.contains('CBCTPEXMM') && !productCodes.contains('MM') &&  input.momPremiumGenomicsQuantity>0) {
            productCodes.add ('MGP');
        }
        if (input.momStandardGenomicsQuantity>0) {
            productCodes.add ('MGS');
        }
        if (input.newbornGenomeQuantity>0) {
            productCodes.add ('NBG');
        }
        if (!productCodes.contains('CBCTPEXMM') && !productCodes.contains('MM') && input.newbornPanelQuantity>0) {
            productCodes.add ('NBP');
        }

        // Maternal exosomes
        if (input.maternalExosomesQuantity>0){
            System.debug('Adding MXO to productCodes...');
            productCodes.add ('MXO');
            if (input.storagePlan=='20YPP') {
                productCodes.add ( 'MXO20Yr' );
            } else if (input.storagePlan=='LTS') {
                productCodes.add ( 'MXOLifetime' );
            }
        }

        integer sumOfProducts = input.cordBlood2Quantity + input.cordTissueQuantity + input.placenta2Quantity + input.exosomesQuantity + input.momPremiumGenomicsQuantity + input.momStandardGenomicsQuantity + input.newbornGenomeQuantity + input.newbornPanelQuantity + input.maternalExosomesQuantity;

        System.debug('productCodes: '+productCodes);
        if (productCodes.contains('CBCT') && productCodes.contains('EX')) {
            input.containsCBCTEX = true;
        } else {
            input.containsCBCTEX = false;
        }
        // 1. get unit prices from pricebook (products and storage plan)
        // if pricebook is null on input, uses the Org site default
        Id priceBookId;
        //Set to current default Pricebook version (removed check for slider calculator)     
        priceBookId = getPriceBookId ( null );
        
        List < LineItem > lineItems = getUnitPricesByPriceBook ( priceBookId, productCodes );
        lineItems = setQuantities ( lineItems, input);
        
        // 2. Lookup Payment Plan rules
        PaymentPlan paymentPlan = getPaymentPlan ( input.paymentPlan );  //not compatible with web slider

        // 3. Lookup Monthly fee Rules
        decimal monthlyFees = getMonthlyFees ( lineItems, paymentPlan ); //not compatible with web slider
        
        // 4. With product quantities, calculate quantity * unit price
        lineItems = setLineItemSubTotal ( lineItems ); //compatible

        // Fill in the Genomics Upfront
        input.genomicsUpfront = 0;
        for (LineItem li: lineItems) {
            if (li.genomicsUpfront!=null && li.genomicsUpfront>0) {
                input.genomicsUpfront += li.genomicsUpfront;                
            }
        }
        
        // 5. Calculate pricing
        return new Output ( lineItems, input, paymentPlan, monthlyFees, sumOfProducts ); //not compatible
    }

    private static Boolean itemCountNullOrZero (Integer count) {
        if (count==null || count==0) {
            return true;
        } else {
            return false;
        }
    }

    // returns a PriceBook ID related to Price Book string
    public static Id getPriceBookId ( Id priceBookId ) {
        // note: if null, look at Custom Setting (Americord Settings)
        // for value
        if ( priceBookId == null ) {
            // custom setting query
            Americord_Settings__c setting = Americord_Settings__c.getInstance ();
            if ( setting == null ) {
                throw new OrderCalculatorException ( 'OrderCalculator.getPriceBookId', 
                                                        'Failed to load default price book id from Americord Settings', 
                                                        OrderCalculatorException.Severity.ALERT 
                                                    );
            } else {
                priceBookId = setting.Current_Price_Book__c;
            }
        }
        return priceBookId;
    }
    
    public static List < LineItem > getUnitPricesByPriceBook ( Id priceBookId, Set < string > productCodes ) {

        List < LineItem > returnLineItems = new List < LineItem > ();
        
        List < PricebookEntry > pricebookEntries = [ SELECT Id, UnitPrice, Product2Id, Product2.ProductCode, Product2.Family, Product2.Name, Product2.Genomics_Upfront_Fee__c, Product2.Is_Biobanking_Product__c, Product2.Is_Genomics_Product__c
                                                        FROM PricebookEntry 
                                                        WHERE Product2.ProductCode IN : productCodes 
                                                        AND Pricebook2Id =: pricebookId ];

        for ( PricebookEntry pe : pricebookEntries ) {
            System.debug('PricebookEntry: '+pe);
            LineItem li = new LineItem ();
            li.unitPrice = pe.UnitPrice;
            li.productId = pe.Product2Id;
            li.productCode = pe.Product2.ProductCode;
            li.category = pe.Product2.Family;
            li.productName = pe.Product2.Name;
            li.genomicsUpfront = pe.Product2.Genomics_Upfront_Fee__c;
            li.isBiobankingProduct = pe.Product2.Is_Biobanking_Product__c;
            li.isGenomicsProduct = pe.Product2.Is_Genomics_Product__c;
            returnLineItems.add ( li );
        }

        return returnLineItems;
    }
    
    private static List < LineItem > setQuantities ( List < LineItem > lineItems, Input input) {

        for ( LineItem li : lineItems ) {
            //genomics products are one per order and do not adjust based on number of births
            if (li.productCode=='MGP' || li.productCode=='MGS' || li.productCode=='NBG' || li.productCode=='NBP' || li.productCode=='MXO') {
                li.quantity = 1;
            } 
            else {
                li.quantity = input.birthCount;
            }
        }

        return lineItems;
    }
    
    // May 2022 the payment options have been limited to just a few, only one of which (48m) has a fee associated.  Switching from using the Monthly_Fee__mdt table to calculating here based on the interest rate for the Payment_Plan__mdt
    public static decimal getMonthlyFees ( List < LineItem > lineItems, PaymentPlan paymentPlan ) {
        
        // Monthly_Fee__mdt
        decimal returnFee;
        // if Payment Plan has one payment, there are no monthly fees
        if (paymentPlan.numberOfPayments == 1 || paymentPlan.rate==null || paymentPlan.rate==0){
            return 0;
        }

        Decimal baseCost = 0; //This is the cost of processing + Storage.  The kit and shipping fees are charged up front and not subject to financing
    
        for (LineItem li: lineItems) {
            if (li.category == 'Product' || li.category == 'Storage') {
                baseCost += (li.unitPrice * li.quantity);
            }
        }

        // convert rate to monthly
        Decimal rate = (paymentPlan.rate/100)/12;
        Decimal monthlyWithoutInterest = baseCost/paymentPlan.numberOfPayments;
        Decimal paymentWithInterest = (baseCost * rate) / (1 - Math.pow(1 + Double.valueOf(rate), - paymentPlan.numberOfPayments));

        //Subtract the monthly cost without interest from the monthly with-interest fee to get the amount of interest being charged each month
        returnFee = (paymentWithInterest-monthlyWithoutInterest).setScale(2);

        return returnFee;

    }
    
    private static PaymentPlan getPaymentPlan ( string paymentPlan ) {
        PaymentPlan returnPaymentPlan;

        List < Payment_Plan_Info__mdt > ppInfoList = [ SELECT Id, Number_of_Fees__c, Number_of_Payments__c, Percent_of_First_Payment__c, MasterLabel, Type__c, Rate__c
                                                        FROM Payment_Plan_Info__mdt 
                                                        WHERE MasterLabel =: paymentPlan ];
        if ( ppInfoList.size () != 1 ) {
            throw new OrderCalculatorException ( 'OrderCalculator.getPaymentPlan', 
                                                    'Found ' + ppInfoList.size () + ' Payment Plan Info records. If you are switching from Ameriflex Calculator, make new selections, then Calculate & Save.', 
                                                    OrderCalculatorException.Severity.INFO 
                                                );
        } else {
            returnPaymentPlan = new PaymentPlan ();
            returnPaymentPlan.numberOfPayments = Integer.valueOf ( ppInfoList [0].Number_of_Payments__c );
            returnPaymentPlan.numberOfFees = Integer.valueOf ( ppInfoList [0].Number_of_Fees__c );
            returnPaymentPlan.percentOfFirstPayment = ppInfoList [0].Percent_of_First_Payment__c;
            returnPaymentPlan.rate = ppInfoList [0].Rate__c;
            returnPaymentPlan.id = ppInfoList [0].Id;
            // calculate Plan Type
            if ( ppInfoList [0].Type__c == 'HYBRID' ) {
                returnPaymentPlan.planType = OrderCalculator.PlanType.HYBRID;
            } else if ( ppInfoList [0].Type__c == 'MONTHLY' ) {
                returnPaymentPlan.planType = OrderCalculator.PlanType.MONTHLY;
            } else if ( ppInfoList [0].Type__c == 'ONETIME' ) {
                returnPaymentPlan.planType = OrderCalculator.PlanType.ONETIME;
            } else {
                throw new OrderCalculatorException ( 'OrderCalculator.getPaymentPlan',
                                                        'Could not find a payment plan type ' + ppInfoList [0].MasterLabel,
                                                        OrderCalculatorException.Severity.ALERT
                                                    );
            }

        }
        
        return returnPaymentPlan;
    }
    
    private static List < LineItem > setLineItemSubTotal ( List < LineItem > lineItems ) {
        // 4. With product quantities, calculate quantity * unit price
        for ( LineItem li : lineItems ) {
            li.lineItemSubTotal = ( li.quantity * li.unitPrice );
        }
        return lineItems;
    }
    
        
    public class LineItem {
        
        public decimal unitPrice;
        public Id productId;
        public string category;
        public string productCode;
        public string productName;
        public integer quantity;
        public decimal lineItemSubTotal;
        public decimal genomicsUpfront;
        public boolean isGenomicsProduct;
        public boolean isBiobankingProduct;
        
    }
    
    public class PaymentPlan {
        public integer numberOfPayments;
        public integer numberOfFees;
        public decimal percentOfFirstPayment; // note 50% looks like 50
        public OrderCalculator.PlanType planType;
        public decimal rate;
        public Id id;
    }
    
    // Input Class
    // All parameters affecting Calculator should be defined in this class
    // This class is to be mostly a structural entity, may have input validation routines as necessary
    public class Input {
        
        public integer birthCount;
        public string birthCountString;
        
        // product quantities
        public integer cordBlood2Quantity; // Product Code : CB
        public integer cordTissueQuantity; // Product Code : CT
        public integer placenta2Quantity;  // Product Code : PAM
        public integer exosomesQuantity;  // Product Code : EX
        public integer momPremiumGenomicsQuantity;  // Product Code : MGP
        public integer momStandardGenomicsQuantity;  // Product Code : MGS
        public integer newbornGenomeQuantity;  // Product Code : NBG
        public integer newbornPanelQuantity;  // Product Code : NBP
        public integer maternalExosomesQuantity; // Product Code : MXO
        public integer countOfNonBundledBiobankingProducts;
        public boolean containsCBCTEX; //There is one combo of biobanking products that does not match the pattern of Bundles OR non-bundleed biobanking discounts.  This is the "fix" for that pending a rearchitecture/refactor of the whole pricing/bundling discounting process.

        // plan attributes
        public string storagePlan;  // Product Code : ASP (annual storage), 20YPP, LTS (lifetime storage)
        public string paymentPlan;  // Abbrev = 20YPP, 24M, 36M, 48M, HY12, HY18, AF, FLEX6, FLEX240 (Annual Fee)
        // financial attributes
        public string discountCode;
        public decimal salesDiscount;
        public decimal depositAmount;
        public decimal genomicsUpfront;
        //shipping
        public string shippingType;
        // other attributes
        public Id priceBookId;
        public string billingNotes;
        public Decimal pricingVersion;

        // loading attributes
        public string dataSource;
        public string orderType;
        public Id recordId;

        public Input () {
            this.cordBlood2Quantity = 0;
            this.cordTissueQuantity = 0;
            this.placenta2Quantity = 0;
            this.exosomesQuantity = 0;
            this.momPremiumGenomicsQuantity = 0;
            this.momStandardGenomicsQuantity = 0;
            this.newbornGenomeQuantity = 0;
            this.newbornPanelQuantity = 0;
            this.maternalExosomesQuantity = 0;
            this.salesDiscount = 0;
            this.depositAmount = 0;
            this.genomicsUpfront = 0;
        }

        public Input ( Opportunity opp ) {
            // set input values
            this.birthCount = birthCountTranslation ( opp.Number_of_Births__c );
            this.birthCountString = opp.Number_of_Births__c;
            this.cordBlood2Quantity = opp.Cord_Blood_2_0__c==null ? 0 : Integer.valueOf ( opp.Cord_Blood_2_0__c );
            this.cordTissueQuantity = opp.Cord_Tissue__c==null ? 0 : Integer.valueOf ( opp.Cord_Tissue__c );
            this.placenta2Quantity = opp.Placenta_2_0__c==null ? 0 : Integer.valueOf ( opp.Placenta_2_0__c );

            this.exosomesQuantity = opp.Exosomes__c==null ? 0 : Integer.valueOf ( opp.Exosomes__c );            
            this.momPremiumGenomicsQuantity = opp.My_Genome_Premium__c==null ? 0 : Integer.valueOf ( opp.My_Genome_Premium__c );
            this.momStandardGenomicsQuantity = opp.My_Genome_Standard__c==null ? 0 : Integer.valueOf ( opp.My_Genome_Standard__c );
            this.newbornGenomeQuantity = opp.Newborn_Genome__c==null ? 0 : Integer.valueOf ( opp.Newborn_Genome__c );
            this.newbornPanelQuantity = opp.Newborn_Panel__c==null ? 0 : Integer.valueOf ( opp.Newborn_Panel__c );

            this.maternalExosomesQuantity = opp.Maternal_Exosomes__c==null ? 0 : Integer.valueOf ( opp.Maternal_Exosomes__c );

            this.storagePlan = opp.Storage_Plan__c;
            this.paymentPlan = opp.Payment_Plans__c;
            this.discountCode = opp.Coupon_Code__c;
            this.salesDiscount = opp.Sales_Discount__c;
            this.depositAmount = opp.Deposit__c;
            this.genomicsUpfront = opp.Genomics_Upfront_Fee__c;

            this.shippingType = opp.Shipping_Type__c;
            this.priceBookId = opp.PriceBook2Id;
            this.dataSource = 'Opportunity';
            this.orderType = 'n/a';
            this.recordId = opp.Id;
        }

        public Input ( fw1__Invoice__c cbo, boolean forceOrderEnrolled ) {
            boolean isEnrolled = true;
            if ( cbo.Baby_Born__c ) {
                if ( forceOrderEnrolled ) {
                    // this forces the selection panel to render data from the enrolled set of fields
                    isEnrolled = true;
                } else {
                    isEnrolled = false;
                }
            }

            // map common fields
            this.birthCount = birthCountTranslation ( cbo.Number_of_Births__c );
            this.birthCountString = cbo.Number_of_Births__c;
            this.salesDiscount = cbo.Sales_Discount__c;
            this.depositAmount = cbo.Deposit__c;
            this.priceBookId = cbo.Price_Book__c;
            this.recordId = cbo.Id;
            this.billingNotes = cbo.Billing_Notes__c;
            this.shippingType = cbo.Shipping_Type__c;        


            // map specific fields
            if ( isEnrolled ) {
                this.cordBlood2Quantity = Integer.valueOf ( cbo.Cord_Blood_2_0_Ordered__c );
                this.cordTissueQuantity = Integer.valueOf ( cbo.Cord_Tissue_Ordered__c );
                this.placenta2Quantity = Integer.valueOf ( cbo.Placenta_2_0_Ordered__c );

                this.exosomesQuantity = cbo.Exosomes_Ordered__c==null ? 0:  Integer.valueOf ( cbo.Exosomes_Ordered__c );
                this.momPremiumGenomicsQuantity = cbo.My_Genome_Premium_Ordered__c==null ? 0 :  Integer.valueOf ( cbo.My_Genome_Premium_Ordered__c );
                this.momStandardGenomicsQuantity = cbo.My_Genome_Standard_Ordered__c==null ? 0 :  Integer.valueOf ( cbo.My_Genome_Standard_Ordered__c );
                this.newbornGenomeQuantity = cbo.Newborn_Genome_Ordered__c==null ? 0 :  Integer.valueOf ( cbo.Newborn_Genome_Ordered__c );
                this.newbornPanelQuantity = cbo.Newborn_Panel_Ordered__c==null ? 0 :  Integer.valueOf ( cbo.Newborn_Panel_Ordered__c );

                this.maternalExosomesQuantity = cbo.Maternal_Exosomes_Ordered__c==null ? 0 : Integer.valueOf( cbo.Maternal_Exosomes_Ordered__c );
                
                this.storagePlan = cbo.Storage_Plan_Ordered__c;
                this.paymentPlan = cbo.Payment_Plan_Ordered__c;

                this.orderType = 'Enrolled';
            } else {
                this.cordBlood2Quantity = Integer.valueOf ( cbo.Cord_Blood_2_0_Stored__c );
                this.cordTissueQuantity = Integer.valueOf ( cbo.Cord_Tissue_Stored__c );
                this.placenta2Quantity = Integer.valueOf ( cbo.Placenta_2_0_Stored__c );

                this.exosomesQuantity = cbo.Exosomes_Stored__c==null ? 0:  Integer.valueOf ( cbo.Exosomes_Stored__c );
                this.momPremiumGenomicsQuantity = cbo.My_Genome_Premium_Stored__c==null ? 0 :  Integer.valueOf ( cbo.My_Genome_Premium_Stored__c );
                this.momStandardGenomicsQuantity = cbo.My_Genome_Standard_Stored__c==null ? 0 :  Integer.valueOf ( cbo.My_Genome_Standard_Stored__c );
                this.newbornGenomeQuantity = cbo.Newborn_Genome_Stored__c==null ? 0 :  Integer.valueOf ( cbo.Newborn_Genome_Stored__c );
                this.newbornPanelQuantity = cbo.Newborn_Panel_Stored__c==null ? 0 :  Integer.valueOf ( cbo.Newborn_Panel_Stored__c );

                this.maternalExosomesQuantity = cbo.Maternal_Exosomes_Stored__c==null ? 0 : Integer.valueOf ( cbo.Maternal_Exosomes_Stored__c );

                this.storagePlan = cbo.Storage_Plan_Stored__c;
                this.paymentPlan = cbo.Payment_Plan_Stored__c;
                
                this.orderType = 'Stored';
            }

            this.dataSource = 'CordBloodOrder';
            
        }

        // returns true if the input object is valid for calculating
        // throws specific errors if not
        public void emptyFieldValidation () {
            List < string > emptyFields = new List < string > ();
            // birth count
            if ( this.birthCount == null ) {
                emptyFields.add ( 'Birth Count' );
            }
            // product quantities
            if ( this.cordBlood2Quantity == null ) {
                emptyFields.add ( 'Cord Blood 2.0 Quantity' );
            }
            if ( this.cordTissueQuantity == null ) {
                emptyFields.add ( 'Cord Tissue Quantity' );
            }
            if ( this.placenta2Quantity == null ) {
                emptyFields.add ( 'Placenta 2.0 Quantity' );
            }


            // if ( this.exosomesQuantity == null ) {
            //     emptyFields.add ( 'Exosomes Quantity' );
            // }
            // if ( this.momPremiumGenomicsQuantity == null ) {
            //     emptyFields.add ( 'My Genetics Premium Quantity' );
            // }
            // if ( this.momStandardGenomicsQuantity == null ) {
            //     emptyFields.add ( 'My Genetics Standard Quantity' );
            // }
            // if ( this.newbornGenomeQuantity == null ) {
            //     emptyFields.add ( 'Newborn Genome Quantity' );
            // }
            // if ( this.newbornPanelQuantity == null ) {
            //     emptyFields.add ( 'Newborn Panel Quantity' );
            // }


            // storage and payment plans
            if ( this.storagePlan == null ) {
                emptyFields.add ( 'Storage Plan' );
            }
            if ( this.paymentPlan == null ) {
                emptyFields.add ( 'Payment Plan' );
            }
            // return results
            if ( emptyFields.size () > 0 ) {
                throw new OrderCalculatorException ( 'OrderCalculator.Input.emptyFieldValidation', 
                                                        'The following fields must have a value to calculate: ' + string.join ( emptyFields, ',' ), 
                                                        OrderCalculatorException.Severity.ALERT 
                                                    );
            }
            // Storage or Shipping Set to None
            if((this.storagePlan == 'None' || this.shippingType == 'None') && 
              (this.cordBlood2Quantity>0 || this.placenta2Quantity>0 || this.cordTissueQuantity > 0 || this.exosomesQuantity > 0 || this.maternalExosomesQuantity > 0)){
                throw new OrderCalculatorException ( 'OrderCalculator.Input.emptyFieldValidation', 
                                                        'You must select a Storage Plan and a Shipping Type if CB/CT/PT/EX/MXO are selected.', 
                                                        OrderCalculatorException.Severity.ALERT 
                                                    );
              }           
            // Annual Storage/Shipping Check
            if((this.storagePlan == 'ASP' && this.paymentPlan != 'AF') || (this.storagePlan != 'ASP' && this.paymentPlan == 'AF')){
                throw new OrderCalculatorException ( 'OrderCalculator.Input.emptyFieldValidation', 
                                                        'You must select Annual for both Storage and Payment Plan.', 
                                                        OrderCalculatorException.Severity.ALERT 
                                                    );
              }                   

        }

        public void fieldValueValidation () {
            // determine if we are Opp, Order/Enrolled or Order/Stored
            boolean isOrderStored = false;

            if (( this.dataSource == 'CordBloodOrder' ) && ( this.orderType == 'Stored' )) {
                isOrderStored = true;
            }

            List < integer > validOptions = new List < integer > ();
            validOptions.add ( 0 );
            validOptions.add ( 1 );
            integer atLeastOneItemValue = 0;

            // setup validation rules based on birth count and Order/Stored
            if ( this.birthCount == 1 ) {
                atLeastOneItemValue = 1;
            } else if ( this.birthCount == 2 ) {
                validOptions.add ( 2 );
                if ( isOrderStored == false ) {
                    atLeastOneItemValue = 2;
                } else {
                    atLeastOneItemValue = 1;
                }
            } else if ( this.birthCount == 3 ) {
                validOptions.add ( 3 );
                validOptions.add ( 2 );
                if ( isOrderStored == false ) {
                    atLeastOneItemValue = 3;
                } else {
                    atLeastOneItemValue = 1;
                }
            }

            // validate
            // this.selectionsAreValidBundles (this.cordBlood2Quantity, this.cordTissueQuantity, this.placenta2Quantity);
            this.isQuantityValid ( validOptions, (this.cordBlood2Quantity*this.birthCount), 'Cord Blood 2.0' );
            this.isQuantityValid ( validOptions, (this.cordTissueQuantity*this.birthCount), 'Cord Tissue' );
            this.isQuantityValid ( validOptions, (this.placenta2Quantity*this.birthCount), 'Placenta 2.0' );

            List < integer > allQuantities = new List < integer > ();
            allQuantities.add ( this.cordBlood2Quantity*this.birthCount);
            allQuantities.add ( this.cordTissueQuantity*this.birthCount );
            allQuantities.add ( this.placenta2Quantity*this.birthCount );

            if (this.exosomesQuantity!=null && this.exosomesQuantity>0) {
                allQuantities.add ( this.exosomesQuantity*this.birthCount );
            }
            allQuantities.add ( this.momPremiumGenomicsQuantity ); //there is only one of these, regardless of birth count
            allQuantities.add ( this.momStandardGenomicsQuantity ); //there is only one of these, regardless of birth count
            allQuantities.add ( this.newbornGenomeQuantity ); //there is only one of these, regardless of birth count
            allQuantities.add ( this.newbornPanelQuantity ); //there is only one of these, regardless of birth count

            allQuantities.add ( this.maternalExosomesQuantity ); //there is only one of these

            // this.haveAtLeastOneItemValueValid ( atLeastOneItemValue, allQuantities );            
            
        }

        private void isQuantityValid ( List < integer > validOptions, integer quantity, string fieldName ) {
            for ( integer i : validOptions ) {
                if ( i == quantity ) {
                    return;
                }
            }
            throw new OrderCalculatorException ( 'OrderCalculator.Input.fieldValueValidation', 
                                                    'The following product quantity field is not valid - ' + fieldName, 
                                                    OrderCalculatorException.Severity.ALERT 
                                                );
        }

        private void haveAtLeastOneItemValueValid ( integer atLeastOneItemValue, List < integer > allQuantities ) {
            for ( integer i : allQuantities ) {
                if ( i == atLeastOneItemValue ) {
                    return;
                }
            }
            throw new OrderCalculatorException ( 'OrderCalculator.Input.fieldValueValidation', 
                                                    'There was no product quantity matching the value of ' + atLeastOneItemValue, 
                                                    OrderCalculatorException.Severity.ALERT 
                                                );
        }

        // converts an Input into Opportunity form
        public Opportunity convertToOpportunity ( Opportunity opp ) {
            opp.Id = this.recordId;
            opp.Number_of_Births__c = this.numberOfBirthsTranslation ( this.birthCount );
            opp.Cord_Blood_2_0__c = this.cordBlood2Quantity;
            opp.Cord_Tissue__c = this.cordTissueQuantity;
            opp.Placenta_2_0__c = this.placenta2Quantity;

            opp.Exosomes__c = this.exosomesQuantity;
            opp.My_Genome_Premium__c = this.momPremiumGenomicsQuantity;
            opp.My_Genome_Standard__c = this.momStandardGenomicsQuantity;
            opp.Newborn_Genome__c = this.newbornGenomeQuantity;
            opp.Newborn_Panel__c = this.newbornPanelQuantity;

            opp.Maternal_Exosomes__c = this.maternalExosomesQuantity;

            opp.Storage_Plan__c = this.storagePlan;
            opp.Payment_Plans__c = this.paymentPlan;
            opp.Coupon_Code__c = this.discountCode;
            opp.Sales_Discount__c = this.salesDiscount;
            opp.Shipping_Type__c = this.shippingType;
            opp.Genomics_Upfront_Fee__c = this.genomicsUpfront;

            //If we are switching contexts, from an opp that was created with the pricing slider calculator, to the standard calculator, we need to set the default pricebook.
            if (this.priceBookId!=null) {
                opp.Pricebook2Id = this.priceBookId;
            } else {
                opp.Pricebook2Id = OrderCalculator.getPriceBookId(null);
            }
            opp.Pricing_Version__c = this.pricingVersion;
            
            return opp;
        }

        // converts an Input into Opportunity form
        public fw1__Invoice__c convertToCordBloodOrder ( fw1__Invoice__c cbo ) {
            cbo.Id = this.recordId;
            cbo.Number_of_Births__c = this.numberOfBirthsTranslation ( this.birthCount );
            cbo.Sales_Discount__c = this.salesDiscount;            
            cbo.Billing_Notes__c = this.billingNotes;
            
            if ( this.orderType == 'Enrolled' ) {
                cbo.Cord_Blood_2_0_Ordered__c = this.cordBlood2Quantity;
                cbo.Cord_Tissue_Ordered__c = this.cordTissueQuantity;
                cbo.Placenta_2_0_Ordered__c = this.placenta2Quantity;

                cbo.Exosomes_Ordered__c = this.exosomesQuantity;
                cbo.My_Genome_Premium_Ordered__c = this.momPremiumGenomicsQuantity;
                cbo.My_Genome_Standard_Ordered__c = this.momStandardGenomicsQuantity;
                cbo.Newborn_Genome_Ordered__c = this.newbornGenomeQuantity;
                cbo.Newborn_Panel_Ordered__c = this.newbornPanelQuantity;

                cbo.Maternal_Exosomes_Ordered__c = this.maternalExosomesQuantity;

                cbo.Storage_Plan_Ordered__c = this.storagePlan;
                cbo.Payment_Plan_Ordered__c = this.paymentPlan;
            } else if ( this.orderType == 'Stored' ) {
                cbo.Storage_Plan_Stored__c = this.storagePlan;
                cbo.Payment_Plan_Stored__c = this.paymentPlan;
            }

            return cbo;
        }

        // private conversion methods
        private integer birthCountTranslation ( string picklistValue ) {
            switch on picklistValue {
                when 'Single' {
                    return 1;
                }
                when 'Twins' {
                    return 2;
                }
                when 'Triplets' {
                    return 3;
                }
            }
            return 0;
        }

        private string numberOfBirthsTranslation ( integer birthCount ) {
            switch on birthCount {
                when 1 {
                    return 'Single';
                }
                when 2 {
                    return 'Twins';
                }
                when 3 {
                    return 'Triplets';
                }
            }
            return null;
        }

    }
    
    // Output class
    // All output values from the Calculator should be defined in this class
    // Similar to Input, this is a structural class, but may include validation or messaging as necessary
    public class Output {
        
        // order level
        public decimal priceBeforeSalesDiscount;
        public decimal priceWithDiscounts;
        public decimal priceAfterDeposit;
        public integer sumOfProducts;
        public decimal hybridFirstPayment;
        public decimal monthlyFee;
        public decimal totalMonthlyFees;
        public decimal monthlyPayment;
        public integer monthlyPaymentRounded;

        public PaymentPlan paymentPlan;
        public List < LineItem > lineItems;
        public string storagePlan;
        public decimal salesDiscount;
        public string discountCode;
        public decimal biobankingMultiProductDiscount;
        public decimal shippingCost;
        public decimal genomicsUpfront;
        public decimal kitFee;
        public decimal totalDeposit;
        public Id recordId;
        
        public Output () {
            this.priceBeforeSalesDiscount = 0;
            this.biobankingMultiProductDiscount = 0;
            this.priceWithDiscounts = 0;
            this.priceAfterDeposit = 0;
            this.sumOfProducts = 0;
            this.hybridFirstPayment = 0;
            this.monthlyFee = 0;
            this.totalMonthlyFees = 0;
            this.monthlyPayment = 0;
            this.monthlyPaymentRounded = 0;
            this.salesDiscount = 0;
            this.discountCode = null;
            this.shippingCost = 0;
            this.kitFee = 0;
            this.genomicsUpfront = 0;
        }
        
        public Output ( List < LineItem > lineItems, Input input, PaymentPlan paymentPlan, decimal monthlyFee, integer sumOfProducts ) {

            this ();

            System.debug ( 'Pre-output calc' );
            System.debug ( 'lineItems -> ' + lineItems );
            System.debug ( 'input -> ' + input );
            System.debug ( 'paymentPlan -> ' + paymentPlan );
            System.debug ( 'monthlyFee -> ' + monthlyFee );
            System.debug ( 'sumOfProducts -> ' + sumOfProducts );

            // total monthly fees
            this.totalMonthlyFees = Math.round ( paymentPlan.numberOfFees * monthlyFee );            

            // traverse line items
            Boolean hasBioBankingProducts = false;
            Boolean hasGenomicsProducts = false;            
            for ( LineItem li : lineItems ) {

                System.debug('looping li:'+li.productCode+'|'+li.productName);

                if (li.genomicsUpfront!=null && li.genomicsUpfront>0) {
                    this.genomicsUpfront += li.genomicsUpfront;
                }
                
                this.priceBeforeSalesDiscount = this.priceBeforeSalesDiscount + li.lineItemSubTotal;
                if (li.productCode=='StndShip' || li.productCode=='RushShip') {
                    this.shippingCost = li.lineItemSubTotal;
                } else if (li.productCode=='CollKit') {
                    this.kitFee = li.lineItemSubTotal;
                }
            }

            if ( paymentPlan.planType != OrderCalculator.PlanType.Onetime ) { 
                this.priceBeforeSalesDiscount = this.priceBeforeSalesDiscount + this.totalMonthlyFees;
            } 
            
            if ( input.salesDiscount == null ) {
                input.salesDiscount = 0.0;
            } 

            // Determine if non-bundled, multi-biobanking pricing should apply
            if (input.countOfNonBundledBiobankingProducts>=1) {
                Map<String, Biobanking_Multi_Product_Price__mdt> bioBulkPricing = Biobanking_Multi_Product_Price__mdt.getAll();
                for (Biobanking_Multi_Product_Price__mdt bioBulkPrice: bioBulkPricing.values()) {
                    Boolean applyDiscount = false;
                    // There is one particular grouping to pull out, CBCT + EX
                    if (input.containsCBCTEX) {
                        if (input.storagePlan=='20YPP' && bioBulkPrice.DeveloperName=='CBCT_w_20Yr_Storage') {
                            applyDiscount = true;
                        } else if (input.storagePlan=='LTS' && bioBulkPrice.DeveloperName=='CBCT_w_Lifetime_Storage') {
                            applyDiscount = true;
                        } else if (input.storagePlan=='ASP' && bioBulkPrice.DeveloperName=='CBCT_w_Annual_Storage') {
                            applyDiscount = true;
                        }
                    // Everything else is based on count + storage
                    } else if (bioBulkPrice.Product_Count__c!=null && bioBulkPrice.Product_Count__c==input.countOfNonBundledBiobankingProducts && bioBulkPrice.Storage_Length__c==input.storagePlan) {
                        applyDiscount = true;
                    }

                    // If needed, apply discount
                    if (applyDiscount) {
                        this.biobankingMultiProductDiscount = bioBulkPrice.Undiscounted_Price__c - bioBulkPrice.Price__c;
                    }
                }
            }

            // Apply sales discounts and biobanking multi-product discounts
            this.salesDiscount = input.salesDiscount.setScale ( 2 );
            
            // Finally, apply applicable discount codes
            // If a coupon code is entered, it will override any manual discount entered
            if (String.isNotBlank(input.discountCode)) {
                //Map<String, Discount_Code__mdt> discountCodes = Discount_Code__mdt.getAll();
                Map<String,Discount_Code__mdt> discountCodes = CustomMetadataService.getMapDiscountCodes();
                Discount_Code__mdt discountCode = discountCodes.get(input.discountCode);
                if (discountCode==null){
                    throw new OrderCalculatorException('Internal Calculator','Unknown discount code',OrderCalculatorException.Severity.ALERT);
                }

                if (cartQualifiesForDiscount(discountCode, lineItems, this)) {
                    this.salesDiscount = discountCode.Amount__c;
                    this.discountCode = input.discountCode;
                }   
            }

            this.totalDeposit = this.shippingCost + this.genomicsUpfront + this.kitFee;
            this.priceWithDiscounts = this.priceBeforeSalesDiscount - (this.salesDiscount + this.biobankingMultiProductDiscount);
            this.priceAfterDeposit = this.priceWithDiscounts - this.totalDeposit;

            // pass through values
            this.monthlyFee = monthlyFee;
            this.sumOfProducts = sumOfProducts;
            
            // monthly payment - HYBRID plan
            if ( paymentPlan.planType == OrderCalculator.PlanType.Hybrid ) {
                this.hybridFirstPayment = ( this.priceAfterDeposit ) * ( paymentPlan.percentOfFirstPayment * 0.01 );
                this.monthlyPayment = ( this.priceAfterDeposit - this.hybridFirstPayment ) / paymentPlan.numberOfPayments;
            } 
            // monthly payment - MONTHLY plan
            else if ( paymentPlan.planType == OrderCalculator.PlanType.Monthly ) {          
                this.monthlyPayment = ( this.priceAfterDeposit ) / paymentPlan.numberOfPayments;
                this.hybridFirstPayment = 0;
            }
            // monthly payment - ONETIME plan (includes AF)
            else {
                this.monthlyPayment = 0;
            }

            this.priceBeforeSalesDiscount = this.priceBeforeSalesDiscount.setScale ( 2 );
            this.priceWithDiscounts = this.priceWithDiscounts.setScale ( 2 );
            this.priceAfterDeposit = this.priceAfterDeposit.setScale ( 2 );
            this.hybridFirstPayment = this.hybridFirstPayment.setScale ( 2 );
            this.monthlyFee = this.monthlyFee.setScale ( 2 );
            this.totalMonthlyFees = this.totalMonthlyFees.setScale ( 2 ); 
            this.monthlyPayment = this.monthlyPayment.setScale ( 2 ); 
            this.salesDiscount = this.salesDiscount.setScale ( 2 );
            
            // rounding for output
            this.monthlyPaymentRounded = Integer.valueOf(this.monthlyPayment.round(System.RoundingMode.HALF_UP));

            // returning additional outputs
            this.lineItems = lineItems;
            this.paymentPlan = paymentPlan;
            this.storagePlan = input.storagePlan;
            
        }

        // note: this should be paired with a call to it's related Input. method
        // as the Input method sets the record Id
        public Opportunity convertToOpportunity ( Opportunity opp ) {
            opp.Id = this.recordId;
            opp.Hybrid_First_Payment_new__c = this.hybridFirstPayment;
            opp.Monthly_Fees_new2__c = this.monthlyFee;
            opp.Total_Monthly_Fees_new__c = this.totalMonthlyFees;
            opp.Monthly_Payments_new__c = this.monthlyPayment;
            opp.Biobanking_Multi_Product_Discount__c = this.biobankingMultiProductDiscount;
            opp.Sales_Discount__c =  this.salesDiscount;
            opp.Coupon_Code__c = this.discountCode;
            opp.Price_with_Sales_Discount_new__c = this.priceWithDiscounts;
            opp.Sum_of_Products_new__c = this.sumOfProducts;
            opp.Number_of_Fees__c = this.paymentPlan.numberOfFees;
            opp.Deposit__c = this.kitFee;
            opp.Genomics_Upfront_Fee__c = this.genomicsUpfront;
            
            return opp;
        }

        // note: this should be paired with a call to it's related Input. method
        // as the Input method sets the record Id
        public fw1__Invoice__c convertToCordBloodOrder ( fw1__Invoice__c cbo, OrderCalculator.Input input ) {
            cbo.Hybrid_First_Payment_new__c = this.hybridFirstPayment;
            cbo.Monthly_Fees_new2__c = this.monthlyFee;
            cbo.Total_Monthly_Fee_new__c = this.totalMonthlyFees;
            cbo.Monthly_Payments_new__c = this.monthlyPayment;
            cbo.Number_of_Fees__c = this.paymentPlan.numberOfFees;            
            cbo.Biobanking_Multi_Product_Discount__c = this.biobankingMultiProductDiscount;

            if ( input.orderType == 'Enrolled' ) {
                cbo.Sum_of_Products_Ordered__c = this.sumOfProducts;
            } else if ( input.orderType == 'Stored' ) {
                cbo.Sum_of_Products_Stored__c = this.sumOfProducts;
            }
            return cbo;
        }
    }

    private static Boolean cartQualifiesForDiscount(Discount_Code__mdt code, List < LineItem > lineItems, OrderCalculator.Output output) {

        if (!discountCodeIsCurrent(code.Start_Date__c, code.End_Date__c)) {
            throw new OrderCalculatorException('Internal Calculator','Discount code is not currently available.',OrderCalculatorException.Severity.ALERT);
        }

        if (!priceQualifiesForDiscount(code, output.priceBeforeSalesDiscount)) {
            System.debug('output.priceBeforeSalesDiscount: '+output.priceBeforeSalesDiscount);
            System.debug('code: '+code);
            throw new OrderCalculatorException('Internal Calculator','Cart does not meet price minimum for this discount code.',OrderCalculatorException.Severity.ALERT);
        }

        if (code.Applicable_Bundles__c!=null && !cartMeetsBundleRequirements(code.Applicable_Bundles__c.split(','), lineItems)) {
            throw new OrderCalculatorException('Internal Calculator','This discount code is not valid for cart contents.',OrderCalculatorException.Severity.ALERT);
        }

        if (code.Applicable_Product_Types__c!=null) {
            if (code.Applicable_Product_Types__c=='Biobanking') {
                if (!cartContainsBioBanking(lineItems)) {
                    throw new OrderCalculatorException('Internal Calculator','This discount code is only valid for carts containing Biobanking services',OrderCalculatorException.Severity.ALERT);
                }
            } else if (code.Applicable_Bundles__c=='Genomics') {
                if (!cartContainsGenomics(lineItems)) {
                    throw new OrderCalculatorException('Internal Calculator','This discount code is only valid for carts containing Genomics services',OrderCalculatorException.Severity.ALERT);
                }
            }
        }

        // If no exceptions were thrown, code is good!
        return true;

    }

    private static Boolean cartContainsBioBanking (List < LineItem > cartLineItems) {
        Boolean cartContainsBioBankProduct = false;
        for (LineItem li: cartLineItems) {
            if (li.isBiobankingProduct) {
                cartContainsBioBankProduct = true;
            }
        }
        return cartContainsBioBankProduct;
    }

    private static Boolean cartContainsGenomics (List < LineItem > cartLineItems) {
        Boolean cartContainsGenomicProduct = false;
        for (LineItem li: cartLineItems) {
            if (li.isGenomicsProduct) {
                cartContainsGenomicProduct = true;
            }
        }
        return cartContainsGenomicProduct;
    }

    private static Boolean cartMeetsBundleRequirements (List < String > qualifyingBundles, List < LineItem > cartLineItems) {
        // If not applicable bundle is specified, return true
        if (qualifyingBundles==null) {
            return true;
        } else {
            Boolean cartContainsBundleCode = false;
            for (LineItem li: cartLineItems) {
                if (qualifyingBundles.contains(li.productCode)) {
                    cartContainsBundleCode = true;
                }
            }
            return cartContainsBundleCode;
        }
    }

    private static Boolean discountCodeIsCurrent (Date startDate, Date endDate) {
        Date today = Date.today();

        if (today>=startDate && today<=endDate) {
            return true;
        } else {
            return false;
        }
    }

    private static Boolean priceQualifiesForDiscount (Discount_Code__mdt code, Decimal price) {
        if (code.Price_Limit__c==null) {
            return true;
        } else {
            return price>=code.Price_Limit__c;
        }
        
    }

    // Utility methods -- will likely move from here
    // public static WebPricing.ProductPaymentDetail getFormattedProductPaymentDetail (PricebookEntry pbe, Decimal totalPrice, String storageOption ) {
    //     WebPricing.ProductPaymentDetail prodPayDetail = new WebPricing.ProductPaymentDetail();
    //     prodPayDetail.bundledProductDetails = new List < WebPricing.BundledProductDetail >();
    //     prodPayDetail.pricingOptions = new List < WebPricing.PricingDetail >();
    //     prodPayDetail.name = pbe.Name;
    //     prodPayDetail.productCode = pbe.ProductCode;

    // //only include the product id for non-bundles
    //     if (!prodPayDetail.name.contains('+')) {
    //         prodPayDetail.product2Id = pbe.Product2Id;
    //     }
    //     prodPayDetail.unitPrice = totalPrice;
    //     prodPayDetail.storageOption = storageOption;
    //     return prodPayDetail;
    // }
}