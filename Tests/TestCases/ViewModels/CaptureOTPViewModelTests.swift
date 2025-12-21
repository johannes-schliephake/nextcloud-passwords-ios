import XCTest
import Nimble
import Factory
@testable import Passwords


final class CaptureOTPViewModelTests: XCTestCase {
    
    @Injected(\.otp) private var otpMock
    
    @LazyInjected(\.mainSchedulerMock) private var mainSchedulerMock
    @MockInjected(\.otpService) private var otpServiceMock: OTPServiceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_thenSetsInitialState() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        
        expect(captureOtpViewModel[\.showErrorAlert]).to(beFalse())
        expect(captureOtpViewModel[\.didCaptureOtp]).to(beFalse())
    }
    
    func testCallAsFunction_whenCallingCaptureQrResultWithSuccess_thenCallsOtpService() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        let urlStringMock = String.random()
        
        captureOtpViewModel(.captureQrResult(.success(urlStringMock)))
        
        expect(self.otpServiceMock).to(beCalled(.once, on: "makeOtp(urlString:)", withParameter: urlStringMock))
    }
    
    func testCallAsFunction_givenMakeOtpReturnsValue_whenCallingCaptureQrResultWithSuccess_thenSetsDidCaptureOtpToTrue() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        otpServiceMock._makeOtp = otpMock
        
        captureOtpViewModel(.captureQrResult(.success(.random())))
        
        expect(captureOtpViewModel[\.didCaptureOtp]).to(beTrue())
    }
    
    func testCallAsFunction_givenMakeOtpReturnsNil_whenCallingCaptureQrResultWithSuccess_thenDoesntSetDidCaptureOtpToTrue() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        
        captureOtpViewModel(.captureQrResult(.success(.random())))
        
        expect(captureOtpViewModel[\.didCaptureOtp]).to(beFalse())
    }
    
    func testCallAsFunction_givenMakeOtpReturnsValue_whenCallingCaptureQrResultWithSuccess_thenCallsCaptureOtp() {
        let closure = ClosureMock()
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel(captureOtp: closure.log)
        otpServiceMock._makeOtp = otpMock
        
        captureOtpViewModel(.captureQrResult(.success(.random())))
        
        expect(closure).to(beCalled(.once, withParameter: otpMock))
    }
    
    func testCallAsFunction_givenMakeOtpReturnsValue_whenCallingCaptureQrResultTwiceWithSuccess_thenCallsCaptureOtpOnce() {
        let closure = ClosureMock()
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel(captureOtp: closure.log)
        otpServiceMock._makeOtp = otpMock
        
        captureOtpViewModel(.captureQrResult(.success(.random())))
        captureOtpViewModel(.captureQrResult(.success(.random())))
        
        expect(closure).to(beCalled(.once))
    }
    
    func testCallAsFunction_givenMakeOtpReturnsNil_whenCallingCaptureQrResultWithSuccess_thenDoesntCallCaptureOtp() {
        let closure = ClosureMock()
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel(captureOtp: closure.log)
        
        captureOtpViewModel(.captureQrResult(.success(.random())))
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenMakeOtpReturnsValue_whenCallingCaptureQrResultWithSuccess_thenShouldDismissEmits() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        otpServiceMock._makeOtp = otpMock
        
        expect(captureOtpViewModel[\.shouldDismiss]).to(emit(when: { captureOtpViewModel(.captureQrResult(.success(.random()))) }))
    }
    
    func testCallAsFunction_givenDidCaptureOtpIsTrueAndMakeOtpReturnsValue_whenCallingCaptureQrResultWithSuccess_thenShouldDismissDoesntEmit() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        otpServiceMock._makeOtp = otpMock
        
        captureOtpViewModel(.captureQrResult(.success(.random())))
        
        expect(captureOtpViewModel[\.shouldDismiss]).toNot(emit(when: { captureOtpViewModel(.captureQrResult(.success(.random()))) }))
    }
    
    func testCallAsFunction_givenMakeOtpReturnsNil_whenCallingCaptureQrResultWithSuccess_thenShouldDismissDoesntEmit() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        
        expect(captureOtpViewModel[\.shouldDismiss]).toNot(emit(when: { captureOtpViewModel(.captureQrResult(.success(.random()))) }))
    }
    
    func testCallAsFunction_whenCallingCaptureQrResultWithFailure_thenSetsShowErrorAlertToTrue() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        
        captureOtpViewModel(.captureQrResult(.failure(ErrorMock.standard)))
        
        expect(captureOtpViewModel[\.showErrorAlert]).to(beTrue())
    }
    
    func testCallAsFunction_whenCallingCancel_thenShouldDismissEmits() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        
        expect(captureOtpViewModel[\.shouldDismiss]).to(emit(when: { captureOtpViewModel(.cancel) }))
    }
    
}
