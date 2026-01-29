import { LightningElement } from 'lwc';
import getObjectRecords from '@salesforce/apex/ObjectRecordsHandler.getObjectRecords';


export default class ExportObjectRecords extends LightningElement {
    objectName = '';
    name ='';
    
    columnHeader = ['Id','Name', 'CreatedDate','LastModifiedDate'];
    csvFieldAPINames = ['Id','Name', 'CreatedDate','LastModifiedDate'];

   async handleCsvFile() {
    const objectRecords = await getObjectRecords({ObjectName: this.objectName,searchName: this.name});
    console.log('Object Records: ', JSON.stringify(objectRecords));
    let csvHeader = this.columnHeader.toString();
    let csvBody = objectRecords.map(currentItem => {
        console.log('Current Item: ', JSON.stringify(currentItem));
        console.log('Object Values: ', Object.values(currentItem).toString());
        return Object.values(currentItem).toString()});
    
    let csvFile = csvHeader + '\n' + csvBody.join('\n');
    
    const downLink = document.createElement('a');
    downLink.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvFile);
    downLink.download = this.objectName ? this.objectName + '.csv' : '';
    downLink.click();

    this.resetInputs();


    }
    handleObjectChange(event){
        this.objectName = event.target.value;
    }
    handleNameChange(event){
        this.name = event.target.value;
    }

    resetInputs(){
        this.objectName = '';
        this.name = '';
        this.template.querySelectorAll('lightning-input').forEach(input => input.value = '');
    }
}