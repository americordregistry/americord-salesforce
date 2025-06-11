/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_AccountTest
{
    @IsTest(SeeAllData=true)
    private static void testTrigger()
    {
        // Force the dlrs_fw1_InvoiceTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Account());
    }
}