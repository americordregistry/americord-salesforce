// ==========================
// SCHEDULER: runs ConvertLead.run()
// ==========================
global class LeadAutoConvertScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ConvertLead.run(); 
    }
}