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

export default class OrderCalculatorDisplayHybrid extends LightningElement {

    // form control
    showComponent = false;

    // outputs
    price12 = 0;
    firstPayment12 = 0;
    monthlyPayment12 = 0;
    totalFees12 = 0;    
    price18 = 0;
    firstPayment18 = 0;
    monthlyPayment18 = 0;
    totalFees18 = 0;

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
        console.log ( 'OrderCalculatorDisplayHybrid message', message );
        // check the action
        if ( message.action === 'calculate-display' ) {
            if (( message.inputArray.storagePlan === 'ASP' ) && ( message.inputArray.paymentPlan === 'AF' )) {
                // exit, don't run
                console.log ( 'skipping Hybrid due to Annual payment and storage plans' );
                context.clearValues ();
                return;
            }
            try {
                context.clearValues ();
                if ( message.inputArray.paymentPlan === 'HY18' ) {
                    // override the payment plan                
                    const inputArray18 = {...message.inputArray, paymentPlan : 'HY18', salesDiscount : 0.0  };
                    // run calculate
                    const [ outputObject18 ] = await Promise.all ([ 
                                                                    runCalculator ( inputArray18 )
                                                                ]);
                    // set form values
                    context.price18 = outputObject18.priceBeforeSalesDiscount;
                    context.firstPayment18 = outputObject18.hybridFirstPayment;
                    context.monthlyPayment18 = outputObject18.monthlyPaymentRounded;
                    context.totalFees18 = outputObject18.totalMonthlyFees;
                }
                if ( message.inputArray.paymentPlan === 'HY12' ) {
                    // override the payment plan                
                    const inputArray12 = {...message.inputArray, paymentPlan : 'HY12', salesDiscount : 0.0  };
                    // run calculate
                    const [ outputObject12 ] = await Promise.all ([ 
                                                                    runCalculator ( inputArray12 )
                                                                ]);
                    // set form values
                    context.price12 = outputObject12.priceBeforeSalesDiscount;
                    context.firstPayment12 = outputObject12.hybridFirstPayment;
                    context.monthlyPayment12 = outputObject12.monthlyPaymentRounded;
                    context.totalFees12 = outputObject12.totalMonthlyFees;
                }


            } catch ( e ) {
                console.log ( 'error --- ', e );
                context.clearValues ();
            }
        }
    }

    clearValues () {
        this.price12 = 0;
        this.firstPayment12 = 0;
        this.monthlyPayment12 = 0;
        this.totalFees12 = 0;        
        this.price18 = 0;
        this.firstPayment18 = 0;
        this.monthlyPayment18 = 0;
        this.totalFees18 = 0;
    }

}