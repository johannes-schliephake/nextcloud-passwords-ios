import Darwin


class ReadersWriterLock {
    
    private var lock = pthread_rwlock_t()
    
    public init() {
        pthread_rwlock_init(&lock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    func read<Result>(_ block: () throws -> Result) rethrows -> Result {
        pthread_rwlock_rdlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        return try block()
    }
    
    func write<Result>(_ block: () throws -> Result) rethrows -> Result {
        pthread_rwlock_wrlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        return try block()
    }
    
}
