import Foundation
import Factory


protocol PasteboardDataSourceProtocol {
    
    func set(string: String, localOnly: Bool, sensitive: Bool)
    
}


struct PasteboardDataSource: PasteboardDataSourceProtocol {
    
    @Injected(\.pasteboard) private var pasteboard
    
    func set(string: String, localOnly: Bool, sensitive: Bool) {
        pasteboard.setObjects([string], localOnly: localOnly, expirationDate: sensitive ? resolve(\.currentDate).advanced(by: 60) : nil)
    }
    
}
