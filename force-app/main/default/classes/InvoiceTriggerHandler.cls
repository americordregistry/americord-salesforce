public with sharing class InvoiceTriggerHandler implements TriggerInterface  {
    
    public static void beforeInsert(List<sObject> newRecordsList){        
       InvoiceTriggerHelper.addOpportunityInfo((List<fw1__Invoice__c>)newRecordsList);
    }

    public static void afterInsert(List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap){      
        InvoiceTriggerHelper.updateRelatedFromOpportunity((Map<Id, fw1__Invoice__c>)newRecordsMap);  
        InvoiceTriggerHelper.createLab((List<fw1__Invoice__c>)newRecordsList); 
        InvoiceTriggerHelper.createLineItemsFromOpp((List<fw1__Invoice__c>)newRecordsList);
    }

    public static void beforeUpdate(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
    }

    public static void afterUpdate(Map<Id, sObject> newRecordsMap,  Map<Id, sObject> oldRecordsMap){    
        InvoiceTriggerHelper.createInstallments((Map<Id, fw1__Invoice__c>)newRecordsMap, (Map<Id, fw1__Invoice__c>)oldRecordsMap);
    }

    public static void beforeDelete(Map<Id, sObject> deleteRecordsMap){
    }


}