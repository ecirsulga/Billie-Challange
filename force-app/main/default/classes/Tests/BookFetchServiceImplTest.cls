@IsTest
private class BookFetchServiceImplTest {
    
    @IsTest
    static void whenExpectedPayload_shouldReturnBooks() {
        String mockResponse = '[{"Publisher":"Test Publisher","Books":[{"Author":"Test Author","Title":"Test Book","Edition":700000}]}]';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        BookFetchServiceImpl service = new BookFetchServiceImpl();
        
        Test.startTest();
        List<BookFetchServiceImpl.BookWithPublisher> result = service.calloutAndParseResponse();
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assertEquals('Test Author', result[0].Author);
        System.assertEquals('Test Book', result[0].Title);
        System.assertEquals(700000, result[0].Edition);
        System.assertEquals('Test Publisher', result[0].Publisher);
    }
    
    @IsTest
    static void whenLowEditions_ShouldFilterBoks() {
        String mockResponse = '[{"Publisher":"Test Publisher","Books":[' +
            '{"Author":"High Author","Title":"High Book","Edition":700000},' +
            '{"Author":"Low Author","Title":"Low Book","Edition":500000}' +
        ']}]';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        BookFetchServiceImpl service = new BookFetchServiceImpl();
        
        Test.startTest();
        List<BookFetchServiceImpl.BookWithPublisher> result = service.calloutAndParseResponse();
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assertEquals('High Author', result[0].Author);
        System.assertEquals(700000, result[0].Edition);
    }
    
    @IsTest
    static void whenMultiplePublishers_shouldReturnCorrectly() {
        String mockResponse = '[' +
            '{"Publisher":"Publisher1","Books":[{"Author":"Author1","Title":"Book1","Edition":700000}]},' +
            '{"Publisher":"Publisher2","Books":[{"Author":"Author2","Title":"Book2","Edition":800000}]}' +
        ']';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        BookFetchServiceImpl service = new BookFetchServiceImpl();
        
        Test.startTest();
        List<BookFetchServiceImpl.BookWithPublisher> result = service.calloutAndParseResponse();
        Test.stopTest();
        
        System.assertEquals(2, result.size());
        System.assertEquals('Publisher1', result[0].Publisher);
        System.assertEquals('Publisher2', result[1].Publisher);
    }
    
    @IsTest
    static void whenPublisherWithNoBooks_shouldOnlyReturnCorrectOne() {
        String mockResponse = '[' +
            '{"Publisher":"Publisher1","Books":[{"Author":"Author1","Title":"Book1","Edition":700000}]},' +
            '{"Publisher":"Publisher2","Books":null}' +
        ']';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        BookFetchServiceImpl service = new BookFetchServiceImpl();
        
        Test.startTest();
        List<BookFetchServiceImpl.BookWithPublisher> result = service.calloutAndParseResponse();
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'should not return publisher without books');
        System.assertEquals('Publisher1', result[0].Publisher);
    }
    
    @IsTest
    static void whenEmptyResponse_shouldReturnEmpty() {
        String mockResponse = '[]';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        BookFetchServiceImpl service = new BookFetchServiceImpl();
        
        Test.startTest();
        List<BookFetchServiceImpl.BookWithPublisher> result = service.calloutAndParseResponse();
        Test.stopTest();
        
        System.assertEquals(0, result.size());
    }
    
    @IsTest
    static void whenHttp500_shouldThrow() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Internal Server Error'));
        
        BookFetchServiceImpl service = new BookFetchServiceImpl();
        
        Test.startTest();
        Exception thrownException;
        try {
            service.calloutAndParseResponse();
        } catch (CalloutException e) {
            thrownException = e;
        }
        Test.stopTest();

        System.assert(thrownException.getMessage().contains('Error while making callout'), 'Exception message should contain expected text');
        System.assert(thrownException.getMessage().contains('500'), 'Exception should contain status code');
    }
    
    @IsTest
    static void whenCompare_shouldCompareCorrectly() {
        BookFetchServiceImpl.BookWithPublisher book1 = new BookFetchServiceImpl.BookWithPublisher('Author1', 'Title1', 700000, 'Publisher1');
        BookFetchServiceImpl.BookWithPublisher book2 = new BookFetchServiceImpl.BookWithPublisher('Author2', 'Title2', 800000, 'Publisher2');
        
        Test.startTest();
        Integer result = book1.compareTo(book2);
        Test.stopTest();
        
        System.assertEquals(100000, result, 'wrong difference');
    }
    
    @IsTest
    static void whenConstruct_shouldCorrectlyConstrucyt() {
        BookFetchServiceImpl.BookWithPublisher book = new BookFetchServiceImpl.BookWithPublisher('Test Author', 'Test Title', 123456, 'Test Publisher');
        
        Test.startTest();
        System.assertEquals('Test Author', book.Author);
        System.assertEquals('Test Title', book.Title);
        System.assertEquals(123456, book.Edition);
        System.assertEquals('Test Publisher', book.Publisher);
        Test.stopTest();
    }
    
    @IsTest
    static void testBookWithPublisher_CompareToSameEdition() {
        BookFetchServiceImpl.BookWithPublisher book1 = new BookFetchServiceImpl.BookWithPublisher('Author1', 'Title1', 700000, 'Publisher1');
        BookFetchServiceImpl.BookWithPublisher book2 = new BookFetchServiceImpl.BookWithPublisher('Author2', 'Title2', 700000, 'Publisher2');
        
        Test.startTest();
        Integer result = book1.compareTo(book2);
        Test.stopTest();
        
        System.assertEquals(0, result, 'Should return zero when editions are equal');
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
        
        public MockHttpResponseGenerator(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }
}