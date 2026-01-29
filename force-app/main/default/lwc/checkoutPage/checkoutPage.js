import { api, LightningElement } from 'lwc';
// import getWalletBalance from '@salesforce/apex/CheckoutController.getWalletBalance';
import placeOrder from '@salesforce/apex/CheckoutController.placeOrder';
// import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class CheckoutPage extends LightningElement {
    @api product;
    @api products=[];
    cardNumber;
    expiry;
    cvv;

    totalAmount = 0;
    paymentMethod = '';
    error;
    isDisabled=true;

    paymentOptions=[
        {label:'Wallet', value:'Wallet'},
        {label:'Credit Card', value:'Credit Card'},
        {label:'Debit Card', value:'Debit Card'}
    ];

    connectedCallback(){
        // if(this.product){
        //     this.totalAmount = Number(this.product.price) * Number(this.product.quantity || 1);
        // }
        this.calculateTotal();
    }

    get hasSingleProduct(){
        return !!this.product;
    }
    get hasMultipleProducts(){
        return this.products && this.products.length > 0;
    }
    

    calculateTotal(){
        if(this.products && this.products.length > 0){
            this.totalAmount = this.products.reduce((sum,item)=> sum +(Number(item.price) * Number(item.quantity || 1)),0);
            return;
        }
        if(this.product){
            this.totalAmount = Number(this.product.price) * Number(this.product.quantity || 1);
            return;
        }
        this.totalAmount = 0;
        
    }

    handlePaymentChange(event){
        this.paymentMethod = event.detail.value;
        if(this.paymentMethod != ''){
            this.isDisabled = false;
        }
        
    }

    async pay(){
        if(this.isCard && !this.validateCard()) return;
    
        this.error = null;
        // const productName = this.product?.name ? this.product.name : 'Products';
        let productName = 'Products';
        if(this.product?.name){
            productName = this.product.name;
        }
        if(this.hasMultipleProducts){
            productName = this.products.map(item=>item.name).join(', ');
        }
        try{
        const result =await placeOrder({
            totalAmount: this.totalAmount,
            paymentMethod: this.paymentMethod, productName: productName
        });
        
        if(result.startsWith('ERROR')){
            this.error = result.replace('ERROR:','');
        }else{
            // this.dispatchEvent(new ShowToastEvent({
            //     title:'Success',
            //     message:'Order Placed Successfully',
            //     variant:'success'
            // }));
            this.dispatchEvent(new CustomEvent('showtoast',{detail:{title: 'Success', message: 'Order Placed Successfully', variant: 'success'},bubbles: true, composed: true}));
            this.dispatchEvent(new CustomEvent('cancel'));
            this.dispatchEvent(new CustomEvent('orderplaced'));
        }
    }catch(error){
        this.error = 'payment failed';
    }
    }

    cancel(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }
    
    get isCard(){
        return this.paymentMethod === 'Credit Card' || this.paymentMethod === 'Debit Card';
    }

    validateCard(){
        if(!this.cardNumber || !this.expiry || !this.cvv){
            this.error = 'Please fill all card details';
            return false;
        }
        return true;
    }

    handleCard(event){

        let value = event.target.value;

        value = value.replace(/\D/g, ''); 

        value = value.substring(0,16);

        const formatted = value.replace(/(.{4})/g, '$1 ').trim();

        this.cardNumber = formatted;

        event.target.value = formatted;
        // const cleaned = event.target.value.replace(/\D/g, '');
        // this.cardNumber = cleaned;
        // event.target.value = cleaned;
    }
    handleExpiry(event){
        this.expiry = event.target.value;
    }

    handleCvv(event){
        this.cvv =event.target.value;
    }

}