import { LightningElement, wire } from 'lwc';

// Utilities
import {
    runCalculator, 
    subscribeToMessageChannel,
    unsubscribeFromMessageChannel
} from 'c/orderCalculatorUtilities';

// Messaging
import {
    MessageContext
} from 'lightning/messageService';

export default class OrderCalculatorDisplayAnnualStorage extends LightningElement {

    // form control
    showComponent = false;

    // outputs
    totalAmount = 0;
    totalAmount20Years = 0;

    // messaging
    subscription = null;
    @wire ( MessageContext )
    messageContext;
    
    // init
    connectedCallback () {
        this.subscription = subscribeToMessageChannel ( this.messageContext, this.subscription, this.handleMessage, this );
        this.showComponent = true;
    }

    disconnectedCallback () {
        this.subscription = unsubscribeFromMessageChannel ( this.subscription );
    }

    async handleMessage ( message, context ) {
        console.log ( 'OrderCalculatorDisplayAnnualStorage message', message );
        // check the action
        if ( message.action === 'calculate-display' ) {
            try {
                 // override the payment plan
                const inputArray = {...message.inputArray, storagePlan : 'ASP', paymentPlan : 'AF', salesDiscount : 0.0 };
                // run calculate
                const outputObject = await runCalculator ( inputArray );
                // set form values
                context.totalAmount = outputObject.priceBeforeSalesDiscount;
                // look for the ASP Product in list
                let annualStorageFee = 0.0;
                outputObject.lineItems.forEach ( function ( lineItem ) {
                    if ( lineItem.productCode === 'ASP' ) {
                        annualStorageFee = lineItem.lineItemSubTotal;
                    }
                })
                context.totalAmount20Years = ( annualStorageFee * 19 ) + outputObject.priceBeforeSalesDiscount;
            } catch ( e ) {
                console.log ( 'error --- ' + e );
                context.clearValues ();
            }
           
        }
    }

    clearValues () {
        this.totalAmount = 0;
        this.totalAmount20Years = 0;
    }

}