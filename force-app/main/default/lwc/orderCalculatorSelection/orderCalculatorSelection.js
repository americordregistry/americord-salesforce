import { LightningElement, wire, api } from 'lwc';

// Utilities
import {
    fetchCurrentValues,
    subscribeToMessageChannel,
    unsubscribeFromMessageChannel,
    publishLoadSelection,
} from 'c/orderCalculatorUtilities';

// Messaging
import {
    MessageContext
} from 'lightning/messageService';

export default class OrderCalculatorSelection extends LightningElement {

    // form control
    showComponent = false;
    disableButton = true;

    // form fields
    selectionTitleText = '';

    // record id
    @api recordId;

    // input
    input;
 
    // output
    output;

    // input form reactive
    inputs;
    birthCountString;
    cordBlood2Quantity;
    cordTissueQuantity;
    placenta2Quantity;
    exosomesQuantity;
    momPremiumGenomicsQuantity;
    momStandardGenomicsQuantity;
    newbornGenomeQuantity;
    newbornPanelQuantity;
    maternalExosomesQuantity;
    storagePlan;
    paymentPlan;
    salesDiscount;
    priceBookId;
    depositAmount;
    dataSource;
    orderType;
    recordId;

    // output form reactive
    price;
    genomicsUpfront;
    withDiscount;
    withDeposit;
    firstPayment;
    monthly;

    // messaging
    subscription = null;
    @wire ( MessageContext )
    messageContext;

    // init
    connectedCallback () {
        this.subscription = subscribeToMessageChannel ( this.messageContext, this.subscription, this.handleMessage, this );
        this.refreshSelection ( this, this.recordId, true );
        this.showComponent = true;
        
    }

    async renderedCallback () {
        console.log ( 'orderCalculatorSelection - renderedCallback');
    }

    disconnectedCallback () {
        this.subscription = unsubscribeFromMessageChannel ( this.subscription );
    }

    async handleMessage ( message, context ) {
        console.log ( 'OrderCalculatorSelection message', message );
        if ( message.action === 'selection-refresh' ) {
            context.refreshSelection ( context, message.recordId, false );
        }
    }

    async refreshSelection ( context, recordId, publishLoad ) {
        const dataArray = await fetchCurrentValues ( recordId, true );
        context.input = dataArray [0]; 
        context.output = dataArray [1];

        const dataArrayActual = await fetchCurrentValues ( recordId, false );

        // inspect type of input loaded
        if (( context.input.dataSource === 'Opportunity' ) || ( dataArrayActual[0].orderType === 'Enrolled' )) {
            context.selectionTitleText = 'Current Selection';
        } else {
            context.selectionTitleText = 'Enrolled';
        }
        
        // write vars
        context.birthCountString = context.input.birthCountString;
        context.cordBlood2Quantity = context.input.cordBlood2Quantity;
        context.cordTissueQuantity = context.input.cordTissueQuantity;
        context.placenta2Quantity = context.input.placenta2Quantity;

        context.exosomesQuantity = context.input.exosomesQuantity;
        context.momPremiumGenomicsQuantity = context.input.momPremiumGenomicsQuantity;
        context.momStandardGenomicsQuantity = context.input.momStandardGenomicsQuantity;
        context.newbornGenomeQuantity = context.input.newbornGenomeQuantity;
        context.newbornPanelQuantity = context.input.newbornPanelQuantity;

        context.maternalExosomesQuantity = context.input.maternalExosomesQuantity;

        context.storagePlan = context.input.storagePlan;
        context.paymentPlan = context.input.paymentPlan;
        context.depositAmount = context.input.depositAmount;
        context.salesDiscount = context.input.salesDiscount;
        context.priceBookId = context.input.priceBookId;
        context.dataSource = context.input.dataSource;
        context.orderType = context.input.orderType;
        context.recordId = context.input.recordId;

        if ( context.output ) {
            context.price = context.output.priceBeforeSalesDiscount;
            context.withDiscount = context.output.priceWithDiscounts;
            context.withDeposit = context.output.priceAfterDeposit;
            context.firstPayment = context.output.hybridFirstPayment;
            context.monthly = context.output.monthlyPaymentRounded;
            context.genomicsUpfront = context.output.genomicsUpfront;
            console.log('context.genomicsUpfront: ',context.genomicsUpfront);            
        }

        // deal with the Order Stored use case
        // call publish load for New Selection Panel
        if ( publishLoad === true ) {
            publishLoadSelection ( context.messageContext, dataArrayActual [0] );
        }
    }

    get myGenomeSelection () {
        if (this.momPremiumGenomicsQuantity>0) {
            return 'MyGenome Premium';
        } else if (this.momStandardGenomicsQuantity>0) {
            return 'MyGenome Standard';
        } else {
            return null;
        }
    }

    get myNewbornSelection () {
        if (this.newbornGenomeQuantity>0) {
            return 'MyNewborn Genome';
        } else if (this.newbornPanelQuantity>0) {
            return 'MyNewborn Panel';
        } else {
            return null;
        }
    }

    get maternalExSelection () {
        if (this.maternalExosomesQuantity>0) {
            return 'Maternal Exosomes';
        } else {
            return null;
        }

    }
}