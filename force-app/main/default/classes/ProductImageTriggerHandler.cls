public class ProductImageTriggerHandler {

    public static void handle(Set<Id> productIds){
        if(productIds == null || productIds.isEmpty()){
            return;
        }

        try{
            // loop each product id and generate url
            for(Id pid : productIds){
                ProductImageContentDistributionService.generatePublicImageUrl(pid);
            }
        } catch(Exception e){
            System.debug('Error generating product image public urls: ' + e.getMessage());
        }
    }
}
