public with sharing class ContentDocumentLinkHandler implements TriggerInterface{

    public static void afterInsert(List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap){      
         ContentDocumentLinkHelper.updateClientDocumentTracker((Map<Id, ContentDocumentLink>)newRecordsMap);  
    }

    public static void beforeInsert(List<sObject> newRecordsList){
    }
    
    public static void afterUpdate(Map<Id, sObject> newRecordsMap , Map<Id, sObject> oldRecordsMap){      
    }

    public static void beforeUpdate(Map<Id, sObject> newRecordsMap , Map<Id, sObject> oldRecordsMap){
    }

    public static void beforeDelete(Map<Id, sObject> oldRecordsMap){
        ContentDocumentLinkHelper.removeDocumentFromClientDocumentTracker((Map<Id, ContentDocumentLink>)oldRecordsMap);  
    }
}