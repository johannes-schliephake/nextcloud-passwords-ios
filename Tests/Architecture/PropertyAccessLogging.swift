protocol PropertyAccessLogging: AnyObject {
    
    typealias PropertyAccess = String
    
    var propertyAccessLog: [PropertyAccess] { get set }
    
}


extension PropertyAccessLogging {
    
    func propertyAccessLog(of propertyName: String) -> [PropertyAccess] {
        propertyAccessLog.filter { $0 == propertyName }
    }
    
    func logPropertyAccess(of propertyName: String = #function) {
        propertyAccessLog.append(propertyName)
    }
    
}
