/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_fw11_Revenue_RecordTrigger on fw11__Revenue_Record__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(fw11__Revenue_Record__c.SObjectType);
}