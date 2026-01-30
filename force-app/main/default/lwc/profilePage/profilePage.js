import { LightningElement, wire, track } from 'lwc';
import getCurrentUserProfile from '@salesforce/apex/UserProfileController.getCurrentUserProfile';

export default class ProfilePage extends LightningElement {
    @track profile;
    @track error;
    loading = true;

    @wire(getCurrentUserProfile)
    wiredProfile({ data, error }) {
        if (data) {
            this.profile = data;
            this.error = undefined;
        } else if (error) {
            // Prefer a friendly string message for display
            this.error = (error && (error.body && error.body.message)) ? error.body.message : 'Unable to load profile.';
            this.profile = undefined;
        }
        this.loading = false;
    }
}
