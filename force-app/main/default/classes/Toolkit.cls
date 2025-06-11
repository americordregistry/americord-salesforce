// Toolkit Class
// Utility methods for Americord Org

public with sharing class Toolkit {

     // compare fields - for use with triggers
     public enum CompareOperation { EQUAL, NOTEQUAL }
    

     // EX: 
     // sObject oldOpp;
     // sObject newOpp;
     // boolean isDifferent = Toolkit.compareFields ( 'StageName', Toolkit.CompareOperation.NOTEQUAL, oldOpp, newOpp );
     
     public static boolean compareFields ( string fieldName, CompareOperation operator, sObject list1, sObject list2 ) {
         // check for null
         if (( list1 == null ) || ( list2 == null )) {
             // we don't have an object to compare
             // TODO: throw exceptipn
         }
         // per operation type
         if ( operator == CompareOperation.EQUAL ) {
             if ( list1.get ( fieldName ) == list2.get ( fieldName )) {
                 return true;
             }
         }
         if ( operator == CompareOperation.NOTEQUAL ) {
             if ( list1.get ( fieldName ) != list2.get ( fieldName )) {
                 return true;
             }
         }
         return false;
     }

    public static Map < string, sObject > indexedSObjectMap ( List < sObject > sobjs, string keyFieldName ) {
        Map < string, sObject > returnMap = new Map < string, sObject > ();

        for ( sObject so : sobjs ) {
            string keyValue = (string) so.get ( keyFieldName );
            returnMap.put ( keyValue, so );
        }

        return returnMap;
    }

}