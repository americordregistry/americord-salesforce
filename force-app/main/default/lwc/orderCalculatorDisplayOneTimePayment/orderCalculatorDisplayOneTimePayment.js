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

export default class OrderCalculatorDisplayOneTimePayment extends LightningElement {

    // form control
    showComponent = false;

    // outputs
    totalAmount20YPP = 0;
    totalAmountLTS = 0;

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
        console.log ( 'OrderCalculatorDisplayOneTimePayment message', message );
        // check the action
        if ( message.action === 'calculate-display' ) {
            try {
                // override the payment plan
                const inputArray20YPP = {...message.inputArray, paymentPlan : 'OTP', storagePlan : '20YPP', salesDiscount : 0.0  };
                const inputArrayLTS = {...message.inputArray, paymentPlan : 'OTP', storagePlan : 'LTS', salesDiscount : 0.0  };
                // run calculate
                const [ outputObject20YPP, outputObjectLTS ] = await Promise.all ([ 
                                                                                    runCalculator ( inputArray20YPP ),
                                                                                    runCalculator ( inputArrayLTS )
                                                                                ]);
                // set form values
                context.totalAmount20YPP = outputObject20YPP.priceBeforeSalesDiscount;
                context.totalAmountLTS = outputObjectLTS.priceBeforeSalesDiscount;
            } catch ( e ) {
                console.log ( 'error ---', e );
                context.clearValues ();
            }
        }
    }

    clearValues () {
        this.totalAmount20YPP = 0;
        this.totalAmountLTS = 0;
    }

}