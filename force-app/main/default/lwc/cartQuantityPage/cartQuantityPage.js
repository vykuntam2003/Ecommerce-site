import { api, LightningElement } from 'lwc';

export default class CartQuantityPage extends LightningElement {
    @api product;

    increase(){
        this.dispatchEvent(new CustomEvent('increase'));
        
    }
    decrease(){
        this.dispatchEvent(new CustomEvent('decrease'));
    }
    closeModal(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}