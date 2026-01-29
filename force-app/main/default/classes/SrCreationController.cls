/**
 * Author: Gladis(Absyz)
 * Description: Controller class for SR creation called from employeeServicesForm LWC component
 * Test Class:  SRCreationControllerTest
 *============================================================================================
 * Version      Date                 Name                 Description
 * ============================================================================================
 * V1.1         11-July-2025         Gladis(Absyz)               Initial Development
 * V1.2         28-Aug-2025          Gulafsha                    Made without sharing, so that user can view results for other accounts when searched
 * V1.3         20-10-2025           Sharath                     checking null before document details is getting assigned to sr.
 * V1.4         20-10-2025           Ramarao                     Added new method for checking duplicate submitted SRs, when raised from another account
 * V1.5         20-10-2025           Gladis                      Updated new method for checking duplicate Draft SRs, when raised from same account
 * V1.6         27-10-2025           Rakesh                      Added Logic to create SR Doc Signer Records Under Service Request
 * V1.7         21-11-2025           Gladis                      Refactored the officer check into a standalone method, since it needs to run during Visa Renewal on load.
 * V1.8         26-11-2025           Sharath                     Updated spl case for Air ticket, Employment_Contract_Type__c and Air_Ticket_on_Visa_Renewal__c
 * V1.9         11-12-2025           Sharath                     added the key,value line for updating contract type value to backend.
 * V1.10        11-12-2025           Gladis                      Added method to delete SR Doc Signer record on change_applicant_job_title uncheck
 * V1.11        11-12-2025           Ramarao                     Added srdetailsview cacheable method and added checkDuplicateEstablishmentCard method
 * V1.12        19-12-2025           Gulafsha/Ramarao            Mapping Entity Details Fields from Contact on Visa Renewal SR Creation
 ============================================================================================*/
