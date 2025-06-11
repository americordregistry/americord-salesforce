public with sharing class ContentDocumentHelper {
    public static void removeDocumentFromClientDocumentTracker(Map<Id,ContentDocument> oldContentDocumentMap){
        Map<Id,ContentDocumentLink> mapContentDocumentLink = new Map<Id,ContentDocumentLink>();
        Set<Id> setContentDocumentIds = new Set<Id>();

        setContentDocumentIds = oldContentDocumentMap.keySet();

        mapContentDocumentLink = new Map<ID, ContentDocumentLink>([
            SELECT 
            Id, LinkedEntityId
            FROM
            ContentDocumentLink
            WHERE ContentDocumentId in :setContentDocumentIds
        ]);

        // create map and call over to the ContentDocumentLinkHelper
        
        ContentDocumentLinkHelper.removeDocumentFromClientDocumentTracker(mapContentDocumentLink);

    }
}