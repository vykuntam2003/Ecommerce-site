public without sharing class ProductImageContentDistributionService {

    public static String generatePublicImageUrl(Id productId) {

        if(productId == null){
            return null;
        }

        // 1) Get latest File linked to this Product
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :productId
            ORDER BY SystemModstamp DESC
            LIMIT 1
        ];

        if(links.isEmpty()){
            return null;
        }

        Id contentDocumentId = links[0].ContentDocumentId;

        // 2) Get latest version
        ContentVersion cv = [
            SELECT Id, Title
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId
            ORDER BY VersionNumber DESC
            LIMIT 1
        ];

        // 3) Find existing distribution
        List<ContentDistribution> existing = [
            SELECT Id, ContentDownloadUrl
            FROM ContentDistribution
            WHERE ContentVersionId = :cv.Id
            LIMIT 1
        ];

        ContentDistribution dist;
        if(!existing.isEmpty()){
            dist = existing[0];
        } else {
            dist = new ContentDistribution();
            dist.Name = 'Product Image Public Link - ' + cv.Title;
            dist.ContentVersionId = cv.Id;
            dist.PreferencesAllowViewInBrowser = true;
            dist.PreferencesAllowOriginalDownload = true;
            dist.PreferencesLinkLatestVersion = true;
            insert dist;

            dist = [
                SELECT Id, ContentDownloadUrl
                FROM ContentDistribution
                WHERE Id = :dist.Id
                LIMIT 1
            ];
        }

        String imageUrl = dist.ContentDownloadUrl;

        // 4) Update Product__c.Image__c with <img>
        Product__c prod = [
            SELECT Id, Image__c
            FROM Product__c
            WHERE Id = :productId
            LIMIT 1
        ];

        prod.Image__c =
            '<img src="' + imageUrl + '" style="width:100%;height:100%;object-fit:contain;" />';

        update prod;

        return imageUrl;
    }
}