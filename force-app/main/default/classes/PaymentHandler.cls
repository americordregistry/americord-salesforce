public class PaymentHandler
{
    public static String submitPayment(PaymentInfo paymentInfo)
    {
        System.debug('Submit payment checkpoint 1');
        Boolean paymentProfileSelected = paymentInfo.paymentProfileId != null && paymentInfo.paymentProfileId  != '-1' && paymentInfo.paymentProfileId  != '-2';
        fw1__Payment__c payment = new fw1__Payment__c();
        payment.fw1__Payment_Processor__c = 'Authorize.Net';
        payment.fw1__API_Payment__c = true;
        payment.fw1__Payment_Method__c = paymentInfo.paymentMethod;
        payment.fw1__Type__c = 'Charge';
        payment.fw1__Payment_Date__c = System.Now();
        payment.fw1__Amount__c = paymentInfo.amount;
        payment.fw1__CVV2__c = paymentInfo.cvv;
        payment.fw1__Account__c = paymentInfo.accountId;
        payment.fw1__Contact__c = paymentInfo.contactId;
        payment.fw1__Invoice__c = paymentInfo.invoiceId;
        if(paymentProfileSelected)
        {
            System.debug('Submit payment checkpoint 2');
            fw1__PaymentProfile__c paymentProfile =
                [
                    SELECT
                            Id, fw1__CreditCardType__c, fw1__First_Name__c, fw1__Last_Name__c, fw1__CreditCardNumber__c,
                            fw1__ExpiryMonth__c, fw1__ExpiryYear__c, fw1__Billing_Street__c, fw1__Billing_City__c,
                            fw1__Billing_State__c, fw1__Billing_Zip__c, fw1__Billing_Country__c, fw1__Bank_ABA_Code__c, 
                            fw1__Bank_Account_Number__c, fw1__Name_On_Account__c, fw1__Profile_Type__c
                    FROM
                            fw1__PaymentProfile__c
                    WHERE
                            Id = :paymentInfo.paymentProfileId
                ];

            System.debug('paymentProfile.type = ' + paymentProfile.fw1__Profile_Type__c);
            if(paymentProfile.fw1__Profile_Type__c == 'Credit Card')
            {
                System.debug('Submit payment checkpoint 3');
                payment.fw1__Credit_Card_Type__c = paymentProfile.fw1__CreditCardType__c;
                payment.fw1__First_Name__c = paymentProfile.fw1__First_Name__c;
                payment.fw1__Last_Name__c = paymentProfile.fw1__Last_Name__c;
                payment.fw1__Billing_Street__c = paymentProfile.fw1__Billing_Street__c;
                payment.fw1__Billing_City__c = paymentProfile.fw1__Billing_City__c;
                payment.fw1__Billing_State__c = paymentProfile.fw1__Billing_State__c;
                payment.fw1__Billing_Zip__c = paymentProfile.fw1__Billing_Zip__c;
                payment.fw1__Billing_Country__c = paymentProfile.fw1__Billing_Country__c;
                payment.fw1__Credit_Card_Number__c = paymentProfile.fw1__CreditCardNumber__c;
            }
            else if(paymentProfile.fw1__Profile_Type__c == 'eCheck')
            {
                System.debug('Submit payment checkpoint 4');
                payment.fw1__Bank_Aba_Code__c = paymentProfile.fw1__Bank_ABA_Code__c;
                payment.fw1__Bank_Account_Number__c = paymentProfile.fw1__Bank_Account_Number__c;
                payment.fw1__Name_On_Account__c = paymentProfile.fw1__Name_On_Account__c;
                payment.fw1__Credit_Card_Number__c = ' ';
                payment.fw1__Is_Business_Checking__c = false;
                payment.fw1__ECheck_Type__c = 'WEB';
            }
            
            payment.fw1__Expiry_Month__c = paymentProfile.fw1__ExpiryMonth__c;
            payment.fw1__Expiry_Year__c = paymentProfile.fw1__ExpiryYear__c;

        }
        else if (paymentInfo.tempPaymentProfile != null)
        {
            System.debug('Submit payment checkpoint 5');
            if(paymentInfo.paymentMethod == 'Credit Card')
            {
                System.debug('Submit payment checkpoint 6');
                payment.fw1__First_Name__c = paymentInfo.tempPaymentProfile.firstName;
                payment.fw1__Last_Name__c = paymentInfo.tempPaymentProfile.lastName;
                payment.fw1__Credit_Card_Number__c = paymentInfo.tempPaymentProfile.creditCardNumber;
                payment.fw1__Expiry_Month__c = paymentInfo.tempPaymentProfile.expiryMonth;
                payment.fw1__Expiry_Year__c = paymentInfo.tempPaymentProfile.expiryYear;
                payment.fw1__Billing_Street__c = paymentInfo.tempPaymentProfile.BillingStreet;
                payment.fw1__Billing_City__c = paymentInfo.tempPaymentProfile.BillingCity;
                payment.fw1__Billing_State__c = paymentInfo.tempPaymentProfile.BillingState;
                payment.fw1__Billing_Zip__c = paymentInfo.tempPaymentProfile.BillingZip;
                payment.fw1__Billing_Country__c = paymentInfo.tempPaymentProfile.BillingCountry;                
            }
            else if(paymentInfo.paymentMethod == 'eCheck')
            {
                System.debug('Submit payment checkpoint 7');
                payment.fw1__Bank_Aba_Code__c = paymentInfo.tempPaymentProfile.routingNumber;
                payment.fw1__Bank_Account_Number__c = paymentInfo.tempPaymentProfile.accountNumber;
                payment.fw1__Name_On_Account__c = paymentInfo.tempPaymentProfile.nameOnAccount;
                payment.fw1__Credit_Card_Number__c = ' ';
                payment.fw1__Expiry_Month__c = '00';
                payment.fw1__Expiry_Year__c = '0000';
                payment.fw1__Is_Business_Checking__c = false;
                payment.fw1__ECheck_Type__c = 'WEB';
            }
        }
        else
        {
            System.debug('No paymentProfileId or tempPaymentProfile');
        }

        fw1__Invoice__c invoice =
            [
                SELECT
                        Name
                FROM
                        fw1__Invoice__c
                WHERE
                        Id = :paymentInfo.invoiceId
            ];

        payment.Name = 'Payment for ' + invoice.Name;

        RestResponse restResponse = RestContext.response;
        Boolean isSuccessful = null;
        
        System.debug('Submit payment checkpoint 8');
        if(!Test.isRunningTest())
        {        
            System.debug('Submit payment checkpoint 9');

            fw1.ProcessorResponseModel response = null;
            
            try
            {            
                response = new fw1.ProcessorResponseModel();
                response.IsSuccessful = fw1.PaymentProcessor.doPayment(payment);
                response.ReferenceId = payment.Id;
                response.Message = payment.fw1__Payment_Result__c;
                response.ErrorType = payment.fw1__Error_Type__c;
                response.ErrorCode = payment.fw1__Error_Code__c;            
            }            
            catch (Exception e)
            {
                system.debug('doPayment failure: ' + e.getMessage());
                throw e;
                // unknownError = true;
                // response.IsSuccessful = false;
                // payment.fw1__Payment_Result__c = exception.getMessage();
            }

            System.debug('Submit payment checkpoint 10');

            System.debug('payment.Id ' + payment.Id);
            System.debug('payment.fw1__Payment_Result__c ' + payment.fw1__Payment_Result__c);
            System.debug('payment.fw1__Error_Type__c ' + payment.fw1__Error_Type__c);
            System.debug('payment.fw1__Error_Code__c ' + payment.fw1__Error_Code__c);
                
            System.debug('Value paymentInfo.invoiceId: ' + paymentInfo.invoiceId);
            System.debug('Value paymentInfo.amount: ' + paymentInfo.amount);
            System.debug('Value payment.Id: ' + payment.Id);
                
            if(response.IsSuccessful)
            {
                isSuccessful = true;
                restResponse.statusCode = 200;
            }
            else
            {
                System.debug('Payment Failure Reason: ' + payment.fw1__Payment_Result__c);
                isSuccessful = false;
                
                restResponse.statusCode = 500;
                restResponse.addHeader('X-AMERICORD-MESSAGE', payment.fw1__Payment_Result__c);
            }    
        }
        else
        {
            System.debug('Submit payment checkpoint 10.9');
            isSuccessful = true;
            payment.Id = 'a1a000000000000';
            System.debug('Submit payment checkpoint 11');
        }

        try 
        {
            if (isSuccessful)
            {
                System.debug('Submit payment checkpoint 12');
                if(!Test.isRunningTest())
                {
                    //fw1.PaymentPlan.updatePaidInstallments(paymentInfo.invoiceId, paymentInfo.amount, payment.Id, 0);
                    System.debug('Submit payment checkpoint 13');
                }
    
                if(paymentInfo.rememberMyCard && !paymentProfileSelected)
                {
                    System.debug('Submit payment checkpoint 14');

                    fw1__PaymentProfile__c paymentProfileToUpdate = new fw1__PaymentProfile__c();
                    paymentProfileToUpdate.fw1__Account__c = payment.fw1__Account__c;
                    paymentProfileToUpdate.fw1__Contact__c = payment.fw1__Contact__c;
                    paymentProfileToUpdate.fw1__CreditCardNumber__c = payment.fw1__Credit_Card_Number__c;
                    paymentProfileToUpdate.fw1__ExpiryMonth__c = payment.fw1__Expiry_Month__c;
                    paymentProfileToUpdate.fw1__ExpiryYear__c = payment.fw1__Expiry_Year__c;
                    
                    if(paymentInfo.paymentMethod == 'Credit Card')
                    {
                        System.debug('Submit payment checkpoint 15');
                        paymentProfileToUpdate.name = payment.fw1__Credit_Card_Type__c + '-' + payment.fw1__First_Name__c + '-' + payment.fw1__Last_Name__c + '-' +
                        payment.fw1__Credit_Card_Number__c.substring(payment.fw1__Credit_Card_Number__c.length()-4, payment.fw1__Credit_Card_Number__c.length());
                        
                        paymentProfileToUpdate.fw1__CreditCardType__c = payment.fw1__Credit_Card_Type__c;
                        paymentProfileToUpdate.fw1__First_Name__c = payment.fw1__First_Name__c;
                        paymentProfileToUpdate.fw1__Last_Name__c = payment.fw1__Last_Name__c;
                        paymentProfileToUpdate.fw1__Billing_Street__c = payment.fw1__Billing_Street__c;
                        paymentProfileToUpdate.fw1__Billing_City__c = payment.fw1__Billing_City__c;
                        paymentProfileToUpdate.fw1__Billing_State__c = payment.fw1__Billing_State__c;
                        paymentProfileToUpdate.fw1__Billing_Zip__c = payment.fw1__Billing_Zip__c;
                        paymentProfileToUpdate.fw1__Billing_Country__c = payment.fw1__Billing_Country__c;          
                    }
                    else if(paymentInfo.paymentMethod == 'eCheck')
                    {
                        System.debug('Submit payment checkpoint 16');
                        paymentProfileToUpdate.Name = 'eCheck-' + payment.fw1__Name_On_Account__c + '-' + payment.fw1__Bank_Account_Number__c.substring(payment.fw1__Bank_Account_Number__c.length()-4, payment.fw1__Bank_Account_Number__c.length());
                        paymentProfileToUpdate.fw1__Bank_ABA_Code__c = payment.fw1__Bank_Aba_Code__c;
                        paymentProfileToUpdate.fw1__Bank_Account_Number__c = payment.fw1__Bank_Account_Number__c;
                        paymentProfileToUpdate.fw1__Name_On_Account__c = payment.fw1__Name_On_Account__c;
                    }
                             
                    System.debug('Submit payment checkpoint 17');
    
                    insert paymentProfileToUpdate;
                    System.debug('Submit payment checkpoint 18');
                }
            }
    
            Portal_Activity__c portalActivity = new Portal_Activity__c();
            portalActivity.Date__c = System.now();
            portalActivity.Portal_User__c = paymentInfo.contactId;
            portalActivity.Payment__c = payment.Id;
            portalActivity.Activity__c = 'Made a Payment';
            if(!Test.isRunningTest())
            {
                insert portalActivity;
            }
            System.debug('Submit payment checkpoint 19');
        } 
        catch(Exception e) 
        {
            system.debug('post payment process failure: ' + e.getMessage());
            throw e;
        }

        System.debug('Process Submit Payment End');
        System.debug('Payment id = ' + payment.Id);
        
        return payment.Id;
    }

    public static String submitCreditMemo(PaymentInfo paymentInfo)
    {
        Boolean isSuccessful = null;

        fw1__Invoice__c invoice =
        [
            SELECT
                    Name
            FROM
                    fw1__Invoice__c
            WHERE
                    Id = :paymentInfo.invoiceId
        ];

        if(!Test.isRunningTest())
        {
            isSuccessful = fw1.Invoice.payInvoiceWithCredit(paymentInfo.invoiceId, paymentInfo.creditMemoId);
        }
        else
        {
            isSuccessful = true;
        }

        RestResponse restResponse = RestContext.response;

        if (isSuccessful)
        {
            if(!Test.isRunningTest())
            {
                restResponse.statusCode = 200;
            }
        }
        else
        {
            restResponse.statusCode = 500;
        }

        fw1__Payment__c payment =
        [
            SELECT
                    Id, Name
            FROM
                fw1__Payment__c
            WHERE
                fw1__Credit_Memo__c = :paymentInfo.creditMemoId
            AND
                fw1__Invoice__c = :paymentInfo.invoiceId
        ];

        Portal_Activity__c portalActivity = new Portal_Activity__c();
        portalActivity.Date__c = System.now();
        portalActivity.Portal_User__c = paymentInfo.contactId;
        portalActivity.Payment__c = payment.Id;
        portalActivity.Activity__c = 'Made a Payment';
        insert portalActivity;

        System.debug('Process Submit Payment End');

        return payment.Id;
    }
}