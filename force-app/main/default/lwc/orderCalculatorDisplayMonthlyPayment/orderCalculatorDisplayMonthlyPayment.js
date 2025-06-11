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

export default class OrderCalculatorDisplayMonthlyPayment extends LightningElement {

    // form control
    showComponent = false;

    // outputs
    price12 = 0;
    monthlyPayment12 = 0;
    totalFees12 = 0;
    price24 = 0;
    monthlyPayment24 = 0;
    totalFees24 = 0;
    price36 = 0;
    monthlyPayment36 = 0;
    totalFees36 = 0;
    price48 = 0;
    monthlyPayment48 = 0;
    totalFees48 = 0;

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
        console.log ( 'OrderCalculatorDisplayMonthlyPayment message', message );
        // check the action
        if ( message.action === 'calculate-display' ) {
            if (( message.inputArray.storagePlan === 'ASP' ) && ( message.inputArray.paymentPlan === 'AF' )) {
                // exit, don't run
                console.log ( 'skipping MonthlyPayment due to Annual payment and storage plans' );
                context.clearValues ();
                return;
            }
            try {
                // override the payment plan
                const inputArray12 = {...message.inputArray, paymentPlan : '12M', salesDiscount : 0.0  };
                const inputArray24 = {...message.inputArray, paymentPlan : '24M', salesDiscount : 0.0  };
                const inputArray36 = {...message.inputArray, paymentPlan : '36M', salesDiscount : 0.0  };
                const inputArray48 = {...message.inputArray, paymentPlan : '48M', salesDiscount : 0.0  };
                // run calculate
                const [ outputObject12, outputObject24, outputObject36, outputObject48 ] = await Promise.all ([ 
                                                                                        runCalculator ( inputArray12 ),
                                                                                        runCalculator ( inputArray24 ),
                                                                                        runCalculator ( inputArray36 ),
                                                                                        runCalculator ( inputArray48 )
                                                                                    ]);
                // set form values
                context.price12 = outputObject12.priceBeforeSalesDiscount;
                context.monthlyPayment12 = outputObject12.monthlyPaymentRounded;                
                context.price24 = outputObject24.priceBeforeSalesDiscount;
                context.monthlyPayment24 = outputObject24.monthlyPaymentRounded;
                context.totalFees24 = outputObject24.totalMonthlyFees;
                context.price36 = outputObject36.priceBeforeSalesDiscount;
                context.monthlyPayment36 = outputObject36.monthlyPaymentRounded;
                context.totalFees36 = outputObject36.totalMonthlyFees;
                context.price48 = outputObject48.priceBeforeSalesDiscount;
                context.monthlyPayment48 = outputObject48.monthlyPaymentRounded;
                context.totalFees48 = outputObject48.totalMonthlyFees;
            } catch ( e ) {
                console.log ( 'error --- ', e );
                context.clearValues ();
            }
        }
    }

    clearValues () {
        this.price12 = 0;
        this.monthlyPayment12 = 0;        
        this.price24 = 0;
        this.monthlyPayment24 = 0;
        this.totalFees24 = 0;
        this.price36 = 0;
        this.monthlyPayment36 = 0;
        this.totalFees36 = 0;
        this.price48 = 0;
        this.monthlyPayment48 = 0;
        this.totalFees48 = 0;
    }

}