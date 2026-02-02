import { LightningElement, wire, track } from 'lwc';
import getCasesForCurrentUser from '@salesforce/apex/CaseController.getCasesForCurrentUser';
import { refreshApex } from '@salesforce/apex';

export default class MyCases extends LightningElement {
    @track cases;
    @track error;
    @track loading = true;
    @track noCases = false;
    
    wiredCasesResult;

    @wire(getCasesForCurrentUser)
    wiredCases(result) {
        this.wiredCasesResult = result;
        if (result.data) {
            this.cases = result.data;
            this.error = undefined;
            this.noCases = result.data.length === 0;
        } else if (result.error) {
            this.error = (result.error && (result.error.body && result.error.body.message)) ? result.error.body.message : 'Unable to load cases.';
            this.cases = undefined;
            this.noCases = false;
        }
        this.loading = false;
    }

    // Method to refresh cases data
    refreshCases() {
        refreshApex(this.wiredCasesResult);
    }

    // Lifecycle method to refresh data when component is loaded/activated
    connectedCallback() {
        this.refreshCases();
    }
}