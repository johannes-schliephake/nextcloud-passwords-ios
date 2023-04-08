import ObjectiveC.runtime


protocol PropertyAccessLogging: AnyObject {
    
    typealias Log = [String]
    
    var propertyAccessLog: Log { get set }
    
}


private var kPropertyAccessLog = "kFunctionCallLog"


extension PropertyAccessLogging {
    
    var propertyAccessLog: Log {
        get {
            guard let propertyAccessLog = objc_getAssociatedObject(self, &kPropertyAccessLog) as? Log else {
                let propertyAccessLog = Log()
                self.propertyAccessLog = propertyAccessLog
                return propertyAccessLog
            }
            return propertyAccessLog
        }
        set {
            objc_setAssociatedObject(self, &kPropertyAccessLog, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}


extension PropertyAccessLogging {
    
    func propertyAccessLog(of propertyName: String) -> Log {
        propertyAccessLog.filter { $0 == propertyName }
    }
    
    func logPropertyAccess(of propertyName: String = #function) {
        propertyAccessLog.append(propertyName)
    }
    
}
