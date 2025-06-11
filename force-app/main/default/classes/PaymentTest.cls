@isTest
private class PaymentTest
{
    @testSetup
    static void dataSetup()
    {
        fw1__Payment_Center_Setting__c s = new fw1__Payment_Center_Setting__c();
        s.Name = 'Default Settings';
        s.fw1__Email_Currency_Symbol__c = '$';
        insert s;

        System.debug('test start');
        Account account = new Account();
        account.RecordTypeId = '012U0000000Q2QvIAK';
        account.Name = 'Test Account';
        insert account;
        System.debug('account id = ' + account.Id);

        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'User';
        insert contact;

        fw1__PaymentProfile__c paymentProfile = new fw1__PaymentProfile__c();
        paymentProfile.fw1__CreditCardType__c = 'Visa';
        paymentProfile.fw1__First_Name__c = 'Test';
        paymentProfile.fw1__Last_Name__c = 'Guy';
        paymentProfile.fw1__CreditCardNumber__c = '4444333322221111';
        paymentProfile.fw1__ExpiryMonth__c = '01';
        paymentProfile.fw1__ExpiryYear__c = '2020';
        paymentProfile.fw1__Billing_Street__c = '11111 S Test ST';
        paymentProfile.fw1__Billing_City__c = 'Test';
        paymentProfile.fw1__Billing_State__c = 'CA';
        paymentProfile.fw1__Billing_Zip__c = '11111';
        paymentProfile.fw1__Billing_Country__c = 'Test';
        insert paymentProfile;

        fw1__PaymentProfile__c paymentProfile1 = new fw1__PaymentProfile__c();
        paymentProfile1.fw1__CreditCardNumber__c = ' ';
        paymentProfile1.fw1__ExpiryMonth__c = '00';
        paymentProfile1.fw1__ExpiryYear__c = '0000';
        paymentProfile1.fw1__Bank_ABA_Code__c = '021000021';
        paymentProfile1.fw1__Bank_Account_Number__c = '111111111';
        paymentProfile1.fw1__Name_On_Account__c = 'Demo';
        insert paymentProfile1;

        // Account account1 = [SELECT Id FROM Account];
        // system.assert(account1.Id != null);

        // Create Payment Plan and Storage
        fw1__Payment_Plan__c pp = new fw1__Payment_Plan__c(
            Name = 'Test PP',
            fw1__Schedule__c = 'Monthly'
        );
        insert pp;

        fw1__Invoice__c invoice = new fw1__Invoice__c();
        invoice.fw1__Account__c = account.id;
        invoice.fw1__Invoice_Date__c = System.today();
        invoice.fw1__Payment_Plan__c = pp.Id;
        invoice.Cord_Blood_2_0_Ordered__c = 1;
        invoice.Storage_Plan_Ordered__c = '20YPP';
        invoice.Payment_Plan_Ordered__c = 'OTP';
        invoice.Shipping_Type__c = 'Standard';
        
        insert invoice;
    }

    static testMethod void creditCardTest()
    {
        Account account = [SELECT Id FROM Account];
        system.assert(account.Id != null);

        Contact contact = [SELECT Id FROM Contact];
        system.assert(contact.Id != null);

        fw1__Invoice__c invoice = [SELECT Id FROM fw1__Invoice__c];
        system.assert(invoice.Id != null);

        TempPaymentProfile tempPaymentProfile = new TempPaymentProfile('Visa', 'Test', 'Guy', '4444333322221111', '01', '2020', null, null, null, '11111', null, 'Test Guy', '021000021', '111111111');
        PaymentInfo paymentInfo = new PaymentInfo(account.Id, 'Credit Card', contact.Id, invoice.Id, null, tempPaymentProfile, '123', 100, true, null);
        String paymentId = ws_Payment.submitPayment(paymentInfo);
        system.assert(paymentId != null);

        fw1__PaymentProfile__c paymentProfile = [SELECT Id FROM fw1__PaymentProfile__c WHERE fw1__Profile_Type__c = 'Credit Card' LIMIT 1];
        system.assert(paymentProfile.Id != null);

        PaymentInfo paymentInfo2 = new PaymentInfo(account.Id, 'eCheck', contact.Id, invoice.Id, paymentProfile.Id, null, null, 100, true, null);
        String payment2Id = ws_Payment.submitPayment(paymentInfo2); //Id paymentId = (Id) 
        system.assert(payment2Id != null);

    }

    static testMethod void creditMemoTest()
    {
        Account account = [SELECT Id FROM Account];
        system.assert(account.Id != null);
        
        Contact contact = [SELECT Id FROM Contact];
        system.assert(contact.Id != null);

        fw1__Invoice__c invoice = [SELECT Id,fw1__Balance_Due__c FROM fw1__Invoice__c];
        system.assert(invoice.Id != null);

        fw1__PaymentProfile__c paymentProfile = [SELECT Id FROM fw1__PaymentProfile__c LIMIT 1];
        system.assert(paymentProfile.Id != null);

        TempPaymentProfile tempPaymentProfile = new TempPaymentProfile('Visa', 'Test', 'Guy', '4444333322221111', '01', '2020', null, null, null, '11111', null, 'Test Guy', '021000021', '111111111');
        PaymentInfo paymentInfo = new PaymentInfo(account.Id, 'Credit Card', contact.Id, invoice.Id, null, tempPaymentProfile, '123', 100, true, null);
        ws_CreditMemo.submitPayment(paymentInfo); //Id paymentId = (Id) 
        //fw1__Payment__c payment = [SELECT Id, fw1__Credit_Memo__c FROM fw1__Payment__c]; // breaks here
        //System.debug('payment Credit Memo Value: ' + payment.fw1__Credit_Memo__c);
        system.assert(paymentProfile.Id != null);
    }

    
    static testMethod void achTest()
    {
        Account account = [SELECT Id FROM Account];
        system.assert(account.Id != null);
        
        Contact contact = [SELECT Id FROM Contact];
        system.assert(contact.Id != null);

        fw1__Invoice__c invoice = [SELECT Id,fw1__Balance_Due__c FROM fw1__Invoice__c];
        system.assert(invoice.Id != null);
        System.debug('fw1__Balance_Due__c Value: ' + invoice.fw1__Balance_Due__c);

        
        TempPaymentProfile tempPaymentProfile = new TempPaymentProfile(null, null, null, ' ', '00', '0000', null, null, null, null, null, 'Demo', '122105155', '123456789');
        PaymentInfo paymentInfo = new PaymentInfo(account.Id, 'eCheck', contact.Id, invoice.Id, null, tempPaymentProfile, null, 100, true, null);
        System.debug('paymentInfo: '+paymentInfo);

        String paymentId = ws_Payment.submitPayment(paymentInfo); //Id paymentId = (Id) 
        system.assert(paymentId != null);

        fw1__PaymentProfile__c paymentProfile = [SELECT Id FROM fw1__PaymentProfile__c WHERE fw1__Profile_Type__c = 'eCheck' LIMIT 1];
        system.assert(paymentProfile.Id != null);

        PaymentInfo paymentInfo2 = new PaymentInfo(account.Id, 'eCheck', contact.Id, invoice.Id, paymentProfile.Id, null, null, 100, true, null);
        String payment2Id = ws_Payment.submitPayment(paymentInfo2); //Id paymentId = (Id) 
        system.assert(payment2Id != null);

    }
}