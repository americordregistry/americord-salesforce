createInputStructure// general interface utilities for Order Calculator LWC
import calculate from '@salesforce/apex/OrderCalculatorController.calculate';
import fetchInputFromRecord from '@salesforce/apex/OrderCalculatorController.fetchInputFromRecord';
import writeToRecord from '@salesforce/apex/OrderCalculatorController.writeToRecord';
import checkInputValidity from '@salesforce/apex/OrderCalculatorController.isInputValid';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    subscribe,
    unsubscribe,
    publish,
    APPLICATION_SCOPE
} from 'lightning/messageService';
import orderCalculatorMessageChannel from '@salesforce/messageChannel/OrderCalculatorMessageChannel__c';

function createInputStructure () {
    let inputJson = {
        birthCount : null,
        cordBlood2Quantity : 0,
        cordTissueQuantity : 0,
        placenta2Quantity : 0,
        exosomesQuantity : 0,
        momPremiumGenomicsQuantity : 0,
        momStandardGenomicsQuantity : 0,
        newbornGenomeQuantity: 0,
        newbornPanelQuantity: 0,
        maternalExosomesQuantity: 0,
        priceBookId : null,
        paymentPlan : null,
        storagePlan : null,
        salesDiscount : null,
        discountCode : null,
        depositAmount : null,
        genomicsUpfront: null,
        shippingType : null,
        dataSource : null,
        orderType : null,
        recordId : null,
        billingNotes : null
    };
    return inputJson;
}

async function runCalculator ( inputArray ) {
    let inputObject = createInputStructure ();
    let outputObject = {};

    inputObject.birthCount = inputArray [ "birthCount" ];
    inputObject.cordBlood2Quantity = inputArray [ "cordBlood2Quantity" ];
    inputObject.cordTissueQuantity = inputArray [ "cordTissueQuantity" ];
    inputObject.placenta2Quantity = inputArray [ "placenta2Quantity" ];
    inputObject.exosomesQuantity = inputArray [ "exosomesQuantity" ];
    inputObject.momPremiumGenomicsQuantity = inputArray [ "momPremiumGenomicsQuantity" ];
    inputObject.momStandardGenomicsQuantity = inputArray [ "momStandardGenomicsQuantity" ];
    inputObject.newbornGenomeQuantity = inputArray [ "newbornGenomeQuantity" ];
    inputObject.newbornPanelQuantity = inputArray [ "newbornPanelQuantity" ];
    inputObject.maternalExosomesQuantity = inputArray [ "maternalExosomesQuantity" ];
    inputObject.priceBookId = inputArray [ "priceBookId" ];
    inputObject.paymentPlan = inputArray [ "paymentPlan" ];
    inputObject.shippingType = inputArray [ "shippingType" ];
    inputObject.storagePlan = inputArray [ "storagePlan" ];
    inputObject.discountCode = inputArray [ "discountCode" ];
    inputObject.salesDiscount = inputArray [ "salesDiscount" ];
    inputObject.depositAmount = inputArray [ "depositAmount" ];
    inputObject.genomicsUpfront = inputArray [ "genomicsUpfront" ];
    inputObject.billingNotes = inputArray [ "billingNotes" ];
    inputObject.hasRushShipping = inputArray ["hasRushShipping"];   

    const outputString = await calculate ({ inputJson : JSON.stringify ( inputObject ) });
    outputObject = JSON.parse ( outputString );

    // set form values
    return outputObject;
}

async function fetchCurrentValues ( recordId, forceOrderEnrolled ) {
    let returnArray = [];

    try {
        const inputString = await fetchInputFromRecord ({ recordId : recordId,
                                                            forceOrderEnrolled : forceOrderEnrolled 
                                                        });
        returnArray.push ( JSON.parse ( inputString ));
        // validate input
        const inputValid = await checkInputValidity ({ inputString : inputString });
        if ( inputValid ) {
            const outputString = await calculate ({ inputJson : inputString });
            returnArray.push ( JSON.parse ( outputString ));
        } else {
            returnArray.push ( null );
        }
    } catch ( e ) {
        handleError ( e );
    }

    return returnArray;
}

async function writeSelectedValues ( input, output ) {
    console.log ( 'writeToRecord', input, output );
        await writeToRecord ({  inputJson : JSON.stringify ( input ),
                                outputJson : JSON.stringify ( output )
                            });
        updateRecord({ fields: { Id: input.recordId } });
        handleMessage ( 'New Selection Successful', 'Your updated selection has been saved', 'success' );
}

async function isInputValid ( input ) {
    return await checkInputValidity ({ inputString : JSON.stringify ( input )});
}

// error handler
function handleError ( error ) {
    console.log('--error--');
    console.log(error);
    let errorObj = JSON.parse(error.body.message);
    dispatchEvent(
    new ShowToastEvent({
        title: errorObj.title,
        message: errorObj.message,
        variant: errorObj.variant,
        mode: errorObj.mode
    })
    );
}

