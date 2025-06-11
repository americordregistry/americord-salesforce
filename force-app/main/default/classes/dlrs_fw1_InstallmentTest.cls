/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_fw1_InstallmentTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_fw1_InstallmentTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new fw1__Installment__c());
    }
}