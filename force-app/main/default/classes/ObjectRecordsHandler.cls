public class ObjectRecordsHandler {

    
    @AuraEnabled(Cacheable=true )
    public Static List<SObject> getObjectRecords(String ObjectName, String searchName){

         String nameFilter = '%' + searchName + '%';
        String query = 'SELECT Id, Name, CreatedDate, LastModifiedDate FROM ' + ObjectName + ' WHERE Name LIKE :nameFilter';
        List<SObject> objectsRecords = Database.query(query);
        System.debug('22 line Records are: ' + objectsRecords);
        return objectsRecords;
    }

    @AuraEnabled(cacheable=true)
    public static list<Account> getAccountRecords(){
        list<Account> accs = [SELECT Id, Name, CreatedDate, LastModifiedDate FROM Account ];
        return accs;
    }

}