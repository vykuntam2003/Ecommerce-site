import { api, LightningElement, track, wire } from 'lwc';
// import Laptop from '@salesforce/resourceUrl/Laptop';
// import Mobile from '@salesforce/resourceUrl/Mobile';
// import Tablet from '@salesforce/resourceUrl/Tablet';
// import SmartWatch from '@salesforce/resourceUrl/SmartWatch';
import getAllProducts from '@salesforce/apex/ProductController.getAllProducts';

export default class Products extends LightningElement {
    
    _category ='';

    @api 
    get category(){
        return this._category;
    }

    set category(value){
        this._category = value ?? '';
        console.log('category in setter',this._category);
        this.loadProducts();
    }

    



    
    

    @track productsList = [
        // {
        //     id: 1,
        //     name: 'LapTop',
        //     price: 55000,
        //     image: Laptop,
        //     specifications: [
        //         'Intel i7 Processor',
        //         '16 GB RAM',
        //         '512 GB SSD',
        //         'Windows 11'
        //     ],
        //     dimensions: '35 × 24 × 2 cm',
        //     weight: '1.6 kg'
        // },
        // {
        //     id: 2,
        //     name: 'Mobile',
        //     price: 25000,
        //     image: Mobile,
        //     specifications: [
        //         'Snapdragon 8 Gen',
        //         '8 GB RAM',
        //         '128 GB Storage',
        //         '5000 mAh Battery'
        //     ],
        //     dimensions: '16 × 7.5 × 0.8 cm',
        //     weight: '180 g'
        // },
        // {
        //     id: 3,
        //     name: 'Tablet',
        //     price: 15000,
        //     image: Tablet,
        //     specifications: [
        //         'Snapdragon 8 Gen',
        //         '8 GB RAM',
        //         '128 GB Storage'
        //     ],
        //     dimensions: '18 × 8.5 × 0.9 cm',
        //     weight: '180 g'
        // },
        // {
        //     id: 4,
        //     name: 'Smart Watch',
        //     price: 20000,
        //     image: SmartWatch,
        //     specifications: [
        //         'Snapdragon 8 Gen',
        //         '1000 mAh Battery'
        //     ],
        //     dimensions: '9 × 2 × 0.1 cm',
        //     weight: '18 g'
        // }
    ];

    // connectedCallback(){
    //     this.loadProducts();
    // }

    async loadProducts(){
        try{
            const data = await getAllProducts({category: this.category});
            this.productsList = data;
            console.log('productsList', JSON.stringify(this.productsList));
        }catch(error){
            console.error('Error fetching products:', error);
            this.productsList = [];
        }
    }
    


    // @wire(getAllProducts, { category: '$category' })
    // wiredProducts({ error, data }) {
    //     console.log('category in products.js',this.category);
    //     if (data) {
    //         this.productsList = data;
    //     } else if (error) {
    //         console.error('Error fetching products:', error);
    //     }
    // }

    addToCart(event) {
        // const product = this.productsList.find(
        //     item => item.id == event.target.dataset.id
        // );
        const productId = event.currentTarget.dataset.id;
        const product = this.productsList.find(item => item.id == productId);


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

    handleImageClick(event) {
        const productId = event.currentTarget.dataset.id || event.target.closest('.imgBox')?.dataset?.id;
        console.log(' clicked productId',productId);
        // const product = this.productsList.find(item => item.id == productId);

        this.dispatchEvent(
            new CustomEvent('openproduct', {
                detail:{ productId },
                bubbles: true,
                composed: true
            })
        );
    }

   


    // handleBuyNow(event) {
    //     const product = this.productsList.find(item => item.id === event.target.dataset.id);
    //     this.dispatchEvent(new CustomEvent('buynow', {detail:{ ...product, quantity: 1}, bubbles: true, composed: true}));
    // }
    handleBuyNow(event) {
    const productId = event.currentTarget.dataset.id;
    console.log(' current productId', productId);

    const product = this.productsList.find(p => p.id == productId);

    this.dispatchEvent(
        new CustomEvent('buynow', {
            detail: {
                id: product.id,
                name: product.name,
                image: product.image,
                price: Number(product.price),
                quantity: 1
            },
            bubbles: true,
            composed: true
        })
    );
}


}