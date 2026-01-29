import { LightningElement } from 'lwc';


export default class HamburgerMenu extends LightningElement {

    products=[];
    handleMenuItemClick(event){
        const category = event.target.dataset.id;
        console.log('Category clicked:', category);

        this.dispatchEvent(new CustomEvent('categoryselect', {
            detail: { category },
            bubbles: true,
            composed: true
        }));
        this.closeMenu();
    }
    closeMenu(){
        this.dispatchEvent(new CustomEvent('closemenu', {
            bubbles: true,
            composed: true
        }));
    }

    stopPropagation(event){
        event.stopPropagation();
    }

}