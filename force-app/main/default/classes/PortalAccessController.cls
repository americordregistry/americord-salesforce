public with sharing class PortalAccessController {
    
    final private String portalAccessLink = null;
    
    public PortalAccessController() {
        final Map<String, String> pageParams = ApexPages.currentPage().getParameters();
        final String basePortalDomain = pageParams.get('isLocal') != null && pageParams.get('isLocal').equals('true') ?  'http://localhost:8080' : ('https://' + pageParams.get('portalDomain'));
        final String path = pageParams.get('path');

        Map<String,String> redirectParams = new Map<String,String>();
        redirectParams.put('userId', UserInfo.getUserId());
        redirectParams.put('sessionId', UserInfo.getSessionId());
        redirectParams.put('serverUrl', URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/c/48.0/' + UserInfo.getOrganizationId());
        for(String parameterKey : pageParams.keySet()) {
            switch on parameterKey {
                when 'isLocal', 'path', 'portalDomain', 'sObjectId' { continue; } 
                when else { redirectParams.put(parameterKey, pageParams.get(parameterKey)); }
            }
        }
        String portalUrlParams = '';
        for(String key : redirectParams.keySet()) {
            portalUrlParams += '&'+key+'='+redirectParams.get(key);
        }
        if(portalUrlParams.length() > 0) portalUrlParams = '?'+portalUrlParams.substring(1, portalUrlParams.length());
        this.portalAccessLink = basePortalDomain + path + portalUrlParams;
    }

    public String getPortalAccessLink() {
        return portalAccessLink;
    }
}