global with sharing class AutoVoidPayments {

    @future (callout=true)
    public static void doVoid(Set<Id> paymentIds) {
        for (Id pId : paymentIds) {
            fw1.ProcessorResponseModel res = new fw1.ProcessorResponseModel();
            res = fw1.PaymentProcessor.doVoidPayment(pId, '', false);
        }
    }
/*
    @future (callout=true)
    public static void linkInvoicePaymentProfile(Set<Id> paymentIds) {
        
        Set<String> userEmail = new Set<String>();
        Map<String, List<fw1__Payment__c>> newCreditcardsPayment = new Map<String, List<fw1__Payment__c>>();
        for (fw1__Payment__c p : [SELECT fw1__Invoice__c, fw1__Email__c, fw1__Credit_Card_Number__c, fw1__First_Name__c, fw1__Last_Name__c, fw1__Credit_Card_Type__c, fw1__Expiry_Month__c, fw1__Expiry_Year__c
                                    FROM fw1__Payment__c
                                   WHERE Id IN: paymentIds]) {
            if(!newCreditcardsPayment.containsKey(p.fw1__Email__c)){
                newCreditcardsPayment.put(p.fw1__Email__c, new List<fw1__Payment__c>());
            }
            newCreditcardsPayment.get(p.fw1__Email__c).add(p);
            userEmail.add(p.fw1__Email__c);
        }
        
        System.debug('userEmail :: ' + userEmail);
        System.debug('newCreditcardsPayment :: ' + newCreditcardsPayment);

        List<fw1__Invoice__c> invoiceList = new List<fw1__Invoice__c>();


        System.debug('paymentProfile :: ' + JSON.serialize([SELECT fw1__Email__c, fw1__CreditCardNumber__c, fw1__First_Name__c, fw1__Last_Name__c, fw1__CreditCardType__c, fw1__ExpiryMonth__c, fw1__ExpiryYear__c, CreatedDate
                                                  FROM fw1__PaymentProfile__c
                                                  WHERE fw1__Email__c IN: newCreditcardsPayment.KeySet()]));
        for(fw1__PaymentProfile__c pp: [SELECT fw1__Email__c, fw1__CreditCardNumber__c, fw1__First_Name__c, fw1__Last_Name__c, fw1__CreditCardType__c, fw1__ExpiryMonth__c, fw1__ExpiryYear__c, CreatedDate
                                                  FROM fw1__PaymentProfile__c
                                                  WHERE fw1__Email__c IN: newCreditcardsPayment.KeySet()
                                                    AND CreatedDate = TODAY
                                               ORDER BY CreatedDate DESC]){
            System.debug('pp :: ' + pp);
            for(fw1__Payment__c p: newCreditcardsPayment.get(pp.fw1__Email__c)){
                if(pp.fw1__CreditCardNumber__c == p.fw1__Credit_Card_Number__c &&
                    pp.fw1__First_Name__c == p.fw1__First_Name__c &&
                    pp.fw1__Last_Name__c == p.fw1__Last_Name__c &&
                    pp.fw1__CreditCardType__c == p.fw1__Credit_Card_Type__c &&
                    pp.fw1__ExpiryMonth__c == p.fw1__Expiry_Month__c &&
                    pp.fw1__ExpiryYear__c == p.fw1__Expiry_Year__c){
                    invoiceList.add(new fw1__Invoice__c(id = p.fw1__Invoice__c, fw1__Payment_Profile__c = pp.id));
                }
            }
        }
        System.debug('invoiceList :: ' + invoiceList);
        Database.Update(invoiceList, false);

    }
*/
}