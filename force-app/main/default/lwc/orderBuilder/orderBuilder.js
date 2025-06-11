import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSearchableItems from '@salesforce/apex/OrderBuilderController.getSearchableItems';
import loadOrder from '@salesforce/apex/OrderBuilderController.loadOrder';
import getAvailablePaymentOptions from '@salesforce/apex/OrderBuilderController.getAvailablePaymentOptions';
import addProducts from '@salesforce/apex/OrderBuilderController.addProducts';
import removeProduct from '@salesforce/apex/OrderBuilderController.removeProduct';
import addBundle from '@salesforce/apex/OrderBuilderController.addBundle';
import removeBundle from '@salesforce/apex/OrderBuilderController.removeBundle';
import clearOrder from '@salesforce/apex/OrderBuilderController.clearOrder';
import addDiscount from '@salesforce/apex/OrderBuilderController.addDiscount';
import removeDiscount from '@salesforce/apex/OrderBuilderController.removeDiscount';
import updateProductQuantities from '@salesforce/apex/OrderBuilderController.updateProductQuantities';
import updateBundleQuantities from '@salesforce/apex/OrderBuilderController.updateBundleQuantities';
import updatePaymentPlan from '@salesforce/apex/OrderBuilderController.updatePaymentPlan';
import removePaymentPlan from '@salesforce/apex/OrderBuilderController.removePaymentPlan';
import updateAdditionToFirstPayment from '@salesforce/apex/OrderBuilderController.updateAdditionToFirstPayment';
import getBiobankingDiscounts from '@salesforce/apex/OrderBuilderController.getBiobankingDiscounts';
import removeBundlesAndProducts from '@salesforce/apex/OrderBuilderController.removeBundlesAndProducts';

import bundleSuggestionsModal from 'c/bundleSuggestionsModal';

// Utilities
import {
    getMarketingDiscountPlaceholder,
    updateSearchableItemsForInterface,
    getPaymentPlanInterestFee,
    bundlesIncludingSelectedProducts,
    handleError
} from 'c/orderBuilderUtilities';

export default class OrderBuilder extends LightningElement {
    @api recordId;
    dataLoaded = false;
    @track searchableItems;
    @track displayedItems;
    @track currentOrder = {};
    @track paymentPlanOptions;
    @track marketingDiscountsMap = new Map();
    discountCodeEntered;
    paymentPlanIsSelected = false;
    orderSummarySectionOpen = false;
    addItemsSectionOpen = true;
    paymentSummarySectionOpen = true;
    dmlActionsDisabled = false;
    initialRenderComplete = false;
    noSearchableItemsFound = false;
    showSpinner = false;
    error;

    orderIncludesAnnualStoragePlanSelections = false;

    biobankingDiscounts; //TEMPORARY

    renderedCallback() {
        if (!this.initialRenderComplete && this.dataLoaded) {
            this.initialRenderComplete = true;

            // Disable buttons for items already in order (excluding marketing discount codes which can represent different discounts)
            this.currentOrder.productsOrdered.forEach((prod) => {
                this.markAsSelected(prod.selectorId);
            });
            this.currentOrder.bundlesOrdered.forEach((bundle) => {
                this.markAsSelected(bundle.selectorId);
            });

            this.currentOrder.discountsOrdered.forEach((disc) => {
                this.markAsSelected(disc.selectorId);
            });

            // Make buttons/ui readonly if opportunity and enrolled
            if(this.currentOrder.orderContext === 'Opportunity' && this.currentOrder.opportunityStage === 'Enrolled') {
                this.disableAllActions();   
            }
        }
    }

    connectedCallback() {
        if (this.recordId) {
            this.loadData();
        }
    }

    async loadData() {
        try {
            let [order, payPlans, searchableItems, biobankingDiscounts] =
                await Promise.all([
                    loadOrder({ orderId: this.recordId }),
                    getAvailablePaymentOptions(),
                    getSearchableItems({ recordId: this.recordId }),
                    getBiobankingDiscounts()
                ]);
                console.log('payPlans',payPlans);
            let updatedItems = updateSearchableItemsForInterface(
                JSON.parse(searchableItems)
            );
            
            this.searchableItems = updatedItems.searchableItems;
            this.marketingDiscountsMap = updatedItems.marketingDiscountsMap;
            this.biobankingDiscounts = JSON.parse(biobankingDiscounts);

            // Combine all Marketing Discount Codes into a single discount option
            this.searchableItems.push(
                getMarketingDiscountPlaceholder(this.marketingDiscountsMap)
            );
            this.searchableItems.sort(this.sortByName);
            this.error = undefined;
            this.displayedItems = this.searchableItems;
            console.log('this.displayedItems',JSON.stringify(this.displayedItems));
            this.currentOrder = JSON.parse(order);

            console.log('this.currentOrder.paymentPlan on load',JSON.stringify(this.currentOrder.paymentPlan));
            if (this.currentOrder.paymentPlan.Id) {
                this.paymentPlanIsSelected = true;
            } else {
                this.currentOrder.paymentPlan = this.emptyCurrentPayPlan;
                this.currentOrder.paymentPlanSelected = null;
            }

            this.paymentPlanOptions = JSON.parse(payPlans);
            this.paymentPlanOptions.sort(function (a, b) {
                return (
                    a.totalNumberOfMonthlyPayments -
                    b.totalNumberOfMonthlyPayments
                );
            });

            this.payPlanSelectList = [];
            this.paymentPlanOptions.forEach((pp) => {
                pp.additionalAmountOnFirstPayment =
                    this.currentOrder.paymentPlan.additionalAmountOnFirstPayment;
                this.payPlanSelectList.push({ label: pp.name, value: pp.Id });
            });

            this.initializeOrder();
            this.dataLoaded = true;
        } catch (e) {
            handleError(e);
        }
    }

    moveArrayElement(arr, fromIndex, toIndex) {
        let element = arr[fromIndex];
        arr.splice(fromIndex, 1);
        arr.splice(toIndex, 0, element);
        return arr;
    }

    // Initialized back to saved/starting values based on current order, adds Selector IDs (IDs in markup cannot start with numbers, we prepend an a-)
    initializeOrder() {
        this.currentOrder.addedToFirstPayment = 0.0;

        for (let prod of this.currentOrder.productsOrdered) {
            prod.selectorId = 'a-' + prod.Id;
        }
        for (let bundle of this.currentOrder.bundlesOrdered) {
            bundle.selectorId = 'a-' + bundle.Id;
            bundle.accordionIcon = 'utility:chevronright';
            if (bundle.type === 'Single-Product') {
                bundle.isSingleProductBundle = true;
            }
            if (bundle.storageType=='ASP') {
                this.orderIncludesAnnualStoragePlanSelections = true;
            }
        }
        for (let disc of this.currentOrder.discountsOrdered) {
            disc.selectorId = 'a-' + disc.Id;
            if (disc.method === 'Amount') {
                disc.isDollarDiscount = true;
            } else if (disc.method === 'Percentage') {
                disc.isPercentageDiscount = true;
            }
        }

        for (let pp of this.paymentPlanOptions) {
            if (pp.Id === this.currentOrder.paymentPlanSelected) {
                pp.selected = true;
                this.paymentPlanIsSelected = true;
            }
        }

        //Set Payment Plan ordering, OTP at the top
        let otpSelectIndex = this.payPlanSelectList.findIndex((x) => x.label === 'OTP');
        if (otpSelectIndex >= 0) {
            this.payPlanSelectList = this.moveArrayElement(this.payPlanSelectList,otpSelectIndex,0);
        }
        let otpIndex = this.paymentPlanOptions.findIndex((x) => x.name === 'OTP');
        if (otpIndex >= 0) {
            this.paymentPlanOptions = this.moveArrayElement(this.paymentPlanOptions,otpIndex,0);
        }
        

        this.updateTotals();
        this.currentOrder.bundlesOrdered.sort(this.sortByName);
        this.currentOrder.productsOrdered.sort(this.sortByName);
        this.currentOrder.discountsOrdered.sort(this.sortByName);
    }

    disableAllActions() {
        this.dmlActionsDisabled = true;

        this.displayedItems.forEach((item) => {
            item.disabled = true;
        });
    }

    // disableNonAnnualStoragePlanOptions() {
    //     this.displayedItems.forEach((item) => {
    //         if (item.type === 'Bundle' && item.bundle.storageType !== 'ASP') {
    //             item.disabled = true;
    //         }
    //     });
    // }

    enableActions() {
        this.dmlActionsDisabled = false;
        this.displayedItems.forEach((item) => {
            // Only re-enable if it's not selected
            if (item.selected) {
                item.disabled = true;
            } else {
                item.disabled = false;
            }
        });
    }

    // A TEMPORARY solution to continue offering discounts based on specific quantities of biobanking services.  This was not intended to be a way of discounting in the new architecture, but AC has not yet adopted its new pricing model
    getTwentyYearBiobankingProductCount(singleProductBundles) {
        let twentyYearProductCount = 0;

        singleProductBundles.forEach((bundle) => {
            let isBiobanking = false;
            let storageTerm;
            bundle.bundledProducts.forEach((prod) => {
                if (prod.isBiobankingProduct && prod.eligibleForVolumeDiscounts) {
                    isBiobanking = true;
                }
            });
            if (isBiobanking) {
                if (bundle.storageType=='20YPP') {
                    storageTerm = '20YPP';
                    twentyYearProductCount+=parseInt(bundle.quantity);
                }
            }
        });

        return twentyYearProductCount;
    }

    getLifetimeBiobankingProductCount(singleProductBundles) {
        let lifetimeProductCount = 0;
        singleProductBundles.forEach((bundle) => {
            let isBiobanking = false;
            bundle.bundledProducts.forEach((prod) => {
                if (prod.isBiobankingProduct && prod.eligibleForVolumeDiscounts) {
                    isBiobanking = true;
                }
            });

            if (isBiobanking) {
                if (bundle.storageType=='Lifetime') {
                    lifetimeProductCount+=parseInt(bundle.quantity);
                }
            }
        });

        return lifetimeProductCount;
    }

