// Order Calculator Controller - for Ameriflex Slider Calculator
// 11/17/2021 Melissa Hansen -- melissa@thehifi.group
//Provides a structure for the SliderPricing logic used by Ameriflex Internally and from the new website purchase option

global with sharing class SliderPricing {

    global Decimal version;
    global String storageTerm;
    global Decimal rate;
    global Decimal downpaymentFloor;
    global Decimal downpaymentDefault;
    global Decimal downpaymentMax;
    global Decimal upfrontFee =199.0;
    global Integer discount20yrMax;
    global Integer discountLifetimeMax;
    global Integer totalPaymentsDefault;
    global Map < Integer, Map < Decimal, Decimal > > paymentMap;


    global SliderPricing() {

    }

}