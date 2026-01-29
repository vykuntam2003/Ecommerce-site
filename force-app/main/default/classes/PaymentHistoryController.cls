public without sharing class PaymentHistoryController {

    @AuraEnabled(cacheable =true)
    public static List<Map<String,Object>> getPaymentHistory() {
        
        User users = [Select ContactId from User where Id =: UserInfo.getUserId()];

        if(users.ContactId == null){
            return new List<Map<String,Object>>();
        }


        Contact con =[Select AccountId from Contact where Id =: users.ContactId];
        if(con.AccountId == null){
            return new List<Map<String,Object>>();
        }

        list<Payment_History__c> payments = [Select Id, Name, Amount__c, Payment_Date__c, Payment_Type__c,Payment_Description__c,Connected_Status__c,External_Record_Id__c, Receipt_Public_URL__c from Payment_History__c where Account__c =: con.AccountId order by Payment_Date__c desc];

        set<Id> paymentIds = new set<Id>();
        for(Payment_History__c pay : payments){
            if(pay.Id != null){
                paymentIds.add(pay.Id);
            }
        }
        
        // map<Id,Id> paymentToContentMap = new map<Id,Id>();
        // for(ContentDocumentLink cdl : [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN : paymentIds]){
        //     if(cdl.LinkedEntityId != null && cdl.ContentDocumentId != null){
        //         paymentToContentMap.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
        //     }
            
        // }

        // Map<Id,Id> paymentToVersionMap = new Map<Id,Id>();
        // for(ContentDocumentLink cdl : [Select LinkedEntityId, ContentDocument.LatestPublishedVersionId from ContentDocumentLink where LinkedEntityId IN : paymentIds]){
        //     if(cdl.LinkedEntityId != null && cdl.ContentDocument.LatestPublishedVersionId != null){
        //         paymentToVersionMap.put(cdl.LinkedEntityId, cdl.ContentDocument.LatestPublishedVersionId);
        //     }
        // }

        list<map<String,Object>> data = new list<map<String,Object>>();

        for(Payment_History__c payment : payments){
            Map<String, Object> row = new Map<String,Object>();
            row.put('Name',payment.Name);
            row.put('Amount__c',payment.Amount__c);
            row.put('Payment_Date__c',payment.Payment_Date__c);
            row.put('Payment_Type__c',payment.Payment_Type__c);
            row.put('Payment_Description__c',payment.Payment_Description__c);
            row.put('Id', payment.Id);
            row.put('Connected_Status__c', payment.Connected_Status__c);
            row.put('External_Record_Id__c', payment.External_Record_Id__c);

            row.put('ReceiptUrl', payment.Receipt_Public_URL__c);
            data.add(row);
        }
        return data;


        // return [Select Id, Name, Amount__c, Payment_Date__c, Payment_Type__c,Payment_Description__c from Payment_History__c where Account__c =: con.AccountId order by Payment_Date__c desc];



    }
}