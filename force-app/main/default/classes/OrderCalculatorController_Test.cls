// OrderCalculatorController Unit Tests
// Bhanudas Tanaka - bhanudas@suryaconnect.com

@isTest
private class OrderCalculatorController_Test {

    @testSetup
    private static void testSetup () {
        AmericordTestDataFactory factory = new AmericordTestDataFactory ();
    }

    @isTest private static void calculate () {

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
        input.dataSource = 'Opportunity';
        input.orderType = '';

        Test.startTest ();

        string outputJson = OrderCalculatorController.calculate ( JSON.serialize ( input ));

        Test.stopTest ();

        OrderCalculator.Output output = (OrderCalculator.Output) JSON.deserialize ( outputJson, OrderCalculator.Output.class );
        System.assertEquals ( 3, output.sumOfProducts );

    }

    @isTest private static void fetchDisplayFromRecord_Opp () {

        Opportunity opp = AmericordTestDataFactory.createOpportunity ( 'Test Opp', 'Closed', true );
        opp.StageName = 'Enrolled';
        opp.Enrollment_Flow_Complete__c = true;
        update opp;
        fw1__Invoice__c cbo = AmericordTestDataFactory.getInvoice ( opp.id );

        Test.startTest ();

        string displayTypeOpp = OrderCalculatorController.fetchTypeOfDisplayFromRecord ( opp.id );
        string displayTypeOrder = OrderCalculatorController.fetchTypeOfDisplayFromRecord ( cbo.id );

        Test.stopTest ();

        System.assertEquals ( 'Opportunity', displayTypeOpp );
        System.assertEquals ( 'Order', displayTypeOrder );
    }


    @isTest private static void fetchInputRecord_Opp () {

        Opportunity opp = AmericordTestDataFactory.createOpportunity ( 'Test Opp', 'Closed', true );
        opp.Number_of_Births__c = 'Single';
        opp.Enrollment_Flow_Complete__c = true;
        opp.StageName = 'Enrolled';
        update opp;
        fw1__Invoice__c cbo = AmericordTestDataFactory.getInvoice ( opp.id );

        Test.startTest ();

        string oppJson = OrderCalculatorController.fetchInputFromRecord ( (string) opp.id, false );
        string orderEnrolledJson = OrderCalculatorController.fetchInputFromRecord ( (string) cbo.id, false );
        // TBD stored
        
        Test.stopTest ();

        OrderCalculator.Input oppInput = (OrderCalculator.Input) JSON.deserialize ( oppJson, OrderCalculator.Input.class );
        OrderCalculator.Input orderEnrolledInput = (OrderCalculator.Input) JSON.deserialize ( orderEnrolledJson, OrderCalculator.Input.class );
        
        System.assertEquals ( 1, oppInput.birthCount );
        System.assertEquals ( 1, orderEnrolledInput.birthCount );
    }


    @isTest private static void writeToRecord_Opp () {

        Opportunity opp = AmericordTestDataFactory.createOpportunity ( 'Test Opp', 'Closed', true );
        opp.Number_of_Births__c = 'Single';
        opp.Enrollment_Flow_Complete__c = true;
        opp.StageName = 'Enrolled';
        update opp;
        fw1__Invoice__c cbo = AmericordTestDataFactory.getInvoice ( opp.id );

        string oppJson = OrderCalculatorController.fetchInputFromRecord ( (string) opp.id, false );
        OrderCalculator.Input oppInput = (OrderCalculator.Input) JSON.deserialize ( oppJson, OrderCalculator.Input.class );
        string outputJson = OrderCalculatorController.calculate ( JSON.serialize ( oppInput ));
        OrderCalculator.Output output = (OrderCalculator.Output) JSON.deserialize ( outputJson, OrderCalculator.Output.class );

        Test.startTest ();

        OrderCalculatorController.writeToRecord ( oppJson, outputJson );
        
        Test.stopTest ();

        // TODO: Asserts
    }

    @isTest private static void writeToRecord_Order () {

        Opportunity opp = AmericordTestDataFactory.createOpportunity ( 'Test Opp', 'Closed', true );
        opp.Number_of_Births__c = 'Single';
        opp.Enrollment_Flow_Complete__c = true;
        opp.StageName = 'Enrolled';
        update opp;
        fw1__Invoice__c cbo = AmericordTestDataFactory.getInvoice ( opp.id );
        cbo.Storage_Plan_Stored__c = 'LTS';
        cbo.Storage_Plan_Ordered__c = 'LTS';
        cbo.Payment_Plan_Stored__c = '24M'; 
        cbo.Payment_Plan_Ordered__c = '24M';       
        update cbo;

        string orderJson = OrderCalculatorController.fetchInputFromRecord ( (string) cbo.id, false );
        OrderCalculator.Input orderInput = (OrderCalculator.Input) JSON.deserialize ( orderJson, OrderCalculator.Input.class );
        string outputJson = OrderCalculatorController.calculate ( JSON.serialize ( orderInput ));
        OrderCalculator.Output output = (OrderCalculator.Output) JSON.deserialize ( outputJson, OrderCalculator.Output.class );

        Test.startTest ();

        OrderCalculatorController.writeToRecord ( orderJson, outputJson );
        
        Test.stopTest ();

        // TODO: Asserts
    }

    @isTest private static void isInputValid_positive () {

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

        Test.startTest ();

        boolean isValid = OrderCalculatorController.isInputValid( JSON.serialize ( input ));
        
        Test.stopTest ();

        System.assertEquals ( true, isValid );

    }

    @isTest private static void isInputValid_negative () {

        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = 1;
        input.cordBlood2Quantity = 23;
        input.cordTissueQuantity = 1;
        input.placenta2Quantity = 0;
        input.priceBookId = null;
        input.paymentPlan = '48M';
        input.storagePlan = 'LTS';
        input.salesDiscount = 1000;
        input.depositAmount = 199;
        input.shippingType = 'Standard';

        Test.startTest ();

        boolean isValid = OrderCalculatorController.isInputValid( JSON.serialize ( input ));
        
        Test.stopTest ();

        System.assertEquals ( false, isValid );

    }
}