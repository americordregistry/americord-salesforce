@isTest
public class Test_ProductFactory {
    private Product2 current;

    public Test_ProductFactory(Product2 current) {
        this.current = current;
    }

    // Entry point builder method to start composing object attributes- default values for required fields- can be overridden
    public static Test_ProductFactory start() {
        return new Test_ProductFactory(
            new Product2(Name='Test Product',Description='Test Description',Family='Product',IsActive=true,ProductCode='TestCode')
        );
    }

    // Composable Functions
    public Test_ProductFactory overrideName(String name) {
        current.name = name;
        return this;
    }

    public Test_ProductFactory asBiobanking() {
        current.Is_Biobanking_Product__c = true;
        current.Family = 'Product';
        return this;
    }

    public Test_ProductFactory asProduct() {
        current.Family = 'Product';
        return this;
    }

    public Test_ProductFactory asFee() {
        current.Family = 'Maintenance';
        return this;
    }

    public Test_ProductFactory asStorage() {
        current.Family = 'Storage';
        return this;
    }

    public Test_ProductFactory asShipping() {
        current.Family = 'Shipping';
        return this;
    }

    public Test_ProductFactory asKit() {
        current.Family = 'Add-on';
        return this;
    }

    public Test_ProductFactory asDueAtCheckout() {
        current.Due_at_Checkout__c = true;
        return this;
    }

    public Test_ProductFactory withPartialAmtDueAtCheckout(Decimal amt) {
        current.Partial_Amount_Due_at_Checkout__c = amt;
        return this;
    }

    public Test_ProductFactory asEligibleForVolumeDiscounting() {
        current.Eligible_for_Volume_Discounting__c = true;
        return this;
    }

    // Insert the constructed object
    public Product2 create() {
        insert current;
        return current;
    }

    // Return the constructed object without inserting
    public Product2 build() {
        return current;
    }

}