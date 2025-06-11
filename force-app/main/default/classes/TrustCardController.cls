//Please follow the secrity rules when edit the controller. https://help.salesforce.com/articleView?id=review_and_certification.htm&type=5
public with sharing class TrustCardController {
    private final List<LocationTrustMeasure> items;
    private String layout;
    private String location;
    private static final String BANNER = 'banner';
    private static final String ONECOLUMN = 'oneColumn';
    private static final String TWOCOLUMNS = 'twoColumns';
    private static final String CUSTOM = 'custom';
    private static final Set<String> validLayouts = new Set<String>(new String[] {BANNER, ONECOLUMN, TWOCOLUMNS, CUSTOM});
    private boolean isLocationBlank;
    public TrustCardController() {
        location = ApexPages.currentPage().getParameters().get('location');
        isLocationBlank = String.isBlank(location);

        if(!isLocationBlank){
                items = [SELECT Title,
                        Description,
                        IconUrl,
                        LocationExternalReference
                FROM LocationTrustMeasure
                WHERE LocationExternalReference = :location
                ORDER BY SortOrder ASC NULLS LAST, LastModifiedDate DESC];
        }else{
            items = new List<LocationTrustMeasure>();
        }

        layout = ApexPages.currentPage().getParameters().get('layout');

        //Validte the url parameter layout.
        if (!validLayouts.contains(layout)) {
            layout = TWOCOLUMNS;
        }
    }

    // Indicate if location parameter is valid
    public boolean getIsLocationBlank(){
        return isLocationBlank;
    }

    // Visual force page TrustCardPage will call this method to get all the items.
    public List<LocationTrustMeasure> getItems() {
        return items;
    }

    // Only show Apex page when has items.
    public Boolean getHasItems(){
        return items.size()>0;
    }

    // Visual force page TrustCardPage will call this method to get css.
    public String getLayout() {
        //User can upload their custom.css into static resource. And pass in layout=custom in query string
        if(layout == CUSTOM) {
            String customUrl = '/resource/' + CUSTOM;
                try {
                    new PageReference(customUrl).getContent();
                    return '/resource/' + layout;
                } catch(VisualforceException e) {
                    //if custom layout doesn't exist in static resource, use two columns' layout
                    return '/resource/TrustCardsTheme/TrustCardsTheme/' + TWOCOLUMNS + '.css';
                }
        }
        //Otherwise use default css provided by us.
        return '/resource/TrustCardsTheme/TrustCardsTheme/' + layout + '.css';
    }
}