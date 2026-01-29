import { api, LightningElement, track } from 'lwc';

export default class CartPage extends LightningElement {
    @api cartItems;
    @track formattedCartItems = [];
    @track totalAmount = 0;
    isCartEmpty = false;
    

    connectedCallback(){
        this.formattedCartItems = this.cartItems.map(item => ({
            ...item,selected:true,
            totalPrice: item.price * item.quantity
        }));
        this.totalAmount = this.formattedCartItems.reduce((total, item) => total + item.totalPrice, 0);
        this.calculateSelectedTotal();

        if(this.formattedCartItems.length === 0){
            this.isCartEmpty = true;
        }

        
     
  }

  get isAllSelected(){
    return this.formattedCartItems.length > 0 && this.formattedCartItems.every(item => item.selected);
  }

  get disableBuyAll(){
    return this.formattedCartItems.filter(item => item.selected).length === 0;
  }

  calculateSelectedTotal(){
    this.totalAmount = this.formattedCartItems.filter(item => item.selected).reduce((total, item) => total + item.totalPrice, 0);
  }
  handleSelectionItem(event){
            const productId = event.target.dataset.id;
            const checked = event.target.checked;
            this.formattedCartItems = this.formattedCartItems.map(item => {
                if(item.id === productId){
                    return {...item, selected: checked};
                }
                return item;
            });
            this.calculateSelectedTotal();

        }

    handleSelectAll(event){
        const checked = event.target.checked;
        this.formattedCartItems = this.formattedCartItems.map(item => ({
            ...item,
            selected: checked
        }));
        this.calculateSelectedTotal();
    }

    handleBuyNow(event){
        const productId = event.target.dataset.id;
        const product = this.cartItems.find(item => item.id == productId);
        this.dispatchEvent(new CustomEvent('buynow', {
    detail:{
        id: product.id,
        name: product.name,
        image: product.image,
        price: Number(product.price),
        quantity: Number(product.quantity)
    },
    bubbles:true,
    composed:true
}));
    }

    handleBuyAll(event){
        const selectedItems = this.formattedCartItems.filter(item => item.selected);
        this.dispatchEvent(new CustomEvent('buyall', {detail:{
            cartItems: selectedItems.map(item => ({
                id: item.id,
                name: item.name,
                image: item.image,
                price: Number(item.price),
                quantity: Number(item.quantity)
            }))
        },
        bubbles:true,
        composed:true
    }));
        }
        
    
}