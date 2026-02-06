import { LightningElement } from 'lwc';
import getAccountRecords from '@salesforce/apex/ObjectRecordsHandler.getAccountRecords';

export default class ObjectsRecordsDataTable extends LightningElement {

    data;

    columns =[
        {label:'Name', fieldName:'Name'},
        {label:'Created Date', fieldName:'CreatedDate'},
        {label:'Last Modified Date', fieldName:'LastModifiedDate'}
    ];

    connectedCallback(){
        getAccountRecords().then(result => {
            this.data = result;
        }).catch(error => {
            console.log('Error: ' + error);
        });
    }
    

}