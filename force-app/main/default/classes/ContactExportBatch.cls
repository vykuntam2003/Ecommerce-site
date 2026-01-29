public class ContactExportBatch implements Database.Batchable<SObject>, Database.Stateful {

    // public List<Contact> allContacts = new List<Contact>();

    // public Database.QueryLocator start(Database.BatchableContext BC) {
    //     return Database.getQueryLocator([SELECT Id, Name, Email, Phone, Title, Description FROM Contact]);
    // }
    // public void execute(Database.BatchableContext BC, List<Contact> scope) {
      
    //     allContacts.addAll(scope);
    // }
    // public void finish(Database.BatchableContext BC) {

    //     System.debug('Total Contacts to Export: ' + allContacts.size());
    // }

     public String objectName;
    public String csvData = 'Id,Name,CreatedDate,LastModifiedDate\n';

    public ContactExportBatch(String objName) {
        this.objectName = objName;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, CreatedDate, LastModifiedDate FROM ' + objectName;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        for (SObject records : scope) {
            csvData +=
                String.valueOf(records.get('Id')) + ',' +
                String.valueOf(records.get('Name')) + ',' +
                String.valueOf(records.get('CreatedDate')) + ',' +
                String.valueOf(records.get('LastModifiedDate')) + '\n';
        }
    }

    public void finish(Database.BatchableContext bc) {
        ContentVersion file = new ContentVersion();
        file.Title = objectName;
        file.PathOnClient = objectName + '.csv';
        file.VersionData = Blob.valueOf(csvData);
        insert file;
    }

}