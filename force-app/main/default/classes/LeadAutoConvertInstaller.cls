// ==========================
// INSTALLER: creates 12 schedules (every 5 minutes)
// ==========================
public class LeadAutoConvertInstaller {
    public static final String NAME_PREFIX = 'Lead Auto Convert q5 m'; // job name prefix
    public static final List<Integer> MINS = new List<Integer>{
        0,5,10,15,20,25,30,35,40,45,50,55
    };

    // Call from Execute Anonymous: LeadAutoConvertInstaller.install(true); 
    @TestVisible
    public static void install(Boolean replaceExisting) {
        if (replaceExisting) {
            // Abort any existing q5 jobs created earlier by this installer
            for (CronTrigger ct : [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE : (NAME_PREFIX + '%')
            ]) {
                System.abortJob(ct.Id);
            }
        }

        Integer idx = 0;
        for (Integer m : MINS) {
            // 6-field CRON: seconds minutes hours day-of-month month day-of-week
            // Use ONLY integers for seconds/minutes to avoid parser errors.
            // Example: "0 5 * * * ?" → at second 0, minute 5, every hour, any day/month, any DOW.
            String jobName;
            String cron = '0 ' + String.valueOf(m) + ' * * * ?';
            if(m < 10){
                jobName = NAME_PREFIX + '0' + m + ' #' + (++idx);
            }
            else{
                jobName = NAME_PREFIX + m + ' #' + (++idx);
            }
            
            System.schedule(jobName, cron, new LeadAutoConvertScheduler());
        }
    }

    // Optional: quick clean-up if you ever want to remove all q5 jobs
    @TestVisible
    public static void uninstall() {
        for (CronTrigger ct : [
            SELECT Id
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE : (NAME_PREFIX + '%')
        ]) {
            System.abortJob(ct.Id);
        }
    }
}