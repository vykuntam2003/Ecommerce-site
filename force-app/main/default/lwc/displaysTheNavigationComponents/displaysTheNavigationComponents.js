import { LightningElement, track, wire } from 'lwc';
import isGuest from '@salesforce/user/isGuest';
// import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import lightningAlert from 'lightning/alert';
import getMaintenanceStatus from '@salesforce/apex/AppConfigController.getMaintenanceStatus';


const PAGE_HOME = 'home';
const PAGE_PRODUCTS = 'products';
const PAGE_PRODUCT = 'product';
const PAGE_SUPPORT = 'support';
const PAGE_CART = 'cart';
const PAGE_WALLET = 'wallet';
const PAGE_CHECKOUT = 'checkout';
const PAGE_PAYMENTS = 'payments';
const PAGE_PROFILE = 'profile';

export default class DisplaysTheNavigationComponents extends LightningElement {

    isHome = true;
    isProducts = false;
    isProductDetails = false;
    isSupport = false;
    isCart = false;
    isWallet = false;
    checkoutItem;
    checkoutItems = [];
    isCheckout = false;
    isPayments=false;
    isHamburgerMenuOpen=false;
    isProfileMenuOpen = false;

    @track isMaintenance = false;
    @track maintenanceMessage ='';

    // productsKey=0;

    selectedProduct;
    selectedCategory;
    @track cartItems = [];

    showCartPopup = false;
    popupItem;

    redirectDone = false;

    @wire(getMaintenanceStatus)
    wiredMaintennance({data,error}){
        if(data){
            this.isMaintenance = data.isMaintenance;
            this.maintenanceMessage = data.message;
        }else if(error){
            this.isMaintenance = false;
            console.error('Error: fecthing maintenance status', error);
        }
    }

    // Profile menu handlers
    toggleProfileMenu() {
        this.isProfileMenuOpen = !this.isProfileMenuOpen;
    }

    closeProfileMenu() {
        this.isProfileMenuOpen = false;
    }

    handleProfileDetails() {
        // Navigate to in-app Profile page (LWC)
        this.closeProfileMenu();
        this.resetVariables();
        // show profile page in shell
        this.isProfile = true;
        window.history.pushState({ page: PAGE_PROFILE }, '', '');
    }



    connectedCallback() {
        
        window.history.replaceState({ page: PAGE_HOME }, '', '');

        
        window.onpopstate = (event) => {
            if (event.state) {
                this.restorePage(event.state.page, event.state.data);
            }
        };
    }

    renderedCallback() {
        if (this.redirectDone) return;

        const path = window.location.pathname;
        if (
            isGuest &&
            !path.includes('/login') &&
            !path.includes('/SelfRegister') &&
            !path.includes('/ForgotPassword')
        ) {
            this.redirectDone = true;
            window.location.replace('/AbsyzEcommerce/login');
        }
    }


    resetVariables() {
        this.isHome = false;
        this.isProducts = false;
        this.isProductDetails = false;
        this.isSupport = false;
        this.isCart = false;
        this.isWallet = false;
        this.isCheckout = false;
        this.isPayments=false;
        this.isHamburgerMenuOpen = false;
        this.isProfile = false;
    }

    restorePage(page, data) {
        this.resetVariables();

        switch (page) {
            case PAGE_HOME:
                this.isHome = true;
                break;

            case PAGE_PRODUCTS:
                this.isProducts = true;
                break;

            case PAGE_PRODUCT:
                this.selectedProduct = data;
                this.isProductDetails = true;
                break;

                
            case PAGE_SUPPORT:
                this.isSupport = true;
                break;

            case PAGE_CART:
                this.isCart = true;
                break;

            
            case PAGE_WALLET:
                this.isWallet = true;
                break;
            
            case PAGE_CHECKOUT:
                this.isCheckout = true;
                break;

            
            case PAGE_PAYMENTS:
                this.isPayments = true;
                break;

            case PAGE_PROFILE:
                this.isProfile = true;
                break;
        }
    }

    

    navigateToHomePage() {
        this.resetVariables();
        this.isHome = true;
        window.history.pushState({ page: PAGE_HOME }, '', '');
    }
    navigateToWallet(){
        this.resetVariables();
        this.isWallet = true;
        window.history.pushState({ page: PAGE_WALLET }, '', '');
    }

