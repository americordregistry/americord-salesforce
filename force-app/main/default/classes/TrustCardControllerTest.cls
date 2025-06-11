@isTest
class TrustCardControllerTest {
    @isTest static void testGetHasItems_false() {
        String locationRef = 'abc';
        PageReference pageRef = Page.TrustCardPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('location',locationRef);
        TrustCardController tc = new TrustCardController();
        Boolean hasItems = tc.getHasItems();
        System.assertEquals(false, hasItems);
    }

    @isTest static void testGetHasItems_true() {
        String locationRef = 'abc';
        Schema.Location location = new Schema.Location(ExternalReference='abc',  Name='name', LocationType='store');
        insert location;
        LocationTrustMeasure ltm = new LocationTrustMeasure(Title='title',Description='description');
        ltm.locationId = location.Id;
        insert ltm;
        PageReference pageRef = Page.TrustCardPage;
        ApexPages.currentPage().getParameters().put('location',locationRef);
        TrustCardController tc = new TrustCardController();
        Boolean hasItems = tc.getHasItems();
        System.assertEquals(true, hasItems);
    }

    @isTest static void testGetIsLocationBlank_false() {
        String locationRef = 'abc';
        PageReference pageRef = Page.TrustCardPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('location',locationRef);
        TrustCardController tc = new TrustCardController();
        Boolean locationBlank = tc.getIsLocationBlank();
        System.assertEquals(false, locationBlank);
    }

    @isTest static void testGetIsLocationBlank_true() {
        TrustCardController tc = new TrustCardController();
        Boolean locationBlank = tc.getIsLocationBlank();
        System.assertEquals(true, locationBlank);
    }

    @isTest static void testGetLayout_banner() {
        String layout = 'banner';
        PageReference pageRef = Page.TrustCardPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('layout',layout);
        TrustCardController tc = new TrustCardController();
        String cssPath = tc.getLayout();
        System.assertEquals('/resource/TrustCardsTheme/TrustCardsTheme/banner.css', cssPath);
    }

    @isTest static void testGetLayout_oneColumn() {
        String layout = 'oneColumn';
        PageReference pageRef = Page.TrustCardPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('layout',layout);
        TrustCardController tc = new TrustCardController();
        String cssPath = tc.getLayout();
        System.assertEquals('/resource/TrustCardsTheme/TrustCardsTheme/oneColumn.css', cssPath);
    }

    @isTest static void testGetLayout_twoColumns() {
        String layout = 'twoColumns';
        PageReference pageRef = Page.TrustCardPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('layout',layout);
        TrustCardController tc = new TrustCardController();
        String cssPath = tc.getLayout();
        System.assertEquals('/resource/TrustCardsTheme/TrustCardsTheme/twoColumns.css', cssPath);
    }

    @isTest static void testGetLayout_custom_notExist() {
        String layout = 'custom';
        PageReference pageRef = Page.TrustCardPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('layout',layout);
        TrustCardController tc = new TrustCardController();
        String cssPath = tc.getLayout();
        System.assertEquals('/resource/TrustCardsTheme/TrustCardsTheme/twoColumns.css', cssPath);
    }
}