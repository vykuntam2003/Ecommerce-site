/******************************************************************************************
*  DMCC - Service Request Trigger

*  Author   : Shadiya Moideen
*  Company  : NSI JLT
*  Date     : 2013-09-25                           
----------------------------------------------------------------------
Version  Date         Author             Remarks                                                 
=======   ==========   =============  ==================================       
V1.0      07-Sep-2014  Nasir           Extension class created from Emp services 
v1.1     14-Dec-2014   RaVI            When Doc.ID is changed, refresh data from Contact to SR - 
new Method is " copyContactAndDocumentDtls "
v1.2      08-Feb-2015   Nasir           copy dnrd related fields to sr HD-8541 
V1.3      09-SEPT-2015  Haribabu       Commnted entire code in the copyDMSLFromReln method .
V1.4      13-OCT-2015   Haribabu       Now uncommneted the code block inside copyDMSLFromReln method and Commnted the code for unused fields assignments only.
V1.5      01-Jun-2016  Ravi           #30243 Continuity of employment on contract amendments-  Commencement_Date__c fetch
V1.6      14-Jul-2016  Ravi           #30493 User entered datae must be older than Commencement_Date__c date on the contact record
V1.6a     24-Jul-2016  Ravi           #30493A User entered datae must be older than Commencement_Date__c date on the contact record
v1.7     20-Oct-2016   Ravi           #39325 eSign Contact fetch new fields (& Create/Update Optimization)
V1.8     21-Nov-2017  Vaishali        Remove field usage - day_of_the_week__c, salary_payment__c, powers__c, person_name_dmssl_del__c
V1.9     11-Sep-2018  Ravi            #58020 Commencement Date cannot be a future date. - Disable
V1.10    24-Jan-2020  Ravi            #90503 EMP Contract Amendment and PIC - Employment Contract Type - Limited/Unlimited Check
V1.11    03-May-2020   Sumit          #93708 on document change
V1.12    14-Sep-2020   Sumit          #106018 on document change- Salary fields added
V1.13    03-FEB-2022   Surya          #136903  Employment Law 2022
v1.14	 23-Sep-2022   Sharath	      Added to fix a recurring issue related to Other Allowance and Other monthly allowance
V1.15    21-June-2023  Ramarao Batta  Lightning Migration
********************************************************************************************/

