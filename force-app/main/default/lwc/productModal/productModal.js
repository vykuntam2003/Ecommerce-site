import { api, LightningElement, track } from 'lwc';
import getProductWithSimilar from '@salesforce/apex/ProductController.getProductWithSimilar';

export default class ProductModal extends LightningElement {
    @api productId;

    @track product;
    @track similarProducts = [];
    @track specList=[];

    goBack() {
        this.dispatchEvent(new CustomEvent('back'));
    }

    connectedCallback(){
        this.loadData();
    }

    async loadData(){
        try{
            console.log('productId in productModal', this.productId);
            const result = await getProductWithSimilar({ productId: this.productId });
            console.log('result', JSON.stringify(result));
            if(result){
                this.product = JSON.parse(JSON.stringify(result.selectedProduct));
                this.specList = this.product?.specifications?this.product.specifications.split("\n") : [];

                this.similarProducts = JSON.parse(JSON.stringify(result.similarProducts));
                console.log('product in the productModal', JSON.stringify(this.product));
                console.log('similarProducts inthe ProductModal', JSON.stringify(this.similarProducts));
            }
        }catch(error){
            console.error('Error fetching product data:', error);
        }
    }
    get showSpecs(){
        return this.specList && this.specList.length > 0;
    }

    // get specList(){
    //     return this.product?.specifications?this.product.specifications.split("\n") : [];
    // }

    handleSimilarClick(event){
        this.productId = event.currentTarget.dataset.id;
        console.log('productId in ProductModal', this.productId);
       // this.loadData();
       for(let key in this.similarProducts){
        if(this.similarProducts[key].id === this.productId){
            let temp = this.product;
            this.product = this.similarProducts[key];
            this.similarProducts[key] = temp;
            this.specList = this.product?.specifications?this.product.specifications.split("\n") : [];
            console.log('specList:'+JSON.stringify(this.specList));
            break;
        }
       }
       console.log('this.product'+JSON.stringify(this.product));
    }

    handleBuyNow(event){
        const productId = event.currentTarget.dataset.id;
        console.log('productId in ProductModal 48 line', productId);

        const product = this.product;
        console.log('product in the productModal 51 line', JSON.stringify(product));
        this.dispatchEvent(new CustomEvent('buynow', {
    detail:{
        id: product.id,
        name: product.name,
        image: product.image,
        price: Number(product.price),
        quantity: 1
    },
    bubbles:true,
    composed:true
}));
    }

    addToCart(event) {
        const productId = event.currentTarget.dataset.id;
        const product = this.product;

        this.dispatchEvent(
            new CustomEvent('addtocart', {
                detail: {
                    id: product.id,
                    name: product.name,
                    price: product.price,
                    image: product.image
                },
                bubbles: true,
                composed: true
            })
        );
    }
}