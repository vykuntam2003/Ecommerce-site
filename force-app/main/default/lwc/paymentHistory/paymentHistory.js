import { LightningElement, track, wire } from 'lwc';
import getPaymentHistory from '@salesforce/apex/PaymentHistoryController.getPaymentHistory';
import {refreshApex} from '@salesforce/apex';

export default class PaymentHistory extends LightningElement {

    @track records=[];
    isData = false;


    connectedCallback(){
        this.refresh();
    }


    columns = [
        {label: 'Payment Transaction Id', fieldName:'Name', hideDefaultActions:true},
        {label:'Payment Type', fieldName:'Payment_Type__c',hideDefaultActions:true},
        {label:'Amount', fieldName:'Amount__c',hideDefaultActions:true},
        {label:'Payment Date', fieldName:'Payment_Date__c',hideDefaultActions:true},
        {label:'Payment Description', fieldName:'Payment_Description__c',hideDefaultActions:true},
        {label:'Connected Status', fieldName:'Connected_Status__c',hideDefaultActions:true},
        {label:'External Id', fieldName:'External_Record_Id__c',hideDefaultActions:true},
        {label:'Payment Receipt', type:'button', hideDefaultActions:true, typeAttributes:{ label:'view Receipt', name:'view_receipt', variant:'base'}}

    ];

    @wire (getPaymentHistory)
    wiredPayments(result){
        this.wiredResult = result;
        console.log('result',JSON.stringify(result));
        if(result.data){
            this.records = result.data;
            if(this.records.length > 0){
                console.log('records',JSON.stringify(this.records));
                this.isData =true;
                console.log('inside if',this.isData);
            }
            
            
        }else{
            this.isData = false;
            console.log('inside',this.isData);
        }
    }

    refresh(){
        console.log('refresh');
        refreshApex(this.wiredResult);
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('actionName',actionName);
        console.log('row',JSON.stringify(row));

        if(actionName === 'view_receipt'){
            this.downloadReceipt(row);
        }
    }

    downloadReceipt(row){
    //     const docId = row.ContentDocumentId;
    //     console.log('docId',docId);
    //     if(!docId){
    //         alert('No receipt available for these transaction');
    //         return;
    //     }

    //     const downloadUrl =`${window.location.origin}/sfc/servlet.shepherd/version/download/${docId}`;
    //     window.open(downloadUrl,'_blank');

    // const versionId = row.ContentVersionId;
    // console.log('versionId',versionId);
    // if(!versionId){
    //     alert('No receipt available for these transaction');
    //     return;
    // }
    // const downloadUrl =`${window.location.origin}/sfc/servlet.shepherd/version/download/${versionId}`;
    // window.open(downloadUrl,'_blank');
    const url = row.ReceiptUrl;
    console.log('url',url);
    if(!url){
        alert('No receipt available for these transaction');
        return;
    }
    window.open(url,'_blank');

    }

    

}