    navigationToProducts() {
        this.resetVariables();
        this.isProducts = true;
        this.selectedCategory = '';
        // this.productsKey++;
        window.history.pushState({ page: PAGE_PRODUCTS }, '', '');
    }

    navigationToSupport() {
        this.resetVariables();
        this.isSupport = true;
        window.history.pushState({ page: PAGE_SUPPORT }, '', '');
    }

    navigateToCart() {
        this.resetVariables();
        this.isCart = true;
        window.history.pushState({ page: PAGE_CART }, '', '');
    }

    navigateToPayments(){
        this.resetVariables();
        this.isPayments = true;
        window.history.pushState({ page: PAGE_PAYMENTS }, '', '');
    }

    toggleMenu(){
       
        this.isHamburgerMenuOpen = !this.isHamburgerMenuOpen;
        console.log('isHamburgerMenuOpen',this.isHamburgerMenuOpen);

    }
    handleCategorySelect(event){
        const category = event.detail?.category;
        this.selectedCategory = category;
        console.log('Category selected in parent:', category);
        console.log('selectedCategory',this.selectedCategory);
        // this.productsKey++;
        this.isHamburgerMenuOpen = false;
        this.resetVariables();
        this.isProducts = true;
        window.history.pushState({ page: PAGE_PRODUCTS }, '', '');
    
        // You can add additional logic here to filter products based on the selected category
    }
    

    openProductPage(event) {
        this.resetVariables();
        const productId = event.detail?.productId;
        console.log('productId',productId);
        this.selectedProduct = productId;
        console.log('selectedProduct',this.selectedProduct);
        this.isProductDetails = true;

        window.history.pushState(
            { page: PAGE_PRODUCT, data: productId },
            '',
            ''
        );
    }

    goBackFromProduct() {
        window.history.back();
    }

    closeHamburgerMenu(){
        this.isHamburgerMenuOpen = false;
    }

   

    handleAddToCart(event) {
        const item = event.detail;
        const existing = this.cartItems.find(c => c.id === item.id);

        if (existing) {
            this.popupItem = existing;
            this.showCartPopup = true;
        } else {
            this.cartItems = [...this.cartItems, { ...item, quantity: 1 }];
            this.showAlert(item.name + ' added to cart');
            // this.dispatchEvent(new ShowToastEvent({title: 'Success', message:item.name + ' added to cart', variant: 'success'}));
        }
    }

   

    handleIncrease() {
        this.popupItem.quantity += 1;
        this.cartItems = [...this.cartItems];
    }

    handleDecrease() {
        if (this.popupItem.quantity > 1) {
            this.popupItem.quantity -= 1;
            this.cartItems = [...this.cartItems];
        }
    }

    closePopup() {
        this.showCartPopup = false;
        this.popupItem = null;
    }

    

    handleLogout() {
        // Close menu and sign out
        this.isProfileMenuOpen = false;
        window.location.replace('/AbsyzEcommerce/secur/logout.jsp');
    }

    goCheckout(event){
        this.resetVariables();
        // this.checkoutItem = {...event.detail, price:Number(event.detail.price), quantity:Number(event.detail.quantity)};
        // this.isCheckout = true;
        if(event.detail?.cartItems){
            this.checkoutItems = event.detail.cartItems.map(item => ({...item, price:Number(item.price), quantity:Number(item.quantity)}));
            this.checkoutItem = null;
            this.isCheckout = true;
            window.history.pushState({ page: PAGE_CHECKOUT }, '', '');
            return;
        }

        this.checkoutItem={
            ...event.detail,
            price:Number(event.detail.price),
            quantity:Number(event.detail.quantity)};
            this.checkoutItems = [];
            this.isCheckout = true;
            window.history.pushState({ page: PAGE_CHECKOUT }, '', '');
       
    }

    cancel(){
        this.resetVariables();
        this.isCart = true;
        window.history.pushState({ page: PAGE_CART }, '', '');
    
    }

    handleOrderPlaced(){
        this.cartItems = [];
        this.resetVariables();
        this.isHome = true;
        this.showAlert('Order Placed Successfully');
        
    }

    // handleToast(event){
    //     const{title, message, variant} = event.detail;
    //     this.dispatchEvent(new ShowToastEvent({title, message, variant}));
    // }

    async showAlert(message, theme = 'success'){
        await lightningAlert.open({
            message: message,
            theme: theme ,
            label: 'Message'
        })
    }

    
    


}
