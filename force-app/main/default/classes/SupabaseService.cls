public without sharing class SupabaseService {
    private static final String SUPABASE_KEY ='sb_secret_kNOVj1M7BsnaBVXJwUHIGA_UbyXTouM';

    public class SupabaseResult {
        public Boolean success;
        public String supabaseId;
        public String error;

    }

    public static SupabaseResult createPayment(Payment_History__c pay){
        SupabaseResult result = new SupabaseResult();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Supabase_NC/rest/v1/payments');
        req.setMethod('POST');

        req.setHeader('Content-Type', 'application/json');
        req.setHeader('apikey', SUPABASE_KEY);
        req.setHeader('Authorization', 'Bearer ' + SUPABASE_KEY);
        req.setHeader('Prefer', 'return=representation');

        map<String, Object> body = new map<String, Object>();
        body.put('salesforce_payment_id', pay.Id);
        body.put('amount', pay.Amount__c);
        body.put('payment_date', pay.Payment_Date__c);
        body.put('description',pay.Payment_Description__c);
        body.put('payment_type', pay.Payment_Type__c);
        

        req.setBody(JSON.serialize(body));

        try{
            Http http = new Http();
            HttpResponse res = http.send(req);
           
            if(res.getStatusCode()==200 || res.getStatusCode() == 201){
                List<Object> rows = (List<Object>) JSON.deserializeUntyped(res.getBody());

                if(!rows.isEmpty()){
                    Map<String,Object> row = (Map<String,Object>) rows[0];
                    result.success = true;
                    result.supabaseId = (String) row.get('id');
                }
                else {
                    result.success = false;
                    result.error = res.getBody();
                }
            }
        }catch(Exception e){
            result.success = false;
            result.error = e.getMessage();
        }

        return result;
        
    }
}