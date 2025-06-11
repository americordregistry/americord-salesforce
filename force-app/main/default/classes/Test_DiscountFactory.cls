@isTest
public class Test_DiscountFactory {
    private Discount__c current;

    public Test_DiscountFactory(Discount__c current) {
        this.current = current;
    }

     // Entry point builder method to start composing object attributes- default values for required fields- can be overridden
    public static Test_DiscountFactory start() {
        return new Test_DiscountFactory(
            new Discount__c (Name='Test Discount', Description__c='Test Discount Description')
        );
    }

    // Composable Functions
    public Test_DiscountFactory overrideName(String name) {
        current.Name = name;
        return this;
    }

    public Test_DiscountFactory amountBased(Decimal amount){
        current.Amount__c = amount;
        current.Method__c = 'Amount';
        return this;
    }

    public Test_DiscountFactory percentageBased(Decimal percentage){
        current.Percentage__c = percentage;
        current.Method__c = 'Percentage';
        return this;
    }

    public Test_DiscountFactory asSales() {
        current.Type__c = 'Sales';
        return this;
    }

    public Test_DiscountFactory withCode(String code) {
        current.Marketing_Code__c = code;
        return this;
    }

    public Test_DiscountFactory asBundleSpecific(ID bundleId) {
        current.Type__c = 'Bundle Specific';
        current.Bundle__c = bundleId;
        return this;
    }

    public Test_DiscountFactory asProductSpecific(ID productId) {
        current.Type__c = 'Product Specific';
        current.Product__c = productId;
        return this;
    }

    public Test_DiscountFactory asWholeOrder() {
        current.Type__c = 'Whole Order';
        return this;
    }

    public Test_DiscountFactory asSystemApplied() {
        current.System_Applied__c = true;
        return this;
    }

    public Test_DiscountFactory asMultiBiobanking(Integer count) {
        current.Services_Count__c = count;
        current.Type__c = 'Multi-Biobanking Pkg';
        current.System_Applied__c = true;
        return this;
    }

    public Test_DiscountFactory setApplicableStorageType(String storageType) {
        current.Applicable_Storage_Type__c = storageType;
        return this;
    }

    public Discount__c build() {
        return current;
    }

    public Discount__c create() {
        insert current;
        return current;
    }


}