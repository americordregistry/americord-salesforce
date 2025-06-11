// Unit Tests for Order Calculator
// Bhanu Tanaka - 8/25/2020
// bhanudas@suryaconnect.com

@isTest
private class OrderCalculator_Test {

    @isTest
    private static void threeProdsOTP () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
        // formulate input - test #1 3ProdsOTP
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 1;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = '20YPP';
        input.salesDiscount = 900;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 3, output.sumOfProducts, 'sumOfProducts' );
        System.assertEquals ( 6878, output.priceBeforeSalesDiscount,'priceBeforeSalesDiscount' ); //7077
        System.assertEquals ( 5700, output.priceAfterDeposit, 'priceAfterDeposit'  );
        System.assertEquals ( 5978, output.priceWithDiscounts,'priceWithDiscounts' ); 
        System.assertEquals ( 0, output.totalMonthlyFees,'totalMonthlyFees' );
        System.assertEquals ( 0, output.monthlyFee, 'monthlyFee');
        System.assertEquals ( 0, output.totalMonthlyFees, 'totalMonthlyFees' );
        System.assertEquals ( 0, output.hybridFirstPayment, 'hybridFirstPayment' );
        System.assertEquals ( 0, output.monthlyPayment,'monthlyPayment' );
        System.assertEquals ( 0, output.monthlyPaymentRounded, 'monthlyPaymentRounded' );  
    }
	
    @isTest
    private static void LTS48M () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // formulate input - test #5 LTS48M
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 0;
        input.priceBookId = null;
        input.paymentPlan = '48M';
        input.storagePlan = 'LTS';
        input.salesDiscount = 1000;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 2, output.sumOfProducts, 'sumOfProducts' );
        System.assertEquals ( 104.74, output.monthlyFee, 'monthlyFee');
        System.assertEquals ( 5028.00, output.totalMonthlyFees, 'totalMonthlyFees' );
        System.assertEquals ( 14206.00, output.priceBeforeSalesDiscount, 'priceBeforeSalesDiscount' ); 
        System.assertEquals ( 0, output.hybridFirstPayment, 'hybridFirstPayment' );
        System.assertEquals ( 269.33, output.monthlyPayment,'monthlyPayment' );
        System.assertEquals ( 269, output.monthlyPaymentRounded, 'monthlyPaymentRounded' );   
        System.assertEquals ( 12928.00, output.priceAfterDeposit, 'priceAfterDeposit' );
        System.assertEquals ( 13206.00, output.priceWithDiscounts, 'priceWithDiscounts' ); 
    }      
    
    
    @isTest
    private static void noSalesDiscount () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // formulate input - noSalesDiscount
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 0;
        input.placenta2Quantity = 0;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = '20YPP';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 1, output.sumOfProducts, 'sumOfProducts' );
        System.assertEquals ( 0, output.monthlyFee, 'monthlyFee');
        System.assertEquals ( 0, output.totalMonthlyFees, 'totalMonthlyFees' );
        System.assertEquals ( 3578, output.priceBeforeSalesDiscount, 'priceBeforeSalesDiscount' ); 
        System.assertEquals ( 0, output.hybridFirstPayment, 'hybridFirstPayment' );
        System.assertEquals ( 0, output.monthlyPayment,'monthlyPayment' );
        System.assertEquals ( 0, output.monthlyPaymentRounded, 'monthlyPaymentRounded' );   
        System.assertEquals ( 3300, output.priceAfterDeposit, 'priceAfterDeposit' );
        System.assertEquals ( 3578, output.priceWithDiscounts, 'priceWithDiscounts' ); 
             
    }
    
    @isTest
    private static void HY18LTS () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // formulate input - test #9 HY18LTS
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 0;
        input.priceBookId = null;
        input.paymentPlan = 'HY18';
        input.storagePlan = 'LTS';
        input.salesDiscount = 1000;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 2, output.sumOfProducts,'sumOfProducts' );
        System.assertEquals ( 0, output.monthlyFee,'monthlyFee');
        System.assertEquals ( 0, output.totalMonthlyFees,'totalMonthlyFees' );
        System.assertEquals ( 9178, output.priceBeforeSalesDiscount,'priceBeforeSalesDiscount' ); 
        System.assertEquals ( 3950, output.hybridFirstPayment,'hybridFirstPayment' );
        System.assertEquals ( 232.35, output.monthlyPayment,'monthlyPayment' );
        System.assertEquals ( 232, output.monthlyPaymentRounded,'monthlyPaymentRounded' );    
        System.assertEquals ( 7900, output.priceAfterDeposit,'priceAfterDeposit' );
        System.assertEquals ( 8178, output.priceWithDiscounts,'priceWithDiscounts' ); 
             
    }   


    // Tests for new package/Product options.  This is related to a short-term update pre-web release.  Plan is to rearchitect soon!
    @isTest
    private static void packageTests1 () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 1;
        input.exosomesQuantity = 1;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = '20YPP';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 4, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    }
    
    @isTest
    private static void packageDiscountTest () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 1;
        input.exosomesQuantity = 1;
        input.momPremiumGenomicsQuantity = 1;
        input.newbornPanelQuantity = 1;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = 'LTS';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        input.discountCode = 'WTE400';

        // Add test discount 
        List<Discount_Code__mdt> lstDiscountCodesTest = new List<Discount_Code__mdt>();
        Discount_Code__mdt discCode = new Discount_Code__mdt();
        discCode.Label = 'WTE400';
        discCode.DeveloperName = 'WTE400';
        discCode.Amount__c = 400;
        discCode.Price_Limit__c = 1000;
        discCode.Start_Date__c = System.today();
        discCode.End_Date__c = System.today()+7;
        lstDiscountCodesTest.add(discCode);
        CustomMetadataService.lstDiscountCodes = lstDiscountCodesTest;        
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 6, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    }

    @isTest
    private static void packageTests2 () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 1;
        input.exosomesQuantity = 1;
        input.momPremiumGenomicsQuantity = 1;
        input.newbornPanelQuantity = 1;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = '20YPP';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 6, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    } 

    @isTest
    private static void packageTests3 () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 0;
        input.cordBlood2Quantity = 0;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 0;
        input.exosomesQuantity = 0;
        input.momPremiumGenomicsQuantity = 0;
        input.newbornPanelQuantity = 0;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = '20YPP';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 1, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    } 

    @isTest
    private static void packageTests4 () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 0;
        input.cordBlood2Quantity = 0;
        input.cordTissueQuantity = 0;
        input.placenta2Quantity = 1;
        input.exosomesQuantity = 0;
        input.momPremiumGenomicsQuantity = 0;
        input.newbornPanelQuantity = 0;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = '20YPP';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 1, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    } 

    @isTest
    private static void packageTests5 () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 0;
        input.cordBlood2Quantity = 0;
        input.cordTissueQuantity = 0;
        input.placenta2Quantity = 0;
        input.exosomesQuantity = 1;
        input.momPremiumGenomicsQuantity = 0;
        input.newbornPanelQuantity = 0;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = '20YPP';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 1, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    }
    
    // Tests for new package/Product options.  This is related to a short-term update pre-web release.  Plan is to rearchitect soon!
    @isTest
    private static void packageTests6 () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 1;
        input.exosomesQuantity = 1;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = 'LTS';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 4, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    } 

    @isTest
    private static void packageTests7 () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 1;
        input.exosomesQuantity = 1;
        input.momPremiumGenomicsQuantity = 1;
        input.newbornPanelQuantity = 1;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = 'LTS';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 6, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    } 

    @isTest
    private static void packageTests8 () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 0;
        input.cordBlood2Quantity = 0;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 0;
        input.exosomesQuantity = 0;
        input.momPremiumGenomicsQuantity = 0;
        input.newbornPanelQuantity = 0;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = 'LTS';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 1, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    } 

    @isTest
    private static void packageTests9 () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 0;
        input.cordBlood2Quantity = 0;
        input.cordTissueQuantity = 0;
        input.placenta2Quantity = 1;
        input.exosomesQuantity = 0;
        input.momPremiumGenomicsQuantity = 0;
        input.newbornPanelQuantity = 0;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = 'LTS';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 1, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    } 

    @isTest
    private static void packageTests10 () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 0;
        input.cordBlood2Quantity = 0;
        input.cordTissueQuantity = 0;
        input.placenta2Quantity = 0;
        input.exosomesQuantity = 1;
        input.momPremiumGenomicsQuantity = 0;
        input.newbornPanelQuantity = 0;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = 'LTS';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 1, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    }

    @isTest
    private static void maternalExosome_Validate () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 0;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 0;
        input.placenta2Quantity = 0;
        input.exosomesQuantity = 0;
        input.momPremiumGenomicsQuantity = 0;
        input.newbornPanelQuantity = 0;
        input.maternalExosomesQuantity = 1;
        input.priceBookId = null;
        input.paymentPlan = 'OTP';
        input.storagePlan = 'LTS';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 2, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    }

    @isTest
    private static void annualStorage_Validate_1Service () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 0;
        input.placenta2Quantity = 0;
        input.exosomesQuantity = 0;
        input.momPremiumGenomicsQuantity = 0;
        input.newbornPanelQuantity = 0;
        input.priceBookId = null;
        input.paymentPlan = 'AF';
        input.storagePlan = 'ASP';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 1, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    }    

    @isTest
    private static void annualStorage_Validate_2Service () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 0;
        input.exosomesQuantity = 0;
        input.momPremiumGenomicsQuantity = 0;
        input.newbornPanelQuantity = 0;
        input.priceBookId = null;
        input.paymentPlan = 'AF';
        input.storagePlan = 'ASP';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 2, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    }    

    @isTest
    private static void annualStorage_Validate_3Service () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 1;
        input.exosomesQuantity = 0;
        input.momPremiumGenomicsQuantity = 0;
        input.newbornPanelQuantity = 0;
        input.priceBookId = null;
        input.paymentPlan = 'AF';
        input.storagePlan = 'ASP';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 3, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    }    

    @isTest
    private static void annualStorage_Validate_4Service () {
        AmericordTestDataFactory testData = new AmericordTestDataFactory ();
        
         // Ultimate Protection plan
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 1;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 1;
        input.exosomesQuantity = 1;
        input.momPremiumGenomicsQuantity = 0;
        input.newbornPanelQuantity = 0;
        input.priceBookId = null;
        input.paymentPlan = 'AF';
        input.storagePlan = 'ASP';
        input.salesDiscount = 0;
        input.depositAmount = 199;
        input.shippingType = 'Standard';
        
        // run test
        Test.startTest ();
        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        Test.stopTest ();
        
        System.debug ( 'Input --> ' + JSON.serialize ( input ));
        System.debug ( 'packageTests2Output --> ' + JSON.serialize ( output ));
        // asserts
        System.assertEquals ( 4, output.sumOfProducts,'sumOfProducts' );  //This is a package             
    }    

    @isTest
    private static void outputConvertToOpp () {
        OrderCalculator.Output output = new OrderCalculator.Output ();
        output.hybridFirstPayment = 1;
        output.monthlyFee = 2;
        output.totalMonthlyFees = 3;
        output.monthlyPayment = 4;
        output.priceWithDiscounts = 5;
        output.sumOfProducts = 6;
        output.paymentPlan = new OrderCalculator.PaymentPlan ();
        output.paymentPlan.numberOfFees = 7;

        Test.startTest ();
        Opportunity opp = new Opportunity ();
        opp = output.convertToOpportunity ( opp );
        Test.stopTest ();

        System.AssertEquals ( 1, opp.Hybrid_First_Payment_new__c );
        System.AssertEquals ( 2, opp.Monthly_Fees_new2__c );
        System.AssertEquals ( 3, opp.Total_Monthly_Fees_new__c );
        System.AssertEquals ( 4, Opp.Monthly_Payments_new__c );
        System.AssertEquals ( 5, Opp.Price_with_Sales_Discount_new__c );
        System.AssertEquals ( 6, Opp.Sum_of_Products_new__c );
        System.AssertEquals ( 7, Opp.Number_of_Fees__c );
    }

    @isTest
    private static void outputConvertToOrder () {
        OrderCalculator.Output output = new OrderCalculator.Output ();
        output.hybridFirstPayment = 1;
        output.monthlyFee = 2;
        output.totalMonthlyFees = 3;
        output.monthlyPayment = 4;
        output.priceWithDiscounts = 5;
        output.sumOfProducts = 6;
        output.paymentPlan = new OrderCalculator.PaymentPlan ();
        output.paymentPlan.numberOfFees = 7;

        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.orderType = 'Enrolled';

        Test.startTest ();
        fw1__Invoice__c cbo = new fw1__Invoice__c ();
        cbo = output.convertToCordBloodOrder ( cbo, input );
        Test.stopTest ();

        System.AssertEquals ( 1, cbo.Hybrid_First_Payment_new__c );
        System.AssertEquals ( 2, cbo.Monthly_Fees_new2__c );
        System.AssertEquals ( 3, cbo.Total_Monthly_Fee_new__c );
        System.AssertEquals ( 4, cbo.Monthly_Payments_new__c );
        System.AssertEquals ( 6, cbo.Sum_of_Products_Ordered__c );
        System.AssertEquals ( 7, cbo.Number_of_Fees__c );
    }

    @isTest
    private static void outputConvertToOrder_Stored () {
        OrderCalculator.Output output = new OrderCalculator.Output ();
        output.hybridFirstPayment = 1;
        output.monthlyFee = 2;
        output.totalMonthlyFees = 3;
        output.monthlyPayment = 4;
        output.priceWithDiscounts = 5;
        output.sumOfProducts = 6;
        output.paymentPlan = new OrderCalculator.PaymentPlan ();
        output.paymentPlan.numberOfFees = 7;

        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.orderType = 'Stored';

        Test.startTest ();
        fw1__Invoice__c cbo = new fw1__Invoice__c ();
        cbo = output.convertToCordBloodOrder ( cbo, input );
        Test.stopTest ();

        System.AssertEquals ( 1, cbo.Hybrid_First_Payment_new__c );
        System.AssertEquals ( 2, cbo.Monthly_Fees_new2__c );
        System.AssertEquals ( 3, cbo.Total_Monthly_Fee_new__c );
        System.AssertEquals ( 4, cbo.Monthly_Payments_new__c );
        System.AssertEquals ( 6, cbo.Sum_of_Products_Stored__c );
        System.AssertEquals ( 7, cbo.Number_of_Fees__c );
    }


}