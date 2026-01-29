import { LightningElement, track } from 'lwc';
import validateCustomerLogin from '@salesforce/apex/CustomerLoginController.validateCustomerLogin';
import storeLogo from '@salesforce/resourceUrl/StoreLogo';
import logindrop from '@salesforce/resourceUrl/logindrop';



export default class CustomerLoginForm extends LightningElement {

    username = '';
    password = '';
    @track errorMessage;

    handleUsernameChange(event) {
        this.username = event.target.value;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
    }

    async handleLogin() {
        this.errorMessage = null;

        try {
            const result = await validateCustomerLogin({
                username: this.username,
                password: this.password
            });

            if (!result) {
                this.errorMessage = 'Invalid username or password';
                return;
            }

            if (result.startsWith('ERROR:')) {
                this.errorMessage = result.replace('ERROR:', '');
                return;
            }

          
            window.location.href = result;

        } catch (e) {
            this.errorMessage = 'Login failed. Please try again.';
        }
    }

    goToForgotPassword() {
        window.location.href = '/AbsyzEcommerce/ForgotPassword';
    }

    goToRegister() {
        window.location.href = '/AbsyzEcommerce/SelfRegister';
    }
}