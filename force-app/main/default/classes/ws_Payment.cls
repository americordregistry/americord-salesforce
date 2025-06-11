@RestResource(urlMapping='/Payment/*')
global with sharing class ws_Payment
{
    @HttpPost
    global static String submitPayment(PaymentInfo paymentInfo)
    {
        String paymentId = null;
        try
        {
            paymentId = PaymentHandler.submitPayment(paymentInfo);
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
        }
        catch (Exception e)
        {
            system.debug('value ' + e.getMessage());
            RestResponse restResponse = RestContext.response;
            restResponse.statusCode = 503;
        }
        
        return paymentId;
    }
}