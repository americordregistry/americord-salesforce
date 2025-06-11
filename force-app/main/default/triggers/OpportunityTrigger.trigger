trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update) {
    Americord_Settings__c setting = Americord_Settings__c.getInstance();
    if (!setting.Disable_Triggers__c) {
    	TriggerDispatcher.run( new OpportunityTriggerHandler() , Trigger.OperationType );
    }
 
}