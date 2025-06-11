global class TempPaymentProfile
{

    global String creditCardType;
    global String firstName;
    global String lastName;
    global String creditCardNumber;
    global String expiryMonth;
    global String expiryYear;
    global String billingStreet;
    global String billingCity;
    global String billingState;
    global String billingZip;
    global String billingCountry;
    global String nameOnAccount;
    global String routingNumber;
    global String accountNumber;

    public TempPaymentProfile() {}

    public TempPaymentProfile(String iCreditCardType, String iFirstName, String iLastName, String iCreditCardNumber, String iExpiryMonth, String iExpiryYear,
                              String iBillingStreet, String iBillingCity, String iBillingState, String iBillingZip, String iBillingCountry, String iNameOnAccount, 
                              String iRoutingNumber, String iAccountNumber)
    {
        creditCardType = iCreditCardType;
        firstName = iFirstName;
        lastName = iLastName;
        creditCardNumber = iCreditCardNumber;
        expiryMonth = iExpiryMonth;
        expiryYear =iExpiryYear;
        billingStreet = iBillingStreet;
        billingCity = iBillingCity;
        billingState = iBillingState;
        billingZip = iBillingZip;
        billingCountry = iBillingCountry;
        nameOnAccount = iNameOnAccount;
        routingNumber = iRoutingNumber;
        accountNumber = iAccountNumber;
    }
}