import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Utilities
import {
    createInputStructure,
    runCalculator,
    writeSelectedValues, 
    isInputValid,
    numberOfBabiesPicklistFactory, 
    storageOptionsPicklistFactory,
    paymentOptionsPicklistFactory,
    shippingOptionsPicklistFactory,
    subscribeToMessageChannel,
    unsubscribeFromMessageChannel,
    publishCalculateRequest,
    publishCalculateDisplayRequest,
    publishRefreshSelection,
    handleError,
    handleMessage
} from 'c/orderCalculatorUtilities';

// Messaging
import {
    MessageContext
} from 'lightning/messageService';

export default class OrderCalculatorInput extends LightningElement {

    // form control
    showComponent = false;
    showCalculateAndSaveButton = false;
    showCalculateButton = false;
    showSaveButton = false;
    disableCalculateAndSaveButton = true;
    disableCalculateButton = true;
    disableSaveButton = true;
    showSpinner = false;
    isOrderStored = false;

    // form components
    inputTitleText = '';

    // input options
    numberOfBabiesOptions = [];
    storageOptions = [];
    paymentOptions = [];
    shippingOptions = [];
    
    // input storage
    inputs;
    birthCount;
    cordBlood2Quantity;
    cordTissueQuantity;
    placenta2Quantity;
    exosomesQuantity;
    momPremiumGenomicsQuantity;
    momStandardGenomicsQuantity;
    newbornGenomeQuantity;
    newbornPanelQuantity;
    maternalExosomesQuantity
    storagePlan;
    paymentPlan;
    shippingType;
    shipingCost;
    salesDiscount;
    priceBookId;
    depositAmount;
    discountCode;
    discountCodeOrAmount;
    dataSource;
    orderType;
    recordId;
    billingNotes;

    // Checkbox values
    myGenomePremiumChecked = false;
    myGenomeStandardChecked = false;
    newbornGenomeChecked = false;
    newbornPanelChecked = false;
    maternalExosomesChecked = false;

    // New Products
    myGenomeValue = [];
    newbornGenomeValue = [];

    // outputs
    price;
    shippingCost;
    withDiscount;
    withDeposit;
    genomicsUpfront;
    // paymentAtCheckout;
    firstPayment;
    monthly;
    outputObject = {};

    // messaging
    subscription = null;
    @wire ( MessageContext )
    messageContext;

    // init
    connectedCallback () {
        this.subscription = subscribeToMessageChannel ( this.messageContext, this.subscription, this.handleMessage, this );        
        this.inputs = createInputStructure ();
    }

    disconnectedCallback () {
        this.subscription = unsubscribeFromMessageChannel ( this.subscription );
    }

    setInputOptions () {
        this.numberOfBabiesOptions = numberOfBabiesPicklistFactory ();
        this.storageOptions = storageOptionsPicklistFactory ();
        this.paymentOptions = paymentOptionsPicklistFactory ();
        this.shippingOptions = shippingOptionsPicklistFactory ();
    }

    get myGenomeOptions() {
        return [
            { label: 'Premium', value: 'premium' },
            { label: 'Standard', value: 'standard' },
        ];
    }

    get newbornGenomeOptions() {
        return [
            { label: 'Genome', value: 'genome' },
            { label: 'Newborn Panel', value: 'newbornPanel' },
        ];
    }

    get maternalOptions() {
        return [
            { label: 'Maternal Exosomes', value: 'maternalExosomes' },
        ];
    }


