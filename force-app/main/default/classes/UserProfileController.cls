/**
 * @description Provides current user profile details for LWC Profile page.
 * @group Profile
 * @author Agentforce
 */
public without sharing class UserProfileController {
   
    @AuraEnabled(cacheable=true)
    public static UserProfileDTO getCurrentUserProfile() {
        // Query current user with security enforcement
        User u = [
            SELECT Id, Name, Email, Phone
            FROM User
            WHERE Id = :UserInfo.getUserId()
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        UserProfileDTO dto = new UserProfileDTO();
        dto.userId = u.Id;
        dto.name = u.Name;
        dto.email = u.Email;
        dto.phone = u.Phone;
        return dto;
    }

    /**
     * Simple DTO for sending user profile data to LWC.
     */
    public class UserProfileDTO {
        @AuraEnabled public Id userId;
        @AuraEnabled public String name;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
    }
}