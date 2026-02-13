public class ObjectAgentAction {
    private static final String SOQL_PROMPT_TEMPLATE_NAME = 'Building_Soql_Quey';

    // Request wrapper for Agent Actions
    public class Request {
        @InvocableVariable(label='User Query' description='The search query from the user' required=true)
        public String userQuery;
    }

    // Response wrapper for Agent Actions
    public class Response {
        @InvocableVariable(label='Search Results' description='JSON result of the query')
        public String searchResults;
        
        @InvocableVariable(label='Record Count' description='Number of records found')
        public Integer recordCount;
        
        @InvocableVariable(label='Error Message' description='Error message if any')
        public String errorMessage;
    }

    @InvocableMethod(
        label='Search Records via AI'
        description='Generates dynamic SOQL query using AI and returns matching records as JSON'
        category='Agent Actions'
    )
    public static List<Response> searchRecords(List<Request> requests) {
        List<Response> responseList = new List<Response>();

        // Handle empty requests
        if (requests == null || requests.isEmpty()) {
            Response errorResponse = new Response();
            errorResponse.errorMessage = 'No request provided';
            errorResponse.recordCount = 0;
            responseList.add(errorResponse);
            return responseList;
        }

        Request req = requests[0];
        Response res = new Response();

        // Validate input
        if (String.isBlank(req.userQuery)) {
            res.errorMessage = 'User query is empty';
            res.recordCount = 0;
            responseList.add(res);
            return responseList;
        }

        try {
            // Step 1: Get field metadata using the other Apex class
            String fieldMetadata = getFieldMetadata();
            System.debug('Field Metadata: ' + fieldMetadata);

            // Step 2: Prepare prompt template input
            ConnectApi.WrappedValue userInputValue = new ConnectApi.WrappedValue();
            userInputValue.value = req.userQuery;

            ConnectApi.WrappedValue metadataValue = new ConnectApi.WrappedValue();
            metadataValue.value = fieldMetadata;

            Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
            inputParams.put('Input:userInput', userInputValue);
            inputParams.put('Apex:ObjectMetadataService.Prompt', metadataValue);

            ConnectApi.EinsteinPromptTemplateGenerationsInput templateInput =
                new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            templateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            templateInput.additionalConfig.applicationName = 'PromptBuilderPreview';
            templateInput.isPreview = false;
            templateInput.inputParams = inputParams;

            // Step 3: Generate SOQL using Prompt Template
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation output =
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                    SOQL_PROMPT_TEMPLATE_NAME,
                    templateInput
                );

            if (output == null || output.generations == null || output.generations.isEmpty()) {
                res.errorMessage = 'No SOQL query generated';
                res.recordCount = 0;
                responseList.add(res);
                return responseList;
            }

            String generatedSOQL = output.generations[0].text.trim();
            System.debug('Generated SOQL: ' + generatedSOQL);

            // Clean up the generated SOQL (remove markdown if present)
            generatedSOQL = cleanSOQL(generatedSOQL);

            // Step 4: Execute the query
            List<SObject> records = Database.query(generatedSOQL);
            
            // Step 5: Prepare response
            res.searchResults = JSON.serializePretty(records);
            res.recordCount = records.size();
            res.errorMessage = null;

            System.debug('Query executed successfully. Records found: ' + records.size());

        } catch (QueryException qe) {
            System.debug('Query Error: ' + qe.getMessage());
            res.errorMessage = 'Query execution failed: ' + qe.getMessage();
            res.recordCount = 0;
            res.searchResults = null;
        } catch (Exception e) {
            System.debug('General Error: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            res.errorMessage = 'Error: ' + e.getMessage();
            res.recordCount = 0;
            res.searchResults = null;
        }

        responseList.add(res);
        return responseList;
    }

    // Helper method to get field metadata
    private static String getFieldMetadata() {
        try {
            ObjectMetadataService.Request metadataReq = new ObjectMetadataService.Request();
            List<ObjectMetadataService.Request> metadataRequests = new List<ObjectMetadataService.Request>();
            metadataRequests.add(metadataReq);
            
            List<ObjectMetadataService.Response> metadataResponses = 
                ObjectMetadataService.fetchFieldDetails(metadataRequests);
            
            if (metadataResponses != null && !metadataResponses.isEmpty()) {
                return metadataResponses[0].Prompt;
            }
            
            return 'No metadata available';
        } catch (Exception e) {
            System.debug('Error fetching metadata: ' + e.getMessage());
            return 'Error fetching metadata: ' + e.getMessage();
        }
    }

    // Helper method to clean SOQL (remove markdown formatting)
    private static String cleanSOQL(String soql) {
        if (String.isBlank(soql)) {
            return soql;
        }
        
        // Remove markdown code blocks
        soql = soql.replaceAll('```sql', '');
        soql = soql.replaceAll('```', '');
        
        // Remove leading/trailing whitespace
        soql = soql.trim();
        
        return soql;
    }
}