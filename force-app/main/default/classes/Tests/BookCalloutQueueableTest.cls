@IsTest
private class BookCalloutQueueableTest {
    
    @IsTest
    static void testExecute_Success() {
        MockEventUnitOfWork uowMock = new MockEventUnitOfWork();
        MockBookFetchService serviceMock = new MockBookFetchService();
        
        serviceMock.booksToReturn.add(new BookFetchServiceImpl.BookWithPublisher('Test Author', 'Test Book', 700000, 'Test Publisher'));
        
        BookCalloutQueueable queueable = new BookCalloutQueueable(uowMock, serviceMock);
        
        Test.startTest();
        queueable.execute(null, 0);
        Test.stopTest();
        
        System.assertEquals(1, uowMock.registeredEvents.size(), 'Should register one event');
        System.assertEquals(true, uowMock.commitWorkCalled, 'Should call commitWork');
        
        PublishedBook__e event = (PublishedBook__e) uowMock.registeredEvents[0];
        System.assertEquals('Test Author', event.Author__c, 'Author should match');
        System.assertEquals('Test Book', event.Title__c, 'Title should match');
        System.assertEquals(700000, event.Edition__c, 'Edition should match');
        System.assertEquals('Test Publisher', event.Publisher__c, 'Publisher should match');
    }
    
    @IsTest
    static void whenBooksReturned_shouldRegisterEvents() {
        MockEventUnitOfWork uowMock = new MockEventUnitOfWork();
        MockBookFetchService serviceMock = new MockBookFetchService();
        
        serviceMock.booksToReturn.add(new BookFetchServiceImpl.BookWithPublisher('test1', 'testbook1', 700000, 'testpublisher1'));
        serviceMock.booksToReturn.add(new BookFetchServiceImpl.BookWithPublisher('test2', 'testbook2', 800000, 'testpublisher2'));
        serviceMock.booksToReturn.add(new BookFetchServiceImpl.BookWithPublisher('test3', 'testbook3', 600000, 'testpublisher3'));
        
        BookCalloutQueueable queueable = new BookCalloutQueueable(uowMock, serviceMock);
        
        Test.startTest();
        queueable.execute(null, 0);
        Test.stopTest();
        
        System.assertEquals(3, uowMock.registeredEvents.size(), '3 events should be registered');
        System.assertEquals(true, uowMock.commitWorkCalled, 'commitwork not called');
    }
    
    @IsTest
    static void whenNoBooksFetched_shouldNotPublish() {
        MockEventUnitOfWork uowMock = new MockEventUnitOfWork();
        MockBookFetchService serviceMock = new MockBookFetchService();
        
        BookCalloutQueueable queueable = new BookCalloutQueueable(uowMock, serviceMock);
        
        Test.startTest();
        queueable.execute(null, 0);
        Test.stopTest();
        
        System.assertEquals(0, uowMock.registeredEvents.size(), 'should not register');
        System.assertEquals(true, uowMock.commitWorkCalled, 'commitwork not called');
    }
    
    @IsTest
    static void whenServiceThrowsException_shouldThrow() {
        MockEventUnitOfWork uowMock = new MockEventUnitOfWork();
        MockBookFetchService serviceMock = new MockBookFetchService();
        serviceMock.shouldThrowException = true;
        
        BookCalloutQueueable queueable = new BookCalloutQueueable(uowMock, serviceMock);
        
        Test.startTest();
        Exception ex;
        try {
            queueable.execute(null, 0);
        } catch (CalloutException e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals('Mock exception', ex.getMessage(), 'wrong exception');
    }
    
    @IsTest
    static void whenRetriesExceeded_shouldThrow() {
        BookCalloutQueueable queueable = new BookCalloutQueueable();
        RetryQueueable.RetriesExceededException exc = new RetryQueueable.RetriesExceededException('Test exception', 3);
        
        Test.startTest();
        Exception ex;
        try {
            queueable.retriesExceeded(exc);
        } catch (RetryQueueable.RetriesExceededException e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals('Test exception', ex.getMessage(), 'wrong exception message');
    }
    
    @IsTest
    static void whenDefaultConstructorCalled_shouldIncreaseCoverage() {
        Test.startTest();
        BookCalloutQueueable queueable = new BookCalloutQueueable();
        Test.stopTest();
        
        System.assertNotEquals(null, queueable, 'Should create queueable with default constructor');
    }

    private class MockEventUnitOfWork implements EventUnitOfWork {
        public List<SObject> registeredEvents = new List<SObject>();
        public Boolean commitWorkCalled = false;
        
        public void registerEvent(SObject event) {
            registeredEvents.add(event);
        }

        public void registerEvent(List<SObject> event) {
            registeredEvents.addAll(event);
        }
        
        public void commitWork() {
            commitWorkCalled = true;
        }
    }
    
    private class MockBookFetchService implements BookFetchService {
        public List<BookFetchServiceImpl.BookWithPublisher> booksToReturn = new List<BookFetchServiceImpl.BookWithPublisher>();
        public Boolean shouldThrowException = false;
        
        public List<BookFetchServiceImpl.BookWithPublisher> calloutAndParseResponse() {
            if (shouldThrowException) {
                throw new CalloutException('Mock exception');
            }
            return booksToReturn;
        }
    }
}