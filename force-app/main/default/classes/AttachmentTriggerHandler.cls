public with sharing class AttachmentTriggerHandler implements TriggerInterface{

    public static void afterInsert(List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap){      
         AttachmentTriggerHelper.updateClientDocumentTracker((Map<Id, Attachment>)newRecordsMap);  
    }

    public static void beforeInsert(List<sObject> newRecordsList){
    }
    
    
    public static void afterUpdate(Map<Id, sObject> newRecordsMap , Map<Id, sObject> oldRecordsMap){      
    }

    public static void beforeUpdate(Map<Id, sObject> newRecordsMap , Map<Id, sObject> oldRecordsMap){
    }

    public static void beforeDelete(Map<Id, sObject> oldRecordsMap){
        AttachmentTriggerHelper.removeDocumentFromClientDocumentTracker((Map<Id, Attachment>)oldRecordsMap);  
    }

 
}