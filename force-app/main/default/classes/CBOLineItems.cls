public with sharing class CBOLineItems {

    private List<fw1__Invoice_Line__c> newInvLineItems = new List<fw1__Invoice_Line__c>();
    private List<fw1__Invoice_Line__c> deleteInvLineItems = new List<fw1__Invoice_Line__c>();
    private List<fw1__Additional_Charge__c> newAddlCharges = new List<fw1__Additional_Charge__c>(); 
    private List<fw1__Additional_Charge__c> delAddlCharges = new List<fw1__Additional_Charge__c>(); 
    private string TOTAL_MONTHLY_FEES = 'Total Monthly Fees';
    Set<Id> invIds = new Set<Id>();
    
    public void create(List<fw1__Invoice__c> invoices) {
        getMaitenanceProducts();
        for (fw1__Invoice__c inv : invoices) { 
            try {     
                OrderCalculator.Output output = OrderCalculator.calculate ( getCalcInput(inv) );
                System.debug('output.lineItems: '+JSON.serialize(output.lineItems));
                    if (output.lineItems.size() > 0) {                
                        newInvLineItems.addAll(convertToInvLineItems(output.lineItems, inv));
                    }
                    if (output.totalMonthlyFees > 0){
                        newAddlCharges.add(createAddlCharge(inv,output.totalMonthlyFees));
                    }
                    invIds.add(inv.Id);
            } catch (OrderCalculatorException oce ){
                inv.addError(oce.userMessage);
            } catch (AuraHandledException ex) {
                inv.addError(ex.getMessage());
            } 
        }
        deleteInvLineItems = getInvoiceLineItems(invIds);
        delAddlCharges = getAddlCharges(invIds);
        
        if (deleteInvLineItems.size() > 0)
            delete deleteInvLineItems;
        if (delAddlCharges.size() > 0)
            delete delAddlCharges;
        
        if (newInvLineItems.size() > 0)
            insert newInvLineItems;        
        if (newAddlCharges.size() > 0)
            insert newAddlCharges;
            
    }
    
    public static OrderCalculator.Input getCalcInput(fw1__Invoice__c inv) {
        OrderCalculator.Input input = new OrderCalculator.Input ();
        if (inv.Deposit__c == null)
            inv.Deposit__c = 0;
        
        input.birthCount = integer.valueOf(inv.Numeric_Births__c);
        input.salesDiscount = inv.Sales_Discount__c ;
        input.depositAmount = inv.Deposit__c;
        input.priceBookId = inv.Price_Book__c;
        input.pricingVersion = inv.Pricing_Version__c;
        input.shippingType = inv.Shipping_Type__c;

        system.debug('Baby Born:'+inv.Baby_Born__c+' Storage:'+inv.Storage_Plan_Ordered__c+' Payment:'+inv.Payment_Plan_Stored__c);        

        if (inv.Baby_Born__c && string.isNotEmpty(inv.Storage_Plan_Stored__c) && string.isNotEmpty(inv.Payment_Plan_Stored__c)) { 
            input.cordBlood2Quantity = integer.valueOf(inv.Cord_Blood_2_0_Stored__c);
            input.cordTissueQuantity = integer.valueOf(inv.Cord_Tissue_Stored__c);
            input.placenta2Quantity = integer.valueOf(inv.Placenta_2_0_Stored__c);        
            
            input.exosomesQuantity = integer.valueOf(inv.Exosomes_Stored__c);   
            input.momPremiumGenomicsQuantity = integer.valueOf(inv.My_Genome_Premium_Stored__c);   
            input.momStandardGenomicsQuantity = integer.valueOf(inv.My_Genome_Standard_Stored__c);   
            input.newbornGenomeQuantity = integer.valueOf(inv.Newborn_Genome_Stored__c);   
            input.newbornPanelQuantity = integer.valueOf(inv.Newborn_Panel_Stored__c); 
            input.maternalExosomesQuantity =  integer.valueOf(inv.Maternal_Exosomes_Stored__c); 

            input.paymentPlan = inv.Payment_Plan_Stored__c;
            input.storagePlan = inv.Storage_Plan_Stored__c;            
        } else {
            input.cordBlood2Quantity = integer.valueOf(inv.Cord_Blood_2_0_Ordered__c);
            input.cordTissueQuantity = integer.valueOf(inv.Cord_Tissue_Ordered__c);
            input.placenta2Quantity = integer.valueOf(inv.Placenta_2_0_Ordered__c);  
            
            input.exosomesQuantity = integer.valueOf(inv.Exosomes_Ordered__c); 
            input.momPremiumGenomicsQuantity = integer.valueOf(inv.My_Genome_Premium_Ordered__c); 
            input.momStandardGenomicsQuantity = integer.valueOf(inv.My_Genome_Standard_Ordered__c); 
            input.newbornGenomeQuantity = integer.valueOf(inv.Newborn_Genome_Ordered__c); 
            input.newbornPanelQuantity = integer.valueOf(inv.Newborn_Panel_Ordered__c); 
            input.maternalExosomesQuantity = integer.valueOf(inv.Maternal_Exosomes_Ordered__c); 

            input.paymentPlan = inv.Payment_Plan_Ordered__c;
            input.storagePlan = inv.Storage_Plan_Ordered__c;
        }
        return input;
    }
    
    private List<fw1__Invoice_Line__c> convertToInvLineItems(List<OrderCalculator.LineItem> lineItems, fw1__Invoice__c inv) {
        List<fw1__Invoice_Line__c> invLines = new List<fw1__Invoice_Line__c>();
        for (OrderCalculator.LineItem li : lineItems) {
            fw1__Invoice_Line__c item = new fw1__Invoice_Line__c();
            item.Name = li.productName;
            item.fw1__Invoice__c = inv.Id;
            item.fw1__Product2__c = li.productId;
            item.fw1__Price_Book__c = inv.Price_Book__c;
            item.Product_Code__c = li.productCode; 
            item.Category__c = li.category;
            if (li.productCode == 'ASP' && inv.Annual_Storage_Fee_Alt_Price__c != null && inv.Annual_Storage_Fee_Alt_Price__c > 0) {
                item.fw1__Unit_Price__c = inv.Annual_Storage_Fee_Alt_Price__c;
                item.Custom_Pricing__c = true;
            } else {
                item.fw1__Unit_Price__c = li.unitPrice;        
            }
            item.fw1__Quantity__c = li.quantity;                                        
            invLines.add(item);
        }
        return invLines;
    }
    
    public List<fw1__Invoice_Line__c> getInvoiceLineItems(Set<Id> invIds) {
        List<fw1__Invoice_Line__c> invLineItems = new List<fw1__Invoice_Line__c>();
        invLineItems = [
            SELECT Id,Name,Category__c,fw1__Price_Book__c,Subtotal__c,fw1__Unit_Price__c,Product_Code__c,fw1__Quantity__c,fw1__Product2__c,fw1__Invoice__c
            FROM fw1__Invoice_Line__c
            WHERE  fw1__Invoice__c IN :invIds];
        
        return invLineItems;
    }
    
    public List<fw1__Additional_Charge__c> getAddlCharges(Set<Id> invIds) {
        List<fw1__Additional_Charge__c> addlCharges = new List<fw1__Additional_Charge__c>();
         
        addlCharges = [
        	SELECT Id,Name,fw1__Invoice__c,fw1__Fixed_Amount__c
            FROM fw1__Additional_Charge__c
            WHERE fw1__Invoice__c IN :invIds
            AND Name Like :TOTAL_MONTHLY_FEES + '%'
        ] ;
        
        return addlCharges; 
    }
    
    private fw1__Additional_Charge__c createAddlCharge(fw1__Invoice__c inv, decimal monthlyFee) {
        fw1__Additional_Charge__c ac = new fw1__Additional_Charge__c();
        Product2 product;
        if (inv.Baby_Born__c && string.isNotEmpty(inv.Storage_Plan_Stored__c) && string.isNotEmpty(inv.Payment_Plan_Stored__c)) {
        	ac.Name = TOTAL_MONTHLY_FEES + ' - ' + inv.Payment_Plan_Stored__c;
            product = maitenanceProductsMap.get(inv.Payment_Plan_Stored__c);
            
        } else {
            ac.Name = TOTAL_MONTHLY_FEES + ' - ' + inv.Payment_Plan_Ordered__c;
            product = maitenanceProductsMap.get(inv.Payment_Plan_Ordered__c);            
        }
        
        if (product != null){
        	ac.Product__c = product.id;
        	ac.Name = product.Name;
        }
            
        ac.fw1__Fixed_Amount__c = monthlyFee;
        ac.fw1__Invoice__c = inv.Id;
        
        return ac;         
    }
    
    private Map<string,Product2> maitenanceProductsMap = new Map<string,Product2>();
    private void getMaitenanceProducts() {
		List<Product2> maitenanceProducts = [SELECT Id, Name, Family, ProductCode
                                            FROM Product2
                                            WHERE Family = 'Maintenance'
                                            AND IsActive = true];
        
        for (Product2 p : maitenanceProducts) {
            maitenanceProductsMap.put(p.ProductCode, p);
        }
    }
        
}