public with sharing class CaseController {
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getCasesForCurrentUser() {
        // Get the current user ID
        user currentUser = [select ContactId, Id from User where Id =: UserInfo.getUserId()];
        
        if(currentUser.ContactId == null){
            return new List<Case>();
        }
        
        // Query the contact ID of the current user
        Contact contact = [select AccountId,Id from Contact where Id =: currentUser.ContactId];
        
        if(contact.AccountId == null){
            return new List<Case>();
        }
        
        // Query cases where the case owner is the current user and status is not resolved/closed
        List<Case> cases = [
            SELECT Id, CaseNumber, Subject, Status, Priority, CreatedDate, AccountId 
            FROM Case 
            WHERE  AccountId = : contact.AccountId
            ORDER BY CreatedDate DESC
        ];
        
        return cases;
    }
}