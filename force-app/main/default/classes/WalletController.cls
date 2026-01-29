public without sharing class WalletController {
    @AuraEnabled
    public static Decimal addMoneyToWallet(Decimal amount){

        User users =[select ContactId from User where Id =: UserInfo.getUserId() Limit 1];

        if(users.ContactId == null){
            throw new AuraHandledException('No Contact Found');
        }


        Contact con =[Select AccountId from Contact where Id =: users.ContactId];

        if(con.AccountId == null){
            throw new AuraHandledException('No Account Found');
        }

        list<Payment_History__c> paymentHistory = new list<Payment_History__c>();

        Payment_History__c payment = new Payment_History__c();
        payment.Account__c = con.AccountId;
        payment.Amount__c = amount;
        payment.Payment_Date__c = System.now();
        payment.Payment_Type__c = 'Credit Card';
        payment.Connected_Status__c='Pending';
        payment.Payment_Description__c = 'Money added to wallet. The Amount is ' + amount;
        paymentHistory.add(payment);
        try{
        insert paymentHistory;

            EcommerceTrackLogger.logEcommerceTrack('Payment_History__c', payment.Id, 'Successfully Money added to the wallet & transaction is created from the walllet Controller', 'Success');

        // insert new Tracking_Logs__c(Created_Date_Time__c = System.now(),Message__c = 'Wallet Top up Successfully & payment transaction inserted Successfully From WalletController', Related_Object_Id__c = payment.Id, Related_Object_Name__c = 'Payment_History__c',Result__c = 'Success');
        } catch(Exception e){
            EcommerceTrackLogger.logEcommerceTrack('Payment_History__c', '', e.getMessage(), 'Error');
            
            // insert new Tracking_Logs__c(Created_Date_Time__c = System.now(),Message__c = e.getMessage(), Related_Object_Id__c = payment.Id, Related_Object_Name__c = 'Payment_History__c',Result__c = 'Error');
        }
        


        PaymentSupabaseSync.syncPayment(payment.Id);

        // String receipt = 'Wallet Top-Up Receipt\n\n' +
        //                  'Thank you for adding money to your wallet!\n\n' +
        //                  'Amount Added: ₹' + amount + '\n' +
        //                  'Payment Method: Credit Card\n\n' +
        //                  'The top-up was successfully processed on ' + System.now().format('dd-MM-yyyy HH:mm:ss') + '.\n\n' +
        //                  'Payment Confirmation: Your wallet has been successfully credited.\n\n' +
        //                  'We appreciate your business and look forward to serving you again.\n\n' +
        //                  'Best Regards,\nABSYZ Store';

        
        
        String transactionId = 'TOPUP' + String.valueOf(System.now().getTime()).substring(3);
        String receiptNumber = 'WAL' + String.valueOf(System.now().getTime()).substring(5);

        DateTime now = System.now();
        String formattedDate = now.format('dd/MM/yyyy');
        String formattedTime = now.format('HH:mm:ss');

        String receipt = '';
        receipt += '================================================================\n';
        receipt += '                        ABSYZ STORE                             \n';
        receipt += '================================================================\n';
        receipt += '                    WALLET TOP-UP RECEIPT                       \n';
        receipt += '================================================================\n\n';

        receipt += 'Receipt No    : ' + receiptNumber + '\n';
        receipt += 'Date          : ' + formattedDate + '\n';
        receipt += 'Time          : ' + formattedTime + '\n';
        receipt += 'Transaction ID: ' + transactionId + '\n\n';

        receipt += '----------------------------------------------------------------\n';
        receipt += 'TOP-UP DETAILS\n';
        receipt += '----------------------------------------------------------------\n';
        receipt += 'Amount Added  : ₹' + amount.setScale(2).toPlainString() + '\n';
        receipt += 'Payment Mode  : Credit Card\n';
        receipt += 'Status        : SUCCESS\n\n';

        receipt += '----------------------------------------------------------------\n';
        receipt += 'NOTE\n';
        receipt += '----------------------------------------------------------------\n';
        receipt += 'Your wallet has been successfully credited with the above amount.\n';
        receipt += 'Please retain this receipt for future reference.\n\n';

        receipt += '================================================================\n';
        receipt += '                    THANK YOU FOR YOUR TOP-UP!                  \n';
        receipt += '================================================================\n\n';

        receipt += 'For queries, contact us at: support@absyz.com\n';
        receipt += 'Customer Service: +91-1800-XXX-XXXX\n';
        receipt += 'Website: www.absyzstore.com\n\n';

        receipt += '================================================================\n';
        receipt += '                 Generated on ' + formattedDate + ' at ' + formattedTime + '\n';
        receipt += '================================================================\n';

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Wallet_TopUp_Receipt_' + System.now().getTime();
        cv.PathOnClient = 'Wallet_Receipt.txt';
        cv.VersionData = Blob.valueOf(receipt);
        cv.FirstPublishLocationId = payment.Id;
        try{
            insert cv;

        }catch(Exception e){
            EcommerceTrackLogger.logEcommerceTrack('Content Version', '', e.getMessage(), 'Error');
           
            // insert new Tracking_Logs__c(Created_Date_Time__c = System.now(),Message__c = e.getMessage(), Related_Object_Id__c = cv.Id, Related_Object_Name__c = 'Content Version',Result__c = 'Error');
        }
        

        ContentDistribution dist = new ContentDistribution();
        dist.Name = 'Wallet Receipt ';
        dist.ContentVersionId = cv.Id;
        dist.PreferencesAllowViewInBrowser = true;
        dist.PreferencesAllowOriginalDownload = true;
        dist.PreferencesLinkLatestVersion = true;
        try{
            insert dist;

        }catch(Exception e){
            EcommerceTrackLogger.logEcommerceTrack('Content Version', '', e.getMessage(), 'Error');
           
            // insert new Tracking_Logs__c(Created_Date_Time__c = System.now(),Message__c = e.getMessage(), Related_Object_Id__c = dist.Id, Related_Object_Name__c = 'Content Distribution',Result__c = 'Error');
        }
        

        dist = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id = :dist.Id];

        payment.Receipt_Public_URL__c = dist.DistributionPublicUrl;
        try{
            update payment;
           
            // insert new Tracking_Logs__c(Created_Date_Time__c = System.now(),Message__c = 'Reciept Updated from the distribution in the wallet controller', Related_Object_Id__c = payment.Id, Related_Object_Name__c = 'Payment_History__c',Result__c = 'Success');

        }catch(Exception e){
            EcommerceTrackLogger.logEcommerceTrack('Person Account', '', e.getMessage(), 'Error');
           
            // insert new Tracking_Logs__c(Created_Date_Time__c = System.now(),Message__c = e.getMessage(), Related_Object_Id__c = payment.Id  , Related_Object_Name__c ='payment_History__c',Result__c = 'Error');
        }
        

        Account acc =[Select Wallet_Balance__pc from Account where Id =: con.AccountId];

        if(acc.Wallet_Balance__pc == null) {
            acc.Wallet_Balance__pc = 0;
        }
        
        acc.Wallet_Balance__pc += amount;
        try{
            update acc; 
        

            // insert new Tracking_Logs__c(Created_Date_Time__c = System.now(),Message__c = 'Wallet Top up Successfully in the wallet controller ', Related_Object_Id__c = acc.Id, Related_Object_Name__c = 'Person Account',Result__c = 'Success');

        }catch(Exception e){
            EcommerceTrackLogger.logEcommerceTrack('Person Account', '', e.getMessage(), 'Error');
           
            // insert new Tracking_Logs__c(Created_Date_Time__c = System.now(),Message__c = e.getMessage(), Related_Object_Id__c = acc.Id, Related_Object_Name__c = 'Person Account',Result__c = 'Error');
        }

        EcommerceTrackLogger.logEcommerceTrack('Payment_History__c', payment.Id, 'Succesfully updated the reciept in the payment transaction in the wallet controller', 'Success');
        EcommerceTrackLogger.logEcommerceTrack('Person Account', acc.Id, 'Successfully added money to the wallet & transaction created in the wallet Controller', 'Success');
        return acc.Wallet_Balance__pc;
    }
}