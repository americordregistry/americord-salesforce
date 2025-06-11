public with sharing class OpportunityTriggerHandler implements TriggerInterface {
    
    public static void beforeInsert(List<sObject> newRecordsList){
        OpportunityTriggerHelper.setPriceBook((List<Opportunity>)newRecordsList);
    }

    public static void afterInsert(List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap){
    }

    public static void beforeUpdate(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
    }

    public static void beforeDelete(Map<Id, sObject> deleteRecordsMap){
    }

    public static void afterUpdate(Map<Id, sObject> newRecordsMap,  Map<Id, sObject> oldRecordsMap){
        List<Opportunity> newOpptyList = (List<Opportunity>)newRecordsMap.values();
        Map<id, Opportunity> oldOpptyMap = (Map<id, Opportunity>) oldRecordsMap;
        OpportunityTriggerHelper.createCordBloodOrder(newOpptyList, oldOpptyMap) ;
    }

}