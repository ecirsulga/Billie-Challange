public with sharing class BookFetchServiceImpl implements BookFetchService{
    private final String BASE_URL = 'callout:Billie_Books_Named_Credentials';
    private final String METHOD = 'GET';
    private final Integer MIN_EDITION = 600000;

    public List<BookWithPublisher> calloutAndParseResponse(){
        HttpResponse response = makeCallOut();
        List<PublisherData> publishers = (List<PublisherData>)JSON.deserialize(
        response.getBody(), 
        List<PublisherData>.class
        );
        List<BookWithPublisher> compareBooks = new List<BookWithPublisher>();
    
        for (PublisherData publisher : publishers) {
        if (publisher.Books != null) {
            for (BookData book : publisher.Books) {
                    if (book.Edition > MIN_EDITION) {
                        compareBooks.add(new BookWithPublisher(
                            book.Author,
                            book.Title,
                            book.Edition,
                            publisher.Publisher
                        ));
                    }
                }
            }
        }
        return compareBooks;
    }

    private HttpResponse makeCallOut(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(this.BASE_URL);
        req.setMethod(this.METHOD);
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = http.send(req);
        if(response.getStatusCode() == 200){
            return response;
        }
        else {
            throw new CalloutException('Error while making callout' + response.getStatusCode() + ' ' + response.getBody() + ' ' + this.BASE_URL + ' ' + this.METHOD + '');
        }
    }

    public class BookWithPublisher implements Comparable {
        public String Author;
        public String Title;
        public Integer Edition;
        public String Publisher;
        
        public BookWithPublisher(String author, String title, Integer edition, String publisher) {
            this.Author = author;
            this.Title = title;
            this.Edition = edition;
            this.Publisher = publisher;
        }
        
        public Integer compareTo(Object compareTo) {
            BookWithPublisher compareBook = (BookWithPublisher)compareTo;
            return compareBook.Edition - this.Edition;
        }
    }

    public class PublisherData {
        public String Publisher;
        public List<BookData> Books;
    }
    
    public class BookData {
        public String Author;
        public String Title;
        public Integer Edition;
    }
}