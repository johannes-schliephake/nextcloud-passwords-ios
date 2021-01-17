import Foundation


final class AutoFillController: ObservableObject {
    
    /// Attributes may be set by password credential extension
    @Published var complete: ((String, String) -> Void)?
    @Published var cancel: (() -> Void)?
    @Published var serviceURLs: [URL]?
    
}


extension AutoFillController: MockObject {
    
    static var mock: AutoFillController {
        AutoFillController()
    }
    
}
