public class CustomerLoginController {

    @AuraEnabled
    public static String validateCustomerLogin(String username, String password) {
        try {
            PageReference pr = Site.login(username, password, '/AbsyzEcommerce');

            if (pr != null) {
                return pr.getUrl(); 
            }
            return null;

        } catch (Exception e) {
            return 'ERROR:' + e.getMessage();
        }
    }
}