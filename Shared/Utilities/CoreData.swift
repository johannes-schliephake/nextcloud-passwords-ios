import CoreData


final class CoreData {
    
    static let `default` = CoreData()
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    private let container: NSPersistentContainer

    init() {
        guard let containerPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Configuration.appGroup) else {
            fatalError("Can't locate the app's group directory") // swiftlint:disable:this fatal_error
        }
        let containerURL = containerPath.appendingPathComponent("CoreData.sqlite")
        let persistentStoreDescription = NSPersistentStoreDescription(url: containerURL)
        
        container = NSPersistentContainer(name: "CoreData")
        container.persistentStoreDescriptions = [persistentStoreDescription]
        container.loadPersistentStores { _, _ in }
    }
    
    func fetch<T>(request: NSFetchRequest<T>) -> [T]? where T: NSManagedObject {
        try? Self.default.container.viewContext.fetch(request)
    }
    
    func save() {
        guard container.viewContext.hasChanges else {
            return
        }
        try? container.viewContext.save()
    }
    
    func delete(_ object: NSManagedObject?) {
        guard let object else {
            return
        }
        container.viewContext.delete(object)
    }
    
    func clear<T>(type: T.Type) where T: NSManagedObject {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: type.fetchRequest())
        _ = try? Self.default.container.viewContext.execute(deleteRequest)
    }
    
}