// error handler
function handleMessage ( title, message, variant ) {
    console.log ( 'handleMessage', title, message, variant );
    dispatchEvent(
    new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: 'dismissable'
    })
    );
}

// option factories
function numberOfBabiesPicklistFactory () {
    let numberOfBabiesOptions = [];
    numberOfBabiesOptions.push ({
        label: "Single",
        value: "1"
    });
    numberOfBabiesOptions.push ({
        label: "Twins",
        value: "2"
    });
    numberOfBabiesOptions.push ({
        label: "Triplets",
        value: "3"
    });
    return numberOfBabiesOptions;
}

function storageOptionsPicklistFactory () {
    let storageOptions = [];
    storageOptions.push ({
        label: "Annual",
        value: "ASP"
    });    
    storageOptions.push ({
        label: "20 YPP",
        value: "20YPP"
    });
    storageOptions.push ({
        label: "Lifetime",
        value: "LTS"
    });
    storageOptions.push ({
        label: "No Storage",
        value: "None"
    });      
    return storageOptions;
}

function shippingOptionsPicklistFactory () {
    let shippingOptions = [];
    shippingOptions.push ({
        label: "Standard",
        value: "Standard"
    });
    shippingOptions.push ({
        label: "Rush",
        value: "Rush"
    });
    shippingOptions.push ({
        label: "No Shipping",
        value: "None"
    });      
    return shippingOptions;
}

function paymentOptionsPicklistFactory () {
    let paymentOptions = [];
    paymentOptions.push ({
        label: "One-time",
        value: "OTP"
    });
    paymentOptions.push ({
        label: "Annual Fee",
        value: "AF"
    });      
    paymentOptions.push ({
        label: "HY-12",
        value: "HY12"
    });    
    paymentOptions.push ({
        label: "HY-18",
        value: "HY18"
    });
    paymentOptions.push ({
        label: "12 M",
        value: "12M"
    });
    paymentOptions.push ({
        label: "24 M",
        value: "24M"
    });
    paymentOptions.push ({
        label: "36 M",
        value: "36M"
    });
    paymentOptions.push ({
        label: "48 M",
        value: "48M"
    });
    return paymentOptions;
}

function subscribeToMessageChannel ( messageContext, subscription, handleMethod, context ) {
    if ( !subscription ) {
        this.subscription = subscribe (
            messageContext,
            orderCalculatorMessageChannel,
            (message) => handleMethod ( message, context ),
            { scope: APPLICATION_SCOPE }
        );
    }
    return subscription;
}

function unsubscribeFromMessageChannel ( subscription ) {
    unsubscribe ( subscription );
    return subscription;
}

function publishCalculateRequest ( messageContext, inputArray, autoSave ) {
    console.log ( 'publishcalculate', messageContext, inputArray, autoSave );
    const payload = { 
        inputArray : inputArray,
        autoSave : autoSave,
        action : "calculate"
    };
    console.log ( 'publishcalculate-payload', payload );
    publish ( messageContext, orderCalculatorMessageChannel, payload );
}

function publishCalculateDisplayRequest ( messageContext, inputArray ) {
    console.log ( 'publishcalculate-display', messageContext, inputArray );
    const payload = { 
        inputArray : inputArray,
        action : "calculate-display"
    };
    console.log ( 'publishcalculate-display-payload', payload );
    publish ( messageContext, orderCalculatorMessageChannel, payload );
}

function publishLoadSelection ( messageContext, inputArray ) {
    console.log ( 'publishLoadSelection', messageContext, inputArray );
    const payload = { 
        inputArray : inputArray,
        action : "load"
    };
    console.log ( 'publishLoadSelection-payload', payload );
    publish ( messageContext, orderCalculatorMessageChannel, payload );
}

function publishRefreshSelection ( messageContext, recordId ) {
    console.log ( 'publishRefreshSelection', messageContext, recordId );
    const payload = { 
        recordId : recordId,
        action : "selection-refresh",
        autoSave : false
    };
    console.log ( 'publishRefreshSelection-payload', payload );
    publish ( messageContext, orderCalculatorMessageChannel, payload );
}

function publishChangeBillingNotes ( messageContext, billingNotes ) {
    console.log ( 'publishChangeBillingNotes', messageContext, billingNotes );
    const payload = { 
        billingNotes : billingNotes,
        action : "change-billing-notes"
    };
    console.log ( 'publishChangeBillingNotes-payload', payload );
    publish ( messageContext, orderCalculatorMessageChannel, payload );
}

export {
    createInputStructure,
    runCalculator,
    fetchCurrentValues,
    writeSelectedValues,
    isInputValid,
    handleError,
    handleMessage,
    numberOfBabiesPicklistFactory,
    storageOptionsPicklistFactory,
    paymentOptionsPicklistFactory,
    shippingOptionsPicklistFactory,
    subscribeToMessageChannel,
    unsubscribeFromMessageChannel,
    publishCalculateRequest,
    publishCalculateDisplayRequest,
    publishLoadSelection,
    publishRefreshSelection,
    publishChangeBillingNotes
};