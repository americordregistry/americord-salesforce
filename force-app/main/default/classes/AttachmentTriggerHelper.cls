public with sharing class AttachmentTriggerHelper {
    static Map<Id,Baby__c> mapFamilyMember = new Map<Id,Baby__c>();
    static String strLabPrefix = getObjectPrefix('Lab__c');
    static String strFamilyMemberPrefix = getObjectPrefix('Baby__c');

    public static void updateClientDocumentTracker(Map<Id,Attachment> newAttachmentMap){
        List<Attachment> lstLabAttachments = new List<Attachment>();
        List<Client_Document_Tracker__c> lstClientDocumentTrackerToUpdate = new List<Client_Document_Tracker__c>();
        Client_Document_Tracker__c currentDocTracker = new Client_Document_Tracker__c();
        Set<String> setParentIds = new Set<String>();
        Set<Id> setAtt = new Set<Id>();
        Set<Id> setFamilyMember = new Set<Id>();
        Set<Id> setLab = new Set<Id>();
        Map<Id,Client_Document_Tracker__c> mapClientDocumentTrackerParentsCreate = new Map<Id,Client_Document_Tracker__c>();
        Map<Id,Client_Document_Tracker__c> mapClientDocumentTrackerParentsUpdate = new Map<Id,Client_Document_Tracker__c>();
        Map<Id,Client_Document_Tracker__c> mapClientDocumentTracker = new Map<Id,Client_Document_Tracker__c>();

        // loop through and find attachments on lab - create sublist
        for(Attachment att: newAttachmentMap.values()){
            if(String.valueOf(att.ParentId).substring(0,3) == strLabPrefix ||
               String.valueOf(att.ParentId).substring(0,3) == strFamilyMemberPrefix){
                lstLabAttachments.add(att);
                setParentIds.add(att.ParentId);
            }
            // store just family member/baby for query
            if(String.valueOf(att.ParentId).substring(0,3) == strFamilyMemberPrefix){
                setFamilyMember.add(att.ParentId);
            }
            // store just lab
            if(String.valueOf(att.ParentId).substring(0,3) == strLabPrefix){
                setLab.add(att.ParentId);
            }
        }

        if(!setFamilyMember.isEmpty()){
            for(Baby__c fm: [
                SELECT Id, Lab__c 
                FROM Baby__c 
                WHERE Id IN :setFamilyMember]){
                    mapFamilyMember.put(fm.id,fm);
                    setLab.add(fm.Lab__c);
                }
        }

        // Get Client Document Trackers for Labs
        for(Client_Document_Tracker__c cdt: [
            SELECT 
            Lab__c,
            Client_Document_1__c, Client_Document_1_Name__c, Client_Document_1_Type__c, Client_Document_1_Label__c,
            Client_Document_2__c, Client_Document_2_Name__c, Client_Document_2_Type__c, Client_Document_2_Label__c,
            Client_Document_3__c, Client_Document_3_Name__c, Client_Document_3_Type__c, Client_Document_3_Label__c,
            Client_Document_4__c, Client_Document_4_Name__c, Client_Document_4_Type__c, Client_Document_4_Label__c,
            Client_Document_5__c, Client_Document_5_Name__c, Client_Document_5_Type__c, Client_Document_5_Label__c,
            Client_Document_6__c, Client_Document_6_Name__c, Client_Document_6_Type__c, Client_Document_6_Label__c,
            Client_Document_7__c, Client_Document_7_Name__c, Client_Document_7_Type__c, Client_Document_7_Label__c,
            Client_Document_8__c, Client_Document_8_Name__c, Client_Document_8_Type__c, Client_Document_8_Label__c,
            Client_Document_9__c, Client_Document_9_Name__c, Client_Document_9_Type__c, Client_Document_9_Label__c,
            Client_Document_10__c, Client_Document_10_Name__c, Client_Document_10_Type__c, Client_Document_10_Label__c,
            Client_Document_11__c, Client_Document_11_Name__c, Client_Document_11_Type__c, Client_Document_11_Label__c,
            Client_Document_12__c, Client_Document_12_Name__c, Client_Document_12_Type__c, Client_Document_12_Label__c,
            Client_Document_13__c, Client_Document_13_Name__c, Client_Document_13_Type__c, Client_Document_13_Label__c,
            Client_Document_14__c, Client_Document_14_Name__c, Client_Document_14_Type__c, Client_Document_14_Label__c,
            Client_Document_15__c, Client_Document_15_Name__c, Client_Document_15_Type__c, Client_Document_15_Label__c,
            Client_Document_16__c, Client_Document_16_Name__c, Client_Document_16_Type__c, Client_Document_16_Label__c,
            Client_Document_17__c, Client_Document_17_Name__c, Client_Document_17_Type__c, Client_Document_17_Label__c,
            Client_Document_18__c, Client_Document_18_Name__c, Client_Document_18_Type__c, Client_Document_18_Label__c,
            Client_Document_19__c, Client_Document_19_Name__c, Client_Document_19_Type__c, Client_Document_19_Label__c,
            Client_Document_20__c, Client_Document_20_Name__c, Client_Document_20_Type__c, Client_Document_20_Label__c,
            Certificate_of_Storage_1__c,
            Certificate_of_Storage_2__c,
            Certificate_of_Storage_3__c,
            Certificate_of_Storage_4__c,
            Certificate_of_Storage_5__c
            FROM Client_Document_Tracker__c 
            WHERE Lab__c in :setLab ]){
            mapClientDocumentTracker.put(cdt.Lab__c,cdt);
        }

        if (lstLabAttachments.size() > 0){ // if lab attachments            
            // loop over lab documents
            for(Attachment att: lstLabAttachments){
                Id idLab = getLabFromAttachment(att);
                // does Client Document Tracker doc exist - if not create it
                if(mapClientDocumentTracker.containsKey(idLab)){
                    currentDocTracker = ClientDocumentTracker.setTrackerFieldsAttachment(mapClientDocumentTracker.get(idLab),att);
                    mapClientDocumentTrackerParentsUpdate.put(idLab,currentDocTracker);
                }
                else{
                    // did we already add it in this batch?
                    if(mapClientDocumentTrackerParentsCreate.containsKey(idLab)){
                        currentDocTracker = ClientDocumentTracker.setTrackerFieldsAttachment(mapClientDocumentTrackerParentsCreate.get(idLab),att);
                        mapClientDocumentTrackerParentsCreate.put(idLab,currentDocTracker);
                    }
                    else{
                        currentDocTracker = ClientDocumentTracker.setTrackerFieldsAttachment(new Client_Document_Tracker__c (Lab__c = idLab),att);
                        mapClientDocumentTrackerParentsCreate.put(idLab,currentDocTracker);
                    }
                }

            }
        }
        // do updates/inserts
        if(mapClientDocumentTrackerParentsCreate.values().size()>0){
            insert mapClientDocumentTrackerParentsCreate.values();
        }

        if(mapClientDocumentTrackerParentsUpdate.values().size()>0){
            update mapClientDocumentTrackerParentsUpdate.values();
        }
        
    }

    public static void removeDocumentFromClientDocumentTracker(Map<Id,Attachment> oldAttachmentMap){
        List<Attachment> lstLabAttachments = new List<Attachment>();
        List<Client_Document_Tracker__c> lstClientDocumentTrackerToUpdate = new List<Client_Document_Tracker__c>();
        Client_Document_Tracker__c currentDocTracker = new Client_Document_Tracker__c();
        Set<String> setParentIds = new Set<String>();
        Set<Id> setAtt = new Set<Id>();
        Set<Id> setFamilyMember = new Set<Id>();
        Set<Id> setLab = new Set<Id>();
        Map<Id,Client_Document_Tracker__c> mapClientDocumentTrackerParentsCreate = new Map<Id,Client_Document_Tracker__c>();
        Map<Id,Client_Document_Tracker__c> mapClientDocumentTrackerParentsUpdate = new Map<Id,Client_Document_Tracker__c>();
        Map<Id,Client_Document_Tracker__c> mapClientDocumentTracker = new Map<Id,Client_Document_Tracker__c>();

        // loop through and find attachments on lab - create sublist
        for(Attachment att: oldAttachmentMap.values()){
            if(String.valueOf(att.ParentId).substring(0,3) == strLabPrefix ||
               String.valueOf(att.ParentId).substring(0,3) == strFamilyMemberPrefix){
                lstLabAttachments.add(att);
                setParentIds.add(att.ParentId);
            }
            // store just family member/baby for query
            if(String.valueOf(att.ParentId).substring(0,3) == strFamilyMemberPrefix){
                setFamilyMember.add(att.ParentId);
            }
            // store just lab
            if(String.valueOf(att.ParentId).substring(0,3) == strLabPrefix){
                setLab.add(att.ParentId);
            }
        }

        if(!setFamilyMember.isEmpty()){
            for(Baby__c fm: [
                SELECT Id, Lab__c 
                FROM Baby__c 
                WHERE Id IN :setFamilyMember]){
                    mapFamilyMember.put(fm.id,fm);
                    setLab.add(fm.Lab__c);
                }
        }

        // Get Client Document Trackers for Labs
        for(Client_Document_Tracker__c cdt: [
            SELECT 
            Lab__c,
            Informed_Consent_Document__c, Surrogate_Informed_Consent_Document__c,
            MHQ_Document__c, Surrogate_MHQ_Document__c,
            Biopreservation_Document__c,
            Healthcare_Team_Document__c,
            General_Services_Agreement_Document__c,
            Storage_Agreement_Document__c,
            Invoice_Document__c,
            Client_Document_1__c, 
            Client_Document_2__c, 
            Client_Document_3__c, 
            Client_Document_4__c, 
            Client_Document_5__c,
            Client_Document_6__c,
            Client_Document_7__c,
            Client_Document_8__c,
            Client_Document_9__c,
            Client_Document_10__c,
            Client_Document_11__c,
            Client_Document_12__c,
            Client_Document_13__c,
            Client_Document_14__c,
            Client_Document_15__c,
            Client_Document_16__c,
            Client_Document_17__c,
            Client_Document_18__c,
            Client_Document_19__c,
            Client_Document_20__c,
            Certificate_of_Storage_1__c,
            Certificate_of_Storage_2__c,
            Certificate_of_Storage_3__c,
            Certificate_of_Storage_4__c,
            Certificate_of_Storage_5__c
            FROM Client_Document_Tracker__c 
            WHERE Lab__c in :setLab ]){
            mapClientDocumentTracker.put(cdt.Lab__c,cdt);
        }

        if (lstLabAttachments.size() > 0){ // if lab attachments            
            // loop over lab documents
            for(Attachment att: lstLabAttachments){
                Id idLab = getLabFromAttachment(att);
                // does Client Document Tracker doc exist - if not - nothing to do
                if(mapClientDocumentTracker.containsKey(idLab)){
                    currentDocTracker = ClientDocumentTracker.clearTrackerFieldsAttachment(mapClientDocumentTracker.get(idLab),att);
                    mapClientDocumentTrackerParentsUpdate.put(idLab,currentDocTracker);
                }
                else{
                    // nothing to do - fetch next attachment
                }

            }
        }
        // do updates for cdt

        if(mapClientDocumentTrackerParentsUpdate.values().size()>0){
            update mapClientDocumentTrackerParentsUpdate.values();
        }

    }
    private static String getObjectPrefix(String strObjectName){
        Schema.SObjectType s = Schema.getGlobalDescribe().get(strObjectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String strReturnPrefix = r.getKeyPrefix();
        return strReturnPrefix;
    }

    private static Id getLabFromAttachment(Attachment att){
        Id idLab;
        if(String.valueOf(att.ParentId).substring(0,3) == strLabPrefix){ // lab entity
            idLab = att.ParentId;
        }
        else if (String.valueOf(att.ParentId).substring(0,3) == strFamilyMemberPrefix) { // baby entity
            idLab = mapFamilyMember.get(att.ParentId).Lab__c;
        }

        return idLab;
    }

}