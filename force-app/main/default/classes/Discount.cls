public with sharing class Discount {
    public Id Id;
    public Id appliedDiscountId;
    public ID opportunityId;
    public ID invoiceId;
    public Id productId;
    public Id bundleId;
    public String name;
    public String description;
    public String marketingCode;
    public String type; //bundle discount or product disocunt
    public String method; //percentage or amt
    public Datetime validFrom;
    public Datetime validTo;
    public Decimal amount;
    public Decimal amountAsNegative;
    public Decimal percentage;
    public Boolean systemApplied; //ideally temporary for multi-biobanking discounts
    public Integer ServicesCount; //ideally temporary for multi-biobanking discounts
    public String applicableStorageType; //ideally temporary for multi-biobanking discounts

    public Discount(){}

    public Discount(Discount__c disc) {
        this.Id = disc.Id;
        this.bundleId = disc.Bundle__c;
        this.productId = disc.Product__c;
        this.name = disc.Name;
        this.description = disc.Description__c;
        this.marketingCode = disc.Marketing_Code__c;
        this.type = disc.Type__c;
        this.method = disc.Method__c;
        this.validFrom = disc.Valid_From__c;
        this.validTo = disc.Valid_To__c;
        this.amount = disc.Amount__c;
        this.systemApplied = disc.System_Applied__c;
        this.ServicesCount = Integer.valueOf(disc.Services_Count__c);
        this.applicableStorageType = disc.Applicable_Storage_Type__c;
        if (this.amount>0) {
            this.amountAsNegative = this.amount * -1;
        }
        if (disc.Percentage__c>0) {
            this.percentage = disc.Percentage__c/100; //Salesforce stores percentage fields as whole numbers
        }
        
    }

    public Discount(Applied_Discount__c appliedDisc) {
        this.Id = appliedDisc.Discount__c;
        this.appliedDiscountId = appliedDisc.Id;
        this.productId = appliedDisc.Discount__r.Product__c;
        this.bundleId = appliedDisc.Discount__r.Bundle__c;
        this.opportunityId = appliedDisc.Opportunity__c;
        this.invoiceId = appliedDisc.Invoice__c;
        this.name = appliedDisc.Discount__r.Name;
        this.description = appliedDisc.Discount__r.Description__c;
        this.marketingCode = appliedDisc.Discount__r.Marketing_Code__c;
        this.type = appliedDisc.Discount__r.Type__c;
        this.method = appliedDisc.Discount__r.Method__c;
        this.validFrom = appliedDisc.Discount__r.Valid_From__c;
        this.validTo = appliedDisc.Discount__r.Valid_To__c;
        this.amount = appliedDisc.Amount__c;
        this.systemApplied = appliedDisc.Discount__r.System_Applied__c;
        this.ServicesCount = Integer.valueOf(appliedDisc.Discount__r.Services_Count__c);
        this.applicableStorageType = appliedDisc.Discount__r.Applicable_Storage_Type__c;
        if (this.amount>0) {
            this.amountAsNegative = this.amount * -1;
        }
        //For ad-hoc sales percentage discounts, the percentage is stored in the applied discount record, otherwise, the linked discount record
        if (appliedDisc.Percentage__c!=null && appliedDisc.Percentage__c>0) {
            this.percentage = appliedDisc.Percentage__c/100; //Salesforce stores percentage fields as whole numbers
        } else if (appliedDisc.Discount__r.Percentage__c>0) {
            this.percentage = appliedDisc.Discount__r.Percentage__c/100; //Salesforce stores percentage fields as whole numbers
        }
        
    }
}