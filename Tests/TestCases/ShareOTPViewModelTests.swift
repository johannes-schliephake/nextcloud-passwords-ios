import XCTest
import Nimble
import Factory
@testable import Passwords


final class ShareOTPViewModelTests: XCTestCase {
    
    private let urlMock = URL.random()
    
    @MockInjected(\.qrCodeService) private var qrCodeServiceMock: QRCodeServiceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.manager.reset()
    }
    
    func testInit_thenSetsInitialState() {
        let shareOtpViewModel: any ShareOTPViewModelProtocol = ShareOTPViewModel(otpUrl: urlMock)
        
        expect(shareOtpViewModel[\.qrCode]).to(beNil())
        expect(shareOtpViewModel[\.qrCodeAvailable]).to(beFalse())
        expect(shareOtpViewModel[\.showShareSheet]).to(beFalse())
    }
    
    func testInit_thenCallsQrCodeService() {
        _ = ShareOTPViewModel(otpUrl: urlMock)
        
        expect(self.qrCodeServiceMock).to(beCalled(.once, on: "generateQrCode(from:)", withParameter: urlMock))
    }
    
    func testInit_whenQrCodeServiceEmittingGeneratorUnavailableFailure_thenDoesntSetQrCode() {
        let shareOtpViewModel: any ShareOTPViewModelProtocol = ShareOTPViewModel(otpUrl: urlMock)
        
        qrCodeServiceMock._generateQrCode.send(completion: .failure(.generatorUnavailable))
        
        expect(shareOtpViewModel[\.qrCode]).to(beNil())
        expect(shareOtpViewModel[\.qrCodeAvailable]).to(beFalse())
    }
    
    func testInit_whenQrCodeServiceEmittingGenerationFailedFailure_thenDoesntSetQrCode() {
        let shareOtpViewModel: any ShareOTPViewModelProtocol = ShareOTPViewModel(otpUrl: urlMock)
        
        qrCodeServiceMock._generateQrCode.send(completion: .failure(.generationFailed))
        
        expect(shareOtpViewModel[\.qrCode]).to(beNil())
        expect(shareOtpViewModel[\.qrCodeAvailable]).to(beFalse())
    }
    
    func testInit_whenQrCodeServiceEmittingConversionFailedFailure_thenDoesntSetQrCode() {
        let shareOtpViewModel: any ShareOTPViewModelProtocol = ShareOTPViewModel(otpUrl: urlMock)
        
        qrCodeServiceMock._generateQrCode.send(completion: .failure(.conversionFailed))
        
        expect(shareOtpViewModel[\.qrCode]).to(beNil())
        expect(shareOtpViewModel[\.qrCodeAvailable]).to(beFalse())
    }
    
    func testInit_whenQrCodeServiceEmittingQrCode_thenSetsQrCode() {
        let shareOtpViewModel: any ShareOTPViewModelProtocol = ShareOTPViewModel(otpUrl: urlMock)
        let imageMock = UIImage(systemName: "qrcode")!
        
        qrCodeServiceMock._generateQrCode.send(imageMock)
        
        expect(shareOtpViewModel[\.qrCode]).toEventually(be(imageMock))
        expect(shareOtpViewModel[\.qrCodeAvailable]).toEventually(beTrue())
    }
    
    func testInit_whenQrCodeServiceEmittingQrCodeFromBackgroundThread_thenSetsQrCodeFromMainThread() {
        let shareOtpViewModel: any ShareOTPViewModelProtocol = ShareOTPViewModel(otpUrl: urlMock)
        let imageMock = UIImage(systemName: "qrcode")!
        
        expect(shareOtpViewModel[\.$qrCode].dropFirst()).to(emit(imageMock, onMainThread: true, when: { self.qrCodeServiceMock._generateQrCode.send(imageMock) }, from: .init()))
        expect(shareOtpViewModel[\.$qrCodeAvailable].dropFirst()).to(emit(true, onMainThread: true, when: { self.qrCodeServiceMock._generateQrCode.send(imageMock) }, from: .init()))
    }
    
    func testCallAsFunction_whenCallingShare_thenSetsShowShareSheetToTrue() {
        let shareOtpViewModel: any ShareOTPViewModelProtocol = ShareOTPViewModel(otpUrl: urlMock)
        
        shareOtpViewModel(.share)
        
        expect(shareOtpViewModel[\.showShareSheet]).to(beTrue())
    }

}
