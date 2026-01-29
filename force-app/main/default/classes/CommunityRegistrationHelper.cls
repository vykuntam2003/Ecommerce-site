public with sharing class CommunityRegistrationHelper {

    @AuraEnabled(cacheable=true)
    public static Id getRegistrationAccountId() {

        List<Account> accs = [
            SELECT Id
            FROM Account
            WHERE Name = 'Absyz Consulting'
            LIMIT 1
        ];

        if (accs.isEmpty()) {
            throw new AuraHandledException('Registration account not found');
        }

        return accs[0].Id;
    }
}