public with sharing class SRTriggerExtn_EmpServices {
    public static service_request__c copyDMSLFromReln(service_request__c sreq,Relationship__c rels){
        //v1.3 un commnted code
        /*Adhoc_debug('Inside    copyDMSLFromReln method');  
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Passport_No__c != null) {//1.8
            SReq.Passport_No__c = rels.Object_Contact__r.Passport_No__c;
            SReq.Changed_Passport_No__c = rels.Object_Contact__r.Passport_No__c;
            
        }
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Passport_Name__c != null) {
            SReq.Passport_Name__c = rels.Object_Contact__r.Passport_Name__c;
            SReq.Changed_Name_as_per_passport__c = rels.Object_Contact__r.Passport_Name__c;
        }
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.FirstName != null) {
            SReq.First_Name__c = rels.Object_Contact__r.FirstName;
            //SReq.Changed_First_Name__c = rels.Object_Contact__r.FirstName; V1.4 
        }
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.LastName != null) {
            SReq.LastName__c = rels.Object_Contact__r.LastName;
            //SReq.Changed_Last_Name__c = rels.Object_Contact__r.LastName;V1.4 
        }
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Gender__c != null) {
            SReq.Gender__c = rels.Object_Contact__r.Gender__c;
            //SReq.Changed_Gender__c = rels.Object_Contact__r.Gender__c;V1.4 
        }
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Title != null) {
            SReq.Title__c = rels.Object_Contact__r.Title;
            //SReq.Changed_Title__c = rels.Object_Contact__r.Title;V1.4 
        } 
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Middle_Names__c != null) {
            SReq.Middle_Name__c = rels.Object_Contact__r.Middle_Names__c;
            //SReq.Changed_Middle_Name__c = rels.Object_Contact__r.Middle_Names__c;V1.4 
        } 
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Email != null) {
            SReq.Person_Email_ID__c = rels.Object_Contact__r.Email;
            //SReq.Changed_Applicant_s_Email_ID__c = rels.Object_Contact__r.Email;V1.4 
        } 
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.MobilePhone != null) {
            SReq.Person_Mobile_No__c = rels.Object_Contact__r.MobilePhone;
            //SReq.Changed_Applicant_s_Mobile_No__c = rels.Object_Contact__r.MobilePhone;V1.4 
        }  
        
        // 
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Nationality_lookup__c != null) {
            SReq.Nationality_lookup__c = rels.Object_Contact__r.Nationality_lookup__c;
            //SReq.Changed_Nationality_Country__c = rels.Object_Contact__r.Nationality_lookup__c;V1.4 
        }  
        
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Place_of_Birth__c != null) {
            SReq.Place_of_Birth__c = rels.Object_Contact__r.Place_of_Birth__c;
            //SReq.Changed_Country_of_Birth__c = rels.Object_Contact__r.Place_of_Birth__c;V1.4 
        }  //COUNTRY_OF_BIRTH__c
        
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Birthdate != null) {
            SReq.Date_of_Birth__c = rels.Object_Contact__r.Birthdate;
            //SReq.Changed_Date_of_Birth__c = rels.Object_Contact__r.Birthdate;V1.4 
        }  
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Place_of_Birth__c != null) {
            SReq.Birth_Place__c = rels.Object_Contact__r.Place_of_Birth__c;
            // SReq.Changed_Place_of_Birth__c = rels.Object_Contact__r.Place_of_Birth__c;V1.4 
        }  
        
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Date_of_Issue__c != null) {
            SReq.Date_of_Issue__c = rels.Object_Contact__r.Date_of_Issue__c;
            //SReq.Changed_Passport_Issue_Date__c = rels.Object_Contact__r.Date_of_Issue__c;V1.4 
        } 
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Passport_Expiry_Date__c != null) {
            SReq.Passport_Expiry_Date__c = rels.Object_Contact__r.Passport_Expiry_Date__c;
            //SReq.Changed_Passport_Expiry_Date__c = rels.Object_Contact__r.Passport_Expiry_Date__c;V1.4 
        } 
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Place_of_Issue__c != null) {
            SReq.Place_of_Issue__c = rels.Object_Contact__r.Place_of_Issue__c;
            //SReq.Changed_Place_of_Issue__c = rels.Object_Contact__r.Place_of_Issue__c;V1.4 
        }
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Issued_Country__c != null) {
            SReq.Country_Of_Issue__c = rels.Object_Contact__r.Issued_Country__c;
            //SReq.Changed_Country_of_Issue__c = rels.Object_Contact__r.Issued_Country__c;V1.4 
        }  
        //
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.First_Name_Arabic__c != null) {
            SReq.First_Name_Arabic__c = rels.Object_Contact__r.First_Name_Arabic__c;
            // SReq.Changed_First_Name_Arabic__c = rels.Object_Contact__r.First_Name_Arabic__c;V1.4 
        }
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Middle_Name_Arabic__c != null) {
            SReq.Middle_Name_Arabic__c = rels.Object_Contact__r.Middle_Name_Arabic__c;
            // SReq.Changed_Middle_Name_Arabic__c = rels.Object_Contact__r.Middle_Name_Arabic__c;V1.4 
        }
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Last_Name_Arabic__c != null) {
            SReq.Last_Name_Arabic__c = rels.Object_Contact__r.Last_Name_Arabic__c;
            // SReq.Changed_Last_Name_Arabic__c = rels.Object_Contact__r.Last_Name_Arabic__c;V1.4 
        } 
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Passport_Name_Arabic__c != null) {
            SReq.Passport_Name_Arabic__c = rels.Object_Contact__r.Passport_Name_Arabic__c;
            // SReq.Changed_Name_as_per_Passport_Arabic__c = rels.Object_Contact__r.Passport_Name_Arabic__c;V1.4 
        }  
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Mother_s_Name_Arabic__c != null) {
            SReq.Mother_name_Arabic__c = rels.Object_Contact__r.Mother_s_Name_Arabic__c;
            // SReq.Changed_Mother_name_Arabic__c = rels.Object_Contact__r.Mother_s_Name_Arabic__c;V1.4 
        }
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Place_of_birth_Arabic__c != null) {
            SReq.Place_of_birth_Arabic__c = rels.Object_Contact__r.Place_of_birth_Arabic__c;
            //SReq.Changed_Place_of_birth_Arabic__c = rels.Object_Contact__r.Place_of_birth_Arabic__c;V1.4 
        } 
        // 
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.ADDRESS_LINE1__c != null) {
            SReq.U_A_E_Address__c = rels.Object_Contact__r.ADDRESS_LINE1__c;
            // SReq.Changed_U_A_E_Address__c = rels.Object_Contact__r.ADDRESS_LINE1__c;V1.4 
        }
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.ADDRESS_LINE2__c != null) {
            SReq.U_A_E_Address_2__c = rels.Object_Contact__r.ADDRESS_LINE2__c;
            // SReq.Changed_U_A_E_Address_2__c = rels.Object_Contact__r.ADDRESS_LINE2__c;V1.4 
        }
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.City_Res__c != null) {
            SReq.U_A_E_Address_City__c = rels.Object_Contact__r.City_Res__c;
            //SReq.Changed_U_A_E_Address_City__c = rels.Object_Contact__r.City_Res__c;V1.4 
        }
        /***
if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.COUNTRY_ENGLISH1__c != null) {
// SReq.U_A_E_Address_Emirates1__c = rels.Object_Contact__r.COUNTRY_ENGLISH1__c;
// SReq.Changed_U_A_E_Address_Emirates__c = rels.Object_Contact__r.COUNTRY_ENGLISH1__c;
}***/
        
        /*if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.POBOX__c != null) {
            SReq.U_A_E_Address_PO_Box__c = rels.Object_Contact__r.POBOX__c;
            // SReq.Changed_U_A_E_Address_PO_Box__c = rels.Object_Contact__r.POBOX__c;V1.4 
        }
        //
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Appointment_Date__c != null) {
            SReq.Appointment_Date__c = rels.Appointment_Date__c;
            // SReq.Changed_Appointment_Date__c = rels.Appointment_Date__c;V1.4 
        }
        /*if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Power__c != null) { //1.8
            SReq.Powers__c = rels.Power__c;
            //SReq.Changed_Powers__c = rels.Power__c;V1.4 
        }*/
        
        /*if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Ter_Date__c != null) {
            SReq.Termination_Date__c = rels.Ter_Date__c;
            // SReq.Changed_Termination_Date__c = rels.Ter_Date__c;V1.4 
        }
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Address_Line_1_HC__c != null) {
            SReq.Permanent_Native_Address_1__c = rels.Object_Contact__r.Address_Line_1_HC__c;
            // SReq.Changed_Permanent_Native_Address_1__c = rels.Object_Contact__r.Address_Line_1_HC__c;V1.4 
        }
        
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.Address_Line_2_HC__c != null) {
            SReq.Permanent_Native_Address_2__c = rels.Object_Contact__r.Address_Line_2_HC__c;
            // SReq.Changed_Permanent_Native_Address_2__c = rels.Object_Contact__r.Address_Line_2_HC__c;V1.4 
        }
       
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.CITY1__c != null) {
            SReq.Permanent_Native_City__c = rels.Object_Contact__r.CITY1__c;
            // SReq.Changed_Permanent_Native_City__c = rels.Object_Contact__r.CITY1__c;V1.4 
        }
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.COUNTRY_ENGLISH2__c != null) {
            SReq.Permanent_Native_Country__c = rels.Object_Contact__r.COUNTRY_ENGLISH2__c;
            //  SReq.Changed_Permanent_Native_Country__c = rels.Object_Contact__r.COUNTRY_ENGLISH2__c;V1.4 
        }
        if(SReq.Person_Name_DMSSL_del__c!=null && rels!=null && rels.Object_Contact__r.PO_Box_HC__c != null) {
            SReq.Permanent_Native_POBox_Postal_Zip_Code__c = rels.Object_Contact__r.PO_Box_HC__c;
            // SReq.Changed_Permanent_Native_POBox__c = rels.Object_Contact__r.PO_Box_HC__c;V1.4 
        */    
        return sreq;    
    }
    public static service_request__c copyContactinfo(service_request__c objSR,contact objCont, string strRecType){
       // Adhoc_debug('Beging SRTriggerExtn_EmpService: Working_Week_To__c '+objSR.Working_Week_To__c+'  objCont. Working_Week_To__c: '+objCont.Working_Week_To__c);
       //V1.11 
        Set<String> includedRecordTypes = new Set<String>{
            'Cancel_An_Employee_Residence_Permit_Visa',
            'Renew_An_Employee_Residence_Permit_Visa',
            'TRANSFER_AN_EMPLOYEE_FROM_DMCC_TO_OTHERS',
            'AMEND_AN_EMPLOYMENT_CONTRACT',
            'TRANSFER_AN_EMPLOYEE_TO_DMCC_FROM_OTHERS',
            'New_Employment_Card_For_An_Employee_On_Father_or_Husband_Sponsorship',
            'Renew_An_Employment_Card_For_An_Employee_On_Father_Husband_Sponsorship',
            'X040_Employee_passport_details_amend',
            'Employee_Residence_permit_Visa_in_a_new_passport_Lost',
            'Employee_Residence_Permit_Visa_In_a_New_Passport_Replacement_Or_New',
            'X006_Employee_residence_permit_visa_cancellation_PreEsign',
            'X006_Cancel_An_Employee_Res_Permit_Terminated_Company',
            'Revalidate_An_Employee_Residence_Permit_Visa_After_6_Months_Outside_Uae',
            'X033_Employment_card_cancellation_employee_on_husband_father_sponsorship_PreEsg'
        };
        Set<String> notIncludedRecordTypes = new Set<String>{
            'New_Employment_Card_For_An_Employee_On_Father_or_Husband_Sponsorship',
            'renew_an_employment_card_for_an_employee_on_father_husband_sponsorship',
            'new_employment_visa_v3',
            'New_Employment_Visa_V3',
            'new_employment_card_for_an_employee_on_father_or_husband_sponsorship',
            'Renew_An_Employment_Card_For_An_Employee_On_Father_Husband_Sponsorship',//V1.15 
            'renew_an_employee_residence_permit_visa',//V1.15 
            'Renew_An_Employee_Residence_Permit_Visa',//V1.15 
            'amend_an_employment_contract',//V1.15 
            'Amend_An_Employment_Contract'//V1.15 
        };
        Boolean copyOnUpdate = false;
        if(includedRecordTypes.contains(strRecType)) {
        system.debug('includedRecordTypes');
            copyOnUpdate = true;
        }
        Boolean notIncludeRT = true;
        if(notIncludedRecordTypes.contains(strRecType)) {
            notIncludeRT = false;
        }
        //End V1.11
        if(copyOnUpdate && ((objSR!=NULL && objSR.Contact__c==null) || (objSR!=NULL && objSR.Contact__c != objCont.Id))){ //V1.11
            objSR.Contact__c = objCont.Id;
        }
        if(objSR.Employment_Status__c==null || (copyOnUpdate && objSR.Employment_Status__c != objCont.Employment_Status__c)){ //V1.11
            objSR.Employment_Status__c = objCont.Employment_Status__c;
        }
        if(objSR.ABSCONDEE_STATUS__c==null || (copyOnUpdate && objSR.ABSCONDEE_STATUS__c != objCont.ABSCONDEE_STATUS__c)){ //V1.11
            objSR.ABSCONDEE_STATUS__c = objCont.ABSCONDEE_STATUS__c;
        }
        if(objSR.Abs_Conf_Date__c==null || (copyOnUpdate && objSR.Abs_Conf_Date__c != objCont.Abs_Conf_Date__c)){ //V1.11
            objSR.Abs_Conf_Date__c = objCont.Abs_Conf_Date__c;
        }
        if(notIncludeRT && (objSR.Passport_No__c==null || (copyOnUpdate && objSR.Passport_No__c != objCont.Passport_No__c))){ //V1.11
            objSR.Passport_No__c = objCont.Passport_No__c;
        }
        if(notIncludeRT && (objSR.Passport_Name__c==null || (copyOnUpdate && objSR.Passport_Name__c != objCont.Passport_Name__c))){ //V1.11
            objSR.Passport_Name__c = objCont.Passport_Name__c;
        }
        if(notIncludeRT && (objSR.Fathers_Name__c==null || (copyOnUpdate && objSR.Fathers_Name__c != objCont.Fathers_Name__c))){ //V1.11
            objSR.Fathers_Name__c = objCont.Fathers_Name__c;
        }
        if(notIncludeRT && (objSR.Mothers_Name__c==null || (copyOnUpdate && objSR.Mothers_Name__c != objCont.Mothers_Name__c))){// V1.11
            objSR.Mothers_Name__c = objCont.Mothers_Name__c;
        }
        if(notIncludeRT && (objSR.Middle_Name__c==null || (copyOnUpdate && objSR.Middle_Name__c != objCont.Middle_Names__c))){// V1.11
            objSR.Middle_Name__c = objCont.Middle_Names__c;
        }
        if(notIncludeRT && (objSR.First_Name__c==null || (copyOnUpdate && objSR.First_Name__c != objCont.FirstName))){ //V1.11
            objSR.First_Name__c = objCont.FirstName;
        }
        if(notIncludeRT && (objSR.LastName__c==null || (copyOnUpdate && objSR.LastName__c != objCont.LastName))){//V1.11
            objSR.LastName__c = objCont.LastName;
        }
        if(notIncludeRT && (objSR.Nationality_lookup__c==null || (copyOnUpdate && objSR.Nationality_lookup__c != objCont.Nationality_lookup__c))){ //V1.11
            objSR.Nationality_lookup__c = objCont.Nationality_lookup__c;
        }
        if(notIncludeRT && (objSR.Birth_Place__c==null || (copyOnUpdate && objSR.Birth_Place__c != objCont.Place_of_Birth__c))){ //V1.11
            objSR.Birth_Place__c = objCont.Place_of_Birth__c;
        }
        if(notIncludeRT && (objSR.Place_of_Birth__c==null || (copyOnUpdate && objSR.Place_of_Birth__c != objCont.COUNTRY_OF_BIRTH__c))){ //V1.11
            objSR.Place_of_Birth__c = objCont.COUNTRY_OF_BIRTH__c;
        }
        if(notIncludeRT && (objSR.Place_of_Issue__c==null || (copyOnUpdate && objSR.Place_of_Issue__c != objCont.Place_of_Issue__c))){//V1.11
            objSR.Place_of_Issue__c = objCont.Place_of_Issue__c;
        }       
        if(notIncludeRT && (objSR.Country_Of_Issue__c==null || (copyOnUpdate && objSR.Country_Of_Issue__c != objCont.Issued_Country__c))){//V1.11
            objSR.Country_Of_Issue__c = objCont.Issued_Country__c;
        }               
        if(notIncludeRT && (objSR.Date_of_Issue__c==null || (copyOnUpdate && objSR.Date_of_Issue__c != objCont.Date_of_Issue__c))){//V1.11
            objSR.Date_of_Issue__c = objCont.Date_of_Issue__c;
        }
        if(notIncludeRT && (objSR.Passport_Expiry_Date__c==null || (copyOnUpdate && objSR.Passport_Expiry_Date__c != objCont.Passport_Expiry_Date__c))){ //V1.11
            objSR.Passport_Expiry_Date__c = objCont.Passport_Expiry_Date__c;
        }
        if(notIncludeRT && (objSR.Date_of_Birth__c==null || (copyOnUpdate && objSR.Date_of_Birth__c != objCont.Birthdate))){//V1.11
            objSR.Date_of_Birth__c = objCont.Birthdate;
        }
        
        if(notIncludeRT && (objSR.Person_Email_ID__c==null || (copyOnUpdate && objSR.Person_Email_ID__c != objCont.Email))){//V1.11
            objSR.Person_Email_ID__c = objCont.Email;
        }
        if(notIncludeRT && (objSR.Person_Mobile_No__c==null || (copyOnUpdate && objSR.Person_Mobile_No__c != objCont.MobilePhone))){ //V1.11
            if(objCont.MobilePhone!=null && objCont.MobilePhone.isNumeric()){
                objSR.Person_Mobile_No__c = objCont.MobilePhone;
            }
        }
        if(notIncludeRT && (objSR.Gender__c==null || (copyOnUpdate && objSR.Gender__c != objCont.Gender__c))){ //V1.11
            objSR.Gender__c = objCont.Gender__c;
        }
        if(notIncludeRT && (objSR.Religion__c==null || (copyOnUpdate && objSR.Religion__c != objCont.RELIGION__c))){ //V1.11
            objSR.Religion__c = objCont.RELIGION__c;
        }
        if(notIncludeRT && (objSR.Title__c==null || (copyOnUpdate && objSR.Title__c != objCont.Title))){//V1.11
            objSR.Title__c = objCont.Title;
        }
        if(notIncludeRT && (objSR.Marital_Status__c==null || (copyOnUpdate && objSR.Marital_Status__c != objCont.Marital_Status__c))){ //V1.11
            objSR.Marital_Status__c = objCont.Marital_Status__c;
        }
        if(notIncludeRT && (objSR.First_Language1__c==null || (copyOnUpdate && objSR.First_Language1__c != objCont.First_Language__c))){//V1.11
            objSR.First_Language1__c = objCont.First_Language__c;
        } 
        
        if(objSR.Qualification__c==null || (copyOnUpdate && objSR.Qualification__c != objCont.Qualification__c)){//V1.11
            objSR.Qualification__c = objCont.Qualification__c;
        }
        if(notIncludeRT && (objSR.Marital_Status__c==null || (copyOnUpdate && objSR.Marital_Status__c != objCont.Marital_Status__c))){//V1.11
            objSR.Marital_Status__c = objCont.Marital_Status__c;
        }
        if(objSR.First_Language__c==null || (copyOnUpdate && objSR.First_Language__c != objCont.Spoken_Language1__c)){//V1.11
            objSR.First_Language__c = objCont.Spoken_Language1__c;
        } 
        //v1.1
        if ( strRecType!= 'transfer_an_employee_between_two_dmcc_companies'){
            if(notIncludeRT && (objSR.Accommodation_allowance__c==null || (copyOnUpdate && objSR.Accommodation_allowance__c != objCont.Accomodation_Amount__c))){//V1.11
                objSR.Accommodation_allowance__c = objCont.Accomodation_Amount__c;
            }
            if(notIncludeRT && (objSR.Accommodation_provided__c==null || (copyOnUpdate && objSR.Accommodation_provided__c != objCont.Accomodation__c))){//V1.11
                objSR.Accommodation_provided__c = objCont.Accomodation__c;
            }
            if(notIncludeRT && (objSR.Accomodation_Type__c==null || (copyOnUpdate && objSR.Accomodation_Type__c != objCont.Accomodation_Type__c))){//V1.11
                objSR.Accomodation_Type__c = objCont.Accomodation_Type__c;
            }
            if(notIncludeRT && (objSR.Food_Provided__c==null || (copyOnUpdate && objSR.Food_Provided__c != objCont.FOOD__c))){//V1.11
                objSR.Food_Provided__c = objCont.FOOD__c;
            }
            
            if(notIncludeRT && (objSR.Food_Allowance__c==null || (copyOnUpdate && objSR.Food_Allowance__c != objCont.FOOD_AMOUNT__c))){//V1.11
                //objSR.Food_Allowance__c = Decimal.valueOf(objCont.FOOD_AMOUNT__c);
                objSR.Food_Allowance__c = objCont.FOOD_AMOUNT__c;
                
            }
            
            if(notIncludeRT && (objSR.Transport_allowance__c==null || (copyOnUpdate && objSR.Transport_allowance__c != objCont.Transport_Amount__c))){//V1.11
                objSR.Transport_allowance__c = objCont.Transport_Amount__c;
            }
            if(notIncludeRT && (objSR.Transport_Provided__c==null || (copyOnUpdate && objSR.Transport_Provided__c != objCont.Transport__c))){//V1.11
                objSR.Transport_Provided__c = objCont.Transport__c;
            }
            if(notIncludeRT && (objSR.Executive_Status__c==null || (copyOnUpdate && objSR.Executive_Status__c != objCont.Executive_Flag_Status__c))){//V1.11
                objSR.Executive_Status__c = objCont.Executive_Flag_Status__c;
            }
            if(notIncludeRT && (objSR.Other_allowance__c==null || (copyOnUpdate && objSR.Other_allowance__c != objCont.Other_Allowance__c))){//V1.11
                objSR.Other_allowance__c = objCont.Other_Allowance__c;
                //v1.14 added to fix a recurring issue relatd to Other Allowance and Other monthly allowance
                objSR.Other_Monthly_Allowance__c = objCont.Other_Allowance__c;
            }                           
        }
        
        if(notIncludeRT && objSR.Record_Type_Name__c=='AMEND_AN_EMPLOYMENT_CONTRACT') { //1.12 //V1.15 
            if(objSR.Commencement_Date__c==null ){ //1.6
                /*if(objCont.Commencement_Date__c != null) //1.9
                    objSR.Commencement_Date__c =objCont.Commencement_Date__c; */
                if(objCont.Commencement_Date__c == null)   //1.6a
                    objSR.Commencement_Date__c =system.today();
            } 
           if(objCont.Join_date__c != null ) //1.9 
           {
                 if(objSR.Continuous_Employment_Date__c == null) {
                    // system.debug('From Contact entered data ' +objCont.Join_date__c);
                    objSR.Continuous_Employment_Date__c =objCont.Join_date__c;
                 }else{
                     //system.debug('user  entered data ' +objSR.Continuous_Employment_Date__c);
                    // objSR.Continuous_Employment_Date__c =objCont.Join_date__c;
                 }
            }
        }
        
        if(notIncludeRT && (objSR.Probation_Period_in_months__c==null || (copyOnUpdate && objSR.Probation_Period_in_months__c != objCont.Probation_Period_in_months__c))){//V1.11
            objSR.Probation_Period_in_months__c = objCont.Probation_Period_in_months__c;
        }           
        if(notIncludeRT && (objSR.Day_of_salary_transfers__c==null || (copyOnUpdate && objSR.Day_of_salary_transfers__c != objCont.Day_of_salary_transfers__c))){//V1.11
            objSR.Day_of_salary_transfers__c = objCont.Day_of_salary_transfers__c;
        }
        if(notIncludeRT && (objSR.Termination_Notice_Period__c==null || (copyOnUpdate && objSR.Termination_Notice_Period__c != objCont.Termination_Notice_Period__c))){//V1.11
            objSR.Termination_Notice_Period__c = objCont.Termination_Notice_Period__c;
        }               
        if(notIncludeRT && (objSR.Payment_method__c==null || (copyOnUpdate && objSR.Payment_method__c != objCont.Payment_method__c))){//V1.11
            objSR.Payment_method__c = objCont.Payment_method__c;
        }               
        if(notIncludeRT && (objSR.Annual_Leave_Days_Calendar__c==null || (copyOnUpdate && objSR.No_of_Days__c != objCont.Annual_Leave_Days__c))){//V1.11
            if(strRecType != 'Revalidate_An_Employee_Residence_Permit_Visa_After_6_Months_Outside_Uae') {
                objSR.No_of_Days__c = objCont.Annual_Leave_Days__c;
            }
        }
        //v1.11       
       /* //1.10
        if(objSR.Non_Competition_agreement__c==false && objSR.Non_Competition_agreement__c != objCont.Non_Competition_agreement__c ){
            objSR.Non_Competition_agreement__c = objCont.Non_Competition_agreement__c;
        }
        */
        //system.debug('objSR.Non_Competition_agreement__c ' + objSR.Non_Competition_agreement__c);
        //system.debug(' objCont.Non_Competition_agreement__c ' + objCont.Non_Competition_agreement__c);
       /* 1.10
        if(objSR.Period__c==null){
            objSR.Period__c = objCont.Non_Competition_Period__c;
        }   */
        if(objSR.Restricted_Area__c==null || (copyOnUpdate && objSR.Restricted_Area__c != objCont.Restricted_Area__c)){//V1.11
            objSR.Restricted_Area__c = objCont.Restricted_Area__c;
        }  
        
        if(notIncludeRT && (objSR.Employee_Code_of_Conduct__c==null || (copyOnUpdate && objSR.Employee_Code_of_Conduct__c != objCont.Employee_Code_of_Conduct__c))){//V1.11
            objSR.Employee_Code_of_Conduct__c = objCont.Employee_Code_of_Conduct__c;
        }
        if(notIncludeRT && (objSR.No_of_Days__c==null || (copyOnUpdate && objSR.No_of_Days__c != objCont.No_of_Days__c))){//V1.11
            if(strRecType != 'Revalidate_An_Employee_Residence_Permit_Visa_After_6_Months_Outside_Uae') {
                objSR.No_of_Days__c = objCont.No_of_Days__c;
            }
        }                                                   
        if(objSR.Annual_Leave_Days_Calendar__c==null || (copyOnUpdate && objSR.Annual_Leave_Days_Calendar__c != objCont.Annual_Leave_Days_new__c)){//V1.11
            objSR.Annual_Leave_Days_Calendar__c = objCont.Annual_Leave_Days_new__c;
        }                                                   
        
        //v1.1 ends
        if(objSR.Person_Internal_Ban_to_Date__c==null || (copyOnUpdate && objSR.Person_Internal_Ban_to_Date__c != objCont.BAN_END_DATE__c)){//V1.11
            objSR.Person_Internal_Ban_to_Date__c = objCont.BAN_END_DATE__c;
        }
        if(objSR.Person_Internal_Ban_From_Date__c==null || (copyOnUpdate && objSR.Person_Internal_Ban_From_Date__c != objCont.BAN_FROM_DATE__c)){//V1.11
            objSR.Person_Internal_Ban_From_Date__c = objCont.BAN_FROM_DATE__c;
        }
        if(notIncludeRT && (objSR.Job_Title__c==null || (copyOnUpdate && objSR.Job_Title__c != objCont.Job_Title__c))){//V1.11
            objSR.Job_Title__c = objCont.Job_Title__c;
        }
        if(notIncludeRT && (objSR.Permanent_Native_Address_1__c==null || (copyOnUpdate && objSR.Permanent_Native_Address_1__c != objCont.Address_Line_1_HC__c))){//V1.11
            objSR.Permanent_Native_Address_1__c = objCont.Address_Line_1_HC__c;
        }
        if(notIncludeRT && (objSR.Permanent_Native_Address_2__c==null || (copyOnUpdate && objSR.Permanent_Native_Address_2__c != objCont.Address_Line_2_HC__c))){//V1.11
            objSR.Permanent_Native_Address_2__c = objCont.Address_Line_2_HC__c;
        }
        if(notIncludeRT && (objSR.Permanent_Native_City__c==null || (copyOnUpdate && objSR.Permanent_Native_City__c != objCont.CITY1__c))){//V1.11
            objSR.Permanent_Native_City__c = objCont.CITY1__c;
        }
        if(notIncludeRT && (objSR.Permanent_Native_Country__c==null || (copyOnUpdate && objSR.Permanent_Native_Country__c != objCont.COUNTRY_ENGLISH2__c))){//V1.11
            objSR.Permanent_Native_Country__c = objCont.COUNTRY_ENGLISH2__c;
        }
        if(notIncludeRT && (objSR.Permanent_Native_POBox_Postal_Zip_Code__c==null || (copyOnUpdate && objSR.Permanent_Native_POBox_Postal_Zip_Code__c != objCont.PO_Box_HC__c))){//V1.11
            
            if(objCont.PO_Box_HC__c!=null && objCont.PO_Box_HC__c.isNumeric()){
                objSR.Permanent_Native_POBox_Postal_Zip_Code__c = objCont.PO_Box_HC__c;
            }
            //objSR.Permanent_Native_POBox_Postal_Zip_Code__c = objCont.PO_Box_HC__c;
        }
        if(notIncludeRT && (objSR.U_A_E_Address__c==null || (copyOnUpdate && objSR.U_A_E_Address__c != objCont.ADDRESS_LINE1__c))){//V1.11
            objSR.U_A_E_Address__c = objCont.ADDRESS_LINE1__c;
        }
        if(notIncludeRT && (objSR.U_A_E_Address_2__c==null || (copyOnUpdate && objSR.U_A_E_Address_2__c != objCont.ADDRESS_LINE2__c))){//V1.11
            objSR.U_A_E_Address_2__c = objCont.ADDRESS_LINE2__c;
        }
        if(notIncludeRT && (objSR.U_A_E_Address_City__c==null || (copyOnUpdate && objSR.U_A_E_Address_City__c != objCont.City_Res__c))){//V1.11
            objSR.U_A_E_Address_City__c = objCont.City_Res__c;
        }
        if(objSR.U_A_E_Address_Emirates__c==null || (copyOnUpdate && objSR.U_A_E_Address_Emirates__c != objCont.COUNTRY_ENGLISH1__c)){//V1.11
            objSR.U_A_E_Address_Emirates__c = objCont.COUNTRY_ENGLISH1__c;
        }
        if(notIncludeRT && (objSR.U_A_E_Address_PO_Box__c==null || (copyOnUpdate && objSR.U_A_E_Address_PO_Box__c != objCont.POBOX__c))){//V1.11
            if(objCont.POBOX__c!=null && objCont.POBOX__c.isNumeric()){
                objSR.U_A_E_Address_PO_Box__c = objCont.POBOX__c;
            }
            //objSR.U_A_E_Address_PO_Box__c = objCont.POBOX__c;
        }   
        if(notIncludeRT && (objSR.Employment_Contract__c==null || (copyOnUpdate && objSR.Employment_Contract__c != objCont.Employment_Contract__c))){//V1.11
            objSR.Employment_Contract__c = objCont.Employment_Contract__c;
        }
        if(objSR.End_Date__c==null ){
            //if(objSR.Employment_Contract_Type__c=='Limited')
            //objSR.End_Date__c = system.today()+365;
        }   
        system.debug(' transfer to company ' + objCont.accountid);
        if ( strRecType== 'transfer_an_employee_between_two_dmcc_companies'){
            if(objSR.Transfer_from_Company_Name__c==null){
                objSR.Transfer_from_Company__c = objCont.accountid;
                objSR.Transfer_from_Company_Name__c = objCont.account.name;
            }                           
        }  
        //1.2
        if (strRecType== 'transfer_an_employee_between_two_dmcc_companies'){
            document_details__c objRV = new document_details__c();
            if (objCont!=null && objCont.document_details__r.size() > 0){
                for(document_details__c eaDD:objCont.document_details__r){
                    if ( eadd.Document_type__c !=null && eadd.Document_status__c !=null && ( eadd.Document_status__c =='Active' || eadd.Document_status__c=='Cancelled') && eadd.Document_type__c=='Residence Visa' ){
                        objRV = eaDD;
                    }
                }
            }
            if (objRV.Document_number__c !=null){
                if(objSR.DNRD_Application_Date__c==null  ){//Shireesh asked to commented this on 21-mar-2014 for Entry Permit Renewal 
                    objSR.DNRD_Application_Date__c = objRV.DNRD_Application_Date__c;
                }
                if(objSR.DNRD_Application_No__c==null ){
                    objSR.DNRD_Application_No__c = objRV.DNRD_Application_No__c;
                }
                if(objSR.DNRD_Document_No__c==null ){
                    objSR.DNRD_Document_No__c = objRV.DOCUMENT_NUMBER__c;
                }
                if(objSR.Document_Issue_Date__c==null ){
                    objSR.Document_Issue_Date__c = objRV.Issue_Date__c;
                } 
                if(objSR.Document_Expiry_Date__c==null ){
                    objSR.Document_Expiry_Date__c = objRV.Expiry_Date__c;
                }          
                
            }
            //1.2        
        }
        
        //1.10
         if(notIncludeRT && (objSR.Record_Type_Name__c=='AMEND_AN_EMPLOYMENT_CONTRACT'  ||  objSR.Record_Type_Name__c== 'Renew_An_Employment_Card_For_An_Employee_On_Father_Husband_Sponsorship')) { //1.12  //V1.15 
        //system.debug('BEFORE UPDATING END_DATE' );
             if(objSR.Employment_Contract_Type__c == 'Unlimited' && objCont.Employment_Contract_Type__c == 'Limited' && notIncludeRT) {
                                objSR.End_Date__c    = null ; 
                                system.debug('upating enddate ');
                        } 
                        
            //Undertaking 
            if (notIncludeRT){
            if(objSR.Non_Competition_agreement__c == false)    { //Selected false
               // system.debug(' Non_Competition_agreement__c is FALSE');
                objSR.Period__c = null;
                objSR.Non_Solicit_of_Business_Restricted_For__c = null;
                 objSR.Restricted_Area_New__c  = null;
                objSR.Non_Solicit_of_Employees_Restricted_For__c = null;
                objSR.Undertaking_Type__c = null;
                //objSR.Non_Competition_agreement__c = FALSE;
            }else{ //Selected TRUE
            //system.debug(' Non_Competition_agreement__c is TRUE ');
                if(objSR.Non_Solicit_of_Business_Restricted_For__c==null){
                  objSR.Non_Solicit_of_Business_Restricted_For__c = objCont.Non_Solicit_of_Business_Restricted_For__c;
                }
                if(objSR.Period__c==null){
                    objSR.Period__c = objCont.Non_Competition_Period__c;
                }   
                if(objSR.Restricted_Area_New__c ==null){
                    objSR.Restricted_Area_New__c  = objCont.Restricted_Area_New_c__c ;
                }  
            
                if(objSR.Non_Solicit_of_Employees_Restricted_For__c==null){
                   objSR.Non_Solicit_of_Employees_Restricted_For__c = objCont.Non_Solicit_of_Employees_Restricted_For__c;
                }
                if(objSR.Undertaking_Type__c==null){
                    objSR.Undertaking_Type__c = objCont.Undertaking_Type__c;
                }
            }
            }
         }
        //1.7 esign
        if (notIncludeRT && (objSR.Working_Week_From__c== null || (copyOnUpdate && objSR.Working_Week_From__c!= objCont.Working_Week_From__c)))   {  //V1.12         
            objSR.Working_Week_From__c= objCont.Working_Week_From__c;
        }
        if (notIncludeRT && (objSR.Working_Week_To__c== null || (copyOnUpdate && objSR.Working_Week_To__c!= objCont.Working_Week_To__c)))   {//V1.12           
            objSR.Working_Week_To__c= objCont.Working_Week_To__c;
        }
        if (notIncludeRT && (objSR.Working_Hours__c== null || (copyOnUpdate && objSR.Working_Hours__c!= objCont.Working_Hours__c)))   {//V1.12           
            objSR.Working_Hours__c= objCont.Working_Hours__c;
            
        }
        if (objSR.Parental_Leave__c== null || (copyOnUpdate && objSR.Parental_Leave__c!= objCont.Parental_Leave__c))   {//V1.12           
            objSR.Parental_Leave__c= objCont.Parental_Leave__c;
            
        }
        /*if (objCont.Salary_Payment__c== null)   {           //1.8
            objSR.Salary_Payment__c= objCont.Salary_Payment__c;
        }*/
        /*if (objSR.Day_Of_The_Week__c== null)   {          //1.8
            objSR.Day_Of_The_Week__c= objCont.Day_Of_The_Week__c;
        }*/
        if (notIncludeRT && (objSR.Contract_Can_Be_Terminated_By__c== null || (copyOnUpdate && objSR.Contract_Can_Be_Terminated_By__c!= objCont.Contract_Can_Be_Terminated_By__c)))   {//V1.12           
            objSR.Contract_Can_Be_Terminated_By__c= objCont.Contract_Can_Be_Terminated_By__c;
            
        }
        if (notIncludeRT && (objSR.Termination__c== null || (copyOnUpdate && objSR.Termination__c != objCont.Termination__c)))   {//V1.12           
            objSR.Termination__c= objCont.Termination__c;
            
        }
        if (notIncludeRT && (objSR.Termination_Notice_Period__c== null || (copyOnUpdate && objSR.Termination_Notice_Period__c!= objCont.Termination_Notice_Period__c)))   {//V1.12           
            objSR.Termination_Notice_Period__c= objCont.Termination_Notice_Period__c;
        }
        if (notIncludeRT && (objSR.Air_Ticket__c== null || (copyOnUpdate && objSR.Air_Ticket__c != objCont.Air_Ticket__c)))   {//V1.12           
            objSR.Air_Ticket__c= objCont.Air_Ticket__c;
        }
        if (notIncludeRT && (objSR.No_of_Days_Per_Week__c== null || (copyOnUpdate && objSR.No_of_Days_Per_Week__c != objCont.No_of_Days_Per_Week__c)))   { //V1.12          
            objSR.No_of_Days_Per_Week__c= objCont.No_of_Days_Per_Week__c;
        }
        if (notIncludeRT && (objSR.No_of_Boxes__c== null || (copyOnUpdate && objSR.No_of_Boxes__c!= objCont.Maternity_days__c)))   {//V1.12           
            objSR.No_of_Boxes__c= objCont.Maternity_days__c;
        }
        if (notIncludeRT && (objSR.PIC_No__c== null || (copyOnUpdate && objSR.PIC_No__c != objCont.Paternity_leave_days__c)))   {//V1.12           
            objSR.PIC_No__c= objCont.Paternity_leave_days__c;
        }
        
        if (notIncludeRT && (objSR.Payment_method__c== null || (copyOnUpdate && objSR.Payment_method__c != objCont.Payment_method__c)))   {//V1.12           
            objSR.Payment_method__c= objCont.Payment_method__c;
        }
        
        if (notIncludeRT && (objSR.No_of_Days__c== null || (copyOnUpdate && objSR.No_of_Days__c != objCont.No_of_Days__c)))   {//V1.12           
            objSR.No_of_Days__c= objCont.No_of_Days__c;
        }
        if (notIncludeRT && (objSR.Day_of_salary_transfers__c== null || (copyOnUpdate && objSR.Day_of_salary_transfers__c != objCont.Day_of_salary_transfers__c)))   { //V1.12          
            objSR.Day_of_salary_transfers__c= objCont.Day_of_salary_transfers__c;
        }
        
        if (notIncludeRT && (objSR.Air_Ticket_on_Visa_Renewal__c== null || (copyOnUpdate && objSR.Air_Ticket_on_Visa_Renewal__c != objCont.Air_Ticket_on_Visa_Renewal__c)))   {//V1.12           
            objSR.Air_Ticket_on_Visa_Renewal__c= objCont.Air_Ticket_on_Visa_Renewal__c;
        }
        if(notIncludeRT && (objSR.First_Language__c==null || (copyOnUpdate && objSR.First_Language1__c != objCont.First_Language__c))){//V1.12
            objSR.First_Language1__c = objCont.First_Language__c;
        }
        if(notIncludeRT && (objSR.Employment_Contract_Type__c==null || (copyOnUpdate && objSR.Employment_Contract_Type__c != objCont.Employment_Contract_Type__c))){//V1.12
            objSR.Employment_Contract_Type__c = objCont.Employment_Contract_Type__c;
        }
       /*1.10 if(objSR.End_Date__c==null){
            objSR.End_Date__c = objCont.End_Date__c;
        }*/
       
       /*
      XX eSign Field Change
       if(objSR.Require_sick_leave_certificate_after__c==null){
            objSR.Require_sick_leave_certificate_after__c = objCont.Require_sick_leave_certificate_after__c;
        }
        */
        if(notIncludeRT && (objSR.basic_monthly_salary_dhs__c==null || (copyOnUpdate && objSR.basic_monthly_salary_dhs__c != objCont.BASIC_SALARY__c))){//V1.12
            objSR.basic_monthly_salary_dhs__c = objCont.BASIC_SALARY__c;
        }
        
       /* if(objSR.Commencement_Date__c==null){ //1.6 //1.9
            if(objCont.Commencement_Date__c != null)
                objSR.Commencement_Date__c =objCont.Commencement_Date__c;
            
        } */
        
         
        
        
      /*  Ravi Unlimited 1.10
       if(objSR.Non_Solicit_of_Business_Restricted_For__c==null){
            objSR.Non_Solicit_of_Business_Restricted_For__c = objCont.Non_Solicit_of_Business_Restricted_For__c;
        }
  
        if(objSR.Non_Solicit_of_Employees_Restricted_For__c==null){
            objSR.Non_Solicit_of_Employees_Restricted_For__c = objCont.Non_Solicit_of_Employees_Restricted_For__c;
        }
         if(objSR.Undertaking_Type__c==null){
            objSR.Undertaking_Type__c = objCont.Undertaking_Type__c;
        }
          */
        if(notIncludeRT && (objSR.Type_of_Competing_Business_or_Service__c==null  || (copyOnUpdate && objSR.Type_of_Competing_Business_or_Service__c != objCont.Type_of_Competing_Business_or_Service__c))){//V1.12
            objSR.Type_of_Competing_Business_or_Service__c = objCont.Type_of_Competing_Business_or_Service__c;
        }
        if(strRecType== 'Renew_An_Employee_Residence_Permit_Visa'){//1.13
            if(objSR.End_Date__c==null && objCont.End_Date__c!=null){
                    objSR.End_Date__c= objCont.End_Date__c;

                }
        }
        if(notIncludeRT && (strRecType == 'New_Employment_Card_For_An_Employee_On_Father_or_Husband_Sponsorship' || strRecType =='Renew_An_Employment_Card_For_An_Employee_On_Father_Husband_Sponsorship')){//1.13
            objSR.Residence_visa_validity__c='1 Year Valid Employment Visa';
        }
        /* //1.10
        if(objSR.Period__c==null){
           objSR.Period__c = objCont.Period__c;
        }
        if(objSR.Restricted_Area_New__c==null){
           objSR.Restricted_Area_New__c = objCont.Restricted_Area_New_c__c;
        }   */     
        system.debug(' Employment_Contract_Type__c '+objCont.Employment_Contract_Type__c+' '+objSR.Employment_Contract_Type__c);
        system.debug(' Commencement_Date__c '+objCont.Commencement_Date__c+' '+objSR.Commencement_Date__c);
        //1.7
        return objSR;
    }
   
    public static service_request__c copydocdtlinfo(Service_request__c objSR, Document_Details__c objDoc,string strRecType){
         system.debug(' strRecType '+strRecType);
          system.debug(' objSR.Residence_Visa_Validity__c '+objSR.Residence_Visa_Validity__c);
          system.debug(' objDoc.Residence_Visa_Validity__c '+objDoc.Residence_Visa_Validity__c);
        if(strRecType=='AMEND_AN_EMPLOYMENT_CONTRACT'){
            if(objSR.Residence_Visa_Validity__c==NULL && objDoc.Residence_Visa_Validity__c!= NULL){
                  objSR.Residence_Visa_Validity__c =   objDoc.Residence_Visa_Validity__c;
            }   
        }
        
        return objSR;
        
    }
}