    //Annual Storage Plan
    getASPBiobankingProductCountSingleBundle(singleProductBundles) {
        let annualStoragePlanCount = 0;
        singleProductBundles.forEach((bundle) => {
            let isBiobanking = false;
            bundle.bundledProducts.forEach((prod) => {
                if (prod.isBiobankingProduct && prod.eligibleForVolumeDiscounts) {
                    isBiobanking = true;
                }
            });

            if (isBiobanking) {
                if (bundle.storageType=='ASP') {
                    annualStoragePlanCount+=parseInt(bundle.quantity);
                }
            }
        });

        return annualStoragePlanCount;
    }

    //Returns a count of biobanking products in all Annual Storage Bundles (single or multi-product)
    getASPBiobankingProductCountAllBundles(bundles) {
        let annualStoragePlanCount = 0;
        bundles.forEach((bundle) => {
            let isBiobanking = false;
            let baseProductCount = 0;
            bundle.bundledProducts.forEach((prod) => {
                if (prod.isBiobankingProduct && prod.eligibleForVolumeDiscounts) {
                    isBiobanking = true;
                    baseProductCount++;
                }
            });

            if (isBiobanking) {
                if (bundle.storageType=='ASP') {
                    annualStoragePlanCount+=(parseInt(bundle.quantity)*baseProductCount);
                }
            }
        });

        return annualStoragePlanCount;
    }

    async deleteExistingBiobankingDiscounts() {
        const currentBiobankingDiscounts =
            this.currentOrder.discountsOrdered.filter(
                (discount) => discount.systemApplied === true
            );
        if (currentBiobankingDiscounts.length > 0) {
            const discountIndex = this.currentOrder.discountsOrdered.findIndex(
                (discount) =>
                    discount.selectorId ===
                    currentBiobankingDiscounts[0].selectorId
            );
            const removedDiscount =
                this.currentOrder.discountsOrdered[discountIndex];
            try {
                await this.removeDiscountFromOrder(
                    this.currentOrder,
                    removedDiscount,
                    false
                );
                this.currentOrder.discountsOrdered.splice(discountIndex, 1);
            } catch (error) {
                console.error(error);
            }
        }
    }

    async loadAutomatedDiscountAndRemoveOldAutomatedDiscounts() {
        // Remove existing biobanking discounts
        await this.deleteExistingBiobankingDiscounts();
        let newDiscounts = this.getAutomatedDiscounts();

        if (newDiscounts.length > 0) {
            let discount = newDiscounts[0];
            discount.selectorId = 'a-' + discount.Id;
            if (this.currentOrder.orderContext === 'Opportunity') {
                discount.opportunityId = this.currentOrder.opportunityId;
            } else if (this.currentOrder.orderContext === 'fw1__Invoice__c') {
                discount.invoiceId = this.currentOrder.invoiceId;
            }

            this.currentOrder.discountsOrdered.push(discount);
            this.currentOrder.discountsOrdered.sort(this.sortByName);
            return discount;
        } else {
            return null;
        }
    }

    getAutomatedDiscounts() {
        // If there is more than one un-bundled bio-banking product, add a discount to arrive at the desired 1-item, 3-item, 4-item pricethis.currentOrder.bundlesOrdered in add
        let singleProductBundles = this.getCurrentSingleProductBundles();
        let twentyYearProductCount =
            this.getTwentyYearBiobankingProductCount(singleProductBundles);
        let lifetimeProductCount =
            this.getLifetimeBiobankingProductCount(singleProductBundles);
        let annualStoragePlanCount = 
            this.getASPBiobankingProductCountSingleBundle(singleProductBundles);

        let newDiscounts = [];

        if (twentyYearProductCount > 0) {
            let discountRecordIndex =
                this.biobankingDiscounts.discountRecords.findIndex(
                    (x) =>
                        x.ServicesCount === twentyYearProductCount &&
                        x.applicableStorageType === '20YPP'
                );
            if (discountRecordIndex >=0 ) {
                // (Deep clone, we do not want a reference here -- )
                let discountRecord = JSON.parse(
                    JSON.stringify(
                        this.biobankingDiscounts.discountRecords[
                            discountRecordIndex
                        ]
                    )
                );
                newDiscounts.push(discountRecord);
            }
                
        }

        if (lifetimeProductCount > 0) {
            let discountRecordIndex =
                this.biobankingDiscounts.discountRecords.findIndex(
                    (x) =>
                        x.ServicesCount === lifetimeProductCount &&
                        x.applicableStorageType === 'Lifetime'
                );
            if (discountRecordIndex >=0 ) {
                // (Deep clone, we do not want a reference here -- )
                let discountRecord = JSON.parse(
                    JSON.stringify(
                        this.biobankingDiscounts.discountRecords[
                            discountRecordIndex
                        ]
                    )
                );
                newDiscounts.push(discountRecord);
            }
        }
        if (annualStoragePlanCount > 0) {
            let discountRecordIndex =
                this.biobankingDiscounts.discountRecords.findIndex(
                    (x) =>
                        x.ServicesCount === annualStoragePlanCount &&
                        x.applicableStorageType === 'ASP'
                );
            if (discountRecordIndex >=0 ) {
                // (Deep clone, we do not want a reference here -- )
                let discountRecord = JSON.parse(
                    JSON.stringify(
                        this.biobankingDiscounts.discountRecords[
                            discountRecordIndex
                        ]
                    )
                );
                newDiscounts.push(discountRecord);
            }
        }
        return newDiscounts;
    }

    async handleItemSelection(event) {
        // disable all select buttons
        this.disableAllActions();

        // Load the Item from searchable
        let itemId = event.target.getAttribute('data-select-item-id');
        let itemIndex = this.searchableItems.findIndex(
            (x) => x.selectorId === itemId
        );
        let selectedItem = JSON.parse(
            JSON.stringify(this.searchableItems[itemIndex])
        );

        console.log('JSON.stringify(this.searchableItems[itemIndex])',JSON.stringify(this.searchableItems[itemIndex]));

        //Check for bail conditions
        if (!this.discountSelectionIsValid(selectedItem)) {
            return;
        }
        console.log('discount is ok');

        if (selectedItem.bundle && selectedItem.bundle.storageType === 'ASP') {
            if (this.currentOrder.bundlesOrdered.length>0 && !this.orderIncludesAnnualStoragePlanSelections) {
                this.showErrorToast(
                    'Annual Storage Plan Bundles/Products may not be combined with other products',
                    'Remove non-ASP products from the cart before adding an ASP bundle.',
                    'dismissible'
                );
                this.enableActions();
                return;
            } else if (!this.orderIncludesAnnualStoragePlanSelections) {
                this.setToASP();
            }
        } else {
            //If the selected bundle is NOT an ASP and the order includes ASPs, we need to prevent the selection
            if (selectedItem.bundle && selectedItem.bundle.storageType !== 'ASP') {
                if (this.currentOrder.bundlesOrdered.length>0 && this.orderIncludesAnnualStoragePlanSelections) {
                    this.showErrorToast(
                        'Non-Annual Storage Plan bundles may not be combined with Annual Storage Plan products',
                        'Remove ASP bundles from the cart before adding a non-ASP Bundle.',
                        'dismissible'
                    );
                    this.enableActions();
                    return;
                }
            }
        }


        // Load current products and single-product bundles. We'll only fire the bundle suggester if there is already one of these present.
        let currentProducts = this.getCurrentProducts();
        let currentSingleProductBundles = this.getCurrentSingleProductBundles();

        //Logic here is to determine if there are a la carte products in the order that are all also in a bundle.  If so, we fire the suggested bundles modal prior to adding the selected item to the order.
        if (
            ((selectedItem.type === 'Bundle' &&
                selectedItem.bundle.type === 'Single-Product') ||
                selectedItem.type === 'Product') &&
            (currentProducts.length > 0 ||
                currentSingleProductBundles.length > 0)
        ) {
            let selectedBundleId =
                await this.checkForSuggestedBundles(selectedItem);
            if (selectedBundleId) {
                this.showSpinner = true;

                // stop adding product, add bundle instead and remove a la cart products that are in the bundle
                let bundleIndex = this.searchableItems.findIndex(
                    (x) => x.selectorId === selectedBundleId
                );
                let chosenBundleItem = JSON.parse(
                    JSON.stringify(this.searchableItems[bundleIndex])
                );

                let allProductsInChosenBundle = [];
                chosenBundleItem.bundle.bundledProducts.forEach((prod) => {
                    if (prod.family != 'Shipping' && prod.family != 'Add-on') {
                        allProductsInChosenBundle.push(prod.name);
                    }
                });

                let productsToRemove = [];
                let bundlesToRemove = [];

                // If a currently selected product is in the new bundle, delete the a la carte product
                currentProducts.forEach((currentProd) => {
                    if (allProductsInChosenBundle.includes(currentProd.name)) {
                        productsToRemove.push(currentProd.Id);
                        this.removeProductInUI(currentProd.selectorId);
                    }
                });

                // If ALL the bundled products are in the new bundle, take the bundle out
                currentSingleProductBundles.forEach((bundle) => {
                    let allBundledProductsInNewBundle = true;
                    bundle.bundledProducts.forEach((bundledProduct) => {
                        if (
                            bundledProduct.family != 'Shipping' &&
                            bundledProduct.family != 'Add-on'
                        ) {
                            if (
                                !allProductsInChosenBundle.includes(
                                    bundledProduct.name
                                )
                            ) {
                                allBundledProductsInNewBundle = false;
                            }
                        }
                    });

                    if (allBundledProductsInNewBundle) {
                        bundlesToRemove.push(bundle.Id);
                        this.removeBundleInUI(bundle.selectorId);
                    }
                });

                // Delete products, bundles, then add new bundle
                this.removeBundlesAndProducts(
                    this.currentOrder,
                    productsToRemove,
                    bundlesToRemove
                )
                    .then(() => this.makeItemSelection(selectedBundleId))
                    .then(() => (this.showSpinner = false));
            } else {
                this.makeItemSelection(itemId);
            }
        } else {
            this.makeItemSelection(itemId);
        }
    }

