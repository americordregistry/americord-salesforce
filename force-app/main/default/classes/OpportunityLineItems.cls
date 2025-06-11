public with sharing class OpportunityLineItems {
    private List<OpportunityLineItem> newOpptyLineItems = new List<OpportunityLineItem>();    
    private List<OpportunityLineItem> deleteOpptyLineItems = new List<OpportunityLineItem>();        
    private Set<Id> opptyIds = new Set<Id>();
    
    public void create(List<Opportunity> opptyList) {
        for (Opportunity op : opptyList) { 
            try {           
                OrderCalculator.Output output = OrderCalculator.calculate ( getCalcInput(op) );
                    System.debug('output: '+output);
                    if (output.lineItems.size() > 0) {                   
                        newOpptyLineItems.addAll(convertToOpptyLineItems(output.lineItems, op.Id, op.Pricebook2Id));
                    }
                    opptyIds.add(op.Id);                                  
                
            } catch (OrderCalculatorException oce ){
                op.addError(oce.userMessage);
            } catch (AuraHandledException ex) {
                op.addError(ex.getMessage());
            } 
            
        }

        deleteOpptyLineItems.addAll(getOpptyLineItems(opptyIds));

        System.debug('Size of delete list:'+deleteOpptyLineItems.size());
        if (deleteOpptyLineItems.size() > 0){
            for(OpportunityLineItem oli: deleteOpptyLineItems){
                System.debug('Deleting:'+oli.Name);
            }
            delete deleteOpptyLineItems;
        }
        
        if (newOpptyLineItems.size() > 0){
            insert newOpptyLineItems;
        }
        
        
        
    }
    
    public void updateOppty(List<Opportunity> opptyList) {
        for (Opportunity op : opptyList) { 
            try {                                                
                OrderCalculator.Output output = OrderCalculator.calculate ( getCalcInput(op) );                 
                op = output.convertToOpportunity (op);                 
            } catch (OrderCalculatorException oce ){
                op.addError(oce.userMessage);
            } catch (AuraHandledException ex) {
                op.addError(ex.getMessage());
            }          
        }
        update opptyList;
    }
    
    public static OrderCalculator.Input getCalcInput(Opportunity op) {
        OrderCalculator.Input input = new OrderCalculator.Input ();
        input.birthCount = integer.valueOf(op.Numeric_Births__c);
        input.cordBlood2Quantity = integer.valueOf(op.Cord_Blood_2_0__c);
        input.cordTissueQuantity = integer.valueOf(op.Cord_Tissue__c);
        input.placenta2Quantity = integer.valueOf(op.Placenta_2_0__c);

        input.exosomesQuantity = integer.valueOf(op.Exosomes__c);
        input.momPremiumGenomicsQuantity = integer.valueOf(op.My_Genome_Premium__c);
        input.momStandardGenomicsQuantity = integer.valueOf(op.My_Genome_Standard__c);
        input.newbornGenomeQuantity = integer.valueOf(op.Newborn_Genome__c);
        input.newbornPanelQuantity = integer.valueOf(op.Newborn_Panel__c);

        input.maternalExosomesQuantity = integer.valueOf(op.Maternal_Exosomes__c);

        input.priceBookId = op.Pricebook2Id;
        input.paymentPlan = op.Payment_Plans__c;
        input.storagePlan = op.Storage_Plan__c;
        input.discountCode = op.Coupon_Code__c;
        input.salesDiscount = op.Sales_Discount__c;
        input.depositAmount = op.Deposit__c;
        input.pricingVersion = op.Pricing_Version__c;
        input.shippingType = op.Shipping_Type__c;
        return input;
    }
    
    
    private List<OpportunityLineItem> convertToOpptyLineItems(List<OrderCalculator.LineItem> lineItems, id opptyId, id priceBookId) {
		List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>();
        for (OrderCalculator.LineItem li : lineItems) {

            System.debug('adding opp line items:'+li.productName+' '+li.productCode);
            
            OpportunityLineItem opli = new OpportunityLineItem();            
            opli.OpportunityId = opptyId;
            opli.Product2Id = li.productId;
            opli.Price_Book__c = priceBookId;
            opli.Product_Code__c = li.productCode;        
            opli.Category__c = li.category;
            opli.Quantity = li.quantity;                        
            opli.ServiceDate = Date.today();       
            opli.TotalPrice = (li.unitPrice * li.quantity).round(System.RoundingMode.HALF_UP); 
            opptyLineItems.add(opli);
        }
		return opptyLineItems;        
    }
	
    private List<OpportunityLineItem> getOpptyLineItems(Set<Id> opptyIds) {

        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>();
        opptyLineItems = [
            SELECT Id,Name,Category__c,Price_Book__c,TotalPrice,UnitPrice,Product_Code__c,Quantity,Product2Id,OpportunityId
            FROM OpportunityLineItem
            WHERE OpportunityId IN :opptyIds];
        
		return opptyLineItems;         
    }

}