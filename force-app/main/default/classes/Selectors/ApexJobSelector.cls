public interface ApexJobSelector {
    Boolean isJobAlreadyRunningByClassName(String jobName);
}