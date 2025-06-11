import { LightningElement, wire } from 'lwc';
import { subscribeToMessageChannel, publishChangeBillingNotes } from 'c/orderCalculatorUtilities';

// Messaging
import {
    MessageContext
} from 'lightning/messageService';

export default class OrderCalculatorBillingNotes extends LightningElement {

    inputs = [];
    billingNotes;

    // messaging
    subscription = null;
    @wire ( MessageContext )
    messageContext;

    connectedCallback () {
        this.subscription = subscribeToMessageChannel ( this.messageContext, this.subscription, this.handleMessage, this );
        this.inputs [ 'billingNotes' ] = '';
    }

    handleChange ( change ) {
        console.log ( 'billing notes change', change );
        if ( this.inputs [ change.target.name ] != change.target.value ) {
            // have a change
            this.inputs [ change.target.name ] = change.target.value;
            if ( change.target.name === 'billingNotes' ) {
                // post message to input component
                publishChangeBillingNotes ( this.messageContext, this.inputs [ 'billingNotes' ]);
            }
        }
    }

    async handleMessage ( message, context ) {
        console.log ( 'OrderCalculatorBillingNotes message', message );
        if ( message.action === 'load' ) {
            // write to the billing notes field
            context.billingNotes = message.inputArray.billingNotes;
        }
    }
}