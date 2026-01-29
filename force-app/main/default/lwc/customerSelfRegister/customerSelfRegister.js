import { LightningElement, track } from 'lwc';
import wallpaper from '@salesforce/resourceUrl/wallpaper';
import selfRegister from '@salesforce/apex/LightningSelfRegisterController.selfRegister';
import getRegistrationAccountId from '@salesforce/apex/CommunityRegistrationHelper.getRegistrationAccountId';

export default class CustomerSelfRegister extends LightningElement {

    firstName;
    lastName;
    email;
    password;
    confirmPassword;

    @track error;

    handleFirstName(event) { 
        this.firstName = event.target.value;
     }
    handleLastName(event) { 
        this.lastName = event.target.value; 
    }
    handleEmail(event) { 
        this.email = event.target.value; 
    }
    handlePassword(event) {
         this.password = event.target.value; 
        }
    handleConfirmPassword(event) { 
        this.confirmPassword = event.target.value; 
    }
    async handleRegister() {
        this.error = null;

        try {
            const accountId = await getRegistrationAccountId();

            const result = await selfRegister({
                firstname: this.firstName,
                lastname: this.lastName,
                email: this.email,
                password: this.password,
                confirmPassword: this.confirmPassword,
                accountId: accountId,
                regConfirmUrl: '/RegistrationConfirm',
                extraFields: null,
                startUrl: '/AbsyzEcommerce',
                includePassword: true
            });

            if (result) {
                this.error = result;
            }

        } catch (e) {
            console.error(JSON.stringify(e));
            this.error =
                e?.body?.message ||
                e?.body?.pageErrors?.[0]?.message ||
                e?.message ||
                'Registration failed';
        }
    }

    redirectToLogin() {
        window.location.href = '/AbsyzEcommerce/login';
    }
}