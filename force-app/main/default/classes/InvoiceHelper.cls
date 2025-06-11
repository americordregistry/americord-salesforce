public with sharing class InvoiceHelper {
    public InvoiceHelper(){
        
    }
/*
    public static void setPaymentPlan2(List<fw1__Invoice__c> invsToUpdate) {
        if (invsToUpdate != null) {
        	if (invsToUpdate.size() > 0) {
            	for (fw1__Invoice__c inv : invsToUpdate) {
                    try {
                        //DateTime dT = inv.LastModifiedDate;
                        DateTime dT = System.now();
                        inv.fw1__Invoice_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                        if (string.isNotEmpty(inv.Payment_Plan_Keyword__c)) {
                            inv.fw1__Payment_Plan__c = getPaymentPlan(inv.Payment_Plan_Keyword__c);
                        }
                    }
                    catch (Exception e) {}
                }
                try {
                	update invsToUpdate;
                }
                catch (Exception e) {}
            }
        }
    }
*/    
    /*
    public static void setPaymentPlan(List<Lab__c> labs) {
        
        // get invoice associated with the lab
        Set<Id> invIds = new Set<Id>();
        Map<Id, Lab__c> invToLabMap = new Map<Id, Lab__c>();
        for (Lab__c lab : labs) {
            if (string.isNotEmpty(lab.Cord_Blood_Order__c)) {
                invIds.add(lab.Cord_Blood_Order__c);
                invToLabMap.put(lab.Cord_Blood_Order__c, lab);
            }
        }
        
        if (invIds != null) {
            if (invIds.size() > 0) {
                List<fw1__Invoice__c> invsToUpdate = new List<fw1__Invoice__c>();
                invsToUpdate = [SELECT Id, fw1__Invoice_Date__c, fw1__Payment_Plan__c,
                                       Payment_Plan_Keyword__c
                                  FROM fw1__Invoice__c
                                 WHERE Id IN :invIds];
                if (invsToUpdate != null) {
                    if (invsToUpdate.size() > 0) {
                        for (fw1__Invoice__c inv : invsToUpdate) {
                            try {
                                DateTime dT = invToLabMap.get(inv.Id).LastModifiedDate;
                                inv.fw1__Invoice_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                                if (string.isNotEmpty(inv.Payment_Plan_Keyword__c)) {
                                    inv.fw1__Payment_Plan__c = getPaymentPlan(inv.Payment_Plan_Keyword__c);
                                }
                            }
                            catch (Exception e) {}
                        }
                        try {
                        	update invsToUpdate;
                        }
                        catch (Exception e) {}
                    }
                }
            }
        }
        
    }
	*/
/*    
    private static ID getPaymentPlan(String planKeyword) {
        ID planId;
        
        try {
            planKeyword = '%' + planKeyword + '%';
            fw1__Payment_Plan__c plan = new fw1__Payment_Plan__c();
            plan = [SELECT Id
                      FROM fw1__Payment_Plan__c
                     WHERE Name LIKE :planKeyword
                     LIMIT 1];
            if (plan != null) {
                planId = plan.Id;
            }
        }
        catch (Exception e) {}
        
        return planId;
    }
*/
}