    discountSelectionIsValid(selectedItem) {
        console.log('selectedItem',JSON.stringify(selectedItem ));
        console.log('this.discountCodeEntered',this.discountCodeEntered);
        if (selectedItem.Id==='MarketingDiscount' && !this.discountCodeEntered) {
            this.showErrorToast(
                'No Code Entered',
                'Please enter a discount code before selecting.',
                'dismissible'
            );
            this.enableActions();
            return false;
        } else if (selectedItem.type==='Discount' && selectedItem.discount && selectedItem.discount.type==='Sales') {
            if (selectedItem.discount.method==='Amount' && !selectedItem.discount.amount) {
                this.showErrorToast(
                    'Invalid Discount',
                    'Please Enter an Amount for the Discount',
                    'dismissible'
                );
                this.enableActions();
                return false;
            } else if (selectedItem.discount.method==='Percentage' && !selectedItem.discount.percentage) {
                this.showErrorToast(
                    'Invalid Discount',
                    'Please Enter a Percentage for the Discount in the format .##',
                    'dismissible'
                );
                this.enableActions();
                return false;
            } else if (selectedItem.discount.method==='Percentage' && selectedItem.discount.percentage>1) {
                this.showErrorToast(
                    'Invalid Discount',
                    'Please Enter a Percentage for the Discount in the format .##',
                    'dismissible'
                );
                this.enableActions();
                return false;
            }
            else {
                return true;
            }
        } else {
            console.log('discount is ok');
            return true;
        }
    }

    async unsetAsASP() {
        try {
            this.orderIncludesAnnualStoragePlanSelections = false;
            this.currentOrder.paymentPlanSelected = null;
            this.currentOrder.paymentPlan = {};
            this.paymentPlanIsSelected = false;

            for (let pp of this.paymentPlanOptions) {
                pp.selected = false;
                pp.disabled = false;
            }

            await removePaymentPlan({
                orderJSON: JSON.stringify(this.currentOrder)
            });
        } catch (e) {
            console.log('error', e);
            handleError(e);
        }


    }

    setToASP() {
        this.orderIncludesAnnualStoragePlanSelections = true;
        let ASPPayPlanIndex = this.paymentPlanOptions.findIndex((x) => x.type === 'Annual');
        console.log('asp plan',JSON.stringify(this.paymentPlanOptions[ASPPayPlanIndex].Id));
        this.setPaymentPlan(this.paymentPlanOptions[ASPPayPlanIndex].Id);

        for (let pp of this.paymentPlanOptions) {
            if (pp.Id!=this.paymentPlanOptions[ASPPayPlanIndex].Id) {
                pp.disabled = true;
            }
            
        }
    }

    async makeItemSelection(itemId) {
        console.log('makeItemSelection',itemId);
        let productsToAdd = [];
        let bundleToAdd;
        let discountToAdd;

        // handle discount codes differently
        if (itemId === 'MarketingDiscount') {
            // check the code
            if (
                this.marketingDiscountsMap.get(
                    this.discountCodeEntered.toLowerCase()
                )
            ) {
                let discountObj = this.marketingDiscountsMap.get(
                    this.discountCodeEntered.toLowerCase()
                );
                // make sure it hasn't already been selected
                let appliedDiscountsIndex =
                    this.currentOrder.discountsOrdered.findIndex(
                        (x) => x.selectorId === discountObj.selectorId
                    );
                if (appliedDiscountsIndex > -1) {
                    this.showErrorToast(
                        'Code Already Used',
                        'The code entered has already been applied to this order.',
                        'dismissible'
                    );
                    this.clearDiscountCode();
                    this.enableActions();
                    return;
                }

                // Make sure that the item or bundle it's discounting is in the cart
                if (discountObj.bundleId) {
                    if (!this.bundleIsOrdered(discountObj.bundleId)) {
                        this.showErrorToast(
                            'Cart Requirements Not Met',
                            'The code entered is for a particular bundle which is not currently in the order.',
                            'dismissible'
                        );
                        this.clearDiscountCode();
                        this.enableActions();
                        return;
                    }
                } else if (discountObj.productId) {
                    if (!this.productIsOrdered(discountObj.productId)) {
                        this.showErrorToast(
                            'Cart Requirements Not Met',
                            'The code entered is for a particular product which is not currently in the order.',
                            'dismissible'
                        );
                        this.clearDiscountCode();
                        this.enableActions();
                        return;
                    }
                }

                // Add the opportunity, or invoice id to the discount object we're synthesizing
                if (this.currentOrder.orderContext === 'Opportunity') {
                    discountObj.opportunityId = this.currentOrder.opportunityId;
                } else if (
                    this.currentOrder.orderContext === 'fw1__Invoice__c'
                ) {
                    discountObj.invoiceId = this.currentOrder.invoiceId;
                }

                this.currentOrder.discountsOrdered.push(discountObj);
                discountToAdd = discountObj;
                this.currentOrder.discountsOrdered.sort(this.sortByName);
                this.clearDiscountCode();
            } else {
                // Throw error toast
                this.showErrorToast(
                    'Invalid Code',
                    'The code entered does not match any active discount codes.',
                    'dismissible'
                );
                this.clearDiscountCode();
            }
        } else {
            let itemIndex = this.searchableItems.findIndex(
                (x) => x.selectorId === itemId
            );
            // Get Item from searchable Items (Deep clone, we do not want a reference here -- )
            let selectedItem = JSON.parse(
                JSON.stringify(this.searchableItems[itemIndex])
            );

            // Mark selection in both displayed array and underlying array
            // let itemIndex = this.searchableItems.findIndex(x => x.selectorId ===itemId);
            let displayItemIndex = this.displayedItems.findIndex(
                (x) => x.selectorId === itemId
            );
            this.searchableItems[itemIndex].selected = true;
            this.displayedItems[displayItemIndex].selected = true;

            let button = this.template.querySelector(
                '[data-select-item-id=' + itemId + ']'
            );
            button.classList.add(
                'ac-select-button-selected',
                'slds-is-selected'
            );
            button.classList.remove('ac-select-button-unselected');

            if (selectedItem.type === 'Bundle') {
                selectedItem.bundle.expanded = false;
                selectedItem.bundle.accordionIcon = 'utility:chevronright';
                selectedItem.bundle.quantity = selectedItem.quantity;
                selectedItem.bundle.listPriceAtQuantity = selectedItem.bundle.quantity * selectedItem.bundle.listPrice;
                selectedItem.bundle.bundleSavingsAtQuantity = selectedItem.bundle.quantity * selectedItem.bundle.bundleSavings;
                if (this.currentOrder.orderContext === 'Opportunity') {
                    selectedItem.bundle.opportunityId =
                        this.currentOrder.opportunityId;
                } else if (
                    this.currentOrder.orderContext === 'fw1__Invoice__c'
                ) {
                    selectedItem.bundle.invoiceId = this.currentOrder.invoiceId;
                }
                this.currentOrder.bundlesOrdered.push(selectedItem.bundle);
                this.currentOrder.bundlesOrdered.sort(this.sortByName);

                // TEMPORARY: ADD AUTOMATED BIOBANKING DISCOUNT IF NEEDED
                discountToAdd =
                    await this.loadAutomatedDiscountAndRemoveOldAutomatedDiscounts();

                // update with quantity, total product list pricing and Opportunity/Invoice ID before adding
                let bundleMembersListPriceTotal = 0;
                for (let product of selectedItem.bundle.bundledProducts) {
                    product.quantity = selectedItem.bundle.quantity * product.startingQuantityInBundle;
                    product.listPriceAtQuantity = product.quantity * product.listPrice;
                    bundleMembersListPriceTotal += product.listPriceAtQuantity;
                    if (this.currentOrder.orderContext === 'Opportunity') {
                        product.opportunityId = this.currentOrder.opportunityId;
                    } else if (
                        this.currentOrder.orderContext === 'fw1__Invoice__c'
                    ) {
                        product.invoiceId = this.currentOrder.invoiceId;
                    }

                    // only add required add-ons if not already in the cart
                    for (let related of product.relatedProducts) {
                        if (related.relationshipType === 'Required Add-On') {
                            if (
                                !this.productAlreadyInCart(related.selectorId)
                            ) {
                                this.addAddOnItem(related.selectorId);
                            }
                        }
                    }
                }
                selectedItem.bundle.bundleMembersListPriceTotal = bundleMembersListPriceTotal;
                bundleToAdd = selectedItem.bundle;
            } else if (selectedItem.type === 'Product') {
                selectedItem.product.quantity = selectedItem.quantity;
                selectedItem.product.listPriceAtQuantity =
                    selectedItem.product.quantity *
                    selectedItem.product.listPrice;
                if (this.currentOrder.orderContext === 'Opportunity') {
                    selectedItem.product.opportunityId =
                        this.currentOrder.opportunityId;
                } else if (
                    this.currentOrder.orderContext === 'fw1__Invoice__c'
                ) {
                    selectedItem.product.invoiceId =
                        this.currentOrder.invoiceId;
                }

                this.currentOrder.productsOrdered.push(selectedItem.product);
                productsToAdd.push(selectedItem.product);
                this.currentOrder.productsOrdered.sort(this.sortByName);

                for (let related of selectedItem.product.relatedProducts) {
                    if (related.relationshipType === 'Required Add-On') {
                        if (!this.productAlreadyInCart(related.selectorId)) {
                            // Add item/disable button
                            this.addAddOnItem(related.selectorId);

                            // Add with other products
                            productsToAdd.push(requiredAddOn.product);
                        }
                    }
                }
            } else if (selectedItem.type === 'Discount') {
                console.log('is discount',selectedItem.discount);
                if (this.currentOrder.orderContext === 'Opportunity') {
                    selectedItem.discount.opportunityId =
                        this.currentOrder.opportunityId;
                } else if (
                    this.currentOrder.orderContext === 'fw1__Invoice__c'
                ) {
                    selectedItem.discount.invoiceId =
                        this.currentOrder.invoiceId;
                }
                this.currentOrder.discountsOrdered.push(selectedItem.discount);
                this.currentOrder.discountsOrdered.sort(this.sortByName);
                discountToAdd = selectedItem.discount;
            }
        }

        console.log('discountToAdd',JSON.stringify(discountToAdd));

        // Call these as promises, synchronously to avoid any row-lock issues with updates.  Update methods will check for values before processing
        this.updateTotals()
            .then(() => this.addBundleToSobj(this.currentOrder, bundleToAdd))
            .then(() => this.addProductToSobj(this.currentOrder, productsToAdd))
            .then(() =>
                this.addDiscountToSobj(this.currentOrder, discountToAdd)
            )
            .then(() => this.enableActions())
            .then(() => console.log('all saving done'));
    }

