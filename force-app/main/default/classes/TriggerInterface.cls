public interface TriggerInterface {
    
    void beforeInsert(List<sObject> newRecordsList);

    void afterInsert(List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap);

    void beforeUpdate(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap); 

    void afterUpdate(Map<Id, sObject> newRecordsMap,  Map<Id, sObject> oldRecordsMap);

    void beforeDelete(Map<Id, sObject> oldRecordsMap);
              
}