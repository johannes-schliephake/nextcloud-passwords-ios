import Foundation


extension Bundle {
    
    var isTestFlight: Bool {
        appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }
    
}
