/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_fw1_Invoice_LineTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_fw1_Invoice_LineTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new fw1__Invoice_Line__c());
    }
}