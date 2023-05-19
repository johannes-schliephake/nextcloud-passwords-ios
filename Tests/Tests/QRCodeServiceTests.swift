import XCTest
import Nimble
import Factory
@testable import Passwords


final class QRCodeServiceTests: XCTestCase {
    
    @MockInjected(\.qrCodeGenerator) private var qrCodeGeneratorMock: QRCodeGeneratorMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.manager.reset()
    }
    
    func testGenerateQrCode_thenEmitsScaledGeneratorImageOnBackgroundThread() {
        let qrCodeService: any QRCodeServiceProtocol = QRCodeService()
        qrCodeGeneratorMock._outputImage = .init(data: Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAAqADAAQAAAABAAAAAgAAAADtGLyqAAAAHGlET1QAAAACAAAAAAAAAAEAAAAoAAAAAQAAAAEAAABDeWVRjwAAAA9JREFUGBliYGBg+A8CAAAAAP//Z5hE4QAAAA1JREFUY/gPBAwMDP8BVrsJ91O1pxYAAAAASUVORK5CYII=")!, options: [.nearestSampling: true])!
        
        let expectedImageData = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAADhlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAAqACAAQAAAABAAAAEKADAAQAAAABAAAAEAAAAAAXnVPIAAAAHGlET1QAAAACAAAAAAAAAAgAAAAoAAAACAAAAAgAAABNXtgsfwAAABlJREFUOBFiYGBg+I8P/ycAgHpHDRj6YQAAAAD//2gPKmsAAAAbSURBVGP4TwAwMDD8x4sJ6MevGWT4qAGDIAwAfKJ9n1S0er4AAAAASUVORK5CYII=")!
        expect(qrCodeService.generateQrCode(from: .random()).map { $0.pngData() }).to(emit(expectedImageData, onMainThread: false))
    }
    
    func testGenerateQrCode_thenCallsQrCodeGenerator() {
        let urlMock = URL.random()
        let qrCodeService: any QRCodeServiceProtocol = QRCodeService()
        
        expect(qrCodeService.generateQrCode(from: urlMock)).to(fail())
        
        let expectedData = Data(urlMock.absoluteString.utf8)
        expect(self.qrCodeGeneratorMock).toEventually(beCalled(.once, on: "setValue(_:forKey:)", withParameters: expectedData, "inputMessage"))
        expect(self.qrCodeGeneratorMock).toEventually(beAccessed(.once, on: "outputImage"))
    }
    
    func testGenerateQrCode_givenMissingGenerator_thenFailsWithGeneratorUnavailable() {
        let qrCodeService: any QRCodeServiceProtocol = QRCodeService()
        Container.shared.qrCodeGenerator.register { nil }
        
        expect(qrCodeService.generateQrCode(from: .random())).to(fail(.generatorUnavailable))
    }
    
    func testGenerateQrCode_givenFailingGenerator_thenFailsWithGenerationFailed() {
        let qrCodeService: any QRCodeServiceProtocol = QRCodeService()
        
        expect(qrCodeService.generateQrCode(from: .random())).to(fail(.generationFailed))
    }
    
    func testGenerateQrCode_givenEmptyGeneratedImage_thenFailsWithConversionFailed() {
        let qrCodeService: any QRCodeServiceProtocol = QRCodeService()
        qrCodeGeneratorMock._outputImage = .init()
        
        expect(qrCodeService.generateQrCode(from: .random())).to(fail(.conversionFailed))
    }
    
}
