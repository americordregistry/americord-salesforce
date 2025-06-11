trigger AttachmentTrigger on Attachment (before insert, after insert, before update, after update, before delete) {
    Americord_Settings__c setting = Americord_Settings__c.getInstance ();
    
    if (!setting.Disable_Triggers__c) {
    	TriggerDispatcher.run( new AttachmentTriggerHandler() , Trigger.OperationType );
    }
    
     
}