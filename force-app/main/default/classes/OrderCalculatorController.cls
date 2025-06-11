// Order Calculator Controller - for Order Calculator LWC solution
// 9/10/2020 - Bhanudas Tanaka - bhanudas@suryaconnect.com

public without sharing class OrderCalculatorController {
    
    // calculate method
    // Receives an input of parameters and outputs results
    @AuraEnabled ( cacheable = false )
    public static string calculate ( string inputJson ) {
        OrderCalculator.Input input = (OrderCalculator.Input) JSON.deserialize ( inputJson, OrderCalculator.Input.class );

        OrderCalculator.Output output = OrderCalculator.calculate ( input );
        return JSON.serialize ( output );
    }

    // load type of display
    @AuraEnabled ( cacheable = false ) 
    public static string fetchTypeOfDisplayFromRecord ( string recordId ) {
        // determine the type of object
        Id typedRecordId = (Id) recordId;
        string sObjectName = typedRecordId.getSobjectType ().getDescribe ().getName ();

        // query by type
        if ( sObjectName == 'Opportunity' ) {
            return 'Opportunity';
        } else if ( sObjectName == 'fw1__Invoice__c' ) {
            return 'Order';
        }
        return 'Unknown';
    }

    // load inputs from Opportunity or CBO object
    // Receives a record ID and returns an Order Calculator Input
    @AuraEnabled ( cacheable = false )
    public static string fetchInputFromRecord ( string recordId, boolean forceOrderEnrolled ) {
        // determine the type of object
        Id typedRecordId = (Id) recordId;
        string sObjectName = typedRecordId.getSobjectType ().getDescribe ().getName ();

        OrderCalculator.Input input;
        // query by type
        if ( sObjectName == 'Opportunity' ) {
            // query for the opp
            List < Opportunity > oppList = [ SELECT Id,
                                                    Number_Of_Births__c,
                                                    Cord_Blood_2_0__c,
                                                    Cord_Tissue__c,
                                                    Placenta_2_0__c,
                                                    Exosomes__c,
                                                    My_Genome_Premium__c,
                                                    My_Genome_Standard__c,
                                                    Newborn_Genome__c,
                                                    Newborn_Panel__c,
                                                    Maternal_Exosomes__c,
                                                    Storage_Plan__c,
                                                    Payment_Plans__c,
                                                    Sales_Discount__c,
                                                    Genomics_Upfront_Fee__c,
                                                    Deposit__c,
                                                    PriceBook2Id,
                                                    Shipping_Type__c,
                                                    Coupon_Code__c,
                                                    Price_with_Sales_Discount_new__c
                                                    FROM Opportunity WHERE Id =: typedRecordId ];
            if ( oppList.size () == 0 ) {
                // TODO: throw Exception - no opp found
            } else {
                // call create input
                input = new OrderCalculator.Input ( oppList [0] );
            }
        } else if ( sObjectName == 'fw1__Invoice__c' ) {
            // query for the CBO
            List < fw1__Invoice__c > cboList = [ SELECT Id,
                                                    Number_Of_Births__c,
                                                    Cord_Blood_2_0_Ordered__c,
                                                    Cord_Tissue_Ordered__c,
                                                    Placenta_2_0_Ordered__c,
                                                    Exosomes_Ordered__c,
                                                    My_Genome_Premium_Ordered__c,
                                                    My_Genome_Standard_Ordered__c,
                                                    Newborn_Genome_Ordered__c,
                                                    Newborn_Panel_Ordered__c,
                                                    Maternal_Exosomes_Ordered__c,
                                                    Storage_Plan_Ordered__c,
                                                    Payment_Plan_Ordered__c,
                                                    Cord_Blood_2_0_Stored__c,
                                                    Cord_Tissue_Stored__c,
                                                    Placenta_2_0_Stored__c,
                                                    Exosomes_Stored__c,
                                                    My_Genome_Premium_Stored__c,
                                                    My_Genome_Standard_Stored__c,
                                                    Newborn_Genome_Stored__c,
                                                    Newborn_Panel_Stored__c,
                                                    Maternal_Exosomes_Stored__c,
                                                    Storage_Plan_Stored__c,
                                                    Payment_Plan_Stored__c,
                                                    Sales_Discount__c,
                                                    Deposit__c,
                                                    Price_Book__c,
                                                    Baby_Born__c,
                                                    Billing_Notes__c,
                                                    Shipping_Type__c
                                                    FROM fw1__Invoice__c WHERE Id =: typedRecordId ];
            if ( cboList.size () == 0 ) {
                // TODO: throw Exception - no opp found
            } else {
                // call create input
                input = new OrderCalculator.Input ( cboList [0], forceOrderEnrolled );
            }
        }
        
        return JSON.serialize ( input );
    }
    
    // write input and output to Opportunity
    @AuraEnabled ( cacheable = false )
    public static void writeToRecord ( string inputJson, string outputJson ) {

        // turn into proper objects
        OrderCalculator.Input input = (OrderCalculator.Input) JSON.deserialize ( inputJson, OrderCalculator.Input.class );
        System.debug('input on write to record: '+input);
        //There are temporarily 2 different paths for calculating.  The Slider calculator and the standard calculator.  These paths will be consolidated once the slider has been tested and either rejected or made standard.  In the meantime, we need to support both. If this method is called from the standard calculator component, but the opportunity it's being called on was created via the web slider, or the internal slider calculator, we need to 'reset' it to utilize the standard calculator.  That means clearing out the pricingVersion field and clearing the web pricebook so it uses the default pricebook
        input.priceBookId = null;
        input.pricingVersion = null;
        OrderCalculator.Output output = (OrderCalculator.Output) JSON.deserialize ( outputJson, OrderCalculator.Output.class );

        // determine the type of object
        Id typedRecordId = (Id) input.recordId;
        string sObjectName = typedRecordId.getSobjectType ().getDescribe ().getName ();

        if ( sObjectName == 'Opportunity' ) {
            Opportunity opp = new Opportunity ();
            opp = input.convertToOpportunity ( opp );
            try {
                update opp; 
            } catch (Exception e) {
                if (e.getMessage().contains('cannot change pricebook on opportunity with line items')) {
                    //If there are already line-items and we're switching pricebooks, delete existing line items
                    List<OpportunityLineItem> existingItems = [SELECT ID FROM OpportunityLineItem WHERE OpportunityId=:opp.Id];
                    delete existingItems;
                    update opp; 
                } else {
                    throw e;
                }
            }

        } else if ( sObjectName == 'fw1__Invoice__c' ) {
            fw1__Invoice__c cbo = new fw1__Invoice__c ();
            cbo = input.convertToCordBloodOrder ( cbo );
            update cbo;
        }       
        return;
    }

    @AuraEnabled ( cacheable = false ) 
    public static boolean isInputValid ( string inputString ) {
        boolean returnVal = false;
        OrderCalculator.Input input = (OrderCalculator.Input) JSON.deserialize ( inputString, OrderCalculator.Input.class );
        try {
            input.emptyFieldValidation ();
            input.fieldValueValidation ();
            returnVal = true;
        } catch ( Exception e ) {
            returnVal = false;
        }
        return returnVal;
    }

}