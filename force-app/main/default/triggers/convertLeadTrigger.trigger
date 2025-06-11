trigger convertLeadTrigger on Lead (after update) {

    public static final String STATUS_FOR_CONVERSION = 'Enrolled';
    
    private LeadConversionSettings__c xSettings = LeadConversionSettings__c.getOrgDefaults();
        
    if (xSettings != null && xSettings.Turn_On_Lead_Conversion__c == true) {
        if (Trigger.isAfter) {
            if (Trigger.isUpdate) {
                List<Lead> leadsToConvert = new List<Lead>();
                for (Lead l : Trigger.New) {
                    if (l.Status == STATUS_FOR_CONVERSION && Trigger.oldMap.get(l.Id).Status != STATUS_FOR_CONVERSION) {
                        if (string.isNotEmpty(l.Authorization_ID__c)) {
                        	leadsToConvert.add(l);
                        }
                    }
                }
                
                if (leadsToConvert != null) {
                    if (leadsToConvert.size() > 0) {
                        // Boolean isSuccessful = LeadHelper.convert(leadsToConvert);
                    }
                }
            }
        }
    }
}