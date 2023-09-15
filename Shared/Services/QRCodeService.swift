import Combine
import SwiftUI
import Factory


protocol QRCodeServiceProtocol {
    
    func generateQrCode(from url: URL) -> AnyPublisher<UIImage, QRCodeError>
    
}


enum QRCodeError: Error {
    case generatorUnavailable
    case generationFailed
    case conversionFailed
}


struct QRCodeService: QRCodeServiceProtocol {
    
    func generateQrCode(from url: URL) -> AnyPublisher<UIImage, QRCodeError> {
        Just(url)
            .receive(on: DispatchQueue(qos: .userInitiated))
            .map { Data($0.absoluteString.utf8) }
            .map { data in
                let filter = resolve(\.qrCodeGenerator)
                filter?.setValue(data, forKey: "inputMessage")
                return filter
            }
            .replaceNil(with: .generatorUnavailable)
            .map(\.outputImage)
            .replaceNil(with: .generationFailed)
            .map { ciImage in
                let transform = CGAffineTransform(scaleX: 8, y: 8)
                let scaledCiImage = ciImage.transformed(by: transform)
                return CIContext().createCGImage(scaledCiImage, from: scaledCiImage.extent)
            }
            .replaceNil(with: .conversionFailed)
            .map(UIImage.init)
            .eraseToAnyPublisher()
    }
    
}
