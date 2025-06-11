@isTest(seeAlldata=true)
public with sharing class PortalAccessController_Test {
    public static testMethod void PortalAccessController_Test() {
        PageReference pageReferenceNoIndex = Page.portalAccessLoginAsUserRedirect;
        Test.setCurrentPage(pageReferenceNoIndex);
        System.currentPageReference().getParameters().put('path', '/testing');
        System.currentPageReference().getParameters().put('portalDomain', 'carsontest.cloud4j.com');
        System.currentPageReference().getParameters().put('wizardName', 'addSleeves');
        System.currentPageReference().getParameters().put('caseId', 'test1234');
        PortalAccessController portalAccessController = new PortalAccessController();
        portalAccessController.getPortalAccessLink();
    }
}