public without sharing class EcommerceTrackLogger {
    @future
    public static void logEcommerceTrack(String relatedObject, String relatedObjectId,  String message, String result){
        try{
            Ecommerce_Track_Logs__b logs = new Ecommerce_Track_Logs__b();
            logs.Action_Date__c = System.now();
            logs.Related_Object__c = relatedObject;
            logs.Record_Id__c = relatedObjectId;
            logs.Message__c = message;
            logs.Result__c = result;

            Database.insertImmediate(logs);
        }catch(Exception e){
            System.debug('Error' + e.getMessage());
        }
    }
}