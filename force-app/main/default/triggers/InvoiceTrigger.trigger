trigger InvoiceTrigger on fw1__Invoice__c (before insert, after insert, before update, after update) {
    Americord_Settings__c setting = Americord_Settings__c.getInstance ();
    if (!setting.Disable_Triggers__c) {
    	TriggerDispatcher.run( new InvoiceTriggerHandler() , Trigger.OperationType );
    }
     
}