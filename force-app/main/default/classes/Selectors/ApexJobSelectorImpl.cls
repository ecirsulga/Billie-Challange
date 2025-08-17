public with sharing class ApexJobSelectorImpl implements ApexJobSelector{
    public Boolean isJobAlreadyRunningByClassName(String jobName) {
        List<AsyncApexJob> runningJobs = [
            SELECT Id 
            FROM AsyncApexJob 
            WHERE ApexClass.Name =:jobName
            AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
            LIMIT 1
        ];
        
        return !runningJobs.isEmpty();
    }
}