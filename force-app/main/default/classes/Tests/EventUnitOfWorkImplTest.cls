@IsTest
private class EventUnitOfWorkImplTest {
    @IsTest
    static void whenRegisterEventCorrectly_shouldRegister() {
        EventUnitOfWorkImpl uow = new EventUnitOfWorkImpl();
        PublishedBook__e event = new PublishedBook__e(
            Author__c = 'test',
            Title__c = 'test',
            Edition__c = 700000,
            Publisher__c = 'test'
        );
        
        Test.startTest();
        uow.registerEvent(event);
        Test.stopTest();
        
        System.assertEquals(1, uow.eventsToPublish.size(), 'did not register 1 event');
        System.assertEquals(event, uow.eventsToPublish[0], 'did not registered correct event');
    }
    
    @IsTest
    static void whenRegisterEventsCorrectly_shouldRegisterAll() {
        EventUnitOfWorkImpl uow = new EventUnitOfWorkImpl();
        List<PublishedBook__e> events = new List<PublishedBook__e>{
            new PublishedBook__e(Author__c = 'test', Title__c = 'test', Edition__c = 700000, Publisher__c = 'tes'),
            new PublishedBook__e(Author__c = 'test', Title__c = 'test', Edition__c = 800000, Publisher__c = 'tes')
        };
        
        Test.startTest();
        uow.registerEvent(events);
        Test.stopTest();
        
        System.assertEquals(2, uow.eventsToPublish.size(), 'registered event count is wrong');
    }
    
    @IsTest
    static void whenWrongTypeRegistered_shouldThrowException() {
        EventUnitOfWorkImpl uow = new EventUnitOfWorkImpl();
        Account testAcc = new Account(Name = 'test');
        
        Test.startTest();
        Exception ex;
        try {
            uow.registerEvent(testAcc);
        } catch (EventUnitOfWorkImpl.UnitOfWorkException e) {
            ex = e;
            
        }
        Test.stopTest();

        System.assert(ex.getMessage().contains('Not a valid SObjectType'), 'wrong Exception message');
    }
    
    @IsTest
    static void whenCommitWork_shouldSuccessfullyCommit() {
        EventUnitOfWorkImpl uow = new EventUnitOfWorkImpl();
        PublishedBook__e event = new PublishedBook__e(
            Author__c = 'test',
            Title__c = 'tes',
            Edition__c = 700000,
            Publisher__c = 'test'
        );
        
        uow.registerEvent(event);
        
        Test.startTest();
        Exception ex;
        try {
            uow.commitWork();
        } catch (Exception e) {
            ex = e;
            
        }
        Test.stopTest();
        
        System.Assert(ex == null, 'should commit successfully but got exception');
    }
    
    @IsTest
    static void whenCommitWithNoEvents_shouldNotThrow() {
        EventUnitOfWorkImpl uow = new EventUnitOfWorkImpl();
        
        Test.startTest();
        Exception ex;
        try {
            uow.commitWork();
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.Assert(ex == null, 'should commit successfully but got exception');
    }
}