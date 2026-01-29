import { LightningElement, track } from 'lwc';
import getWalletBalance from '@salesforce/apex/CheckoutController.getWalletBalance';
import addMoneyToWallet from '@salesforce/apex/WalletController.addMoneyToWallet';
import lightningAlert from 'lightning/alert';

export default class WalletPanel extends LightningElement {
    @track walletBalance=0;
    amount = 0;
    card;
    expiry;
    cvv;
    message;
    error;
    isMoney=false;
    


    async connectedCallback(){
        this.loadBalance();
    }

    async loadBalance(){
        try{
            const result = await getWalletBalance();
            this.walletBalance = result;
        }catch(error){
            this.walletBalance = 0;
            this.error = error.body.message;
        }
    }


//     async connectedCallback(){
//         try{
//             this.walletBalance = await getWalletBalance();
//         }catch(error){
//             this.walletBalance = 0;
//             this.error = 'Unable to load Wallet';
//     }
// }



    handleAmount(event){
        this.amount = event.target.value;

    }

    handleCard(event){

        let value = event.target.value;

        value = value.replace(/\D/g, ''); 

        value = value.substring(0,16);

        const formatted = value.replace(/(.{4})/g, '$1 ').trim();

        this.card = formatted;

        event.target.value = formatted;
        // this.card = event.target.value;
    }

    handleExpiry(event){
        this.expiry = event.target.value;
    }

    handleCvv(event){
        this.cvv =event.target.value;
    }

    addMoneyToWallet(){
        this.isMoney = true;
    }

    async addMoney(){

        if(this.isMoney && !this.validateCard()) return;


        if(!this.amount || this.amount <= 0 ){
            this.error = 'Please Enter a valid amount';
            return;
        }
        try{

        this.walletBalance = await addMoneyToWallet({amount:parseFloat(this.amount)});
        this.message = 'Money added Successfuly';
        this.showAlert('Money added Successfully');
        this.isMoney = false;
        }catch(e){
            this.error = e.body.message;

        }
    }

    validateCard(){
        if(!this.card || !this.expiry || !this.cvv){
            this.error = 'Please fill all card details';
            return false;
        }
        return true;
    }

    async showAlert(message, theme = 'success'){
        await lightningAlert.open({
            message: message,
            theme: theme,
            label: 'Message'
        });
    }
}