/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_fw11_Revenue_RecordTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_fw11_Revenue_RecordTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new fw11__Revenue_Record__c());
    }
}