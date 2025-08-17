@IsTest
private class ApexJobSelectorImplTest {
    @IsTest
    static void whenNoJobRunning_shouldReturnFalse() {
        String jobName = 'Queueable';
        ApexJobSelectorImpl selector = new ApexJobSelectorImpl();
        
        Test.startTest();
        Boolean result = selector.isJobAlreadyRunningByClassName('Queueable');
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false when no job is running');
    }
}