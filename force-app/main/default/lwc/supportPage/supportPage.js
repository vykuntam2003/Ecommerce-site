import { LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';

export default class SupportPage extends LightningElement {

    issueOptions = [];
    selectedIssue;

    isMisMatched = false;
    isBillingInquiry = false;

    recordTypeMap = {};

    isLoading = false;

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseObjectInfo({ data, error }) {
        this.isLoading = true;
        if (data) {
            const recordTypes = data.recordTypeInfos;

            this.issueOptions = Object.keys(recordTypes)
                .filter(rtId => recordTypes[rtId].available && recordTypes[rtId].name !== 'Master')
                .map(rtId => {
                    this.recordTypeMap[rtId] = recordTypes[rtId].name;
                    return {
                        label: recordTypes[rtId].name,
                        value: rtId
                    };
                });
            this.isLoading = false;
        }

        if (error) {
            console.error(error);
            this.isLoading = false;
        }
    }

    handleSubmit() {
        this.isLoading = true;
    }

    handleIssueChange(event) {
        this.isLoading = true;
        this.selectedIssue = event.detail.value;

        const selectedName = this.recordTypeMap[this.selectedIssue];

        this.isMisMatched = selectedName === 'MissMatched Items';
        this.isBillingInquiry = selectedName === 'Billing Inquiry';
    }

    handleLoad(){
        this.isLoading = false;
    }

    handleSuccess(event) {
        this.isLoading = false;
        alert('Case Created Successfully! Case ID: ' + event.detail.id);

        this.selectedIssue = null;
        this.isMisMatched = false;
        this.isBillingInquiry = false;
    }
    handleError(event){
        this.isLoading = false;
        alert('Error in case creation: ' + event.detail.message);
    }
}