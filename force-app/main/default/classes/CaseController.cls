public with sharing class CaseController {
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getCasesForCurrentUser() {
        // Get the current user ID
        Id currentUserId = UserInfo.getUserId();
        
        // Query cases where the case owner is the current user and status is not resolved/closed
        List<Case> cases = [
            SELECT Id, CaseNumber, Subject, Status, Priority, CreatedDate 
            FROM Case 
            WHERE OwnerId = :currentUserId 
            AND Status != 'Resolved'
            AND Status != 'Closed'
            ORDER BY CreatedDate DESC
        ];
        
        return cases;
    }
}
