@isTest
public class Test_BundleFactory {
    private Bundle__c current;

    public Test_BundleFactory(Bundle__c current) {
        this.current = current;
    }

    public static Test_BundleFactory start() {
        return new Test_BundleFactory(
            new Bundle__c(Name='Test Bundle', Description__c='Test Bundle Description')
        );
    }

    public Test_BundleFactory overrideName(String name) {
        current.Name = name;
        return this;
    }

    public Test_BundleFactory asSingleProduct() {
        current.Type__c = 'Single-Product';
        return this;
    }

    public Test_BundleFactory asMultiProduct() {
        current.Type__c = 'Multi-Product';
        return this;
    }

    public Test_BundleFactory setTimeframe(Date startDate, Date endDate) {
        current.Valid_From_Date__c = startDate;
        current.Valid_To_Date__c = endDate;
        return this;
    }

    public Bundle__c create(Decimal amount) {
        insert current;

        Bundle_Pricebook_Entry__c bpe = new Bundle_Pricebook_Entry__c(
            Price_Book__c = Test.getStandardPricebookId(),
            Bundle__c = current.Id,
            List_Price__c = amount,
            Order_Builder_Visible__c = true
        );
        insert bpe;
        return current;
    }

    public Bundle__c createWithBundleMembers(List < Product2 > products, Decimal amount) {
        insert current;

        Bundle_Pricebook_Entry__c bpe = new Bundle_Pricebook_Entry__c(
            Price_Book__c = Test.getStandardPricebookId(),
            Bundle__c = current.Id,
            List_Price__c = amount,
            Order_Builder_Visible__c = true
        );
        insert bpe;
        System.debug('bpe: '+bpe);

        List < Bundle_Member__c > bundleMembers = new List < Bundle_Member__c > ();
        for (Product2 p: products) {
            Bundle_Member__c bm = new Bundle_Member__c();
            bm.Product__c = p.Id;
            bm.Bundle__c = current.Id;
            bm.Quantity__c = 1;
            bundleMembers.add(bm);
        }

        insert bundleMembers;
        return current;
    }

    public Bundle__c build() {
        return current;
    }
}