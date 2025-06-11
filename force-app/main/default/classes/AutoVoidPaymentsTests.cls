@isTest
public with sharing class AutoVoidPaymentsTests {

    @TestSetup
    static void testSetup(){ 
        Account acct = new Account();
        acct.name ='TestAcct';
        insert acct;
        
    }    

    static testMethod void testDoVoid() {
        // create a lead
        Lead l = new Lead();
        l.FirstName = 'test';
        l.LastName = 'test';
        l.Status = 'Open';
        insert l;
        
        // create settings
        fw1__Payment_Center_Setting__c s = new fw1__Payment_Center_Setting__c();
        s.Name = 'Default Settings';
        insert s;
        
        fw1.PackagedData.restoreStripeData();
        
        // create a payment
        fw1__Payment__c p = new fw1__Payment__c();
        p.Name = 'test payment';
        p.fw1__Payment_Processor__c = 'Stripe';
        p.fw1__Payment_Date__c = system.now();
        p.fw1__Status__c = 'Authorized';
        p.fw1__Type__c = 'Authorization';
        p.fw1__Payment_Method__c = 'Credit Card';
        p.Lead__c = l.Id;
        insert p;
    }

    static testMethod void testDoVoid_Opp() {
        // get test acct
        Account acct = [SELECT Id FROM ACCOUNT LIMIT 1];

        // create opp
        Opportunity opp = new Opportunity(
            Name = 'TestOpp',
            AccountId=acct.id,
            Stagename = 'New',
            CloseDate = System.today()
            );
        insert opp;
        
        // create settings
        fw1__Payment_Center_Setting__c s = new fw1__Payment_Center_Setting__c();
        s.Name = 'Default Settings';
        insert s;
        
        fw1.PackagedData.restoreStripeData();
        
        // create a payment
        fw1__Payment__c p = new fw1__Payment__c();
        p.Name = 'test payment';
        p.fw1__Payment_Processor__c = 'Stripe';
        p.fw1__Payment_Date__c = system.now();
        p.fw1__Status__c = 'Authorized';
        p.fw1__Type__c = 'Authorization';
        p.fw1__Payment_Method__c = 'Credit Card';
        p.fw1__Opportunity__c = opp.Id;
        insert p;
    }

    static testMethod void testDoVoid_NewCardRef() {
        // create a lead
        Lead l = new Lead();
        l.FirstName = 'test';
        l.LastName = 'test';
        l.Status = 'Open';
        insert l;
        
        // create settings
        fw1__Payment_Center_Setting__c s = new fw1__Payment_Center_Setting__c();
        s.Name = 'Default Settings';
        insert s;
        
        fw1.PackagedData.restoreStripeData();
        
        // create a payment
        fw1__Payment__c p = new fw1__Payment__c();
        p.Name = 'test payment';
        p.fw1__Reference__c = 'New Credit Card';
        p.fw1__Payment_Processor__c = 'Stripe';
        p.fw1__Payment_Date__c = system.now();
        p.fw1__Status__c = 'Not Authorized';
        p.fw1__Type__c = 'Authorization';
        p.fw1__Payment_Method__c = 'Credit Card';
        p.Lead__c = l.Id;
        insert p;
    }
    
    static testMethod void testInvoiceHelper() {
        InvoiceHelper ih = new InvoiceHelper();
    }
}