    async checkForSuggestedBundles(selectedItem) {
        // If the user is adding a single Product or single-product bundle, check to see if there are suggested bundles instead
        let orderedSingleProductBundles = this.getCurrentSingleProductBundles();
        let productsToCheck = [];
        orderedSingleProductBundles.forEach((bundle) => {
            bundle.bundledProducts.forEach((prod) => {
                if (prod.family != 'Shipping' && prod.family != 'Add-on') {
                    productsToCheck.push(prod);
                }
            });
        });

        // Add current products
        let currentProducts = this.getCurrentProducts();
        productsToCheck = productsToCheck.concat(currentProducts);
        // Add the newly selected item(s) to the list to check
        if (
            selectedItem.type === 'Bundle' &&
            selectedItem.bundle.type === 'Single-Product'
        ) {
            selectedItem.bundle.bundledProducts.forEach((prod) => {
                if (prod.family != 'Shipping' && prod.family != 'Add-on') {
                    productsToCheck.push(prod);
                }
            });
        } else if (selectedItem.type === 'Product') {
            if (
                selectedItem.product.family != 'Shipping' &&
                selectedItem.product.family != 'Add-on'
            ) {
                productsToCheck.push(selectedItem.product);
            }
        }

        let availableBundles = [];
        this.displayedItems.forEach((item) => {
            if (
                item.displayed &&
                item.bundle &&
                item.bundle.type === 'Multi-Product'
            ) {
                // create a shortened list of the main products in the bundle
                let bundleSummary;
                item.bundle.bundledProducts.forEach((product) => {
                    if (product.family === 'Product') {
                        if (bundleSummary) {
                            bundleSummary += ', ' + product.name;
                        } else {
                            bundleSummary = product.name;
                        }
                    }
                });
                item.bundle.summary = bundleSummary;
                item.bundle.selectorId = item.selectorId;
                availableBundles.push(item.bundle);
            }
        });

        let suggestedBundles = bundlesIncludingSelectedProducts(
            availableBundles,
            productsToCheck
        );
        if (suggestedBundles.length > 0) {
            let bundleOptions = [];
            suggestedBundles.forEach((bundle) => {
                let label = bundle.name.toUpperCase() + ': ' + bundle.summary;
                bundleOptions.push({ label: label, value: bundle.selectorId });
            });

            // Create checkbox group with selected bundles
            let selectedBundleId;
            const result = await bundleSuggestionsModal.open({
                size: 'large',
                header: 'Are You Trying to Add a Bundle?',
                description: 'Check for available bundles',
                bundleOptions: bundleOptions,
                onbundleselected: (e) => {
                    e.stopPropagation(); // stop further propagation of the event
                    selectedBundleId = e.detail;
                }
            });
            // if modal closed with X button, promise returns result = 'undefined'
            // if modal closed with OK button, promise returns result = selectedBundleId
            return selectedBundleId;
        } else {
            return null;
        }
    }

    getCurrentSingleProductBundles() {
        let singleProductBundles = [];
        this.currentOrder.bundlesOrdered.forEach((bundle) => {
            if (bundle.type === 'Single-Product') {
                singleProductBundles.push(bundle);
            }
        });
        return singleProductBundles;
    }

    getCurrentProducts() {
        let singleProducts = [];
        // Add Products
        this.currentOrder.productsOrdered.forEach((prod) => {
            if (prod.family != 'Shipping' && prod.family != 'Add-on') {
                singleProducts.push(prod);
            }
        });
        return singleProducts;
    }

    markAsSelected(selectorId) {
        let itemIndex = this.searchableItems.findIndex(
            (x) => x.selectorId === selectorId
        );
        if (itemIndex >= 0) {
            let displayItemIndex = this.displayedItems.findIndex(
                (x) => x.selectorId === selectorId
            );
            this.searchableItems[itemIndex].selected = true;
            this.displayedItems[displayItemIndex].selected = true;
            this.searchableItems[itemIndex].disabled = true;
            this.displayedItems[displayItemIndex].disabled = true;
            let button = this.template.querySelector(
                '[data-select-item-id=' + selectorId + ']'
            );
            button.classList.add(
                'ac-select-button-selected',
                'slds-is-selected'
            );
            button.classList.remove('ac-select-button-unselected');
        }
    }

    productAlreadyInCart(selectorId) {
        let alreadyInCart = false;
        for (let prod of this.currentOrder.productsOrdered) {
            if (prod.selectorId === selectorId) {
                alreadyInCart = true;
            }
        }
        return alreadyInCart;
    }

    addAddOnItem(selectorId) {
        let itemIndex = this.searchableItems.findIndex(
            (x) => x.selectorId === selectorId
        );
        let requiredAddOn = JSON.parse(
            JSON.stringify(this.searchableItems[itemIndex])
        );

        let displayItemIndex = this.displayedItems.findIndex(
            (x) => x.selectorId === selectorId
        );
        requiredAddOn.selected = !requiredAddOn.selected;
        this.displayedItems[displayItemIndex].selected =
            !this.displayedItems[displayItemIndex].selected;

        let button = this.template.querySelector(
            '[data-select-item-id=' + selectorId + ']'
        );
        button.classList.add('ac-select-button-selected', 'slds-is-selected');
        button.classList.remove('ac-select-button-unselected');

        //add to selected items
        this.currentOrder.productsOrdered.push(requiredAddOn.product);
        this.currentOrder.productsOrdered.sort(this.sortByName);
    }

