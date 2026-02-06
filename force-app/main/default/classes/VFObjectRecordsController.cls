public without sharing class VFObjectRecordsController {

    public List<Account> accountList {get; set;}

    public VFObjectRecordsController() {
        accountList = [SELECT Id, Name, CreatedDate,LastModifiedDate FROM Account];

    }
}