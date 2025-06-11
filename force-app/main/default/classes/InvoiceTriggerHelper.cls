public with sharing class InvoiceTriggerHelper {

    public static void addOpportunityInfo(List<fw1__Invoice__c> invoices) {
        Invoice cbo = new Invoice(); 
        Set<Id> opptyIds = new Set<Id>();
        Set<Id> acctIds = new Set<Id>();
        
        for (fw1__Invoice__c inv : invoices) {
            if (string.isNotEmpty(inv.fw2__Opportunity__c)) { // stem cell order
                acctIds.add(inv.fw1__Account__c);
                opptyIds.add(inv.fw2__Opportunity__c);                     
            }
            if (string.isNotEmpty(inv.Upgrade_Opportunity__c)) { // upgrade
                acctIds.add(inv.fw1__Account__c);
                opptyIds.add(inv.Upgrade_Opportunity__c);                     
            }
        }
        
        if (opptyIds.size() > 0) {
            cbo.getPaymentProfile(acctIds);
            cbo.addOpportunityInfo(opptyIds,invoices);
        }
    }

    public static void updateRelatedFromOpportunity(Map<Id, fw1__Invoice__c> invoices){
        List < ID > relatedOppIds = new List < ID >();
        
        for (fw1__Invoice__c inv: invoices.values()) {
            relatedOppIds.add(inv.fw1__Opportunity__c);
        }

        Map < ID, Opportunity > oppMap = new Map < ID, Opportunity >([SELECT ID,Additional_Amount_on_First_Payment__c,Number_of_Payments__c,Amount,Total_Amount_Due_at_Checkout__c, fw2__Payment_Plan__r.Name, (SELECT ID, Invoice__c FROM Applied_Discounts__r),(SELECT ID, Invoice__c FROM Applied_Bundles__r) FROM Opportunity WHERE ID in:relatedOppIds]);

        // Get all Payment plan metdata in accessible format
        System.debug('get pay plans: ');
        List < Payment_Plan_Info__mdt > payPlans = Payment_Plan_Info__mdt.getAll().values();
        System.debug('payPlans: '+payPlans);
        Map < Integer, Payment_Plan_Info__mdt > payPlansMap = new Map < Integer, Payment_Plan_Info__mdt >();

        for (Payment_Plan_Info__mdt pp: payPlans) {
            payPlansMap.put(Integer.valueOf(pp.Number_of_Payments__c),pp);
        }
        List < SObject > bundlesAndDiscountsToUpdate = new List < SObject >();
        List < fw1__Additional_Charge__c > additionalChargesToInsert = new List < fw1__Additional_Charge__c >();
        
        List < Product2 > feeProducts = [SELECT ID, Name FROM Product2 WHERE Name LIKE '%Fees%']; // get all interest fee products
        Map < String, Product2 > feeProductsMap = new Map < String, Product2>();
        for (Product2 prod: feeProducts){
            feeProductsMap.put(prod.Name,prod);
        }

        for (fw1__Invoice__c inv: invoices.values()) {
            if (inv.fw1__Opportunity__c!=null) {
                Opportunity opp = oppMap.get(inv.fw1__Opportunity__c);
                // If any of the applied bundles or discounts are not linked to the invoice, add the link
                for (Applied_Bundle__c bundle: opp.Applied_Bundles__r) {
                    if (bundle.Invoice__c!=inv.Id) {
                        bundle.Invoice__c = inv.Id;
                        bundlesAndDiscountsToUpdate.add(bundle);
                    }
                }
                for (Applied_Discount__c disc: opp.Applied_Discounts__r) {
                    if (disc.Invoice__c!=inv.Id) {
                        disc.Invoice__c = inv.Id;
                        bundlesAndDiscountsToUpdate.add(disc);
                    }
                }

                Payment_Plan_Info__mdt pp = payPlansMap.get(Integer.valueOf(opp.Number_of_Payments__c));
                // Add a finance fee line item if needed 
                if (pp!=null && pp.Rate__c!=null && pp.Rate__c>0) {
                    String strFeeProduct = 'Total Monthly Fees'+' - '+opp.fw2__Payment_Plan__r.Name;
                    Decimal financeFees = PaymentPlan.getPaymentPlanInterestFee(pp.Rate__c,(opp.Amount-opp.Total_Amount_Due_at_Checkout__c),opp.Number_of_Payments__c);
                    fw1__Additional_Charge__c charge = new fw1__Additional_Charge__c (
                        Name = strFeeProduct,
                        fw1__Invoice__c = inv.Id,
                        fw1__Fixed_Amount__c = financeFees,
                        Product__c = feeProductsMap.get(strFeeProduct).Id
                    );
                    additionalChargesToInsert.add(charge);
                }
                
            }
        }

        update bundlesAndDiscountsToUpdate;
        insert additionalChargesToInsert;
    }
    
    public static void createLab(List<fw1__Invoice__c> invoices) {
        Invoice cbo = new Invoice();  
        cbo.doCreateLabProcess(invoices); 
    }

    public static void createLineItemsFromOpp(List<fw1__Invoice__c> invoices) {

        List < ID > oppIds = new List < ID >();
        for (fw1__Invoice__c inv: invoices) {
            oppIds.add(inv.fw2__Opportunity__c);
        }
        Map < ID, Opportunity > relatedOppsMap = new Map < ID, Opportunity >([SELECT ID, (SELECT ID,Applied_Bundle__c, Bundle_Savings__c, Discount, Marketing_Discount__c, Sales_Discount__c, Description, ListPrice, UnitPrice, TotalPrice, Price_Book__c, ProductCode, Quantity, Product2Id, Product2.Name FROM OpportunityLineItems) FROM Opportunity WHERE ID in:oppIds]);

        System.debug('relatedOppsMap: '+JSON.serialize(relatedOppsMap));

        List < fw1__Invoice_Line__c > lineItemsToCreate = new List < fw1__Invoice_Line__c >();

        for (fw1__Invoice__c inv: invoices) {
            Opportunity relatedOpp = relatedOppsMap.get(inv.fw2__Opportunity__c);
            if (relatedOpp!=null && relatedOpp.OpportunityLineItems!=null && relatedOpp.OpportunityLineItems.size()>0) {
                System.debug('relatedOpp.OpportunityLineItems: '+JSON.serialize(relatedOpp.OpportunityLineItems));
                for (OpportunityLineItem oli: relatedOpp.OpportunityLineItems) {
                    Decimal totalDiscountAndSavings = ((oli.Sales_Discount__c + oli.Marketing_Discount__c + oli.Bundle_Savings__c))*-1;
                    fw1__Invoice_Line__c invoiceLine = new fw1__Invoice_Line__c (
                        Name=oli.Product2.Name,
                        fw1__Invoice__c=inv.Id,
                        fw1__Quantity__c= oli.Quantity,
                        Applied_Bundle__c = oli.Applied_Bundle__c,
                        Bundle_Savings__c = oli.Bundle_Savings__c,
                        Marketing_Discount__c = oli.Marketing_Discount__c,
                        Sales_Discount__c = oli.Sales_Discount__c,
                        fw1__Item_Description__c = oli.Description,
                        fw1__Unit_Price__c = oli.ListPrice,
                        Product_Code__c = oli.ProductCode,
                        fw1__Discount_Amount__c = totalDiscountAndSavings,
                        fw2__Product__c=oli.Product2Id,
                        fw1__Product2__c=oli.Product2Id
                    );
                    lineItemsToCreate.add(invoiceLine);
                }
            }
        }

        
        insert lineItemsToCreate;

        System.debug('invoice lineItemsToCreate: '+JSON.serialize(lineItemsToCreate));

    }

    public static void createInstallments(Map<Id, fw1__Invoice__c> invoices, Map<Id, fw1__Invoice__c> oldInvoices) {

        Recordtype upgradeRecordType = [SELECT Id FROM Recordtype WHERE SobjectType = 'fw1__Invoice__c' AND Developername = 'Upgrade'];

        List < fw1__Invoice__c > invoicesToGenerateInstallments = new list < fw1__Invoice__c >();

        for (fw1__Invoice__c inv: invoices.values()) {
            // exclude upgrades
            if(inv.recordtypeid != upgradeRecordType.Id){
                fw1__Invoice__c oldInv = oldInvoices.get(inv.Id);
                if (inv.fw1__Auto_BillPay__c==true && oldInv.fw1__Auto_BillPay__c!=true) {
                    invoicesToGenerateInstallments.add(inv);
                }
            }
        }

        // Query for any installments that may still exist on the invoice for deletion (so long as they are unpaid)
        List < fw1__Installment__c > existingInstallmentsToDelete = [SELECT ID FROM fw1__Installment__c WHERE fw1__Invoice__c in:invoicesToGenerateInstallments AND (fw1__Paid_Amount__c=null OR fw1__Paid_Amount__c<=0)];
        
        List < fw1__Installment__c > installmentsToCreate = new List < fw1__Installment__c >();
        for (fw1__Invoice__c inv: invoicesToGenerateInstallments) {
            Decimal additionalAmountOnFirstPayment;
            if (inv.Additional_Amount_on_First_Payment__c==null) {
                additionalAmountOnFirstPayment = 0;
            } else {
                additionalAmountOnFirstPayment = inv.Additional_Amount_on_First_Payment__c;
            }
            Decimal totalLeftToPayAfterUpfront = inv.Total_Monthly_Fee_new__c!=null? inv.fw1__Net_Amount__c + inv.Total_Monthly_Fee_new__c: inv.fw1__Net_Amount__c;
            System.debug('totalLeftToPayAfterUpfront: '+totalLeftToPayAfterUpfront);

            if (inv.fw1__Total_Paid_Amount__c!=null) {
                totalLeftToPayAfterUpfront = totalLeftToPayAfterUpfront - inv.fw1__Total_Paid_Amount__c;
            }
            
            Decimal amountToDistributeEvenly = totalLeftToPayAfterUpfront - additionalAmountOnFirstPayment;
            Decimal baseMonthlyPaymentAmount = (amountToDistributeEvenly / inv.Number_of_Payments__c).setScale(2, RoundingMode.HALF_UP);
            Decimal lastMonthlyPaymentAmount = baseMonthlyPaymentAmount - ((baseMonthlyPaymentAmount*inv.Number_of_Payments__c)-amountToDistributeEvenly);

            //TODO: After the payments are generated in memory, look for variance to the final expected amount.  Add/subtract overage/underage from the lat payment

            Date billingStartDate = System.today();
            for (Integer i=1;i<=inv.Number_of_Payments__c;i++) {
                // special handling for first payment
                if (i==1) {
                    fw1__Installment__c installment = new fw1__Installment__c (
                        Name = 'Installment '+i,
                        fw1__Invoice__c = inv.Id,
                        fw1__Auto_Billed__c = true,
                        fw1__Installment_Amount__c = baseMonthlyPaymentAmount + additionalAmountOnFirstPayment,
                        fw1__Installment_Date__c = billingStartDate
                    );
                    installmentsToCreate.add(installment);
                } else if (i== inv.Number_of_Payments__c){ // last installment with adjustments
                    fw1__Installment__c installment = new fw1__Installment__c (
                        Name = 'Installment '+i,
                        fw1__Invoice__c = inv.Id,
                        fw1__Auto_Billed__c = true,
                        fw1__Installment_Amount__c = lastMonthlyPaymentAmount,
                        fw1__Installment_Date__c = billingStartDate.addMonths(i-1)
                    );
                    installmentsToCreate.add(installment);
                } else {
                    fw1__Installment__c installment = new fw1__Installment__c (
                        Name = 'Installment '+i,
                        fw1__Invoice__c = inv.Id,
                        fw1__Auto_Billed__c = true,
                        fw1__Installment_Amount__c = baseMonthlyPaymentAmount,
                        fw1__Installment_Date__c = billingStartDate.addMonths(i-1)
                    );
                    installmentsToCreate.add(installment);
                }
            }

            if (existingInstallmentsToDelete.size()>0) {
                delete existingInstallmentsToDelete;
            }
            if (installmentsToCreate.size()>0) {
                insert installmentsToCreate;
                System.debug('created installments: '+JSON.serialize(installmentsToCreate));
            }
        
        }
    }
    

}