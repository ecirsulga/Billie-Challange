public with sharing class MostPublishedBooksController {
    @TestVisible
    private static SystemApi systemApi = new SystemApiImpl();
    @TestVisible
    private static ApexJobSelector apexJobSelector = new ApexJobSelectorImpl();
    private static final Integer RETRY_COUNT = 3;
    private static final String JOB_NAME = 'RetryQueueable';

    @AuraEnabled
    public static string fetchMostPublishedBooks(){
        if(apexJobSelector.isJobAlreadyRunningByClassName(JOB_NAME)){
            return 'Job is already running';
        }
            
        RetryQueueable queueable = new RetryQueueable(new BookCalloutQueueable(), RETRY_COUNT);
        try {
            Id jobId = systemApi.enqueueJob(queueable);
            return jobId;
        } catch (Exception e) {
            throw new AuraHandledException('Job queueing failed: ' + e.getMessage());
        }
    }
}