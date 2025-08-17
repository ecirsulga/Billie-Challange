public with sharing class BookCalloutQueueable implements RetryQueueable.Retryable{
    private final EventUnitOfWork uow;
    private final BookFetchService  bookFetchService;

    public BookCalloutQueueable() {
        this(new EventUnitOfWorkImpl(), new BookFetchServiceImpl());
    }

    public BookCalloutQueueable(EventUnitOfWork uow, BookFetchService bookFetchService) {
        this.uow = uow;
        this.bookFetchService = bookFetchService;
    }

    public void execute(QueueableContext context, Integer retryCount){

        List<BookFetchServiceImpl.BookWithPublisher> bookData = this.bookFetchService.calloutAndParseResponse();

        //Ideally this should be in some kind of repository/domain layer
        bookData.sort();
        publishEvents(bookData);

        this.uow.commitWork();
    }

    public void retriesExceeded(RetryQueueable.RetriesExceededException exc) {
        // Ideally it should have some kind of log mechanism. I prefer using Nebula logger.
		throw exc;
	}

    private void publishEvents(List<BookFetchServiceImpl.BookWithPublisher> books){
        for(BookFetchServiceImpl.BookWithPublisher book : books){
            this.uow.registerEvent(
                new PublishedBook__e(
                Author__c = book.Author,
                Title__c = book.Title,
                Edition__c = book.Edition,
                Publisher__c = book.Publisher)
                );
        }
    }
}