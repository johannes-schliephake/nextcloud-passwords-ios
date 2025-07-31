import Foundation // swiftlint:disable:this file_name


protocol CryptoSHA256Protocol {
    
    static func hash(_ data: Data, humanReadable: Bool) -> String
    
}


extension CryptoSHA256Protocol {
    
    static func hash(_ data: Data) -> String {
        hash(data, humanReadable: false)
    }
    
}


extension Crypto.SHA256: CryptoSHA256Protocol {}
