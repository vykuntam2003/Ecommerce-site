@isTest()
public class ObjectRecordsHandlerTest {
    @isTest()
    public static void testGetObjectRecords() {
        List<SObject> records = ObjectRecordsHandler.getObjectRecords('Account', 'Test');
        System.Assert.areEqual(0, records.size());
    }

}