    showErrorToast(title, message, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error',
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    clearDiscountCode() {
        let discountCodeInput = this.template.querySelector(
            '[data-discount-input-item-id="MarketingDiscount"]'
        );
        discountCodeInput.value = null;
    }

    async handleBundleRemoval(event) {

        // Update Selected Items Data
        this.disableAllActions();
        let selectedBundleSelectorId = event.target.getAttribute(
            'data-item-removal-id'
        );
        let selectedBundleIndex = this.currentOrder.bundlesOrdered.findIndex(
            (x) => x.selectorId === selectedBundleSelectorId
        );
        let selectedBundleId =
            this.currentOrder.bundlesOrdered[selectedBundleIndex].Id;

        this.removeBundleInUI(selectedBundleSelectorId);

        // TEMPORARY: If needed remove biobanking discount/add another if applicable
        this.loadAutomatedDiscountAndRemoveOldAutomatedDiscounts().then(
            (discountToAdd) => {
                this.updateTotals()
                    .then(() =>
                        this.removeBundleFromSobj(
                            this.currentOrder,
                            selectedBundleId,
                            false
                        )
                    )
                    .then(() =>
                        this.addDiscountToSobj(this.currentOrder, discountToAdd)
                    )
                    .then(() => this.enableActions());
            }
        );
    }

    removeBundleInUI(selectedBundleId) {
        let displayItemIndex = this.displayedItems.findIndex(
            (x) => x.selectorId === selectedBundleId
        );
        this.displayedItems[displayItemIndex].selected = false;

        let selectedBundleIndex = this.currentOrder.bundlesOrdered.findIndex(
            (x) => x.selectorId === selectedBundleId
        );
        this.currentOrder.bundlesOrdered.splice(selectedBundleIndex, 1);

        //Check if there are any ASP bundles remaining
        let nonASPBundlePresent = false;
        if (this.currentOrder.bundlesOrdered.length>0) {
            this.currentOrder.bundlesOrdered.forEach((bundle) => {
                if (bundle.storageType === 'ASP') {
                    nonASPBundlePresent = true;
                }
            });
        }   

        //If there are no ASP bundles remaining, unset the order as an ASP order
        if (!nonASPBundlePresent && this.orderIncludesAnnualStoragePlanSelections) {
            this.unsetAsASP();
        } 
    
        //re-enable button
        let button = this.template.querySelector(
            '[data-select-item-id=' + selectedBundleId + ']'
        );
        button.classList.remove(
            'ac-select-button-selected',
            'slds-is-selected'
        );
        button.classList.add('ac-select-button-unselected');
    }

    handleProductRemoval(event) {
        this.disableAllActions();
        let selectedProductSelectorId = event.target.getAttribute(
            'data-item-removal-id'
        );
        let selectedProductIndex = this.currentOrder.productsOrdered.findIndex(
            (x) => x.selectorId === selectedProductSelectorId
        );
        let selectedProductId =
            this.currentOrder.productsOrdered[selectedProductIndex].Id;
        this.removeProductInUI(selectedProductSelectorId);
        this.removeProductFromSobj(this.currentOrder, selectedProductId);
        this.updateTotals();
    }

    removeProductInUI(selectedProductId) {
        let selectedProductIndex = this.currentOrder.productsOrdered.findIndex(
            (x) => x.selectorId === selectedProductId
        );
        let displayItemIndex = this.displayedItems.findIndex(
            (x) => x.selectorId === selectedProductId
        );
        this.displayedItems[displayItemIndex].selected = false;
        this.currentOrder.productsOrdered.splice(selectedProductIndex, 1);

        //re-enable button
        let button = this.template.querySelector(
            '[data-select-item-id=' + selectedProductId + ']'
        );
        button.classList.remove(
            'ac-select-button-selected',
            'slds-is-selected'
        );
        button.classList.add('ac-select-button-unselected');
    }

    handleDiscountRemoval(event) {
        this.disableAllActions();
        let selectedDiscountId = event.target.getAttribute(
            'data-item-removal-id'
        );
        let selectedDiscountIndex = this.currentOrder.discountsOrdered.findIndex(
            (x) => x.selectorId === selectedDiscountId
        );
        let removedDiscount =
            this.currentOrder.discountsOrdered[selectedDiscountIndex];
        console.log('this.currentOrder at removal',JSON.stringify(this.currentOrder));
        this.removeDiscountFromOrder(this.currentOrder, removedDiscount, true);
        this.currentOrder.discountsOrdered.splice(selectedDiscountIndex, 1);

        //re-enable button
        // If it's a marketing code discount there is no need to update the button
        if (!removedDiscount.marketingCode) {
            let button = this.template.querySelector(
                '[data-select-item-id=' + selectedDiscountId + ']'
            );
            let displayItemIndex = this.displayedItems.findIndex(
                (x) => x.selectorId === selectedDiscountId
            );
            
            //Not all discounts are displayed
            if (displayItemIndex>=0) {
                this.displayedItems[displayItemIndex].selected = false;
                button.classList.remove(
                    'ac-select-button-selected',
                    'slds-is-selected'
                );
                button.classList.add('ac-select-button-unselected');
            }
            
        }

        this.updateTotals()
            .then(() => this.enableActions());
    }

    handleSelectedBundleToggle(event) {
        let bundleAccordionId = event.target.getAttribute(
            'data-selected-bundle-id'
        );

        let selectedBundleIndex = this.currentOrder.bundlesOrdered.findIndex(
            (x) => x.selectorId === bundleAccordionId
        );
        this.currentOrder.bundlesOrdered[selectedBundleIndex].expanded =
            !this.currentOrder.bundlesOrdered[selectedBundleIndex].expanded;

        if (this.currentOrder.bundlesOrdered[selectedBundleIndex].expanded) {
            this.currentOrder.bundlesOrdered[
                selectedBundleIndex
            ].accordionIcon = 'utility:chevrondown';
        } else {
            this.currentOrder.bundlesOrdered[
                selectedBundleIndex
            ].accordionIcon = 'utility:chevronright';
        }
    }

    handleLineItemQuantity(event) {
        let quantity = event.target.value;
        let itemId = event.target.getAttribute('data-quantity-input-id');
        let itemIndex = this.searchableItems.findIndex(
            (x) => x.selectorId === itemId
        );

        // Input updates the displayed items array, keep the underlying searchable Items array in-sync
        this.searchableItems[itemIndex].quantity = quantity;
    }

    handleSummaryProductQuantity(event) {
        //There is validation to display an error message on zero
        if (!event.target.value || event.target.value < 1) {
            return;
        }
        let quantity = event.target.value;
        let itemId = event.target.getAttribute(
            'data-summary-prod-quantity-input-id'
        );
        let orderedProductIndex = this.currentOrder.productsOrdered.findIndex(
            (x) => x.selectorId === itemId
        );
        this.currentOrder.productsOrdered[orderedProductIndex].quantity =
            quantity;
        this.currentOrder.productsOrdered[
            orderedProductIndex
        ].listPriceAtQuantity =
            this.currentOrder.productsOrdered[orderedProductIndex].listPrice *
            quantity;
        this.updateTotals();
    }

    handleSummaryBundleQuantity(event) {
        //There is validation to display an error message on zero
        if (!event.target.value || event.target.value < 1) {
            return;
        }
        let quantity = event.target.value;
        let itemId = event.target.getAttribute(
            'data-summary-bundle-quantity-input-id'
        );
        let orderedBundleIndex = this.currentOrder.bundlesOrdered.findIndex(
            (x) => x.selectorId === itemId
        );
        this.currentOrder.bundlesOrdered[orderedBundleIndex].quantity = quantity;
        this.currentOrder.bundlesOrdered[orderedBundleIndex].listPriceAtQuantity = this.currentOrder.bundlesOrdered[orderedBundleIndex].listPrice * quantity;
        this.currentOrder.bundlesOrdered[orderedBundleIndex].bundleSavingsAtQuantity = this.currentOrder.bundlesOrdered[orderedBundleIndex].bundleSavings * quantity;

        let bundleMembersListPriceTotal = 0;
        this.currentOrder.bundlesOrdered[
            orderedBundleIndex
        ].bundledProducts.forEach((product) => {
            product.quantity = quantity * product.startingQuantityInBundle;
            product.listPriceAtQuantity = product.listPrice * product.quantity;
            bundleMembersListPriceTotal += product.listPriceAtQuantity;
        });
        this.currentOrder.bundlesOrdered[
            orderedBundleIndex
        ].bundleMembersListPriceTotal = bundleMembersListPriceTotal;
        this.updateTotals();
    }

    // Fired on blur, save updated quantities to object
    async handleSummaryBundleQuantitiesSet(event) {
        this.disableAllActions();
        let itemId = event.target.getAttribute(
            'data-summary-bundle-quantity-input-id'
        );
        let orderedBundleIndex = this.currentOrder.bundlesOrdered.findIndex(
            (x) => x.selectorId === itemId
        );

        let discountToAdd = await this.loadAutomatedDiscountAndRemoveOldAutomatedDiscounts();
        this.updateTotals()
        .then(() => this.updateBundleQuantities(
            this.currentOrder,
            this.currentOrder.bundlesOrdered[orderedBundleIndex]))
        .then(() => this.addDiscountToSobj(this.currentOrder, discountToAdd))
        .then(() => console.log('all saving done'));

        
    }

    handleSummaryProductQuantitiesSet(event) {
        this.disableAllActions();
        let selectedProductId = event.target.getAttribute(
            'data-summary-prod-quantity-input-id'
        );
        let orderedProductIndex = this.currentOrder.productsOrdered.findIndex(
            (x) => x.selectorId === selectedProductId
        );
        this.updateProductQuantities(
            this.currentOrder,
            this.currentOrder.productsOrdered[orderedProductIndex]
        );
    }

    handleItemFilter(event) {
        let searchTerm = event.target.value;

        let displayRows = this.template.querySelectorAll(
            'tr[data-item-display-row]'
        );
        let returnedItemCount = 0;
        for (let row of displayRows) {
            if (
                row
                    .getAttribute('data-search-term')
                    .toLowerCase()
                    .includes(searchTerm.toLowerCase())
            ) {
                row.classList.remove('ac-hidden');
                returnedItemCount++;
            } else {
                row.classList.add('ac-hidden');
            }
        }

        // Set variable to track when we have an empty items list
        returnedItemCount > 0
            ? (this.noSearchableItemsFound = false)
            : (this.noSearchableItemsFound = true);
    }

    // The x that appears on lightning-input type=search does not do anything OOTB, we have to detect when it's clicked and see if the value is null
    handleItemSearchClear(event) {
        if (!event.target.value) {
            this.noSearchableItemsFound = false;
            let displayRows = this.template.querySelectorAll(
                'tr[data-item-display-row]'
            );
            for (let row of displayRows) {
                row.classList.remove('ac-hidden');
            }
        }
    }

    async updateTotals() {
        let totalListPrice = 0.0;
        let bundleSavings = 0.0;
        let otherDiscounts = 0.0;
        let orderPrice = 0.0;
        let totalDiscountPercentage = 0.0;
        let upfrontAmount = 0;
        let totalListPriceDiscountableProducts = 0;

        // (Note: this ordering means a potentially larger discount to customers -- another, more complicated, option is to take off the whole order $$amounts as the second step, and then percentages for bundles/products)
        // 1: take off any products/bundles $$ values
        // 2: take off any percentages for bundles or products
        // 3: take off any whole order $$ values
        // 4: take off the percentage for whole orders (if exists)

        // TODO: Rule: Only one order-wide percentage discount per order

        this.currentOrder.discountsOrdered

        console.log('this.currentOrder.discountsOrdered',JSON.stringify(this.currentOrder.discountsOrdered));
        let bundleProductDollarDiscounts =
            this.currentOrder.discountsOrdered.filter(function (discount) {
                return (
                    (discount.type === 'Bundle Specific' ||
                        discount.type === 'Product Specific') &&
                    discount.method === 'Amount'
                );
            });
        console.log('this.currentOrder.discountsOrdered',JSON.stringify(this.currentOrder.discountsOrdered));
        let wholeOrderDollarDiscounts =
            this.currentOrder.discountsOrdered.filter(function (discount) {
                return (
                    (discount.type === 'Whole Order' ||
                        discount.type === 'Sales' || discount.type === 'Multi-Biobanking Pkg') &&
                    discount.method === 'Amount'
                );
            });
        console.log('wholeOrderDollarDiscounts',JSON.stringify(wholeOrderDollarDiscounts));
        let bundleProductPercentageDiscounts =
            this.currentOrder.discountsOrdered.filter(function (discount) {
                return (
                    (discount.type === 'Bundle Specific' ||
                        discount.type === 'Product Specific') &&
                    discount.method === 'Percentage'
                );
            });

        let wholeOrderPercentageDiscounts =
            this.currentOrder.discountsOrdered.filter(function (discount) {
                return (
                    (discount.type === 'Whole Order' || discount.type === 'Sales') &&
                    discount.method === 'Percentage'
                );
            });

        console.log('wholeOrderPercentageDiscounts',wholeOrderPercentageDiscounts);
        
        // clear discount data before re-applying with new values
        for (let bundle of this.currentOrder.bundlesOrdered) {
            bundle.combinedDiscounts = 0;
            bundle.finalPrice = bundle.listPriceAtQuantity;
        }
        for (let product of this.currentOrder.productsOrdered) {
            product.combinedDiscounts = 0;
            product.finalPrice = product.listPriceAtQuantity;
        }

        // 1. First take off whole dollar amounts from bundles and packages
        for (let discount of bundleProductDollarDiscounts) {
            for (let bundle of this.currentOrder.bundlesOrdered) {
                if (discount.bundleId === bundle.Id) {
                    let totalDiscountAmount = discount.amount * bundle.quantity;
                    bundle.finalPrice -= totalDiscountAmount;
                    bundle.combinedDiscounts = totalDiscountAmount;
                }
            }
            for (let product of this.currentOrder.productsOrdered) {
                if (discount.productId === product.Id) {
                    let totalDiscountAmount =
                        discount.amount * product.quantity;
                    product.finalPrice -= totalDiscountAmount;
                    product.combinedDiscounts += totalDiscountAmount;
                }
            }
        }

        // 2. Then take off percentages from bundles and packages
        for (let discount of bundleProductPercentageDiscounts) {
            for (let bundle of this.currentOrder.bundlesOrdered) {
                if (discount.bundleId === bundle.Id) {
                    // take the percentage off the current marketing price
                    let discountAmount = bundle.listPrice * discount.percentage;
                    bundle.combinedDiscounts += discountAmount;
                    bundle.finalPrice -= discountAmount;

                    // Update the amount on the discount (for display)
                    let itemIndex =
                        this.currentOrder.discountsOrdered.findIndex(
                            (x) => x.Id === discount.Id
                        );
                    this.currentOrder.discountsOrdered[itemIndex].amount =
                        discountAmount;
                    this.currentOrder.discountsOrdered[
                        itemIndex
                    ].amountAsNegative = (discountAmount * -1).toFixed(2);
                }
            }
            for (let product of this.currentOrder.productsOrdered) {
                if (discount.productId === product.Id) {
                    let discountAmount =
                        product.listPrice * discount.percentage;
                    product.combinedDiscounts += discountAmount;
                    product.finalPrice -= discountAmount;
                    // Update the amount on the discount (for display)
                    let itemIndex =
                        this.currentOrder.discountsOrdered.findIndex(
                            (x) => x.Id === discount.Id
                        );
                    this.currentOrder.discountsOrdered[itemIndex].amount =
                        discountAmount;
                    this.currentOrder.discountsOrdered[
                        itemIndex
                    ].amountAsNegative = (discountAmount * -1).toFixed(2);
                }
            }
        }

        // Calculate the cart totals
        console.log('this.currentOrder.bundlesOrdered',JSON.stringify(this.currentOrder.bundlesOrdered));
        for (let bundle of this.currentOrder.bundlesOrdered) {
            totalListPrice += bundle.bundleMembersListPriceTotal;
            orderPrice += bundle.finalPrice;
            bundleSavings += bundle.bundleSavings * bundle.quantity;
            otherDiscounts += bundle.combinedDiscounts;

            console.log('bundle.quantity',bundle.quantity);
   
            for (let prod of bundle.bundledProducts) {
                if (!prod.exemptFromDiscount) {
                    totalListPriceDiscountableProducts +=
                        prod.listPriceAtQuantity;
                }

 

                if (prod.isDueAtCheckout) {
                    upfrontAmount += prod.finalPrice * prod.quantity;
                } else if (prod.upfrontAmount) {
                    upfrontAmount += prod.upfrontAmount * prod.quantity;
                }
            }
        }
        for (let product of this.currentOrder.productsOrdered) {
            totalListPrice += product.listPriceAtQuantity;
            orderPrice += product.finalPrice;
            otherDiscounts += product.combinedDiscounts;

            if (!product.exemptFromDiscount) {
                totalListPriceDiscountableProducts +=
                    product.listPriceAtQuantity;
            }

            if (product.isDueAtCheckout) {
                upfrontAmount += product.listPrice * product.quantity;
            } else if (product.upfrontAmount) {
                upfrontAmount += product.upfrontAmount * product.quantity;
            }
        }

        let totalListPriceNonDiscountableProducts = totalListPrice - totalListPriceDiscountableProducts;

        // 4: take off whole order percentages (There can only be one of these)
        console.log('wholeOrderPercentageDiscounts',JSON.stringify(wholeOrderPercentageDiscounts));
        if (
            wholeOrderPercentageDiscounts &&
            wholeOrderPercentageDiscounts.length > 0
        ) {
            let discountableTotalAfterOtherDiscountsApplied =
                orderPrice -
                totalListPriceNonDiscountableProducts;
            console.log('this.currentOrder.totalListPriceNonDiscountableProducts',this.currentOrder.totalListPriceNonDiscountableProducts);
            console.log('totalListPriceNonDiscountableProducts',totalListPriceNonDiscountableProducts);
            
            console.log('discountableTotalAfterOtherDiscountsApplied',discountableTotalAfterOtherDiscountsApplied);
            //14796
            let percentageDiscountAsAmount =
                discountableTotalAfterOtherDiscountsApplied *
                wholeOrderPercentageDiscounts[0].percentage;
            console.log('discountableTotalAfterOtherDiscountsApplied',discountableTotalAfterOtherDiscountsApplied);
            console.log('percentageDiscountAsAmount',percentageDiscountAsAmount);
            console.log('wholeOrderPercentageDiscounts[0].percentage',wholeOrderPercentageDiscounts[0].percentage);
            console.log('orderPrice before sub',orderPrice);
            orderPrice -= percentageDiscountAsAmount;
            otherDiscounts += percentageDiscountAsAmount;

            console.log('orderPrice after sub',orderPrice);

            this.discounts;
            let discountIndex = this.currentOrder.discountsOrdered.findIndex(
                (x) =>
                    x.selectorId === wholeOrderPercentageDiscounts[0].selectorId
            );
            this.currentOrder.discountsOrdered[discountIndex].amount =
                percentageDiscountAsAmount;
            this.currentOrder.discountsOrdered[discountIndex].amountAsNegative =
                (percentageDiscountAsAmount * -1).toFixed(2);
        }
        console.log('orderPrice before wholeOrderDollarDiscounts',orderPrice);
        // 3: Then take off any whole order $$ values (checked)
        for (let discount of wholeOrderDollarDiscounts) {
            orderPrice -= Number(discount.amount);
            otherDiscounts += Number(discount.amount);
        }

        console.log('orderPrice after wholeOrderDollarDiscounts',orderPrice);

        // totalDiscountPercentage
        this.currentOrder.totalDueAtCheckout = upfrontAmount;
        this.currentOrder.finalPrice = orderPrice;
        this.currentOrder.totalBundleSavings = bundleSavings;
        this.currentOrder.totalListPrice = totalListPrice;
        this.currentOrder.totalDiscountPercentage = totalDiscountPercentage;
        this.currentOrder.totalDiscount = otherDiscounts * -1;

        // total list price discountable
        this.currentOrder.totalListPriceDiscountableProducts =
            totalListPriceDiscountableProducts;

        // Update Payment Plan info
        this.updatePayPlanData();
        console.log('totalListPrice after update totals',totalListPrice);
        console.log('this.currentOrder.discountsOrdered',JSON.stringify(this.currentOrder.discountsOrdered));
    }

    get noItemsSelected() {
        if (
            this.currentOrder.bundlesOrdered.length > 0 ||
            this.currentOrder.productsOrdered.length > 0 ||
            this.currentOrder.discountsOrdered.length > 0
        ) {
            return false;
        } else {
            return true;
        }
    }

    updatePayPlanData() {
        console.log('updatePayPlanData');
        for (let pp of this.paymentPlanOptions) {
            if(!pp.additionalAmountOnFirstPayment) {
                pp.additionalAmountOnFirstPayment = 0;
            }
            pp.totalDueAtCheckout = this.currentOrder.totalDueAtCheckout; //Kit + shipping + upfront
            if (
                this.currentOrder.productsOrdered.length <= 0 &&
                this.currentOrder.bundlesOrdered.length <= 0
            ) {
                pp.noProductsSelected = true;
            } else {
                pp.noProductsSelected = false;
            }

            if (pp.type === 'Onetime') {
                pp.isOneTime = true;
                pp.additionalAmountOnFirstPayment = 0;
                pp.firstPayment =
                    this.currentOrder.finalPrice - pp.totalDueAtCheckout;
                pp.monthlyPaymentAmount = null;
                pp.totalFees = null;
            } else if (pp.type==='Annual') {
                pp.isAnnual = true;
                pp.additionalAmountOnFirstPayment = 0;
                pp.firstPayment =
                    this.currentOrder.finalPrice - pp.totalDueAtCheckout;

                //For Annual plans, it's an annual payment that depends on number of Annual Biobanking Products 
                let baseMonthlyPaymentAmount = 0;
                this.currentOrder.bundlesOrdered.forEach((bundle) => {
                    if (bundle.storageType === 'ASP') {
                        bundle.bundledProducts.forEach((product) => {
                            if (product.family === 'Storage') {                          
                                baseMonthlyPaymentAmount += product.listPriceAtQuantity;
                            }
                        });
                    }
                });

                console.log('annual base monthly',baseMonthlyPaymentAmount);

                let singleProductBundles = this.getCurrentSingleProductBundles();
                let annualStoragePlanCount = this.getASPBiobankingProductCountAllBundles(this.currentOrder.bundlesOrdered);
                console.log('this.biobankingDiscounts.discountRecords',JSON.stringify(this.biobankingDiscounts.discountRecords));
                console.log('annualStoragePlanCount',annualStoragePlanCount);
    
                const storageDiscountIndex = this.biobankingDiscounts.discountRecords.findIndex(
                    (discount) =>
                        discount.type === 'Multi-Annual Storage'
                        && discount.ServicesCount === annualStoragePlanCount
                );
                
                console.log('storageDiscountIndex',storageDiscountIndex);

                if (storageDiscountIndex >= 0) {
                    pp.monthlyPaymentAmount = baseMonthlyPaymentAmount - this.biobankingDiscounts.discountRecords[storageDiscountIndex].amount;
                } else {
                    pp.monthlyPaymentAmount = baseMonthlyPaymentAmount;
                }

                console.log('annual pp.monthlyPaymentAmount',pp.monthlyPaymentAmount);
       
                pp.totalFees = null;
            } else {
                let totalLeftToPayAfterUpfront =
                    this.currentOrder.finalPrice -
                    this.currentOrder.totalDueAtCheckout;
                pp.totalAmountAfterUpfront = totalLeftToPayAfterUpfront;
                if (pp.interestRate > 0) {
                    let paymentDetails = getPaymentPlanInterestFee(
                        pp,
                        totalLeftToPayAfterUpfront
                    );
                    pp.totalFees = paymentDetails.interest;
                    let baseMonthlyPaymentAmount = paymentDetails.monthly;
                    pp.firstPayment =
                        baseMonthlyPaymentAmount +
                        pp.additionalAmountOnFirstPayment;
                    pp.monthlyPaymentAmount = baseMonthlyPaymentAmount;
                } else {
                    let remainderAfterAdditionalFirstPayment =
                        totalLeftToPayAfterUpfront -
                        pp.additionalAmountOnFirstPayment;
                    let baseMonthlyPaymentAmount =
                        remainderAfterAdditionalFirstPayment /
                        pp.totalNumberOfMonthlyPayments;
                    pp.firstPayment =
                        baseMonthlyPaymentAmount +
                        pp.additionalAmountOnFirstPayment;
                    pp.monthlyPaymentAmount = baseMonthlyPaymentAmount;
                }
            }
            pp.totalAmountBeforeInterest = this.currentOrder.finalPrice;
            pp.totalAmountAfterInterest =
                this.currentOrder.finalPrice + pp.totalFees;

            // update currently selected payplan details
            if (pp.Id === this.currentOrder.paymentPlan.Id) {
                this.currentOrder.paymentPlan = pp;
            }
        }
    }

    get orderSummary() {
        if (this.currentOrder) {
            let listPriceFormatted =
                this.currentOrder.totalListPrice.toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD'
                });
            let bundleSavings =
                this.currentOrder.totalBundleSavings.toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD'
                });
            let discounts = this.currentOrder.totalDiscount.toLocaleString(
                'en-US',
                { style: 'currency', currency: 'USD' }
            );
            let finalPrice = this.currentOrder.finalPrice.toLocaleString(
                'en-US',
                { style: 'currency', currency: 'USD' }
            );

            return (
                '<strong>ORDER SUMMARY</strong>&emsp;&emsp;&emsp; TOTAL LIST PRICE ' +
                listPriceFormatted +
                '&emsp;&emsp;BUNDLE SAVINGS ' +
                bundleSavings +
                '&emsp;&emsp;OTHER DISCOUNTS ' +
                discounts +
                '&emsp;&emsp;ORDER PRICE ' +
                finalPrice
            );
        }
    }

    handleOrderSummaryToggle(event) {
        this.orderSummarySectionOpen = !this.orderSummarySectionOpen;

        let orderSummarySection = this.template.querySelector(
            '[data-section-id=' + 'orderSummaryContents' + ']'
        );
        if (this.orderSummarySectionOpen) {
            orderSummarySection.classList.remove('ac-hidden');
        } else {
            orderSummarySection.classList.add('ac-hidden');
        }
    }

    handleAddItemSectionToggle(event) {
        this.addItemsSectionOpen = !this.addItemsSectionOpen;
        let itemContentsSection = this.template.querySelector(
            '[data-section-id=' + 'addItemsContents' + ']'
        );
        if (this.addItemsSectionOpen) {
            itemContentsSection.classList.remove('ac-hidden');
        } else {
            itemContentsSection.classList.add('ac-hidden');
        }
    }

    handlePaymentSummarySectionToggle(event) {
        if (event.target.name != 'addToUpfront') {
            //Stopping propagation at the child was not preventing the accordion toggle
            this.paymentSummarySectionOpen = !this.paymentSummarySectionOpen;
            let paymentSummarySection = this.template.querySelector(
                '[data-section-id=' + 'paymentSummaryContents' + ']'
            );
            if (this.paymentSummarySectionOpen) {
                paymentSummarySection.classList.remove('ac-hidden');
            } else {
                paymentSummarySection.classList.add('ac-hidden');
            }
        }
    }

    get orderSummarySectionIcon() {
        if (this.orderSummarySectionOpen) {
            return 'utility:chevrondown';
        } else {
            return 'utility:chevronright';
        }
    }

    get orderSummarySectionClassList() {
        if (this.orderSummarySectionOpen) {
            return 'slds-var-m-top_large';
        } else {
            return 'slds-var-m-top_large ac-hidden';
        }
    }

    get addItemSectionIcon() {
        if (this.addItemsSectionOpen) {
            return 'utility:chevrondown';
        } else {
            return 'utility:chevronright';
        }
    }

    get addItemSectionClassList() {
        if (this.addItemsSectionOpen) {
            return 'ac-searchable-section slds-scrollable slds-var-m-top_medium';
        } else {
            return 'ac-searchable-section slds-scrollable slds-var-m-top_medium ac-hidden';
        }
    }

    get paymentSummarySectionIcon() {
        if (this.paymentSummarySectionOpen) {
            return 'utility:chevrondown';
        } else {
            return 'utility:chevronright';
        }
    }

    get paymentSummarySectionClassList() {
        if (this.paymentSummarySectionOpen) {
            return '';
        } else {
            return 'ac-hidden';
        }
    }

    handleDiscountAmtChange(event) {
        //There is validation to display an error message on zero
        if (!event.target.value || event.target.value < 1) {
            return;
        }

        let itemId = event.target.getAttribute('data-discount-input-item-id');
        let itemIndex = this.searchableItems.findIndex(
            (x) => x.selectorId === itemId
        );
        this.searchableItems[itemIndex].discount.amount = event.target.value;
        this.searchableItems[itemIndex].discount.amountAsNegative =
            (event.target.value * -1).toFixed(2);
    }

    handleDiscountPercentageChange(event) {
        //There is validation to display an error message on zero
        console.log('event.target.value',event.target.value);

        //Should not be null, should be less than 1
        if (!event.target.value || event.target.value >= 1) {
            return;
        }

        let itemId = event.target.getAttribute('data-discount-input-item-id');
        let itemIndex = this.searchableItems.findIndex(
            (x) => x.selectorId === itemId
        );
        this.searchableItems[itemIndex].discount.percentage = event.target.value;
    }

    handleDiscountCodeEntry(event) {
        this.discountCodeEntered = event.target.value;
    }

    async handleOrderClear(event) {
        console.log('handleOrderClear');
        this.disableAllActions();
        event.stopPropagation(); //don't fire the accordion toggle (parent)

        
        this.currentOrder.paymentPlanSelected = null;
        this.currentOrder.paymentPlan = this.emptyCurrentPayPlan;
        this.paymentPlanIsSelected = false;
        this.currentOrder.additionalAmountOnFirstPayment = 0;
        this.currentOrder.productsOrdered = [];
        this.currentOrder.bundlesOrdered = [];
        this.currentOrder.discountsOrdered = [];

        //Clear any upfronts added
        this.paymentPlanOptions.forEach((pp) => {
            pp.additionalAmountOnFirstPayment = 0;
            pp.selected = false;
        });

        let displayedPlans = this.template.querySelectorAll(
            '[name=' + 'PaymentPlanRadioSelector' + ']'
        );
        displayedPlans.forEach((plan) => {
            plan.checked = false;
        });

        //If annual plan, clear that
        if (this.orderIncludesAnnualStoragePlanSelections) {
            this.unsetAsASP();
        }

        this.updateTotals();
        await this.clearOrderOnSobj(this.currentOrder);

        // re-enable buttons
        this.displayedItems.forEach((item) => {
            item.selected = false;
            item.disabled = false;
        });

        let buttons = this.template.querySelectorAll(
            '[data-name=' + 'ItemSelectButton' + ']'
        );
        buttons.forEach((button) => {
            button.classList.remove(
                'ac-select-button-selected',
                'slds-is-selected'
            );
            button.classList.add('ac-select-button-unselected');
        });

        
    }

    get emptyCurrentPayPlan() {
        return {"type":null,"totalPrincipal":null,"totalNumberOfMonthlyPayments":null,"totalFees":null,"totalAmountBeforeInterest":null,"totalAmountAfterInterest":null,"name":null,"monthlyPaymentAmount":null,"interestRate":null,"Id":null,"firstPayment":null,"additionalAmountOnFirstPayment":null};
    }

    get payPlanSelectorDisabled() {
        //enable once there are items selected
        if (this.currentOrder.productsOrdered.length <= 0 && this.currentOrder.bundlesOrdered.length <= 0) {
            return true;
        } else if (this.dmlActionsDisabled) {
            return true;
        } else {
            return false;
        }
    }

    get payPlanInputsDisabled() {
        //Can't change pp details if there is no payment plan selected or if we're in a saved state
        if (this.dmlActionsDisabled) {
            return true;
        } else if (!this.paymentPlanIsSelected) {
            return true;
        } else {
            return false;
        }
    }

    handlePPSelect(event) {
        let ppId = event.target.getAttribute('data-pp-selected-id');
        this.setPaymentPlan(ppId);
    }

    handlePPSummarySelect(event) {
        this.setPaymentPlan(event.target.value);
    }

    setPaymentPlan(ppID) {
        this.disableAllActions();
        let ppIndex = this.paymentPlanOptions.findIndex((x) => x.Id === ppID);
        if (!this.orderIncludesAnnualStoragePlanSelections && this.paymentPlanOptions[ppIndex].type==='Annual') {

            this.showErrorToast(
                'Annual Storage Payment Plan may not be selected with non-Annual Storage Bundles',
                'Please select a different payment plan',
                'dismissible'
            );
            this.enableActions();
            return;
        } else if (this.orderIncludesAnnualStoragePlanSelections && this.paymentPlanOptions[ppIndex].type!=='Annual') {
            this.showErrorToast(
                'Annual Storage Products and Bundles may only be selected with an Annual Storage Payment Plan',
                'Please clear Annual Products and add 20-yr or Lifetime Storage Products to select a non-Annual payment plan',
                'dismissible'
            );
            this.enableActions();
            return;
        }
        this.currentOrder.paymentPlanSelected = ppID;
        this.currentOrder.paymentPlan = this.paymentPlanOptions[ppIndex];
        this.paymentPlanIsSelected = true;

        for (let pp of this.paymentPlanOptions) {
            if (pp.Id === ppID) {
                pp.selected = true;
            } else {
                pp.selected = false;
            }
        }

        this.updatePaymentPlan(
            this.currentOrder,
            this.paymentPlanOptions[ppIndex]
        );
    }

    handleUpfrontPPSpecificChange(event) {
        let amt;
        if (!event.target.value) {
            amt = 0;
        } else {
            amt = parseFloat(event.target.value);
        }

        let ppId = event.target.getAttribute('data-payment-upfront-added');
        let ppIndex = this.paymentPlanOptions.findIndex((x) => x.Id === ppId);
        this.paymentPlanOptions[ppIndex].additionalAmountOnFirstPayment = amt;

        // If the upfront was changed on the current plan, make the change there as well
        if (ppId === this.currentOrder.paymentPlan.Id) {
            this.currentOrder.paymentPlan.additionalAmountOnFirstPayment = amt;
        }
        this.updatePayPlanData();
    }

    handleUpfrontGlobalChange(event) {
        event.stopPropagation(); //don't fire the accordion toggle (parent)
        let amt;
        if (!event.target.value) {
            amt = 0;
        } else {
            amt = parseFloat(event.target.value);
        }
        //change on current pay plan
        this.currentOrder.paymentPlan.additionalAmountOnFirstPayment = amt;
        // change on pay plan options
        for (let pp of this.paymentPlanOptions) {
            pp.additionalAmountOnFirstPayment = amt;
        }
        this.updatePayPlanData();
    }

    handleSummaryAddtlAmountClear(event) {
        this.disableAllActions();
        event.stopPropagation(); //don't fire the accordion toggle (parent)
        //change on current pay plan
        this.currentOrder.paymentPlan.additionalAmountOnFirstPayment = 0;
        // change on pay plan options
        for (let pp of this.paymentPlanOptions) {
            pp.additionalAmountOnFirstPayment = 0;
        }

        this.updatePayPlanData();
        this.updateAdditionToFirstPayment(this.currentOrder, 0);
    }

    handleUpfrontChangeSet(event) {
        if (event.target.reportValidity()) {
            this.disableAllActions();

            //if we're on annual or OTP, this cannot be set
            if (this.currentOrder.paymentPlan.type === 'Annual' || this.currentOrder.paymentPlan.type === 'Onetime') {
                this.currentOrder.paymentPlan.additionalAmountOnFirstPayment = 0;
                // change on pay plan options
                for (let pp of this.paymentPlanOptions) {
                    pp.additionalAmountOnFirstPayment = 0;
                }
                this.updatePayPlanData();
                this.showErrorToast(
                    'Upfront Amount may not be set for this payment plan',
                    'Please select a different payment plan',
                    'dismissible'
                );
                let upfrontSummaryInput = this.template.querySelector(
                    '[data-name="summaryLevelUpfrontChange"]'
                );
                upfrontSummaryInput.value = null;
                this.enableActions();
                return;
            }

            
            this.updateAdditionToFirstPayment(
                this.currentOrder,
                this.currentOrder.paymentPlan.additionalAmountOnFirstPayment
            );
        }
    }

    sortByName(a, b) {
        if (a.name < b.name) {
            return -1;
        }
        if (a.name > b.name) {
            return 1;
        }
        return 0;
    }

    bundleIsOrdered(bundleId) {
        let requiredBundleInCart = false;
        for (let bundle of this.currentOrder.bundlesOrdered) {
            if (bundle.Id === bundleId) {
                requiredBundleInCart = true;
            }
        }
        return requiredBundleInCart;
    }

    productIsOrdered(productId) {
        let requiredProductInCart = false;
        for (let prod of this.currentOrder.productsOrdered) {
            if (prod.Id === productId) {
                requiredProductInCart = true;
            }
        }
        return requiredProductInCart;
    }

    updateOrderedProductLineItems(updatedProducts) {
        // update the current order products with line item ids from inserted objects
        this.currentOrder.productsOrdered.forEach((currentProduct) => {
            updatedProducts.forEach((updatedProduct) => {
                if (currentProduct.Id === updatedProduct.Id) {
                    if (!currentProduct.opportunityLineItemId) {
                        currentProduct.opportunityLineItemId =
                            updatedProduct.opportunityLineItemId;
                    }
                    if (!currentProduct.invoiceLineItemId) {
                        currentProduct.invoiceLineItemId =
                            updatedProduct.invoiceLineItemId;
                    }
                }
            });
        });
    }

    // DML Operations
    async addProductToSobj(order, products) {
        if (products.length > 0) {
            try {
                let updatedProducts = JSON.parse(
                    await addProducts({
                        orderJSON: JSON.stringify(order),
                        productJSON: JSON.stringify(products)
                    })
                );
                this.updateOrderedProductLineItems(updatedProducts);
                return;
            } catch (e) {
                handleError(e);
            }
        } else {
            return;
        }
    }

    async addBundleToSobj(order, bundle) {
        if (bundle) {
            try {
                let updatedOrder = JSON.parse(
                    await addBundle({
                        orderJSON: JSON.stringify(order),
                        bundleJSON: JSON.stringify(bundle)
                    })
                );
                // Update Bundled product line items with the SObject IDS (This allows them to be deleted correctly if removed)
                this.currentOrder.bundlesOrdered.forEach((currentBundle) => {
                    let updatedBundleIndex =
                        updatedOrder.bundlesOrdered.findIndex(
                            (x) => x.Id === currentBundle.Id
                        );
                    if (updatedBundleIndex >= 0) {
                        let updatedBundle =
                            updatedOrder.bundlesOrdered[updatedBundleIndex];
                        currentBundle.appliedBundleId =
                            updatedBundle.appliedBundleId;
                        currentBundle.bundledProducts.forEach(
                            (currentProduct) => {
                                let updatedProductIndex =
                                    updatedBundle.bundledProducts.findIndex(
                                        (x) => x.Id === currentProduct.Id
                                    );
                                let updatedProduct =
                                    updatedBundle.bundledProducts[
                                        updatedProductIndex
                                    ];
                                if (!currentProduct.opportunityLineItemId) {
                                    currentProduct.opportunityLineItemId =
                                        updatedProduct.opportunityLineItemId;
                                    currentProduct.appliedBundleId =
                                        updatedProduct.appliedBundleId;
                                }
                                if (!currentProduct.invoiceLineItemId) {
                                    currentProduct.invoiceLineItemId =
                                        updatedProduct.invoiceLineItemId;
                                    currentProduct.appliedBundleId =
                                        updatedProduct.appliedBundleId;
                                }
                            }
                        );
                    }
                });
                // Update product line items (add-on products will be outside the bundle)
                this.updateOrderedProductLineItems(
                    updatedOrder.productsOrdered
                );
                return;
            } catch (e) {
                handleError(e);
            }
        } else {
            return;
        }
    }

    async addDiscountToSobj(order, discount) {
        if (discount) {
            try {
                let appliedDiscountId = await addDiscount({
                    orderJSON: JSON.stringify(order),
                    discountJSON: JSON.stringify(discount)
                });
                // Update discounts with the SObject IDS (This allows them to be deleted correctly if removed)
                let currentDiscountIndex =
                    this.currentOrder.discountsOrdered.findIndex(
                        (x) => x.Id === discount.Id
                    );
                this.currentOrder.discountsOrdered[
                    currentDiscountIndex
                ].appliedDiscountId = appliedDiscountId;
                return;
            } catch (e) {
                console.log('e', e);
                console.log('e', JSON.stringify(e));
                handleError(e);
            }
        } else {
            return;
        }
    }

    async removeDiscountFromOrder(order, discount, enableAfterRemoval) {
        if (discount) {
            try {
                await removeDiscount({
                    orderJSON: JSON.stringify(order),
                    discountJSON: JSON.stringify(discount)
                });
                if (enableAfterRemoval) {
                    this.enableActions();
                }
                return;
            } catch (e) {
                handleError(e);
            }
        } else {
            this.enableActions();
            return;
        }
    }

    async removeProductFromSobj(order, selectedProductId) {
        if (selectedProductId) {
            try {
                await removeProduct({
                    orderJSON: JSON.stringify(order),
                    productId: selectedProductId
                });
                this.enableActions();
                return;
            } catch (e) {
                handleError(e);
            }
        } else {
            this.enableActions();
            return;
        }
    }

    async removeBundleFromSobj(order, selectedBundleId, enableAfterRemoval) {
        if (selectedBundleId) {
            try {
                await removeBundle({
                    orderJSON: JSON.stringify(order),
                    bundleId: selectedBundleId
                });
                if (enableAfterRemoval) {
                    this.enableActions();
                }
            } catch (e) {
                handleError(e);
            }
        } else {
            this.enableActions();
            return;
        }
    }

    async clearOrderOnSobj(order) {
        try {
            await clearOrder({ orderJSON: JSON.stringify(order) });
            this.enableActions();
        } catch (e) {
            handleError(e);
        }
    }

    async updateBundleQuantities(order, bundle) {
        try {
            await updateBundleQuantities({
                orderJSON: JSON.stringify(order),
                bundleJSON: JSON.stringify(bundle)
            });
            this.enableActions();
        } catch (e) {
            handleError(e);
        }
    }

    async updateProductQuantities(order, product) {
        try {
            await updateProductQuantities({
                orderJSON: JSON.stringify(order),
                productJSON: JSON.stringify(product)
            });
            this.enableActions();
        } catch (e) {
            handleError(e);
        }
    }

    async updatePaymentPlan(order, paymentPlan) {
        try {
            await updatePaymentPlan({
                orderJSON: JSON.stringify(order),
                paymentJSON: JSON.stringify(paymentPlan)
            });
            this.enableActions();
        } catch (e) {
            console.log('error', e);
            handleError(e);
        }
    }

    async updateAdditionToFirstPayment(order, amt) {
        try {
            await updateAdditionToFirstPayment({
                orderJSON: JSON.stringify(order),
                amount: amt
            });
            this.enableActions();
        } catch (e) {
            console.log('error', e);
            handleError(e);
        }
    }

    async removeBundlesAndProducts(order, products, bundles) {
        try {
            await removeBundlesAndProducts({
                orderJSON: JSON.stringify(order),
                products: JSON.stringify(products),
                bundles: JSON.stringify(bundles)
            });
        } catch (e) {
            console.log('error', e);
            handleError(e);
        }
    }
}