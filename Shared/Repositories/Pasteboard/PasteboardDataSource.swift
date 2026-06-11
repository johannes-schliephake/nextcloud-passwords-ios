import Foundation
import FactoryKit


protocol PasteboardDataSourceProtocol {
    
    func set(string: String, localOnly: Bool, sensitive: Bool)
    
}


struct PasteboardDataSource: PasteboardDataSourceProtocol {
    
    @Injected(\.pasteboard) private var pasteboard
    
    func set(string: String, localOnly: Bool, sensitive: Bool) {
        pasteboard.setObjects([string], localOnly: localOnly, expirationDate: sensitive ? dependency(\.currentDate).advanced(by: 60) : nil)
    }
    
}
