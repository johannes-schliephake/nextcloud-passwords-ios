import CoreImage


protocol QRCodeGenerating {
    
    var outputImage: CIImage? { get }
    
    func setValue(_ value: Any?, forKey: String)
    
}


extension CIFilter: QRCodeGenerating {}
