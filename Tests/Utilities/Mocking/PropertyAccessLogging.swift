protocol PropertyAccessLogging: AnyObject, Associating {
    
    typealias Log = [String]
    
    static var propertyAccessLog: Log { get set }
    var propertyAccessLog: Log { get set }
    
}


extension PropertyAccessLogging {
    
    static var propertyAccessLog: Log {
        get { getAssociated() }
        set { setAssociated(newValue) }
    }
    
    var propertyAccessLog: Log {
        get { getAssociated() }
        set { setAssociated(newValue) }
    }
    
    static func propertyAccessLog(of propertyName: String) -> Log {
        propertyAccessLog.filter { $0 == propertyName }
    }
    
    static func logPropertyAccess(of propertyName: String = #function) {
        propertyAccessLog.append(propertyName)
    }
    
    func propertyAccessLog(of propertyName: String) -> Log {
        propertyAccessLog.filter { $0 == propertyName }
    }
    
    func logPropertyAccess(of propertyName: String = #function) {
        propertyAccessLog.append(propertyName)
    }
    
}
