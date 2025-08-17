// FOR BILLIE: I got this from my own old project. Didn't want to rewrite :). Usually you wouldn't use retries on get calls but its really useful for syncs
public class RetryQueueable implements Queueable, Database.AllowsCallouts {
	/**
	 * Objects implementing this Interface can be wrapped with the RetryQueueable,
	 * to be automatically retried on failure
	 */
	public interface Retryable {
		void execute(System.QueueableContext context, Integer retryCount);
		/**
		 * is executed if maxRetries were exceeded
		 */
		void retriesExceeded(RetriesExceededException exc);
	}

	/**
	 * RetryQueables can use different Backoff strategies, that can be implemented
	 * with this interface.
	 */
	public interface Backoff {
		/**
		 * @param count current count of retries
		 * @return delay for the next Retry in minutes (SF Limitation: 10 minutes max.)
		 */
		Double minutes(Integer count);
	}

	private final SystemApi systemApi;
	private final Retryable retryable;
	private final Backoff backoff;
	private final Integer count;
	private final Integer maxRetries;

	/**
	 * secondary ctor
	 * @param retryable Instance of Retryable, that will be retried on failure
	 * @param maxRetries Maximum number of retries, will be fit into exponential delay of 10 minutes max
	 */
	public RetryQueueable(Retryable retryable, Integer maxRetries) {
		this(retryable, maxRetries, new ExponentialBackoff(1, 10, maxRetries));
	}

	/**
	 * secondary ctor
	 * @param retryable Instance of Retryable, that will be retried on failure
	 * @param backoff backoff mechanism to use for delaying
	 * @param maxRetries Maximum number of retries, will be fit into exponential delay of 10 minutes max
	 */
	public RetryQueueable(Retryable retryable, Integer maxRetries, Backoff backoff) {
		this(retryable, maxRetries, backoff, 0, new SystemApiImpl());
	}

	/**
	 * primary ctor
	 * @param retryable Instance of Retryable, that will be retried on failure
	 * @param maxRetries Maximum number of retries, will be fit into exponential delay of 10 minutes max
	 * @param backoff backoff mechanism to use for delaying defaults to Exponential which repeats after 1 2 4 6 10 minutes
	 * @param count current retry count (0-based)
	 * @param systemApi Instance of SystemApi
	 */
	@TestVisible
	private RetryQueueable(Retryable retryable, Integer maxRetries, Backoff backoff, Integer count, SystemApi systemApi) {
		this.retryable = retryable;
		this.backoff = backoff;
		this.maxRetries = maxRetries;
		this.count = count;
		this.systemApi = systemApi;
	}

	/**
	 * System.Queueable implementation. Entrypoint called by SF, when Queueable is started
	 */
	public void execute(QueueableContext context) {
		Retryable nextRetryable;
		try {
			this.retryable.execute(context, this.count);
		} catch (Exception e) {
			System.debug('Failed Retry: ' + e.getMessage());
			System.debug(e.getStackTraceString());
			nextRetryable = retryable;
		}

		if (nextRetryable != null) {
			if (this.count < this.maxRetries && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
				this.scheduleRetry(nextRetryable);
			} else {
				RetriesExceededException exc = new RetriesExceededException(
					String.format(
						'Maximum number of retries ({0}) exceeded for: {1}',
						new List<Object>{ this.maxRetries, String.valueOf(this.retryable).substringBefore(':') }
					),
					this.count
				);
				nextRetryable.retriesExceeded(exc);
			}
		}
	}

	private void scheduleRetry(Retryable nextRetryable) {
		Integer minutesFromNow = this.backoff.minutes(this.count).round().intValue();
		Integer nextCount = this.count + 1;

		RetryQueueable nextTry = new RetryQueueable(
			nextRetryable,
			this.maxRetries,
			this.backoff,
			nextCount,
			this.systemApi
		);
		this.systemApi.enqueueJob(nextTry, minutesFromNow);
	}

	/**
	 * Exception Type, that can be thrown by Retryable objects, allows passing a new instance for the next retry
	 */
	public class RetryException extends Exception {
		private final Retryable nextTry;

		public RetryException(Retryable nextTry, String message) {
			this(nextTry, message, null);
		}

		public RetryException(Retryable nextTry, String message, Exception innerEx) {
			// Apex quirk: when extending BaseException, the upper constructor is called with this() and not super()
			this(message, innerEx);
			this.nextTry = nextTry;
		}

		public Retryable getNextRetryable() {
			return this.nextTry;
		}
	}

	/**
	 * Exception Type that gets thrown if all Retries have failed, makes the failure show up
	 * in Error Emails and the Apex Jobs overview page
	 */
	public class RetriesExceededException extends Exception {
		public final Integer count;

		public RetriesExceededException(String message, Integer count) {
			// Apex quirk: when extending BaseException, the upper constructor is called with this() and not super()
			this(message);
			this.count = count;
		}
	}

	/**
	 * Backoff strategy that makes the delays between retries grow exponentially (recommended for callouts)
	 */
	public class ExponentialBackoff implements Backoff {
		private final Double minDelay;
		private final Double base;

		/**
		 * secondary ctor
		 * fits as many retries as wanted between a minimum and maximum delay
		 * @param minDelay minimum delay (in minutes)
		 * @param maxDelay maximum delay (in minutes)
		 * @param maxIterations number of iterations, that should be fit between minDelay and maxDelay
		 */
		public ExponentialBackoff(Double minDelay, Double maxDelay, Integer maxIterations) {
			this(minDelay, Math.pow(maxDelay / minDelay, 1 / Double.valueOf(maxIterations - 1)));
		}

		/**
		 * primary ctor
		 * @param minDelay minimum delay (in minutes)
		 * @param base exponential base value (should be >= 1)
		 */
		public ExponentialBackoff(Double minDelay, Double base) {
			this.minDelay = minDelay;
			this.base = base;
		}

		public Double minutes(Integer iteration) {
			return this.minDelay * Math.pow(this.base, iteration);
		}
	}
}