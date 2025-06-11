trigger AutoVoidPaymentTrigger on fw1__Payment__c (after insert, after update) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Set<Id> recordIds = new Set<Id>();
            Map<Id, Id> recordToPaymentMap = new Map<Id, Id>();
            Set<Id> paymentsToVoid = new Set<Id>();
            Set<Id> newCreditCardsNeeded = new Set<Id>();
            Boolean isLead = true;

            for (fw1__Payment__c p : Trigger.New) {
                if (p.fw1__Status__c != 'Authorized') { continue; }

                if(String.isNotEmpty(p.fw1__Reference__c) && p.fw1__Reference__c == 'New Credit Card' && Trigger.isInsert){

                    paymentsToVoid.add(p.Id);
                    newCreditCardsNeeded.add(p.Id);

                } else if(String.isNotEmpty(p.Lead__c)){

                    recordIds.add(p.Lead__c);
                    recordToPaymentMap.put(p.Lead__c, p.Id);

                } else if(String.isNotEmpty(p.fw1__Opportunity__c)){

                    isLead = false;
                    recordIds.add(p.fw1__Opportunity__c);
                    recordToPaymentMap.put(p.fw1__Opportunity__c, p.Id);
                }
            }

            //if(!newCreditCardsNeeded.isEmpty()){
                //new credit card
                //link invoice to the new payment profile
                //AutoVoidPayments.linkInvoicePaymentProfile(newCreditCardsNeeded);
            //}

            if (recordIds != null) {
                if (recordIds.size() > 0) {
                    List<Sobject> recordList = new List<Sobject>();

                    if(isLead){
                        recordList = [SELECT Id
                                   FROM Lead
                                  WHERE Id IN :recordIds
                                    AND IsConverted = false
                                    AND Status != 'Enrolled'
                                    ];
                    } else {
                        recordList = [SELECT Id
                                        FROM Opportunity
                                       WHERE Id IN: recordIds];
                    }
                    
                    if (!recordList.isEmpty()) {
                        for (Sobject l : recordList) {
                            try {
                              paymentsToVoid.add(recordToPaymentMap.get(l.Id));
                            } catch (Exception e) {}
                        }
                    }
                }
            }

            if (!paymentsToVoid.isEmpty()) {
                // call future class to void payments
                AutoVoidPayments.doVoid(paymentsToVoid);
            }

        }
    }
}