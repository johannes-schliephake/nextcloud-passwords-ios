import CoreImage


protocol QRCodeGenerating {
    
    var outputImage: CIImage? { get }
    
    func setValue(_ value: Any?, forKey key: String)
    
}


extension CIFilter: QRCodeGenerating {}
