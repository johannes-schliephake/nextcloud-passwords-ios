import Foundation
import Factory


extension DispatchQueue {
    
    convenience init(qos: DispatchQoS = .default, fileID: String = #fileID, functionName: String = #function, line: UInt = #line) {
        let label = [
            resolve(\.configurationType).appService,
            fileID,
            functionName,
            String(line)
        ].joined(separator: ".")
        
        self.init(label: label, qos: qos)
    }
    
}
