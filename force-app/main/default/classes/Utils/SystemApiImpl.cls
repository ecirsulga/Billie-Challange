public inherited sharing class SystemApiImpl implements SystemApi {
	public Id enqueueJob(System.Queueable queueable) {
		return System.System.enqueueJob(queueable);
	}

	public Id enqueueJob(System.Queueable queueable, Integer delay) {
		return System.System.enqueueJob(queueable, delay);
	}
}