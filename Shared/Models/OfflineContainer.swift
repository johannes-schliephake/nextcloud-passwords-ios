import CoreData


@objc(OfflineContainer) final class OfflineContainer: NSManagedObject {
    
    @NSManaged var data: Data
    @NSManaged var rawType: Int16
    
    var type: Type {
        get {
            Type(rawValue: rawType) ?? .folder
        }
        set {
            rawType = newValue.rawValue
        }
    }
    
    convenience init(context: NSManagedObjectContext, folder: Folder) {
        self.init(context: context)
        
        self.type = .folder
        update(from: folder)
    }
    
    convenience init(context: NSManagedObjectContext, password: Password) {
        self.init(context: context)
        
        self.type = .password
        update(from: password)
    }
    
    func update(from folder: Folder) {
        let key = Crypto.AES256.getKey(named: "offlineKey")
        guard let data = Crypto.AES256.encrypt(folder: folder, key: key) else {
            return
        }
        self.data = data
    }
    
    func update(from password: Password) {
        let key = Crypto.AES256.getKey(named: "offlineKey")
        guard let data = Crypto.AES256.encrypt(password: password, key: key) else {
            return
        }
        self.data = data
    }
    
}


extension OfflineContainer {
    
    @nonobjc class func request() -> NSFetchRequest<OfflineContainer> {
        NSFetchRequest<OfflineContainer>(entityName: "OfflineContainer")
    }
    
}


extension OfflineContainer {
    
    enum `Type`: Int16 {
        case folder
        case password
    }
    
}
