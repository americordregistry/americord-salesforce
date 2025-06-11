import { LightningElement, api } from 'lwc';
import fetchTypeOfDisplay from '@salesforce/apex/OrderCalculatorController.fetchTypeOfDisplayFromRecord'
import { handleError } from 'c/orderCalculatorUtilities';
export default class OrderCalculatorComponent extends LightningElement {
    @api recordId;
    isOrder = false;
    // init
    async connectedCallback () {
        try {
            const typeOfDisplay = await fetchTypeOfDisplay ({ recordId : this.recordId });
            if ( typeOfDisplay == 'Order' ) {
                this.isOrder = true;
            } else {
                this.isOrder = false;
            }
        } catch ( e ) {
            handleError ( e );
        }
        
    }
}