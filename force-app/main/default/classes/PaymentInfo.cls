global class PaymentInfo
{
    global String accountId;
    global String paymentMethod;
    global String contactId;
    global String invoiceId;
    global String creditMemoId;
    global String paymentProfileId;
    global TempPaymentProfile tempPaymentProfile;
    global String cvv;
    global Double amount;
    global Boolean rememberMyCard;

    public PaymentInfo() {}

    public PaymentInfo(String iAccountId, String iPaymentMethod, String iContactId, String iInvoiceId, String iPaymentProfileId, TempPaymentProfile iTempPaymentProfile, String iCvv, Double iAmount, Boolean iRememberMyCard, String iCreditMemoId)
    {
        accountId = iAccountId;
        paymentMethod = iPaymentMethod;
        contactId = iContactId;
        invoiceId = iInvoiceId;
        paymentProfileId = iPaymentProfileId;
        tempPaymentProfile = iTempPaymentProfile;
        cvv = iCvv;
        amount = iAmount;
        rememberMyCard = iRememberMyCard;
        creditMemoId = iCreditMemoId;
    }
}