    handleChange ( change ) {
        if (!change.target.value) { //checkboxes don't have a value
            // first, uncheck the other myGenome product if selected (you can only choose one)
            switch(change.target.name) {
                case "myGenomePremium":
                    if (change.target.checked) {
                        this.inputs [ "momPremiumGenomicsQuantity" ] = 1;
                        // clear out the standard genome selection
                        this.template.querySelector('[data-id="myGenomeStandard"]').checked =false;
                        this.inputs [ "momStandardGenomicsQuantity" ] = 0;
                    } else {
                        this.inputs [ "momPremiumGenomicsQuantity" ] = 0;
                    }
                    break;
                case "myGenomeStandard":
                    if (change.target.checked) {
                        this.inputs [ "momStandardGenomicsQuantity" ] = 1;
                        // clear out the premium genome selection
                        this.template.querySelector('[data-id="myGenomePremium"]').checked =false;
                        this.inputs [ "momPremiumGenomicsQuantity" ] = 0;
                    } else {
                        this.inputs [ "momStandardGenomicsQuantity" ] = 0;
                    }
                    break;
                case "newbornPanel":
                    if (change.target.checked) {
                        this.inputs [ "newbornPanelQuantity" ] = 1;
                    } else {
                        this.inputs [ "newbornPanelQuantity" ] = 0;
                    }
                    break;
                case "maternalExosomes":
                    if (change.target.checked) {
                        this.inputs [ "maternalExosomesQuantity" ] = 1;
                    } else {
                        this.inputs [ "maternalExosomesQuantity" ] = 0;
                    }
                    break;
            } 
        } else {
            if ( this.inputs [ change.target.name ] != change.target.value ) {
                // have a change
                this.inputs [ change.target.name ] = change.target.value;
            }
        }

        // A discount code may be entered OR a discount amount, but not both
        if (change.target.name==="discountCodeOrAmount") {
            change.target.value = change.target.value.trim()
            if (!change.target.value) {
                console.log('No Discount or Code');
                this.inputs [ "discountCode" ] = null;
                this.inputs [ "salesDiscount" ] = 0;
            } else if (isNaN(change.target.value)) {
                console.log('Discount Code Entered - Clear custom discount amount');
                this.inputs [ "discountCode" ] = change.target.value;
                this.inputs [ "salesDiscount" ] = 0;
            } else {
                console.log('Sales Discount Entered - Clear Coupon Code');
                this.inputs [ "discountCode" ] = null;
                this.inputs [ "salesDiscount" ] = change.target.value;
            }
        } 
        
        if (this.selectionIsValid(change.target.name, change.target.value)) {
            this.disableCalculateButton = false;
            this.disableSaveButton = true;
            this.disableCalculateAndSaveButton = false;
        } else {
            this.disableCalculateAndSaveButton = true;
        }
    }

