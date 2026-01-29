public without sharing class ProductController {

    public class ProductWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public Decimal price;
        @AuraEnabled public String category;

        @AuraEnabled public String image;
        @AuraEnabled public String specifications;
        @AuraEnabled public String dimensions;
        @AuraEnabled public String weight;

        public ProductWrapper(String id, String name, Decimal price, String category, String image, String specifications, String dimensions, String weight){
            this.id = id;
            this.name = name;
            this.price = price;
            this.category = category;
            this.image = image;
            this.specifications = specifications;
            this.dimensions = dimensions;
            this.weight = weight;
        }
           
        
    }

    public class ProductModalWrapper{
        @AuraEnabled public ProductWrapper selectedProduct;
        @AuraEnabled public list<ProductWrapper> similarProducts;

        public ProductModalWrapper(ProductWrapper selectedProduct, list<ProductWrapper> similarProducts){
            this.selectedProduct = selectedProduct;
            this.similarProducts = similarProducts;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getAllProducts(String category){

        System.debug('Category received: ' + category);

    list<Product__c> productList = new list<Product__c>();
        if(String.isBlank(category)){
            productList = [SELECT Id, Name, Price__c, Category__c, Image__c FROM Product__c limit 10];
        }else{
            productList = [SELECT Id, Name, Price__c, Category__c, Image__c FROM Product__c WHERE Category__c =: category];
        }

        List<ProductWrapper> results = new List<ProductWrapper>();
        for(Product__c product : productList){
            results.add(new ProductWrapper(
                product.Id,
                product.Name,
                product.Price__c,
                product.Category__c,
                product.Image__c,
                null,
                null,
                null
            ));
        }
    
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static ProductModalWrapper getProductWithSimilar(Id productId){

        Product__c selected = [SELECT Id, Name, Price__c, Category__c, Image__c,Specifications__c,Dimensions__c,Weight__c FROM Product__c WHERE Id =: productId];

        list<Product__c> similar = [select Id, Name, Price__c, Category__c, Image__c,Specifications__c,Dimensions__c,Weight__c FROM Product__c WHERE Category__c =: selected.Category__c AND Id !=: productId];

        ProductWrapper selectedWrapper = new ProductWrapper(
            selected.Id,
            selected.Name,
            selected.Price__c,
            selected.Category__c,
            selected.Image__c,
            selected.Specifications__c,
            selected.Dimensions__c,
            selected.Weight__c
        );

        list<ProductWrapper> similarWrappers = new list<ProductWrapper>();
        for(Product__c prod : similar){
            similarWrappers.add(new ProductWrapper(
                prod.Id,
                prod.Name,
                prod.Price__c,
                prod.Category__c,
                prod.Image__c,
                prod.Specifications__c,
                prod.Dimensions__c,
                prod.Weight__c
            ));
        }

        return new ProductModalWrapper(selectedWrapper, similarWrappers);
    }

    

   
}