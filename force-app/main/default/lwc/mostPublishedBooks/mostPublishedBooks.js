import { LightningElement, track } from 'lwc';
import { subscribe, onError } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchMostPublishedBooks from '@salesforce/apex/MostPublishedBooksController.fetchMostPublishedBooks';

export default class MostPublishedBooks extends LightningElement {
    @track books = [];
    @track isLoading = false;
    subscription = {};
    channelName = '/event/PublishedBook__e';
    currentJobId = null;

    connectedCallback() {
        this.handleSubscribe();
        this.registerErrorListener();
    }

    handleSubscribe() {
        const messageCallback = (response) => {
            this.handlePlatformEvent(response);
            this.isLoading = false;
        };

        subscribe(this.channelName, -1, messageCallback).then(response => {
            this.subscription = response;
            console.log('Subscribed to PublishedBook__e events');
        }).catch(error => {
            console.error('Subscription error: ', error);
            this.showToast('Error', 'Failed to subscribe to events', 'error');
        });
    }

    registerErrorListener() {
        onError(error => {
            console.error('EMP API error: ', error);
            this.showToast('Error', 'Platform event subscription error', 'error');
        });
    }

    handlePlatformEvent(response) {
        const eventData = response.data.payload;
        
        const bookId = `${eventData.Title__c}_${eventData.Author__c}_${Date.now()}`;
        
        const newBook = {
            id: bookId,
            title: eventData.Title__c,
            author: eventData.Author__c,
            edition: eventData.Edition__c,
            publisher: eventData.Publisher__c,
            rank: this.books.length + 1
        };

        this.books = [...this.books, newBook];
        
        this.books = this.books.map((book, index) => ({
            ...book,
            rank: index + 1
        }));
    }

    async handleTriggerFetch() {
        this.isLoading = true;
        
        try {
            const jobId = await fetchMostPublishedBooks();
            this.books = [];
            this.currentJobId = jobId;
            
            this.showToast(
                'Success', 
                `Book fetch job queued successfully. Job ID: ${jobId}`, 
                'success'
            );
            
        } catch (error) {
            this.handleError(error, 'Error triggering fetch');
        }
    }

    handleClearList() {
        this.books = [];
        this.showToast('Success', 'Book list cleared', 'success');
    }

    handleError(error, defaultMessage) {
        const message = error.body?.message || error.message || defaultMessage;
        this.showToast('Error', message, 'error');
        console.error(defaultMessage, error);
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    get hasBooks() {
        return this.books.length > 0;
    }

    get totalBooks() {
        return this.books.length;
    }
}