    selectionIsValid (inputName, inputValue) {
        let storagePlan;
        let paymentPlan;
        let numberOfStemServices;
        let newbornPanelQty;

        if (inputName==='storagePlan') {
            paymentPlan = this.inputs [ 'paymentPlan'];
            storagePlan = inputValue;
        } else if (inputName==='paymentPlan') {
            storagePlan = this.inputs [ 'storagePlan'];
            paymentPlan = inputValue;
        }

        //can't select 48 month payment plan with 20 Year storage
        if (paymentPlan==='48M' && storagePlan=='20YPP') {
            const evt = new ShowToastEvent({
                title: 'Invalid Selection',
                message: '48 month payment plans are not available for 20-year storage plans, unless this opportunity was quoted prior to 5/17/22',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        } 

        //prevent selecting non-OTP when newborn standalone - not stem cell services
        if (inputName==='paymentPlan' || inputName === 'newbornPanelQuantity' || 
            inputName === 'cordBlood2Quantity' || inputName ==='cordTissueQuantity' ||
            inputName === 'placenta2Quantity' || inputName === 'exosomesQuantity'){
            paymentPlan = this.inputs [ 'paymentPlan'];
            numberOfStemServices = this.inputs [ 'cordBlood2Quantity' ]; 
            numberOfStemServices = numberOfStemServices + this.inputs [ 'cordTissueQuantity' ];
            numberOfStemServices = numberOfStemServices + this.inputs [ 'placenta2Quantity' ];
            numberOfStemServices = numberOfStemServices + this.inputs [ 'exosomesQuantity' ];
            newbornPanelQty = this.inputs ['newbornPanelQuantity'] ;
        }

        if (paymentPlan != 'OTP' && numberOfStemServices == 0 && newbornPanelQty == 1){
            const evt = new ShowToastEvent({
                title: 'Invalid Selection',
                message: 'You must select One-time Payment when only seleecting Newborn Genome Panel.',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }

        return true;
    }

    async renderForm ( inputArray ) {
        console.log('render inputArray',inputArray);
        this.setInputOptions ();
        // set inputs 
        if ( inputArray.birthCount ) {
            this.birthCount = inputArray.birthCount.toString ();
        } else {
            this.birthCount = null;
        }
        
        this.cordBlood2Quantity = inputArray.cordBlood2Quantity;
        this.cordTissueQuantity = inputArray.cordTissueQuantity;
        this.placenta2Quantity = inputArray.placenta2Quantity;
        this.exosomesQuantity = inputArray.exosomesQuantity;
        this.momPremiumGenomicsQuantity = inputArray.momPremiumGenomicsQuantity;
        this.momStandardGenomicsQuantity = inputArray.momStandardGenomicsQuantity;
        this.newbornGenomeQuantity = inputArray.newbornGenomeQuantity;
        this.newbornPanelQuantity = inputArray.newbornPanelQuantity;
        this.maternalExosomesQuantity = inputArray.maternalExosomesQuantity;
        this.storagePlan = inputArray.storagePlan;
        this.paymentPlan = inputArray.paymentPlan;
        this.shippingType = inputArray.shippingType;
        this.depositAmount = inputArray.depositAmount;
        this.genomicsUpfront = inputArray.genomicsUpfront;  
        this.discountCode = inputArray.discountCode;
        this.salesDiscount = inputArray.salesDiscount;
        this.priceBookId = inputArray.priceBookId;
        this.dataSource = inputArray.dataSource;
        this.orderType = inputArray.orderType;
        this.recordId = inputArray.recordId;
        this.billingNotes = inputArray.billingNotes;
        this.price = inputArray.priceBeforeSalesDiscount;

        //Set checkboxes
        if (this.momPremiumGenomicsQuantity>0) {
            this.myGenomePremiumChecked = true;
        } 
        if (this.momStandardGenomicsQuantity>0) {
            this.myGenomeStandardChecked = true;
        }
        if (this.newbornGenomeQuantity>0) {
            this.newbornGenomeChecked = true;
        }
        if (this.newbornPanelQuantity>0) {
            this.newbornPanelChecked = true;
        }
        if (this.maternalExosomesQuantity>0) {
            this.maternalExosomesChecked = true;
        }

        // set buttons
        if ( this.dataSource === 'Opportunity' ) {
            this.showCalculateAndSaveButton = true;
            this.showCalculateButton = false;
            this.showSaveButton = false;
            this.inputTitleText = 'New Selection / Calculation';
        } else {
            this.showCalculateAndSaveButton = false;
            this.showCalculateButton = true;
            this.showSaveButton = true;
            if ( this.orderType === 'Enrolled') {
                this.inputTitleText = 'New Selection / Calculation';
            } else {
                this.inputTitleText = 'Stored';
            }
        }
        // default all buttons disabled
        this.disableCalculateAndSaveButton = true;
        this.disableCalculateButton = true;
        this.disableSaveButton = true;

        // set array
        this.inputs ['birthCount'] = this.birthCount;
        this.inputs ['cordBlood2Quantity'] = this.cordBlood2Quantity;
        this.inputs ['cordTissueQuantity'] = this.cordTissueQuantity;
        this.inputs ['placenta2Quantity'] = this.placenta2Quantity;

        this.inputs ['exosomesQuantity'] = this.exosomesQuantity;
        this.inputs ['momPremiumGenomicsQuantity'] = this.momPremiumGenomicsQuantity;
        this.inputs ['momStandardGenomicsQuantity'] = this.momStandardGenomicsQuantity;
        this.inputs ['newbornGenomeQuantity'] = this.newbornGenomeQuantity;
        this.inputs ['newbornPanelQuantity'] = this.newbornPanelQuantity;
        this.inputs ['maternalExosomesQuantity'] = this.maternalExosomesQuantity;

        this.inputs ['storagePlan'] = this.storagePlan;
        this.inputs ['paymentPlan'] = this.paymentPlan;
        this.inputs ['shippingType'] = this.shippingType;
        this.inputs ['depositAmount'] = this.depositAmount;

        this.inputs ['salesDiscount'] = this.salesDiscount;
        this.inputs ['discountCode'] = this.discountCode;
        this.inputs ['priceBookId'] = this.priceBookId;
        this.inputs ['dataSource'] = this.dataSource;
        this.inputs ['orderType'] = this.orderType;
        this.inputs ['recordId'] = this.recordId;
        this.inputs ['billingNotes'] = this.billingNotes;
        this.inputs ['genomicsUpfront'] = this.genomicsUpfront;

        // check for Order Stored
        if ( this.orderType === 'Stored' ) {
            this.isOrderStored = true;
        }

        // render
        this.showComponent = true;

        // check input validity and call calculate if valid
        const _isInputValid = await isInputValid ( inputArray );
        if ( _isInputValid ) {
            publishCalculateRequest ( this.messageContext, inputArray );
        }
    }

    get paymentAtCheckout() {
        if (this.depositAmount && this.shippingCost) {
            if (this.genomicsUpfront) {
                return this.depositAmount + this.genomicsUpfront + this.shippingCost;
            } else {
                return this.depositAmount + this.shippingCost;
            }
            
        } else {
            if (this.genomicsUpfront) {
                return this.genomicsUpfront;
            } else {
                return 0;
            }
        }
    } 

    get myGenomePremiumChecked() {
        if (this.momPremiumGenomicsQuantity>0) {
            return true;
        } else {
            return false;
        }
    }

    get myGenomeStandardChecked() {
        if (this.momStandardGenomicsQuantity>0) {
            return true;
        } else {
            return false;
        }
    }

    get newbornGenomeChecked() {
        if (this.newbornGenomeQuantity>0) {
            return true;
        } else {
            return false;
        }
    }

    get newbornPanelChecked() {
        if (this.newbornPanelQuantity>0) {
            return true;
        } else {
            return false;
        }
    }

    get maternalExosomesChecked() {
        if (this.maternalExosomesQuantity>0) {
            return true;
        } else {
            return false;
        }
    }    

    async handleMessage ( message, context ) {
        // check the action
        if ( message.action === 'calculate' ) {
            // run calculate
            context.showSpinner = true;
            let haveError = false;
            let localOutput = {};
            // calculate
            try {
                console.log('+++++++++++++message.inputArray ON CALCULATE',message.inputArray);
                localOutput = await runCalculator ( message.inputArray );
                console.log('++++++++++++++++++++++++localOutput',localOutput);
                // set form values - note: must use context as this
                context.price = localOutput.priceBeforeSalesDiscount;
                context.biobankingMultiProductDiscount = localOutput.biobankingMultiProductDiscount;
                context.withDiscount = localOutput.priceWithDiscounts;
                context.withDeposit = localOutput.priceAfterDeposit;
                context.firstPayment = localOutput.hybridFirstPayment;
                context.monthly = localOutput.monthlyPaymentRounded;
                context.shippingCost = localOutput.shippingCost;
                context.depositAmount = localOutput.kitFee;
                context.salesDiscount = localOutput.salesDiscount;
                context.discountCode = localOutput.discountCode;
                context.genomicsUpfront = localOutput.genomicsUpfront;
                context.inputs [ 'genomicsUpfront' ] = localOutput.genomicsUpfront;
                context.outputObject = localOutput;
                
            } catch ( e ) {
                handleError ( e );
                haveError = true;
            }
            // auto save
            if ( haveError === false ) {
                try {
                    // handle autosave
                    if ( message.autoSave ) {
                        context.disableCalculateAndSaveButton = true;
                        await writeSelectedValues ( message.inputArray, localOutput );
                        publishRefreshSelection ( context.messageContext, message.inputArray.recordId );
                    }
                } catch ( e ) {
                    console.log ( 'error ---  ', e );
                    handleMessage ( 'An error has occurred', 'New selection could not be saved, please review input selection and try again', 'error' );
                    haveError = true;
                }
            }
            // lower panels
            if ( haveError === false ) {
                // publish calculate-display message for lower panels
                context.callCalculateDisplay ( context.messageContext, message.inputArray );
            }
            context.showSpinner = false;
        } else if ( message.action === 'load' ) {
            // load values into form fields
            context.renderForm ( message.inputArray );
        } else if ( message.action === 'change-billing-notes' ) {
            // set billing notes from external LWC
            context.billingNotes = message.billingNotes;
            context.inputs [ 'billingNotes' ] = message.billingNotes;
            context.disableSaveButton = false;
        }
    }

    callCalculateDisplay ( messageContext, inputArray ) {
        publishCalculateDisplayRequest ( messageContext, inputArray );
    }

    isFormValid () {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {
            return true;
        } else {
            handleMessage ( 'Cannot complete request', 'Please review errors below and try again.', 'error' );
            return false;
        }
    }

    handleCalculateButton ( event ) {
        event.preventDefault ();
        if ( this.isFormValid ()) {
            this.showSpinner = true;
            this.disableCalculateButton = true;
            this.disableSaveButton = false;
            publishCalculateRequest ( this.messageContext, this.inputs, false );
        }
    }

    async handleSaveButton ( event ) {
        event.preventDefault ();
        if ( this.isFormValid ()) {
            this.disableSaveButton = true;
            this.showSpinner = true;
            await writeSelectedValues ( this.inputs, this.outputObject );
            publishRefreshSelection ( this.messageContext, this.inputs.recordId );
            this.showSpinner = false;
        }
    }

    handleCalculateAndSaveButton ( event ) {
        event.preventDefault ();
        if ( this.isFormValid ()) {
            this.showSpinner = true;
            this.disableCalculateButton = true;
            publishCalculateRequest ( this.messageContext, this.inputs, true );
            //publishRefreshSelection ( this.messageContext, this.inputs.recordId );
        }
        console.log ( 'Calculate and save clicked', this.inputs )
    }

}