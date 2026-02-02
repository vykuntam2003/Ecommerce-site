/**
 * @description Service class to handle Case related operations
 * @author Agentforce
 */
public with sharing class CaseService {
    
    /**
     * @description Get cases created by the current user
     * @return List of Case records
     */
    @AuraEnabled(cacheable=true)
    public static List<Case> getUserCases() {
        try {
            // Get the current user ID
            Id currentUserId = UserInfo.getUserId();
            
            // Query cases where the owner is the current user
            List<Case> userCases = [
                SELECT Id, CaseNumber, Subject, Status, Priority, Origin, CreatedDate, Type, Reason, Product__c
                FROM Case 
                WHERE OwnerId = :currentUserId
                ORDER BY CreatedDate DESC
                LIMIT 50
            ];
            
            return userCases;
        } catch (Exception e) {
            System.debug('Error fetching user cases: ' + e.getMessage());
            return new List<Case>();
        }
    }
}