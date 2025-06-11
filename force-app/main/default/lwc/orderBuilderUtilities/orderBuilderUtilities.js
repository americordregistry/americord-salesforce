import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

function getMarketingDiscountPlaceholder(marketingDiscountsMap) {
    let marketingDisc = {};
    marketingDisc.Id = "MarketingDiscount";
    marketingDisc.selectorId = marketingDisc.Id;
    marketingDisc.type = "Discount";
    marketingDisc.name = "Discount: Marketing Code";
    marketingDisc.searchName = marketingDisc.name;
    marketingDisc.description = "Add a marketing code for a special discount; rules may apply";
    marketingDisc.isCodeDiscountField = true;
    marketingDisc.displayed = true;
    marketingDisc.contentsPreview = '';
    marketingDiscountsMap.forEach((discount, code) => {
        marketingDisc.contentsPreview += '"' + code + '": ' + discount.description + '<br>';
    });
    return marketingDisc;
}

function updateSearchableItemsForInterface(searchableItems) {
    let marketingDiscountsMap = new Map();
    for (let i=searchableItems.length-1; i>=0; i--) {
        let item = searchableItems[i];
        item.quantity = 1;
        item.selected = false;
        item.displayed = true;
        item.disabled = false;
        item.searchName = item.name;
        item.selectorId = 'a-'+item.Id;  //In order to retrieve via query-selector, IDs can't start with a number
        if (item.type==='Bundle') {
            
            if (item.bundle.type==='Multi-Product') {
                item.searchName = 'Bundle ' + item.searchName;
            } else if (item.bundle.type==='Single-Product') {
                item.bundle.isSingleProductBundle = true;
            }
            item.bundle.selectorId = 'a-'+item.Id;
            for (let prod of item.bundle.bundledProducts) {
                for (let related of prod.relatedProducts) {
                    related.selectorId = 'a-'+related.Id;
                }
            }
        } else if (item.type==='Product') {
            item.product.selectorId = 'a-'+item.Id;
            for (let related of item.product.relatedProducts) {
                related.selectorId = 'a-'+related.Id;
            }
        } else if (item.type==='Discount') {
            // Discounts behave a bit differently in the UI.  For Discounts with marketing codes, we only want to display one item in the list, and users will add the correct code 
            item.discount.selectorId = 'a-'+item.Id;

            if (item.discount.method==='Amount') {
                item.isDollarDiscount = true;
                item.discount.isDollarDiscount = true;
            } else if (item.discount.method==='Percentage') {
                item.isPercentageDiscount = true;
                item.discount.isPercentageDiscount = true;
            }

            if (item.discount.marketingCode) {
                // Handle marketing code discounts
                marketingDiscountsMap.set(item.discount.marketingCode.toLowerCase(),item.discount);
                // this.marketingDiscountsMap.set(item.discount.marketingCode.toLowerCase(),item.discount);
                // remove from searchable items
                searchableItems.splice(i,1);    
            }
        }
    }
    return {searchableItems:searchableItems, marketingDiscountsMap:marketingDiscountsMap};
}

function getPaymentPlanInterestFee(payPlan, amountToFinance) {
    // https://www.calculatorsoup.com/calculators/financial/simple-interest-plus-principal-calculator.php

    if (payPlan.totalNumberOfMonthlyPayments<=1 || !payPlan.interestRate || payPlan.interestRate<=0) {
        return 0;
    } else {
        let principal = amountToFinance - payPlan.additionalAmountOnFirstPayment;
        let rate = payPlan.interestRate;
        let payments = payPlan.totalNumberOfMonthlyPayments;
        let interest = (rate/100) /12;
        let x = Math.pow(1+interest,payments);
        let monthly = (principal * x * interest) / (x-1);

        let totalWithInterest = monthly * payments;
        let totalInterestPaid = totalWithInterest - principal;


        return {totalWithInterest:totalWithInterest,principal:principal,interest:totalInterestPaid,monthly:monthly};
    }
}

function bundlesIncludingSelectedProducts(availableBundles, alaCarteProducts) {
    let suggestedBundles = [];

    availableBundles.forEach((bundle)=>{
        let allProductsInBundle = [];
        bundle.bundledProducts.forEach((product)=>{
            allProductsInBundle.push(product.name);
        });

        let containsAllProducts = true;
        alaCarteProducts.forEach((product)=>{
            if (!allProductsInBundle.includes(product.name)) {
                containsAllProducts = false;
            }
        });

        if (containsAllProducts) {
            suggestedBundles.push(bundle);
        }
    });
    return suggestedBundles;
}

function handleError ( error ) {
    ('--error--');
    console.log(error);
    console.log('error',JSON.stringify(error));
    let errorObj = JSON.parse(error.body.message);
    
    console.log('errorObj',error.body.message);
    dispatchEvent(
    new ShowToastEvent({
            title: errorObj.title,
            message: errorObj.message,
            variant: errorObj.variant,
            mode: errorObj.mode
        })
    );
}

export {
    getMarketingDiscountPlaceholder,
    updateSearchableItemsForInterface,
    getPaymentPlanInterestFee,
    handleError,
    bundlesIncludingSelectedProducts,
};