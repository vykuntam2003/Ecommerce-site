import { LightningElement, track } from 'lwc';
import forgotPassword from '@salesforce/apex/LightningForgotPasswordController.forgotPassword';
import setExperienceId from '@salesforce/apex/LightningForgotPasswordController.setExperienceId';

export default class CustomForgotPassword extends LightningElement {

    username;
    @track error;

    connectedCallback() {
        setExperienceId({ expId: null });
    }

    handleUsername(e) {
        this.username = e.target.value;
    }

    async handleReset() {
        this.error = await forgotPassword({
            username: this.username,
            checkEmailUrl: '/CheckPasswordResetEmail'
        });
    }
}