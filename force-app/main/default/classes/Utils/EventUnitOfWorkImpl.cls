public with sharing class EventUnitOfWorkImpl implements EventUnitOfWork {
    @TestVisible
    private final List<SObject> eventsToPublish = new List<SObject>();

     public void registerEvent(List<SObject> events) {
        for (SObject event : events) {
            registerEvent(event);
        }
    }

    public void registerEvent(SObject event) {
        String sObjectType = event.getSObjectType().getDescribe().getName();
        validate(sObjectType);
        this.eventsToPublish.add(event);
    }

    private void validate(String sObjectType) {
        if (sObjectType.length() > 3 && sObjectType.right(3) != '__e'){
             throw new UnitOfWorkException('Not a valid SObjectType. Only Platform Events are supported in this UOW');
        }
    }

    public void commitWork() {
        if (eventsToPublish.size() > 0) {
            List<Database.SaveResult> results = EventBus.publish(this.eventsToPublish);
            
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    throw new UnitOfWorkException('Error on publishing event: ' + sr.getErrors());
                }
            }
        }
    }

    public class UnitOfWorkException extends Exception {
    }
}