trigger setPaymentPlanTrigger on Lab__c (after update) {
    
    /*
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            
            List<Lab__c> labs = new List<Lab__c>();
            for (Lab__c lab : Trigger.New) {
                if (lab.ACord_Certificate_of_Storage_Generated__c == true && 
                    Trigger.oldMap.get(lab.Id).ACord_Certificate_of_Storage_Generated__c == false) {
                    
                    labs.add(lab);
                }
            }
            if (labs != null) {
                if (labs.size() > 0) {
                    InvoiceHelper.setPaymentPlan(labs);
                }
            }
        }
    }
	*/

}