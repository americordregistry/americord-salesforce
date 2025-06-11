public with sharing class PaymentPlan {
    public ID Id;
    public String name;
    public String type;
    public Decimal totalPrincipal;
    public Decimal additionalAmountOnFirstPayment;
    public Decimal monthlyPaymentAmount;
    public Decimal firstPayment;
    public Integer totalNumberOfMonthlyPayments;
    public Decimal interestRate;
    public Decimal totalFees;
    public Decimal totalAmountBeforeInterest;
    public Decimal totalAmountAfterInterest;

    public PaymentPlan () {}

    public PaymentPlan(Payment_Plan_Info__mdt ppInfo) {
        this.Id = ppInfo.Id;
        this.name = ppInfo.MasterLabel;
        this.type = ppInfo.Type__c;
        this.totalNumberOfMonthlyPayments = Integer.valueOf(ppInfo.Number_of_Payments__c);
        this.additionalAmountOnFirstPayment = 0;
        this.interestRate = ppInfo.Rate__c;
    }

    // takes an opportunity with it's child payment object included
    public PaymentPlan(Opportunity opp) {

        // get corresponding metadata record 
        Payment_Plan_Info__mdt ppMetadata = [SELECT ID, Number_of_Fees__c, Number_of_Payments__c, Rate__c, Type__c FROM Payment_Plan_Info__mdt WHERE Number_of_Payments__c=:opp.fw2__Payment_Plan__r.Number_of_Payments__c AND Active__c=true LIMIT 1];

        this.Id = ppMetadata.Id;
        this.name = opp.fw2__Payment_Plan__r.Name;
        this.totalNumberOfMonthlyPayments = Integer.valueOf(ppMetadata.Number_of_Payments__c);
        this.interestRate = ppMetadata.Rate__c;
        if (opp.Amount==null) {opp.Amount = 0;}
        if (opp.Additional_Amount_on_First_Payment__c==null) {opp.Additional_Amount_on_First_Payment__c = 0;}
        this.totalPrincipal = opp.Amount - (opp.Additional_Amount_on_First_Payment__c + opp.Total_Amount_Due_at_Checkout__c);

        if (ppMetadata.Number_of_Payments__c==1) {
            this.type = 'Onetime';
        } else if (ppMetadata.Number_of_Payments__c==null) {
            this.type = 'Annual';
        } else {
            this.type = 'Monthly';
        }

        if (opp.Additional_Amount_on_First_Payment__c==null) {
            opp.Additional_Amount_on_First_Payment__c = 0;
        }
        
        if (this.type=='Onetime' || this.type=='Annual') {
            this.additionalAmountOnFirstPayment = 0;
            this.firstPayment = opp.Amount - opp.Total_Amount_Due_at_Checkout__c;
            this.monthlyPaymentAmount = 0;
            this.totalFees = 0;
        } else {
            this.additionalAmountOnFirstPayment = opp.Additional_Amount_on_First_Payment__c;
            Decimal totalLeftToPayAfterUpfront = opp.Amount - opp.Total_Amount_Due_at_Checkout__c;
            if (this.interestRate>0) {
                this.totalFees = PaymentPlan.getPaymentPlanInterestFee(this.interestRate,totalLeftToPayAfterUpfront,ppMetadata.Number_of_Payments__c);
                Decimal totalRemainingWithInterest = totalLeftToPayAfterUpfront + this.totalFees;
                Decimal amountToDistributeEvenly = totalRemainingWithInterest - opp.Additional_Amount_on_First_Payment__c;
                Decimal baseMonthlyPaymentAmount = amountToDistributeEvenly / ppMetadata.Number_of_Payments__c;
                
                this.firstPayment = baseMonthlyPaymentAmount + opp.Additional_Amount_on_First_Payment__c;
                this.monthlyPaymentAmount = baseMonthlyPaymentAmount;
            } else {
                this.totalFees = 0;
                Decimal remainderAfterAdditionalFirstPayment = totalLeftToPayAfterUpfront - opp.Additional_Amount_on_First_Payment__c;
                Decimal baseMonthlyPaymentAmount = remainderAfterAdditionalFirstPayment / ppMetadata.Number_of_Payments__c;
                this.firstPayment = baseMonthlyPaymentAmount + opp.Additional_Amount_on_First_Payment__c;
                this.monthlyPaymentAmount = baseMonthlyPaymentAmount;
            }
        }
        this.totalAmountBeforeInterest = opp.Amount;
        this.totalAmountAfterInterest = opp.Amount + this.totalFees;

    }

    // takes an Invoice with it's child payment object included
    public PaymentPlan(fw1__Invoice__c inv) {

        //initialize potentially null values
        if (inv.Additional_Amount_on_First_Payment__c==null) {
            inv.Additional_Amount_on_First_Payment__c = 0;
        }
        if (inv.fw1__Total_Paid_Amount__c==null) {
            inv.fw1__Total_Paid_Amount__c = 0;
        }

        // get coresponding metadata record 
        Payment_Plan_Info__mdt ppMetadata = [SELECT ID, Number_of_Fees__c, Number_of_Payments__c, Rate__c, Type__c FROM Payment_Plan_Info__mdt WHERE Number_of_Payments__c=:inv.fw1__Payment_Plan__r.Number_of_Payments__c AND Active__c=true LIMIT 1];

        this.Id = ppMetadata.Id;
        this.name = inv.fw1__Payment_Plan__r.Name;
        this.totalNumberOfMonthlyPayments = Integer.valueOf(ppMetadata.Number_of_Payments__c);
        this.interestRate = ppMetadata.Rate__c;
        this.totalPrincipal = inv.fw1__Net_Amount__c - (inv.Additional_Amount_on_First_Payment__c + inv.fw1__Total_Paid_Amount__c);

        if (ppMetadata.Number_of_Payments__c==1) {
            this.type = 'Onetime';
        } else if (ppMetadata.Number_of_Payments__c==null) {
            this.type = 'Annual';
        } else {
            this.type = 'Monthly';
        }

        if (inv.Additional_Amount_on_First_Payment__c==null) {
            inv.Additional_Amount_on_First_Payment__c = 0;
        }
        
        if (this.type=='Onetime' || this.type=='Annual') {
            this.additionalAmountOnFirstPayment = 0;
            this.firstPayment = inv.fw1__Net_Amount__c - inv.fw1__Total_Paid_Amount__c;
            this.monthlyPaymentAmount = 0;
            this.totalFees = 0;
        } else {
            this.additionalAmountOnFirstPayment = inv.Additional_Amount_on_First_Payment__c;
            Decimal totalLeftToPayAfterUpfront = inv.fw1__Net_Amount__c - inv.fw1__Total_Paid_Amount__c;
            if (this.interestRate>0) {
                this.totalFees = PaymentPlan.getPaymentPlanInterestFee(this.interestRate,totalLeftToPayAfterUpfront,ppMetadata.Number_of_Payments__c);
                Decimal totalRemainingWithInterest = totalLeftToPayAfterUpfront + this.totalFees;
                Decimal amountToDistributeEvenly = totalRemainingWithInterest - inv.Additional_Amount_on_First_Payment__c;
                Decimal baseMonthlyPaymentAmount = amountToDistributeEvenly / ppMetadata.Number_of_Payments__c;
                
                this.firstPayment = baseMonthlyPaymentAmount + inv.Additional_Amount_on_First_Payment__c;
                this.monthlyPaymentAmount = baseMonthlyPaymentAmount;
            } else {
                this.totalFees = 0;
                Decimal remainderAfterAdditionalFirstPayment = totalLeftToPayAfterUpfront - inv.Additional_Amount_on_First_Payment__c;
                Decimal baseMonthlyPaymentAmount = remainderAfterAdditionalFirstPayment / ppMetadata.Number_of_Payments__c;
                this.firstPayment = baseMonthlyPaymentAmount + inv.Additional_Amount_on_First_Payment__c;
                this.monthlyPaymentAmount = baseMonthlyPaymentAmount;
            }
        }
        this.totalAmountBeforeInterest = inv.fw1__Net_Amount__c;
        this.totalAmountAfterInterest = inv.fw1__Net_Amount__c + this.totalFees;

    }

    public void recalculateInterest() {
        Decimal totalInterestCharged = getPaymentPlanInterestFee(this.interestRate, this.totalPrincipal, this.totalNumberOfMonthlyPayments);
        this.totalFees = totalInterestCharged;
    }

    public static Decimal getPaymentPlanInterestFee(Decimal rate, Decimal amtToFinance, Decimal numberOfPayments) {
        Decimal totalInterestCharged;
        if (numberOfPayments>1 && rate>0) {
            Double interest = (rate/100)/12;
            Decimal x = Math.pow(1+interest, Double.valueOf(numberOfPayments));
            Double monthly = (amtToFinance * x * interest) / (x-1);
            Decimal totalAmountToPay = monthly * numberOfPayments;
            totalInterestCharged = totalAmountToPay - amtToFinance;
        } else {
            totalInterestCharged = 0;
        }
        return totalInterestCharged;
    }
}