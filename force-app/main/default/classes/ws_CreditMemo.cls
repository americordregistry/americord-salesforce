@RestResource(urlMapping='/CreditMemo/*')
global with sharing class ws_CreditMemo
{
    @HttpPost
    global static String submitPayment(PaymentInfo paymentInfo)
    {
        String paymentId = null;
        try
        {
            paymentId = PaymentHandler.submitCreditMemo(paymentInfo); 
        }
        catch (Exception exception1)
        {
            system.debug('value ' + exception1.getMessage());
        }
        return paymentId;
    }
}