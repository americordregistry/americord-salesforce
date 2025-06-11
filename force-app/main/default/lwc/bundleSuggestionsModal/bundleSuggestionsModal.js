import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class BundleSuggestionsModal extends LightningModal {
    @api header;
    @api saveLabel = 'Save';
    @api bundleOptions;
    value;

    get options() {
        return [
            { label: 'Ross', value: 'option1' },
            { label: 'Rachel', value: 'option2' },
        ];
    }

    handleChange(e) {
        this.value = e.detail.value;
        console.log('this.value',this.value);
    }

    handleCancel() {
        this.close();
    }

    handleSave() {
        console.log('handleSave');
        
        const saveEvent = new CustomEvent("bundleselected", {
            detail: this.value
        });

        console.log('saveEvent',saveEvent);

        this.dispatchEvent(saveEvent);
        console.log('now close');
        this.close();
    }

    get saveDisabled () {
        if (this.value) {
            return false;
        } else {
            return true;
        }
    }
}