public with sharing class OpportunityTriggerHelper {

    public static void setPriceBook (List<Opportunity> opptyList) {
        Americord_Settings__c setting = Americord_Settings__c.getInstance(); 
        for (Opportunity op : opptyList) {
            op.Pricebook2Id = setting.Current_Price_Book__c; 
        }
    }

    public static void createCordBloodOrder(List<Opportunity> opptyList,  Map<id, Opportunity> oldOpptyMap) {
        List<Id> oppIds = new List<Id>();
        boolean isStageNameChanged;
        for (Opportunity op : opptyList) { 
            isStageNameChanged =  Toolkit.compareFields ( 'StageName', Toolkit.CompareOperation.NOTEQUAL, oldOpptyMap.get(op.Id), op );
            if (isStageNameChanged  && op.StageName == 'Enrolled') {
                oppIds.add(op.Id);
            }
        }
        
        if (oppIds.size() > 0) {
            fw2.OpportunityToInvoice.createInvOrRecurringInv(oppIds);
        }
    }
    
   
}