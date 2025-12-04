@IsTest
private class LeadAutoConvertInstallerTest {

    @IsTest
    static void test_install_and_uninstall_only() {
        // Create the 12 schedules and let them execute once
        Test.startTest();
        LeadAutoConvertInstaller.install(true);
        Test.stopTest(); // scheduled jobs fire here (execute()), but we don't assert convert counters

        // Verify 12 jobs exist (named with the installer prefix) 
        Integer scheduledCount = [
            SELECT COUNT()
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE : (LeadAutoConvertInstaller.NAME_PREFIX + '%')
        ];
        System.assertEquals(12, scheduledCount, 'Expected 12 jobs to be scheduled.');

        // Uninstall WITHOUT a second startTest()
        LeadAutoConvertInstaller.uninstall();

        // Confirm removal
        Integer remaining = [
            SELECT COUNT()
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE : (LeadAutoConvertInstaller.NAME_PREFIX + '%')
        ];
        System.assertEquals(0, remaining, 'Expected all jobs to be removed.');
    }
}