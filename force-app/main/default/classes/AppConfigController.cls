public without sharing class AppConfigController {
    
    public class MaintenanceStatus{
        @AuraEnabled public Boolean isMaintenance{ get; set;}
        @AuraEnabled public String message{get; set;}
    }

    @AuraEnabled(cacheable = true)
    public static MaintenanceStatus getMaintenanceStatus(){
        MaintenanceStatus status = new MaintenanceStatus();
        
        try{
            App_Maintenance_Config__mdt config =[Select Is_Maintenance__c ,Message__c, DeveloperName from App_Maintenance_Config__mdt where DeveloperName = 'Server_Maintenance' limit 1];

            status.isMaintenance = config.Is_Maintenance__c;
            status.message = config.Message__c;
        
        }catch(Exception e){
            status.isMaintenance = false;
            status.message = '';
            System.debug('Error fetching maintennace config ' + e.getMessage());
        }
        return status;
        }

}

    
