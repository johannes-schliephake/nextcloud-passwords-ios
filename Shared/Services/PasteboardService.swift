import SwiftUI


protocol PasteboardServiceProtocol {
    
    func set(_ string: String)
    
}


// TODO: replace temporary implementation
struct PasteboardService: PasteboardServiceProtocol {
    
    func set(_ string: String) {
        UIPasteboard.general.string = string
    }
    
}
