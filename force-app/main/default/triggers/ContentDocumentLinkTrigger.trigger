trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {

    String productPrefix = Product__c.SObjectType.getDescribe().getKeyPrefix();
    Set<Id> productIds = new Set<Id>();

    for(ContentDocumentLink cdl : Trigger.new){
        if(cdl.LinkedEntityId != null && String.valueOf(cdl.LinkedEntityId).startsWith(productPrefix)){
            productIds.add(cdl.LinkedEntityId);
        }
    }

    if(!productIds.isEmpty()){
        ProductImageTriggerHandler.handle(productIds);
    }
}