/**
* CustomMetadataService
* ------------------
* @author jdseibert
*/
public class CustomMetadataService {
    @testVisible public static List<Americord_Docusign_Templates__mdt> lstDocusignTemplates;
    @testVisible public static List<Discount_Code__mdt> lstDiscountCodes;

    public static List<Americord_Docusign_Templates__mdt> getAllDocusignTemplates(){
        if (lstDocusignTemplates == null){
            lstDocusignTemplates = Americord_Docusign_Templates__mdt.getAll().values();
        }
        return lstDocusignTemplates;
    }    

    public static Map<String,Americord_Docusign_Templates__mdt> getMapDocusignTemplates(){
        Map<String,Americord_Docusign_Templates__mdt> mapDocusignTemplates = new Map<String,Americord_Docusign_Templates__mdt>();
        if (lstDocusignTemplates == null){
            lstDocusignTemplates = Americord_Docusign_Templates__mdt.getAll().values();
        }

        for(Americord_Docusign_Templates__mdt dt: lstDocusignTemplates){
            mapDocusignTemplates.put(dt.developername,dt);
        }

        return mapDocusignTemplates;
    }    

    public static List<Discount_Code__mdt> getAllDiscountCodes(){
        if (lstDiscountCodes == null){
            lstDiscountCodes = Discount_Code__mdt.getAll().values();
        }
        return lstDiscountCodes;
    }

    public static Map<String,Discount_Code__mdt> getMapDiscountCodes(){
        Map<String,Discount_Code__mdt> mapDiscountCodes = new Map<String,Discount_Code__mdt>();
        if (lstDiscountCodes == null){
            lstDiscountCodes = Discount_Code__mdt.getAll().values();        
        }
        for(Discount_Code__mdt disc: lstDiscountCodes){
            mapDiscountCodes.put(disc.DeveloperName,disc);
        }

        return mapDiscountCodes;
    }       
        
}