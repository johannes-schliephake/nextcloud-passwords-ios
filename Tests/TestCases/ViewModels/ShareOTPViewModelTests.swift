import XCTest
import Nimble
import Factory
@testable import Passwords


final class ShareOTPViewModelTests: XCTestCase {
    
    private let urlMock = URL.random()
    
    @LazyInjected(\.mainSchedulerMock) private var mainSchedulerMock
    @MockInjected(\.qrCodeService) private var qrCodeServiceMock: QRCodeServiceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_thenSetsInitialState() {
        let shareOtpViewModel: any ShareOTPViewModelProtocol = ShareOTPViewModel(otpUrl: urlMock)
        
        expect(shareOtpViewModel[\.qrCode]).to(beNil())
        expect(shareOtpViewModel[\.qrCodeAvailable]).to(beFalse())
    }
    
    func testInit_thenCallsQrCodeService() {
        _ = ShareOTPViewModel(otpUrl: urlMock)
        
        expect(self.qrCodeServiceMock).to(beCalled(.once, on: "generateQrCode(from:)", withParameter: urlMock))
    }
    
    func testInit_whenQrCodeServiceEmittingGeneratorUnavailableFailure_thenDoesntSetQrCode() {
        let shareOtpViewModel: any ShareOTPViewModelProtocol = ShareOTPViewModel(otpUrl: urlMock)
        
        qrCodeServiceMock._generateQrCode.send(completion: .failure(.generatorUnavailable))
        mainSchedulerMock.advance()
        
        expect(shareOtpViewModel[\.qrCode]).to(beNil())
        expect(shareOtpViewModel[\.qrCodeAvailable]).to(beFalse())
    }
    
    func testInit_whenQrCodeServiceEmittingGenerationFailedFailure_thenDoesntSetQrCode() {
        let shareOtpViewModel: any ShareOTPViewModelProtocol = ShareOTPViewModel(otpUrl: urlMock)
        
        qrCodeServiceMock._generateQrCode.send(completion: .failure(.generationFailed))
        mainSchedulerMock.advance()
        
        expect(shareOtpViewModel[\.qrCode]).to(beNil())
        expect(shareOtpViewModel[\.qrCodeAvailable]).to(beFalse())
    }
    
    func testInit_whenQrCodeServiceEmittingConversionFailedFailure_thenDoesntSetQrCode() {
        let shareOtpViewModel: any ShareOTPViewModelProtocol = ShareOTPViewModel(otpUrl: urlMock)
        
        qrCodeServiceMock._generateQrCode.send(completion: .failure(.conversionFailed))
        mainSchedulerMock.advance()
        
        expect(shareOtpViewModel[\.qrCode]).to(beNil())
        expect(shareOtpViewModel[\.qrCodeAvailable]).to(beFalse())
    }
    
    func testInit_whenQrCodeServiceEmittingQrCode_thenSetsQrCodeOnMainScheduler() {
        let shareOtpViewModel: any ShareOTPViewModelProtocol = ShareOTPViewModel(otpUrl: urlMock)
        let imageMock = UIImage(systemName: "qrcode")!
        
        expect(shareOtpViewModel[\.$qrCode].dropFirst())
            .toNot(emit(when: { self.qrCodeServiceMock._generateQrCode.send(imageMock) }))
            .to(emit(imageMock, when: { self.mainSchedulerMock.advance() }))
        expect(shareOtpViewModel[\.$qrCodeAvailable].dropFirst())
            .toNot(emit(when: { self.qrCodeServiceMock._generateQrCode.send(imageMock) }))
            .to(emit(true, when: { self.mainSchedulerMock.advance() }))
    }
    
}
