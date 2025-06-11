trigger setPaymentPlanTrigger2 on fw1__Invoice__c (before update) {
/*    
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            
            List<fw1__Invoice__c> invs = new List<fw1__Invoice__c>();
            for (fw1__Invoice__c inv : Trigger.New) {
                if (inv.fw1__Auto_BillPay__c == true && 
                    Trigger.oldMap.get(inv.Id).fw1__Auto_BillPay__c == false &&
                    !inv.is_Migrated__c) {
                    
                    invs.add(inv);
                }
            }
            if (invs != null) {
                if (invs.size() > 0) {
                    InvoiceHelper.setPaymentPlan2(invs);
                }
            }
        }
    }
*/
}