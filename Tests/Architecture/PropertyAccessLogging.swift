protocol PropertyAccessLogging: AnyObject {
    
    var propertyAccessLog: [String] { get set }
    
}


extension PropertyAccessLogging {
    
    func logPropertyAccess(of propertyName: String = #function) {
        propertyAccessLog.append(propertyName)
    }
    
}
