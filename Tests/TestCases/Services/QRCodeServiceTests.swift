import XCTest
import Nimble
import FactoryKit
@testable import Passwords


final class QRCodeServiceTests: XCTestCase {
    
    @LazyInjected(\.userInitiatedSchedulerMock) private var userInitiatedSchedulerMock
    @MockInjected(\.qrCodeGenerator) private var qrCodeGeneratorMock: QRCodeGeneratorMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testGenerateQrCode_thenEmitsScaledGeneratorImageOnUserInitiatedScheduler() {
        let qrCodeService: any QRCodeServiceProtocol = QRCodeService()
        qrCodeGeneratorMock._outputImage = .init(data: Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAAqADAAQAAAABAAAAAgAAAADtGLyqAAAAHGlET1QAAAACAAAAAAAAAAEAAAAoAAAAAQAAAAEAAABDeWVRjwAAAA9JREFUGBliYGBg+A8CAAAAAP//Z5hE4QAAAA1JREFUY/gPBAwMDP8BVrsJ91O1pxYAAAAASUVORK5CYII=")!, options: [.nearestSampling: true])!
        
        let expectedImageData = if #available(iOS 17, *) {
            Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAHhlWElmTU0AKgAAAAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIAAIdpAAQAAAABAAAAWgAAAAAAAABIAAAAAQAAAEgAAAABAAKgAgAEAAAAAQAAABCgAwAEAAAAAQAAABAAAAAAiKeUQwAAAAlwSFlzAAALEwAACxMBAJqcGAAAABxpRE9UAAAAAgAAAAAAAAAIAAAAKAAAAAgAAAAIAAAATV7YLH8AAAAZSURBVDgRYmBgYPiPD/8nAIB6Rw0Y+mEAAAAA//9oDyprAAAAG0lEQVRj+E8AMDAw/MeLCejHrxlk+KgBgyAMAHyifZ9UtHq+AAAAAElFTkSuQmCC")!
        } else {
            Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAADhlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAAqACAAQAAAABAAAAEKADAAQAAAABAAAAEAAAAAAXnVPIAAAAHGlET1QAAAACAAAAAAAAAAgAAAAoAAAACAAAAAgAAABNXtgsfwAAABlJREFUOBFiYGBg+I8P/ycAgHpHDRj6YQAAAAD//2gPKmsAAAAbSURBVGP4TwAwMDD8x4sJ6MevGWT4qAGDIAwAfKJ9n1S0er4AAAAASUVORK5CYII=")!
        }
        expect(qrCodeService.generateQrCode(from: .random()).map { $0.pngData() })
            .toNot(emit())
            .to(emit(expectedImageData, when: { self.userInitiatedSchedulerMock.advance() }))
    }
    
    func testGenerateQrCode_thenCallsQrCodeGenerator() throws {
        let urlMock = URL.random()
        let qrCodeService: any QRCodeServiceProtocol = QRCodeService()
        
        try require(qrCodeService.generateQrCode(from: urlMock)).to(fail(when: { self.userInitiatedSchedulerMock.advance() }))
        
        let expectedData = Data(urlMock.absoluteString.utf8)
        expect(self.qrCodeGeneratorMock).to(beCalled(.once, on: "setValue(_:forKey:)", withParameters: expectedData, "inputMessage"))
        expect(self.qrCodeGeneratorMock).to(beAccessed(.once, on: "outputImage"))
    }
    
    func testGenerateQrCode_givenMissingGenerator_thenFailsWithGeneratorUnavailable() {
        Container.shared.qrCodeGenerator.register { nil }
        let qrCodeService: any QRCodeServiceProtocol = QRCodeService()
        
        expect(qrCodeService.generateQrCode(from: .random())).to(fail(.generatorUnavailable, when: { self.userInitiatedSchedulerMock.advance() }))
    }
    
    func testGenerateQrCode_givenFailingGenerator_thenFailsWithGenerationFailed() {
        let qrCodeService: any QRCodeServiceProtocol = QRCodeService()
        
        expect(qrCodeService.generateQrCode(from: .random())).to(fail(.generationFailed, when: { self.userInitiatedSchedulerMock.advance() }))
    }
    
    func testGenerateQrCode_givenEmptyGeneratedImage_thenFailsWithConversionFailed() {
        let qrCodeService: any QRCodeServiceProtocol = QRCodeService()
        qrCodeGeneratorMock._outputImage = .init()
        
        expect(qrCodeService.generateQrCode(from: .random())).to(fail(.conversionFailed, when: { self.userInitiatedSchedulerMock.advance() }))
    }
    
}
