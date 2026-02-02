public without sharing class PaymentSupabaseSync {
    @future(callout=true)
    public static void syncPayment(Id paymentId){
        Payment_History__c payments = [Select Id, Amount__c, Payment_Date__c,Payment_Type__c,payment_Description__c from Payment_History__c where Id =: paymentId];

        SupabaseService.SupabaseResult res = SupabaseService.createPayment(payments);
        System.debug('Supabase Result: ' + res);

        if(res.success){
            payments.External_Record_Id__c = 'Successfully created with ' + res.supabaseId;
            payments.Connected_Status__c = 'Success';
            

        }else {
            payments.Connected_Status__c ='Failed';
        }
        update payments;

    }

}