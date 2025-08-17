@IsTest
private class MostPublishedBooksControllerTest {
    
    @IsTest
    static void whenFetchCalled_shouldSuccesfullyReturnJobId() {
        MockSystemApi mockSystemApi = new MockSystemApi();
        MockApexJobSelector mockApexJobSelector = new MockApexJobSelector();
        mockApexJobSelector.isJobRunning = false;
        
        MostPublishedBooksController.systemApi = mockSystemApi;
        MostPublishedBooksController.apexJobSelector = mockApexJobSelector;
        
        Test.startTest();
        String result = MostPublishedBooksController.fetchMostPublishedBooks();
        Test.stopTest();
        
        System.assertEquals(mockSystemApi.jobId, result, 'Should return the job ID');
    }
    
    @IsTest
    static void whenFetchCalled_shouldReturnJobAlreadyRunning() {
        MockApexJobSelector mockApexJobSelector = new MockApexJobSelector();
        mockApexJobSelector.isJobRunning = true;
        
        MostPublishedBooksController.apexJobSelector = mockApexJobSelector;
        
        Test.startTest();
        String result = MostPublishedBooksController.fetchMostPublishedBooks();
        Test.stopTest();
        
        System.assertEquals('Job is already running', result, 'Should return job already running message');
    }
    
    @IsTest
    static void whenFetchCalled_shouldThrow() {
        MockSystemApi mockSystemApi = new MockSystemApi();
        MockApexJobSelector mockApexJobSelector = new MockApexJobSelector();
        mockSystemApi.shouldThrowException = true;
        mockApexJobSelector.isJobRunning = false;
        
        MostPublishedBooksController.systemApi = mockSystemApi;
        MostPublishedBooksController.apexJobSelector = mockApexJobSelector;
        
        Test.startTest();
        Exception ex;
        try {
            MostPublishedBooksController.fetchMostPublishedBooks();
            System.assert(false, 'Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            ex = e;
        }
        Test.stopTest();

        System.Assert(ex != null, 'didnt throw AuraHandledException');
    }

    // I usually prefer to mock these with Apex Common library but for this assignment I didn't want to add fflib as a dependency
    private class MockSystemApi implements SystemApi {
        public Id jobId = '707Aw00000ynwsYIAQ';
        public Boolean shouldThrowException = false;
        
        public Id enqueueJob(System.Queueable queueable) {
            if (shouldThrowException) {
                throw new DmlException('Mock exception');
            }
            return jobId;
        }
        
        public Id enqueueJob(System.Queueable queueable, Integer delay) {
            return enqueueJob(queueable);
        }
    }
    
    private class MockApexJobSelector implements ApexJobSelector {
        public Boolean isJobRunning = false;
        
        public Boolean isJobAlreadyRunningByClassName(String jobName) {
            return isJobRunning;
        }
    }
}