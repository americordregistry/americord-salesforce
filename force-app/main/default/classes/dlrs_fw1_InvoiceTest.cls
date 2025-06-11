/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_fw1_InvoiceTest
{
    @IsTest(SeeAllData=true)
    private static void testTrigger()
    {
Account acct = new Account(name='TestAcct');
insert acct;

dlrs.RollupService.testHandler(new fw1__Invoice__c(fw1__Account__c=acct.Id));
    }
}