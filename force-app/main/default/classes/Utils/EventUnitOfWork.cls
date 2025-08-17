public interface EventUnitOfWork {
    void registerEvent(SObject event);
    void registerEvent(List<SObject> events);
    void commitWork();
}