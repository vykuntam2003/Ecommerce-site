public without sharing class CheckoutController {
    @AuraEnabled
    public Static Decimal getWalletBalance(){

        User users = [select ContactId, Email from User where Id =: UserInfo.getUserId()];
        if(users.ContactId == null) return 0;
        Contact con = [select AccountId from Contact where Id =: users.ContactId];
        if(con.AccountId == null) return 0;
        Account acc =[select Wallet_Balance__pc from Account where Id =: con.AccountId];

        return acc.Wallet_Balance__pc == null ? 0: acc.Wallet_Balance__pc;

    }

    @AuraEnabled
    public Static String placeOrder(Decimal totalAmount, String paymentMethod, String productName){

        String paymentType = paymentMethod == null ? 'Wallet' : paymentMethod;

        User users = [select ContactId,Email from User where Id =: UserInfo.getUserId()];
        Contact con =[select AccountId from Contact where Id =:users.ContactId];
        Account acc = [select Wallet_Balance__pc,PersonEmail From Account where Id =: con.AccountId];

        if(paymentMethod != null && paymentMethod.toLowerCase().trim() == 'wallet'){

            if(acc.Wallet_Balance__pc < totalAmount || acc.Wallet_Balance__pc == null){
                return 'ERROR: Insufficient Balance';
            }
            acc.Wallet_Balance__pc -= totalAmount;
            update acc;
        }

        // Invoice inv = new Invoice(BillingAccountId = acc.Id,	InvoiceDate= Date.today());
        // insert inv;

        list<Payment_History__c> paymentHistory = new list<Payment_History__c>();

        Payment_History__c payment = new Payment_History__c();
        payment.Account__c = con.AccountId;
        payment.Amount__c = totalAmount;
        payment.Payment_Date__c = System.now();
        payment.Payment_Type__c = paymentType;
        payment.Connected_Status__c = 'pending';
        payment.Payment_Description__c = 'Money is debited from  ' + paymentType;
        paymentHistory.add(payment);

        insert paymentHistory;


        // String receipt = 'Payment Receipt\n\n' +
        //                  'Thank you for your purchase!\n\n' +
        //                  'Product: '+ productName + '\n' +
        //                  'Amount Paid: ₹' + totalAmount + '\n' +
        //                  'Payment Method: ' + paymentType + '\n\n' +
        //                  'payment has been successfully processed on ' + System.now().format('dd-MM-yyyy HH:mm:ss') + '.\n\n' +
        //                  'Payment Confirmation: Your payment has been successfully processed.\n\n' +
        //                  'And Money debited from ' + paymentType + '.\n\n' +
        //                  'We appreciate your business and look forward to serving you again.\n\n' +
        //                  'Best Regards,\nABSYZ Store';

        // ✅ Generate Receipt
        String transactionId = 'TXN' + String.valueOf(System.now().getTime()).substring(3);
        String receiptNumber = 'RCP' + String.valueOf(System.now().getTime()).substring(5);

        DateTime now = System.now();
        String formattedDate = now.format('dd/MM/yyyy');
        String formattedTime = now.format('HH:mm:ss');

        String receipt = '';
        receipt += '================================================================\n';
        receipt += '                        ABSYZ STORE                             \n';
        receipt += '================================================================\n';
        receipt += '                      PAYMENT RECEIPT                           \n';
        receipt += '================================================================\n\n';

        receipt += 'Receipt No    : ' + receiptNumber + '\n';
        receipt += 'Date          : ' + formattedDate + '\n';
        receipt += 'Time          : ' + formattedTime + '\n';
        receipt += 'Transaction ID: ' + transactionId + '\n\n';

        receipt += '----------------------------------------------------------------\n';
        receipt += 'CUSTOMER DETAILS\n';
        receipt += '----------------------------------------------------------------\n';
        receipt += 'Email         : ' + acc.PersonEmail + '\n\n'; 

        receipt += '----------------------------------------------------------------\n';
        receipt += 'ORDER DETAILS\n';
        receipt += '----------------------------------------------------------------\n';
        receipt += 'Product       : ' + productName + '\n';
        receipt += 'Amount        : ₹' + totalAmount.setScale(2).toPlainString() + '\n\n';

        receipt += '----------------------------------------------------------------\n';
        receipt += 'PAYMENT SUMMARY\n';
        receipt += '----------------------------------------------------------------\n';
        receipt += 'Subtotal      : ₹' + totalAmount.setScale(2).toPlainString() + '\n';
        receipt += 'Tax           : ₹0.00\n';
        receipt += 'Discount      : ₹0.00\n';
        receipt += '                ----------------------------------------\n';
        receipt += 'TOTAL PAID    : ₹' + totalAmount.setScale(2).toPlainString() + '\n';
        receipt += 'Payment Mode  : ' + paymentType + '\n';
        receipt += 'Status        : SUCCESS\n\n';

        receipt += '================================================================\n';
        receipt += '                    THANK YOU FOR YOUR PURCHASE!                \n';
        receipt += '================================================================\n\n';

        receipt += 'This is a computer-generated receipt and does not require a\n';
        receipt += 'signature. Please retain this receipt for your records.\n\n';

        receipt += 'For queries, contact us at: support@absyz.com\n';
        receipt += 'Customer Service: +91-1800-XXX-XXXX\n';
        receipt += 'Website: www.absyzstore.com\n\n';

        receipt += '================================================================\n';
        receipt += '                 Generated on ' + formattedDate + ' at ' + formattedTime + '\n';
        receipt += '================================================================\n';

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Payment_Receipt_' + System.now().getTime();
        cv.PathOnClient = 'Receipt.txt';
        cv.VersionData = Blob.valueOf(receipt);
        cv.FirstPublishLocationId = payment.Id;
        insert cv;

        ContentDistribution dist = new ContentDistribution();
        dist.Name = 'Payment Receipt ';
        dist.ContentVersionId = cv.Id;
        dist.PreferencesAllowViewInBrowser = true;
        dist.PreferencesAllowOriginalDownload = true;
        dist.PreferencesLinkLatestVersion = true;
        insert dist;

        dist = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id = :dist.Id];

        payment.Receipt_Public_URL__c = dist.DistributionPublicUrl;

        update payment;

        // Id docId =[SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;

        // insert new ContentDocumentLink(
        //     ContentDocumentId = docId,
        //     LinkedEntityId = payment.Id,
        //     ShareType = 'V',
        //     Visibility = 'AllUsers'
            
        // );


        OrgWideEmailAddress[] owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'karthik.vykuntam@absyz.com' LIMIT 1];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       if(owea.size() > 0){
            mail.setOrgWideEmailAddressId(owea[0].Id);
       }
        mail.setToAddresses(new String[]{acc.PersonEmail });
        System.debug('Email Address: ' + acc.PersonEmail);
        System.debug('mail to address:' + mail.getToAddresses());
        mail.setSubject('Order Confirmation');
        mail.setPlainTextBody(
    'Hello Customer,' + '\n\n' +

    'Thank you for shopping with ABSYZ Store!' + '\n' +
    'Your order has been placed successfully and the payment is confirmed.' + '\n\n' +

    '==================== ORDER DETAILS ====================' + '\n' +
    'Product Name   : ' + productName + '\n' +
    'Amount Paid    : ₹' + totalAmount.setScale(2) + '\n' +
    'Payment Mode   : ' + paymentType + '\n' +
    'Order Date     : ' + System.now().format('dd-MM-yyyy') + '\n' +
    'Order Time     : ' + System.now().format('HH:mm:ss') + '\n' +
    'Status         : SUCCESS' + '\n' +
    '=======================================================' + '\n\n' +

    'If you have any questions, please contact our support team.' + '\n\n' +

    'Regards,' + '\n' +
    'ABSYZ Store Team' + '\n' +
    'Email: ' + owea[0].Address + '\n' +
    'Customer Care: +91-1800-XXX-XXXX'
);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        System.debug('mail sent'+ mail);


        PaymentSupabaseSync.syncPayment(payment.Id);

        
        return 'Order Placed Successfully';

    
    }

    


}