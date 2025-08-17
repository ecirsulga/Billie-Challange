public interface SystemApi {
	Id enqueueJob(System.Queueable queueable);
	Id enqueueJob(System.Queueable queueable, Integer delay);
}