public without sharing class SRCreationController { // V1.2 

    public static Amendment__c amendmentData;
    public static Entity_Details__c entityDetailsData;

    // Method to Retrieve Contact details based on provided Passport Number and Nationality, and returns the result to the front-end
    @AuraEnabled
    public static  Map<String, Object> searchContact(String passportNumber, String nationality, List<String> fields, List<String> lookupFields, String recordTypeName) {
        String customError = '';
        String strCECNumber = '';
        Map<String, Object> finalConMap = new Map<String, Object>();    
        Set<String> uniqueFields = new Set<String>();
        for (String field : fields) {
            if (field != null && Pattern.matches('^[a-zA-Z0-9_]+$', field) && !field.endsWith('__dummy')) {
                uniqueFields.add(field);
            }
        }
        uniqueFields.add('Id');

        Set<String> lookupRelationshipFields = new Set<String>();
        if (lookupFields != null) {
            for (String lookupField : lookupFields) {
                if (lookupField.endsWith('__c')) {
                    lookupRelationshipFields.add(lookupField.replace('__c', '__r.Name'));
                }
                else if (lookupField.endsWith('Id')) {
                    String relName = lookupField.substring(0, lookupField.length()-2);
                    lookupRelationshipFields.add(relName + '.Name');
                }
            }
        }
        String fieldList = String.join(new List<String>(uniqueFields), ', ');
        if (!lookupRelationshipFields.isEmpty()) {
            fieldList += ', ' + String.join(new List<String>(lookupRelationshipFields), ', ');
        }
        //custom dynamic query to fetch contact fields using nationality        
        String query = 'SELECT ' + fieldList + 
                    ' FROM Contact WHERE Passport_No__c = :passportNumber AND Nationality_Lookup__c = :nationality ORDER BY CreatedDate DESC LIMIT 1';            
               
        try 
        {
            List<Contact> contactList = Database.query(query);
            Contact con = null;
            if(!contactList.isEmpty()){
                con = contactList[0];

                //Throw validation when an active CEC document found for the contact
                if(recordTypeName != null && (recordTypeName == 'New_Employment_Visa_V3' || recordTypeName == 'New_Employment_Card_For_An_Employee_On_Father_or_Husband_Sponsorship')){
                    DocumentDetailStaticQueries.GetRecordByContactAndDocType(con.Id, 'CEC Number');
                    List<Document_Details__c> lstDocDetails = new List<Document_Details__c>();
                    if (!DocumentDetailStaticQueries.RecordMap.isEmpty()) {
                        for (Document_Details__c docDetails : DocumentDetailStaticQueries.RecordMap.values()) {
                            Boolean isPICActive = docDetails.DOCUMENT_TYPE__c == 'PIC' && (docDetails.DOCUMENT_STATUS__c == 'Active' || docDetails.DOCUMENT_STATUS__c == 'Expired') &&
                                                docDetails.Contact__c == con.Id;
                            
                            Boolean isCECActive = docDetails.DOCUMENT_TYPE__c == 'CEC Number' &&
                                                (docDetails.DOCUMENT_STATUS__c == 'Active' || docDetails.DOCUMENT_STATUS__c == 'Transfer Under Process') &&
                                                docDetails.Contact__c == con.Id;

                            if (isPICActive || isCECActive) {
                                lstDocDetails.add(docDetails);
                            }
                        }
                    }
                    if (!lstDocDetails.isEmpty()) {
                        for (Document_Details__c doc : lstDocDetails) {
                            strCECNumber = strCECNumber == '' ? doc.Name : strCECNumber + ', ' + doc.Name;
                        }
                        customError = 'The Employee has an active PIC/CEC card. Please cancel the existing card before submitting a new request.';
                        throw new AuraHandledException('The Employee has an active PIC/CEC card. Please cancel the existing card before submitting a new request.');
                    }
                }
                Map<String, Object> conFieldMap = con.getPopulatedFieldsAsMap(); //standard method to get all field values as map
                for (String fieldName : conFieldMap.keySet()) {
                    finalConMap.put(fieldName, conFieldMap.get(fieldName));
                }
                // Since few fields are not directly available on the Contact record.
                List<Entity_Details__c> entityList = EntityDetailsStaticQueries.getLatestEntityDetailsRecordsByConId(new Set<Id>{con.Id});
                if (!entityList.isEmpty()) {
                    Entity_Details__c entity = entityList[0];

                    //Map latest ED values to dummy fields in finalConMap
                    finalConMap.put('Notice_During_Probation_Period__dummy', entity.Notice_During_Probation_Period__c);
                    finalConMap.put('Parental_Leave_No_of_days__dummy', entity.Parental_Leave_No_of_days__c);
                    finalConMap.put('Disciplinary_procedure__dummy', entity.Disciplinary_procedure__c);
                    finalConMap.put('Grievance_procedure__dummy', entity.Grievance_procedure__c);
                }
                
                //system.debug('@finalConMap'+finalConMap);
                return finalConMap; 
            } 
        } catch (Exception e) {
            if (String.isNotBlank(customError)) {
                throw new AuraHandledException(customError);
            } else {
                throw new AuraHandledException('Error Fetching records in SRCreationController.searchContact: ' + e.getMessage());
            }
        }
        return null;
    }

    // Method to insert Service Request and prepare Amendment and Entity Details data for post-processing in SRAfterInsertTriggerHandler
    @AuraEnabled
    public static Service_Request__c saveServiceRequest(Map<String, Object> serviceRequestData, Map<String, Object> amendmentData, Map<String, Object> entityDetailsData, Map<String, Object> recordTypesMap,  Map<String, Map<String, String>> fieldTypesMap, Map<String, Object> docSignerData) {
        
        Id srRTId = null;
        Id amendmentRTId = null;
        Id entityDetailsRTId = null; 
        Id oldContact = null;
        Id documentDetailId = null;
        String customError = '';
        Boolean accPrimaryRelationship = false;
        List<Contact> oldContactData = new List<Contact>();
        Contact objContact = new Contact();
        List<Service_Request__c> serviceRequestsToUpsert = new List<Service_Request__c>();
        List<Amendment__c> amendmentsToUpsert = new List<Amendment__c>();
        List<Entity_Details__c> entityDetailsToUpsert = new List<Entity_Details__c>();
        List<SR_Doc_Signer__c> signersToUpsert = new List<SR_Doc_Signer__c>(); //V1.6 
        Set<String> skippedRTsForAMandED = new Set<String>{'Company_Establishment_Card'};
        Set<String> renewalRecordTypes = new Set<String>{'Renew_An_Employee_Residence_Permit_Visa','AMEND_AN_EMPLOYMENT_CONTRACT'};//V1.12 
        try {

            if (recordTypesMap != null) {
                //srRTId = Schema.SObjectType.Service_Request__c.getRecordTypeInfosByDeveloperName().get((String)recordTypesMap.get('Service_Request__c')).getRecordTypeId();
                //amendmentRTId = Schema.SObjectType.Amendment__c.getRecordTypeInfosByDeveloperName().get((String)recordTypesMap.get('Amendment__c')).getRecordTypeId();
                //entityDetailsRTId = Schema.SObjectType.Entity_Details__c.getRecordTypeInfosByDeveloperName().get((String)recordTypesMap.get('Entity_Details__c')).getRecordTypeId();
            

                srRTId = recordTypesMap.containsKey('Service_Request__c') && recordTypesMap.get('Service_Request__c') != null
                        ? Schema.SObjectType.Service_Request__c.getRecordTypeInfosByDeveloperName().get((String)recordTypesMap.get('Service_Request__c')).getRecordTypeId() 
                        : null;

                amendmentRTId = recordTypesMap.containsKey('Amendment__c') && recordTypesMap.get('Amendment__c') != null ? Schema.SObjectType.Amendment__c.getRecordTypeInfosByDeveloperName().get((String)recordTypesMap.get('Amendment__c')).getRecordTypeId() 
                        : null;

                entityDetailsRTId = recordTypesMap.containsKey('Entity_Details__c') && recordTypesMap.get('Entity_Details__c') != null ? Schema.SObjectType.Entity_Details__c.getRecordTypeInfosByDeveloperName().get((String)recordTypesMap.get('Entity_Details__c')).getRecordTypeId() 
                        : null;
            }

            //Interim SR insert
            Boolean isFinalSubmit = false;
            if (serviceRequestData != null && serviceRequestData.containsKey('finalizeAmendmentFlg__c')) {
                Object finalAmFlag = serviceRequestData.get('finalizeAmendmentFlg__c');
                if (finalAmFlag instanceof Boolean) {
                    isFinalSubmit = (Boolean)finalAmFlag;
                }
            }

            //Build Service Request
            Service_Request__c sr;
            Id amendmentId = null;
            Id entityDetailsId = null;  
            Id srDocSignerId= null;
            if (serviceRequestData != null && serviceRequestData.containsKey('Id') && serviceRequestData.get('Id') != null && serviceRequestData.get('Id') !='') {
                Id srId = (Id)serviceRequestData.get('Id');
                ServiceRequestStaticQueries.getAmendmentEntityDetailByID(new Set<Id>{srId});
                Map<Id, Service_Request__c> srMap = ServiceRequestStaticQueries.recordMap;
                if(srMap != null && srMap.containsKey(srId)) {
                    //sr = srMap.values(); 
                    sr = srMap.get(srId);
                }
                amendmentId = sr.Amendments__r.isEmpty() ? null : sr.Amendments__r[0].Id;
                entityDetailsId = sr.Entity_Details__r.isEmpty() ? null : sr.Entity_Details__r[0].Id;
                srDocSignerId = sr.SR_Doc_Signers__r.isEmpty() ? null : sr.SR_Doc_Signers__r[0].Id;
            } else {
                sr = new Service_Request__c();
            }
            sr.RecordTypeId = srRTId;
            if (serviceRequestData != null) {
                Map<String, String> srFTMap = fieldTypesMap != null ? fieldTypesMap.get('Service_Request__c') : null;
                for (String key : serviceRequestData.keySet()) {
                    Object keyVal = serviceRequestData.get(key);
                    Object val;
                    String srFieldType = srFTMap != null ? srFTMap.get(key) : null;
                    //Dispalyed as picklist in front-end
                    if (key == 'Priority_Application__c') {
                        if (keyVal instanceof String) {
                            String strVal = (String)keyVal;
                            val = strVal != null && strVal.equalsIgnoreCase('Yes');
                        } else {
                            val = false;
                        }
                    } else if(key == 'Contact__c' && keyVal != null && String.valueOf(keyVal).trim() != ''){
                        oldContact = (Id)keyVal;
                    }
                    else if(key == 'Document_Detail__c' && keyVal != null && String.valueOf(keyVal).trim() != ''){
                         if (keyVal instanceof Map<String, Object>) {
                            Map<String, Object> detailMap = (Map<String, Object>) keyVal;
                            if (detailMap.containsKey('Id') && detailMap.get('Id') != null) {
                                documentDetailId = (Id) detailMap.get('Id');
                            }
                        } else if (keyVal instanceof String) {
                            documentDetailId = (Id) keyVal;
                        }
                    }
                    else {
                        val = castValueByType(srFieldType, keyVal);
                    }
                    try {
                        if (val != null) {
                            sr.put(key, val);
                        } else {
                            Object emptyVal = castValueByType(srFieldType, null);
                            sr.put(key, emptyVal);
                        }
                    } catch (Exception e) {
                        customError = e.getMessage();
                        throw new AuraHandledException('Skipping invalid field');
                    }
                }
                sr.Email__c = extractString(serviceRequestData, 'Company_Correspondance_Email__c');   
            }
            if(!skippedRTsForAMandED.contains((String)recordTypesMap.get('Service_Request__c'))){
            if (sr.Customer__c != null) {
                //sr.Customer_Name__c =  String.isNotBlank(sr.Customer__r.name) ? sr.Customer__r.name : null; // Commented by Gulafsha to avoid field length exceeding issue 
                LicenseStaticQueries.GetRecordByAccountId(new set<ID> {sr.Customer__c}); 
                List<License__c> licenses = new List<License__c>();
                if (!LicenseStaticQueries.recordMap.isEmpty()){
                    for (License__c license: LicenseStaticQueries.recordMap.values()) {
                        if(license.Account__c == sr.Customer__c) {
                            if(license.License_Status__c == 'Active') {
                                licenses.add(license);
                            }
                        }
                    }
                }
                if (!licenses.isEmpty()) {
                    sr.License__c = licenses[0].Id; 
                    }
                }
            }
                if (sr.Customer__c != null && oldContact != null) {
                    /*List<Relationship__c> accountRelationshipList = new List<Relationship__c>();
                
                    RelationshipStaticQueries.GetRecordBySubjectAccount(new set<ID> {sr.Customer__c});
                
                    if (!RelationshipStaticQueries.RecordMap.isEmpty()) {
                        for (Relationship__c relationshipDetails : RelationshipStaticQueries.RecordMap.values()) {
                            Boolean hasActiveRelation = relationshipDetails.Active__c == true &&
                                                relationshipDetails.Subject_Account__c == sr.Customer__c &&
                                                relationshipDetails.Object_Contact__c == oldContact;
                            if(hasActiveRelation) {
                                accountRelationshipList.add(relationshipDetails);
                            }
                        }
                    }
                    if (!accountRelationshipList.isEmpty()) {
                        accPrimaryRelationship = true;
                    }*/
                    accPrimaryRelationship = checkIsOfficer(sr.Customer__c, oldContact); //V1.7 
                }
                if (oldContact != null) {
                    oldContactData = getOldContactDetails(oldContact); //V1.13
                    if(!oldContactData.isEmpty()){
                        objContact = oldContactData[0];
                    }
                }
                if(sr.finalizeAmendmentFlg__c == false ){
                    sr.Submitted_Date__c = null;
                } else{
                    sr.Submitted_Date__c = system.today(); 
                }
            //Build Amendment
            if (amendmentData != null && !amendmentData.isEmpty()) {
            Amendment__c amendment = new Amendment__c();
            if(amendmentId != null){
                amendment.Id = amendmentId;
            }
            amendment.RecordTypeId = amendmentRTId;
                Map<String, String> amFTMap = fieldTypesMap != null ? fieldTypesMap.get('Amendment__c') : null;
                for (String key : amendmentData.keySet()) {
                        Object val;
                        Object keyVal = amendmentData.get(key);
                        String amFieldType = amFTMap != null ? amFTMap.get(key) : null;
                        //Is_this_person_in_U_A_E_now__c picklist field is treated as checkbox in front-end
                        if (key == 'Is_this_person_in_U_A_E_now__c') {
                            if (keyVal instanceof Boolean) {
                                amendment.put(key, ((Boolean)keyVal) ? 'Yes' : 'No');
                            } else {
                                amendment.put(key, null);
                            }
                        }
                        else { 
                            val = castValueByType(amFieldType, keyVal);

                            if (val instanceof Map<String, Object>) {
                                Map<String, Object> recordMap = (Map<String, Object>)val;
                                val = recordMap.containsKey('Id') ? (Id)recordMap.get('Id') : null;
                            }
                            try {
                                if (val != null) {
                                    amendment.put(key, val);
                                } else {
                                    Object emptyVal = castValueByType(amFieldType, null);
                                    amendment.put(key, emptyVal);
                                }
                            } catch (Exception e) {
                                customError = e.getMessage();
                                throw new AuraHandledException('Skipping invalid field');
                            }
                        }    
                }
                if(oldContact != null){
                    amendment.Old_Contact__c = oldContact;
                    amendment.Existing_Contact_Company__c = true;
                }
                amendment.Existing_Relationship__c =  accPrimaryRelationship;               
                if(renewalRecordTypes.contains((String)recordTypesMap.get('Service_Request__c'))  && objContact != null){//V1.8 //V1.12 
                    mapAmendmentFieldsFromContact(amendment, objContact);
                }
                amendment.Status__c = 'Draft';
                if (amendment.Nationality__r != null) {
                    amendment.Country_Of_Issue__c = amendment.Nationality__r.name;
                } else {
                    amendment.Country_Of_Issue__c = null;
                }
                sr.Passport_No__c = amendment.Passport_No__c;
                sr.Passport_Name__c = amendment.Full_Name__c;
                sr.Nationality_Lookup__c = amendment.Nationality__c;
                sr.Person_Mobile_No__c = amendment.Mobile_Number_ESign__c;
                if((String)recordTypesMap.get('Service_Request__c') == 'Renew_An_Employment_Card_For_An_Employee_On_Father_Husband_Sponsorship'|| (String)recordTypesMap.get('Service_Request__c') == 'AMEND_AN_EMPLOYMENT_CONTRACT' || (String)recordTypesMap.get('Service_Request__c') == 'Renew_An_Employee_Residence_Permit_Visa') {
                    sr.Contact__c = oldContact;
                    //V1.3 START
                    if(documentDetailId != null) {
                    sr.Document_Detail__c = documentDetailId;
                    }
                    //V1.3 END    
                } else {
                    sr.Contact__c = null;  
                    sr.Document_Detail__c = null; 
                }                
                //serviceRequestsToUpsert.add(sr);
                amendmentsToUpsert.add(amendment);
                
            }

            //Build Entity Details
            if (entityDetailsData != null && !entityDetailsData.isEmpty()) {
                Map<String, String> edFTMap = fieldTypesMap != null ? fieldTypesMap.get('Entity_Details__c') : null;
                Entity_Details__c entityDetails = new Entity_Details__c();
                if(entityDetailsId != null){
                    entityDetails.Id = entityDetailsId;
                }
                entityDetails.RecordTypeId = entityDetailsRTId;
                entityDetails.Status__c = 'Draft';
                if((String)recordTypesMap.get('Service_Request__c') == 'AMEND_AN_EMPLOYMENT_CONTRACT' || (String)recordTypesMap.get('Service_Request__c') == 'Renew_An_Employee_Residence_Permit_Visa') { //V1.8
                        entityDetails.Contact__c = oldContact;
                    }
                for (String key : entityDetailsData.keySet()) {
                    Object keyVal = entityDetailsData.get(key);
                    Object val;
                    String edFieldType = edFTMap != null ? edFTMap.get(key) : null;
                    if (key == 'Old_Priority_Application__c') {
                        if (keyVal instanceof String) {
                            String strVal = (String)keyVal;
                            val = strVal != null && strVal.equalsIgnoreCase('Yes');
                        } else {
                            val = false;
                        }
                    } //V1.8 starts
                    else if (key == 'Air_Ticket__c' || key == 'Air_Ticket_on_Visa_Renewal__c' || key == 'Old_Air_Ticket__c' || key == 'Old_Air_Ticket_on_Visa_Renewal__c' ) {
                            Boolean boolVal = false;
                                if (keyVal instanceof String) {
                                    String strVal = (String)keyVal;
                                    boolVal = strVal != null && strVal.equalsIgnoreCase('Yes');
                                }
                            val = boolVal;
                            entityDetails.put(key, val);

                    } else if (key == 'Employment_Contract_Type__c') {
                        if (keyVal instanceof String && String.isNotBlank((String)keyVal)) {
                            val = (String)keyVal;
                            entityDetails.put(key, val);//V1.9   
                        } else {
                            val = null;
                        }
                    } //V1.8 ends
                    else {
                        val = castValueByType(edFieldType, keyVal);

                        if (val instanceof Map<String, Object>) {
                            Map<String, Object> recordMap = (Map<String, Object>)val;
                            val = recordMap.containsKey('Id') ? (Id)recordMap.get('Id') : null;
                        }
                        try {
                            if (val != null) {
                                entityDetails.put(key, val); 
                            } else {
                                Object emptyVal = castValueByType(edFieldType, null);
                                entityDetails.put(key, emptyVal);
                            }
                        } catch (Exception e) {
                            customError = e.getMessage();
                            throw new AuraHandledException('Skipping invalid field');
                        }
                    }    
                }    
                //V1.12 
                if((String)recordTypesMap.get('Service_Request__c') == 'Renew_An_Employee_Residence_Permit_Visa' && objContact !=  null){
                    mapEntityDetailsFieldsFromContact(entityDetails, objContact);
                }  
                entityDetailsToUpsert.add(entityDetails);                
            }
            //V1.6 START - Build SR_Doc_Signer__c 
            if (
                docSignerData != null &&
                !docSignerData.isEmpty() &&
                docSignerData.containsKey('Primary_Relationship__c') &&
                docSignerData.get('Primary_Relationship__c') != null &&
                String.isNotBlank(String.valueOf(docSignerData.get('Primary_Relationship__c')))
            ) {
                SR_Doc_Signer__c signer = new SR_Doc_Signer__c();
                if(srDocSignerId != null){
                   signer.Id = srDocSignerId;

                }
                signer.IsActive__c = true;
                // Name field
                Object nameVal = docSignerData.get('Name');
                if (nameVal != null) signer.Name = String.valueOf(nameVal);

                // E_Signature_Details__c 
                Object esignId = docSignerData.get('E_Signature_Details__c');
                if (esignId != null) {
                    if (esignId instanceof Map<String, Object>) {
                        Map<String, Object> esignMap = (Map<String, Object>)esignId;
                        if (esignMap.containsKey('Id') && esignMap.get('Id') != null) {
                            signer.E_Signature_Details__c = (Id)esignMap.get('Id');
                        }
                    } else if (esignId instanceof String && String.valueOf(esignId).trim() != '') {
                        signer.E_Signature_Details__c = (Id)esignId;
                    }
                }

                // Tech_Company__c (Account)
                Object accId = docSignerData.get('Tech_Company__c');
                if (accId != null) {
                    if (accId instanceof Map<String, Object>) {
                        Map<String, Object> accMap = (Map<String, Object>)accId;
                        if (accMap.containsKey('Id') && accMap.get('Id') != null) {
                            signer.Tech_Company__c = (Id)accMap.get('Id');
                        }
                    } else if (accId instanceof String && String.valueOf(accId).trim() != '') {
                        signer.Tech_Company__c = (Id)accId;
                    }
                }

                // Primary_Relationship__c
                Object relationshipId = docSignerData.get('Primary_Relationship__c');
                if (relationshipId != null) {
                    if (relationshipId instanceof Map<String, Object>) {
                        Map<String, Object> relationshipMap = (Map<String, Object>)relationshipId;
                        if (relationshipMap.containsKey('Id') && relationshipMap.get('Id') != null) {
                            signer.Primary_Relationship__c = (Id)relationshipMap.get('Id');
                        }
                    } else if (relationshipId instanceof String && String.valueOf(relationshipId).trim() != '') {
                        signer.Primary_Relationship__c = (Id)relationshipId;
                    }
                }

                // Service_Request__c
                Object srIdObj = docSignerData.get('Service_Request__c');
                if (srIdObj != null) {
                    if (srIdObj instanceof Map<String, Object>) {
                        Map<String, Object> srMap = (Map<String, Object>)srIdObj;
                        if (srMap.containsKey('Id') && srMap.get('Id') != null) {
                            signer.Service_Request__c = (Id)srMap.get('Id');
                        }
                    } else if (srIdObj instanceof String && String.valueOf(srIdObj).trim() != '') {
                        signer.Service_Request__c = (Id)srIdObj;
                    }
                }
                signersToUpsert.add(signer);
            }
            //V1.6 END
            serviceRequestsToUpsert.add(sr);
            if (!serviceRequestsToUpsert.isEmpty()) {
                    upsert serviceRequestsToUpsert;
                }

            if (!amendmentsToUpsert.isEmpty()) {
                for (Amendment__c am : amendmentsToUpsert) {
                    am.ServiceRequest__c = serviceRequestsToUpsert.isEmpty() ? null : serviceRequestsToUpsert[0].Id;
                }
                upsert amendmentsToUpsert;
            }

            if (!entityDetailsToUpsert.isEmpty()) {
                for (Entity_Details__c ed : entityDetailsToUpsert) {
                    ed.Service_Request__c = serviceRequestsToUpsert.isEmpty() ? null : serviceRequestsToUpsert[0].Id;
                    ed.amendment__c = amendmentsToUpsert.isEmpty() ? null : amendmentsToUpsert[0].Id;
                }
                upsert entityDetailsToUpsert;
            }

            //V1.6 START
            if (!signersToUpsert.isEmpty()) {
                if (!serviceRequestsToUpsert.isEmpty()) {
                    Id newSrId = serviceRequestsToUpsert[0].Id;
                    for (SR_Doc_Signer__c s : signersToUpsert) {
                        if (s.Service_Request__c == null) s.Service_Request__c = newSrId;
                    }
                }
                upsert signersToUpsert;
            }
            //V1.6 END

            ServiceRequestStaticQueries.GetRecordByID(new set<id>{sr.Id}); 
            if(ServiceRequestStaticQueries.RecordMap!=null && ServiceRequestStaticQueries.RecordMap.size()>0){
                for(Service_Request__c srObj:ServiceRequestStaticQueries.RecordMap.values()){
                    if(srObj.id == sr.Id) {
                        sr = srObj;
                    }
                }
            }
            return sr;

        } catch (Exception e) {
            if (String.isNotBlank(customError)) {
                throw new AuraHandledException(customError);
            } else {
                throw new AuraHandledException('Error saving records in SRCreationController.saveServiceRequest: ' + e.getMessage());
            }
        }
    }

    //Method to extract a String value safely from Map
    private static String extractString(Map<String, Object> data, String key) {
        return (data != null && data.get(key) instanceof String) ? (String)data.get(key) : null;
    }


    // Method to cast value to appropriate field type
    private static Object castValueByType(String strFieldType, Object value) {
        
        String fieldType = strFieldType != null ? strFieldType.toLowerCase() : '';

        try {
            //if val is null
            if (value == null || String.isBlank(String.valueOf(value))) {
                if (fieldType == 'text' || fieldType == 'picklist' || fieldType == 'textarea' || 
                    fieldType == 'phone' || fieldType == 'email' || fieldType == 'string' || fieldType == 'customCheckBoxCard') {
                    return null;
                } else if (fieldType == 'id' || fieldType == 'reference') {
                    return null;
                } else if (fieldType == 'boolean' || fieldType == 'checkbox') {
                    return false;
                } else {
                    return null;
                }
            }

            //if val is !null
           String strVal = value != null ? String.valueOf(value).trim() : null;

            if (fieldType == 'date') {
                return !string.isblank(strVal)? Date.valueOf(strVal) : null;
            } else if (fieldType == 'datetime') {
                return !string.isblank(strVal)? DateTime.valueOf(strVal) : null;
            } else if (fieldType == 'boolean' || fieldType == 'checkbox') {
                if (value instanceof Boolean) {
                    return value;
                }
                if (strVal != null) {
                    String lower = strVal.toLowerCase();
                    return lower == 'true' || lower == 'yes' || lower == '1';
                }
                return false;
            } else if (fieldType == 'customCheckBoxCard') {
                if (value instanceof Boolean) {
                    return ((Boolean)value) ? 'Yes' : 'No';
                }
                return null;
            } else if (fieldType == 'currency' || fieldType == 'decimal' || fieldType == 'double' || fieldType == 'number' ) {
                return !string.isblank(strVal)? Decimal.valueOf(strVal) : null;
            } else if (fieldType == 'integer' || fieldType == 'int') {
                return !string.isblank(strVal)? Integer.valueOf(strVal) : null;
            } else if (fieldType == 'picklist') {
                return !string.isblank(strVal)? htmlDecode(strVal): null;
            } else if (fieldType == 'multipicklist' || fieldType == 'multi-select') {
                if (value instanceof List<Object>) {
                    List<String> stringList = new List<String>();
                    for (Object item : (List<Object>)value) {
                        if (item != null) {
                            stringList.add(String.valueOf(item));
                        }
                    }
                    return String.join(stringList, ';');
                }
                return strVal;
            } else if (fieldType == 'reference' || fieldType == 'id' || fieldType == 'lookup') {
                if (value instanceof Map<String, Object> || value instanceof Map<Object, Object>) {
                    Map<Object, Object> rawMap = (Map<Object, Object>)value;
                    Map<String, Object> refMap = new Map<String, Object>();
                    for (Object keyObj : rawMap.keySet()) {
                        String strKey = String.valueOf(keyObj);
                        refMap.put(strKey, rawMap.get(keyObj));
                    }
                    if (refMap.containsKey('Id')) {
                        Object refId = refMap.get('Id');
                        if (refId instanceof String) {
                            return (Id)refId;
                        }
                    } 
                    return null;
                } else if (value instanceof String) {
                    return (Id)value;
                } 
                return null;
            } else {
                if (value instanceof List<Object>) {
                    return null;
                }
                return value;
            }
            
        } catch (Exception ex) {
            throw new AuraHandledException('Error casting field with type [' + fieldType + ']: ' + ex.getMessage());
        }
    }


    //Method to decode special charcters before passing to a picklist field
    private static String htmlDecode(String input) {
        if (input == null) {
            return null;
        }
        String output = input;
        output = output.replace('&amp;', '&');
        output = output.replace('&quot;', '"');
        output = output.replace('&#39;', '\'');
        output = output.replace('&lt;', '<');
        output = output.replace('&gt;', '>');
        return output;
    }
    //V1.11
    @AuraEnabled(cacheable = true)
    public static Service_Request__c getSRViewDetailsCached(Id srId){
        return getSRViewDetails(srId);
    }
    @AuraEnabled
    public static Service_Request__c getSRViewDetails(Id srId) {
        if (srId == null) return null;

        try {
            Service_Request__c srRec = [ SELECT Parent_SR__c FROM Service_Request__c WHERE Id = :srId LIMIT 1 ];

            Id effectiveSrId = (srRec.Parent_SR__c != null) ? srRec.Parent_SR__c : srId;
            ServiceRequestStaticQueries.getAmendmentEntityDetailByID(new Set<Id>{ effectiveSrId });
            Map<Id, Service_Request__c> srMap = ServiceRequestStaticQueries.recordMap;
            return (srMap != null) ? srMap.get(effectiveSrId) : null;

        } catch (Exception e) {
            return null;
        }
    }

    // Method to get all the lookup Nationalities
    @AuraEnabled(cacheable=true)
    public static List<Lookup__c> getAllNationalities() {
        return LookupStaticQueries.getAllNationalities();
    }

    @AuraEnabled(cacheable=true)
    public static Account getAccount(Id accountId) {
        Id finalAccountId = accountId;
        String customError = '';
        Account userAccount = null;
        try {

            if (finalAccountId == null) {
                UserStaticQueries.getRecordById(new Set<Id>{UserInfo.getUserId()});
                if (!UserStaticQueries.recordMap.isEmpty()) {
                    for (User currentUser : UserStaticQueries.recordMap.values()) {
                        if (currentUser.Id == UserInfo.getUserId() &&
                            currentUser.Contact != null &&
                            currentUser.Contact.AccountId != null) {
                            finalAccountId = currentUser.Contact.AccountId;
                        }
                    }
                }

                if (finalAccountId == null) {
                    customError = 'Unable to proceed: Your user profile is not linked to a Contact/Account. Please contact your system administrator.';
                    throw new AuraHandledException(customError);
                }
            }
            //system.debug('@finalAccountId' + finalAccountId);
            AccountStaticQueries.getRecordById(new Set<Id>{finalAccountId});
            for (Account account : AccountStaticQueries.recordMap.values()) {
                if (account.Id == finalAccountId) {
                    userAccount = account;
                    break;
                }
            }
            return userAccount;

        } catch (Exception e) {
            if (String.isNotBlank(customError)) {
                throw new AuraHandledException('Error fetching account in getAccount: ' + customError);
            } else {
                throw new AuraHandledException('Error fetching account in getAccount: ' + e.getMessage());
            }
        }
    }
    //V1.4, V1.5  Check for duplicate draft/submitted SRs for different accounts 
    @AuraEnabled
    public static Service_Request__c getDuplicateServiceRequest(Id accountId, String type, String nationality, String passportNo, String recordTypeName) {
        Service_Request__c objSR = null;
        Set<String> recordTypeNameSet = new Set<String>{'New_Employment_Visa_V3','New_Employment_Card_For_An_Employee_On_Father_or_Husband_Sponsorship'};
        if(passportNo != null && nationality != null && recordTypeNameSet.contains(recordTypeName) && type != null) { 
            List<Service_Request__c> serviceRequestList = ServiceRequestStaticQueries.getSRByPassportNoAndNationality(accountId, type, nationality, passportNo);
            if (serviceRequestList != null && !serviceRequestList.isEmpty()) {
                objSR = serviceRequestList[0];
            }
        }
        return objSR;
    }

    //V1.7
    @AuraEnabled
    public static Boolean checkIsOfficer(Id customerId, Id oldContact){
        Boolean isOfficer = false;
        if (customerId != null && oldContact != null) {
            List<Relationship__c> accountRelationshipList = new List<Relationship__c>();
            RelationshipStaticQueries.GetRecordBySubjectAccount(new set<ID> {customerId});
            if (!RelationshipStaticQueries.RecordMap.isEmpty()) {
                for (Relationship__c relationshipDetails : RelationshipStaticQueries.RecordMap.values()) {
                    Boolean hasActiveRelation = relationshipDetails.Active__c == true &&
                                        relationshipDetails.Subject_Account__c == customerId &&
                                        relationshipDetails.Object_Contact__c == oldContact;
                    if(hasActiveRelation) {
                        accountRelationshipList.add(relationshipDetails);
                    }
                }
            }
            if (!accountRelationshipList.isEmpty()) {
                isOfficer = true;
            }
        }
        return isOfficer;
    }

    //V1.10 Delete doc signer when change_applicant_job title = false
    @AuraEnabled
    public static Boolean deleteSRDocSigner(Id srDocSignerId) {
        try {
            if (srDocSignerId != null) {
                delete [SELECT Id FROM SR_Doc_Signer__c WHERE Id = :srDocSignerId];
            }
            return true;
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting SR Doc Signer: ' + e.getMessage());
        }
    }
    //V1.11
    @AuraEnabled
    public static boolean checkDuplicateEstablishmentCard(String accountId, String docType){
        Set<Id> setEstCardAccountId = new Set<Id>{(Id) accountId};
        DocumentDetailStaticQueries.GetRecordByAccountAndDocType(setEstCardAccountId, docType, null);
        list<document_Details__c> docdtlsList = new list<document_Details__c>();
        if(!DocumentDetailStaticQueries.RecordMap.isEmpty()){
            for(document_Details__c docDtls : DocumentDetailStaticQueries.recordMap.values()){
                if(setEstCardAccountId.contains(docDtls.account__c) && docDtls.DOCUMENT_STATUS__c!='Terminated' && docDtls.document_type__c == 'Establishment Card' && docDtls.DOCUMENT_STATUS__c == 'Active'){
                    docdtlsList.add(docDtls);
                }
            }
        }
        if(!docdtlsList.isEmpty()){
            return true;
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static List<Contact> getOldContactDetails(Id oldContact) {
        List<Contact> oldContactData = new List<Contact>();
        ContactStaticQueries.GetRecordById(new Set<Id>{oldContact});
        if (!ContactStaticQueries.RecordMap.isEmpty()) {
            for (Contact contactDetails : ContactStaticQueries.RecordMap.values()) {
                if (contactDetails.Id == oldContact) {
                    oldContactData.add(contactDetails);
                }
            }
        }
        return oldContactData;
    }

    public static void mapEntityDetailsFieldsFromContact(Entity_Details__c entityDetails, Contact objContact){
            entityDetails.Food_Allowance__c = entityDetails.Food_Allowance__c == null ? objContact.FOOD_AMOUNT__c : entityDetails.Food_Allowance__c;
            entityDetails.Food_Provided__c = entityDetails.Food_Provided__c == null ? objContact.FOOD__c : entityDetails.Food_Provided__c;
            entityDetails.Accommodation_provided__c = entityDetails.Accommodation_provided__c == null ? objContact.Accomodation__c : entityDetails.Accommodation_provided__c;
            entityDetails.Accommodation_allowance__c = entityDetails.Accommodation_allowance__c == null ? objContact.Accomodation_Amount__c : entityDetails.Accommodation_allowance__c;
            entityDetails.Accomodation_Type__c = entityDetails.Accomodation_Type__c == null ? objContact.Accomodation_Type__c : entityDetails.Accomodation_Type__c;
            entityDetails.Transport_Provided__c = entityDetails.Transport_Provided__c == null ? objContact.Transport__c : entityDetails.Transport_Provided__c;
            entityDetails.Transport_allowance__c = entityDetails.Transport_allowance__c == null ? objContact.Transport_Amount__c : entityDetails.Transport_allowance__c;
            entityDetails.Basic_Monthly_Salary_Dhs__c = entityDetails.Basic_Monthly_Salary_Dhs__c == null ? objContact.BASIC_SALARY__c : entityDetails.Basic_Monthly_Salary_Dhs__c;
            entityDetails.Termination_Notice_Period__c = entityDetails.Termination_Notice_Period__c == null ? objContact.Termination_Notice_Period__c : entityDetails.Termination_Notice_Period__c;
            entityDetails.Probation_Period_in_months__c = entityDetails.Probation_Period_in_months__c == null ? objContact.Probation_Period_in_months__c : entityDetails.Probation_Period_in_months__c;
            entityDetails.Employment_Contract_Type__c =  entityDetails.Employment_Contract_Type__c == null ? objContact.Employment_Contract_Type__c :  entityDetails.Employment_Contract_Type__c;
            entityDetails.Other_Monthly_Allowance__c = entityDetails.Other_Monthly_Allowance__c == null ? objContact.Other_Allowance__c : entityDetails.Other_Monthly_Allowance__c;
            entityDetails.Employment_Contract__c = entityDetails.Employment_Contract__c == null ? objContact.Employment_Contract__c : entityDetails.Employment_Contract__c;
            entityDetails.Employment_Contract_Type__c = 'Limited';
            entityDetails.Continuous_Employment_Date__c = entityDetails.Continuous_Employment_Date__c == null ? objContact.Join_date__c : entityDetails.Continuous_Employment_Date__c;
            entityDetails.Probation_Period_in_months__c = entityDetails.Probation_Period_in_months__c == null ? objContact.Probation_Period_in_months__c : entityDetails.Probation_Period_in_months__c;
            entityDetails.Payment_method__c = entityDetails.Payment_method__c == null ? objContact.Payment_method__c : entityDetails.Payment_method__c;
            entityDetails.Working_Hours__c = entityDetails.Working_Hours__c == null ? objContact.Working_Hours__c : entityDetails.Working_Hours__c;
            entityDetails.Working_Week_To__c = entityDetails.Working_Week_To__c == null ? objContact.Working_Week_To__c : entityDetails.Working_Week_To__c;
            entityDetails.No_of_Boxes__c = entityDetails.No_of_Boxes__c == null ? objContact.Maternity_days__c : entityDetails.No_of_Boxes__c;
            entityDetails.Require_sick_leave_certificate_after__c = entityDetails.Require_sick_leave_certificate_after__c == null ? objContact.Require_sick_leave_certificate_after__c :  entityDetails.Require_sick_leave_certificate_after__c;
            entityDetails.Non_Competition_agreement__c = entityDetails.Non_Competition_agreement__c == null ? objContact.Non_Competition_agreement__c : entityDetails.Non_Competition_agreement__c;
            entityDetails.Type_of_Competing_Business_or_Service__c = entityDetails.Type_of_Competing_Business_or_Service__c == null ? objContact.Type_of_Competing_Business_or_Service__c : entityDetails.Type_of_Competing_Business_or_Service__c;
            entityDetails.Period__c = entityDetails.Period__c == null ? objContact.Non_Competition_Period__c : entityDetails.Period__c;
            entityDetails.Non_Solicit_of_Employees_Restricted_For__c = entityDetails.Non_Solicit_of_Employees_Restricted_For__c == null ? objContact.Non_Solicit_of_Employees_Restricted_For__c : entityDetails.Non_Solicit_of_Employees_Restricted_For__c;
            entityDetails.End_Date__c = entityDetails.End_Date__c == null ? objContact.End_Date__c : entityDetails.End_Date__c;
            entityDetails.No_of_Days_Per_Week__c = entityDetails.No_of_Days_Per_Week__c == null ? objContact.No_of_Days_Per_Week__c : entityDetails.No_of_Days_Per_Week__c;
            entityDetails.Working_Week_From__c = entityDetails.Working_Week_From__c == null ? objContact.Working_Week_From__c : entityDetails.Working_Week_From__c;
            entityDetails.PIC_No__c = entityDetails.PIC_No__c == null ? objContact.Paternity_leave_days__c : entityDetails.PIC_No__c;
            entityDetails.Termination_Notice_Period__c = entityDetails.Termination_Notice_Period__c == null ? objContact.Termination_Notice_Period__c : entityDetails.Termination_Notice_Period__c;
            entityDetails.Employee_Code_of_Conduct__c = entityDetails.Employee_Code_of_Conduct__c == null ? objContact.Employee_Code_of_Conduct__c : entityDetails.Employee_Code_of_Conduct__c;
            entityDetails.Undertaking_Type__c = entityDetails.Undertaking_Type__c == null ? objContact.Undertaking_Type__c : entityDetails.Undertaking_Type__c;
            entityDetails.Restricted_Area_New__c = entityDetails.Restricted_Area_New__c == null ? objContact.Restricted_Area_New_c__c : entityDetails.Restricted_Area_New__c;
            entityDetails.Non_Solicit_of_Business_Restricted_For__c = entityDetails.Non_Solicit_of_Business_Restricted_For__c == null ? objContact.Non_Solicit_of_Business_Restricted_For__c : entityDetails.Non_Solicit_of_Business_Restricted_For__c;
            entityDetails.No_of_Days__c = entityDetails.No_of_Days__c == null ? objContact.No_of_Days__c : entityDetails.No_of_Days__c;
            entityDetails.Commencement_Date__c = entityDetails.Commencement_Date__c == null ? objContact.Commencement_Date__c : entityDetails.Commencement_Date__c;
            entityDetails.Day_of_salary_transfers__c = entityDetails.Day_of_salary_transfers__c == null ? objContact.Day_of_salary_transfers__c : entityDetails.Day_of_salary_transfers__c;
            entityDetails.Termination__c = entityDetails.Termination__c == null ? objContact.Termination__c : entityDetails.Termination__c;
            entityDetails.Contract_Can_Be_Terminated_By__c = entityDetails.Contract_Can_Be_Terminated_By__c == null ? objContact.Contract_Can_Be_Terminated_By__c : entityDetails.Contract_Can_Be_Terminated_By__c;   
    }

    public static void mapAmendmentFieldsFromContact(Amendment__c amendment, Contact objContact){
        amendment.Street_Area__c = amendment.Street_Area__c == null ? objContact.Address_Line_2_HC__c:amendment.Street_Area__c ;
        amendment.Apt_Villa_Office_Number__c =  amendment.Apt_Villa_Office_Number__c == null ? objContact.Address_Line_1_HC__c: amendment.Apt_Villa_Office_Number__c;
        amendment.Passport_Type__c = amendment.Passport_Type__c == null ? objContact.Passport_Type__c : amendment.Passport_Type__c;
        amendment.Place_of_Issue__c = amendment.Place_of_Issue__c == null ? objContact.Place_of_Issue__c : amendment.Place_of_Issue__c;
        amendment.Passport_Issue_Date__c = amendment.Passport_Issue_Date__c == null ? objContact.Date_of_Issue__c : amendment.Passport_Issue_Date__c;
        amendment.Passport_Expiry_Date__c =  amendment.Passport_Expiry_Date__c == null ? objContact.Passport_Expiry_Date__c : amendment.Passport_Expiry_Date__c;        
        amendment.City__c = amendment.City__c == null ? objContact.CITY1__c : amendment.City__c;
        amendment.Country__c = amendment.Country__c == null ? objContact.COUNTRY_ENGLISH2__c : amendment.Country__c;
        amendment.Date_of_Birth__c =  amendment.Date_of_Birth__c ==  null ? objContact.Birthdate : amendment.Date_of_Birth__c;
        amendment.Country_Of_Birth__c = amendment.Country_Of_Birth__c == null ? objContact.COUNTRY_OF_BIRTH__c : amendment.Country_Of_Birth__c;
        amendment.Mothers_Name__c = amendment.Mothers_Name__c == null ? objContact.Mothers_Name__c: amendment.Mothers_Name__c;
        amendment.Fathers_Name__c = amendment.Fathers_Name__c == null ? objContact.Fathers_Name__c :amendment.Fathers_Name__c;
        amendment.First_Name_Arabic__c = amendment.First_Name_Arabic__c == null ? objContact.First_Name_Arabic__c:amendment.First_Name_Arabic__c;
        amendment.Middle_Name_Arabic__c = amendment.Middle_Name_Arabic__c == null ? objContact.Middle_Name_Arabic__c :amendment.Middle_Name_Arabic__c;
        amendment.Last_Name_Arabic__c =  amendment.Last_Name_Arabic__c == null ? objContact.Last_Name_Arabic__c : amendment.Last_Name_Arabic__c;
        amendment.Mother_name_Arabic__c = amendment.Mother_name_Arabic__c ==  null ? objContact.Mother_s_Name_Arabic__c : amendment.Mother_name_Arabic__c;
        amendment.Place_of_birth_Arabic__c = amendment.Place_of_birth_Arabic__c == null ? objContact.Place_of_birth_Arabic__c : amendment.Place_of_birth_Arabic__c;
        amendment.Passport_Name_Arabic__c = amendment.Passport_Name_Arabic__c == null ? objContact.Passport_Name_Arabic__c : amendment.Passport_Name_Arabic__c;
        amendment.Gender__c = amendment.Gender__c == null ? objContact.Gender__c : amendment.Gender__c;
        amendment.Apt_Villa_Office_Number_Resident__c = amendment.Apt_Villa_Office_Number_Resident__c == null ? objContact.ADDRESS_LINE1__c : amendment.Apt_Villa_Office_Number_Resident__c; //V1.12 
        amendment.PO_Box_Zip_Code_Resident__c = amendment.PO_Box_Zip_Code_Resident__c == null ? objContact.POBOX__c : amendment.PO_Box_Zip_Code_Resident__c; //V1.12 
        amendment.City_Resident__c = amendment.City_Resident__c == null ? objContact.City_Res__c : amendment.City_Resident__c; //V1.12 

    }
}