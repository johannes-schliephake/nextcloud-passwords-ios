import XCTest
import Nimble
import Factory
@testable import Passwords
import AVFoundation


final class CaptureOTPViewModelTests: XCTestCase {
    
    @Injected(\.otp) private var otpMock
    
    @MockInjected(\.torchService) private var torchServiceMock: TorchServiceMock
    @MockInjected(\.otpService) private var otpServiceMock: OTPServiceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_thenSetsInitialState() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        
        expect(captureOtpViewModel[\.isTorchAvailable]).to(beFalse())
        expect(captureOtpViewModel[\.isTorchActive]).to(beFalse())
        expect(captureOtpViewModel[\.showErrorAlert]).to(beFalse())
        expect(captureOtpViewModel[\.didCaptureOtp]).to(beFalse())
    }
    
    func testInit_thenCallsTorchService() {
        _ = CaptureOTPViewModel { _ in }
        
        expect(self.torchServiceMock).to(beAccessed(.once, on: "isTorchAvailable"))
        expect(self.torchServiceMock).to(beAccessed(.once, on: "isTorchActive"))
    }
    
    func testInit_whenTorchServiceEmittingIsTorchAvailable_thenSetsIsTorchAvailable() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        let isTorchAvailableMock = Bool.random()
        
        torchServiceMock._isTorchAvailable.send(isTorchAvailableMock)
        
        expect(captureOtpViewModel[\.isTorchAvailable]).toEventually(equal(isTorchAvailableMock))
    }
    
    func testInit_whenTorchServiceEmittingIsTorchAvailableFromBackgroundThread_thenSetsIsTorchAvailableFromMainThread() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        let isTorchAvailableMock = Bool.random()
        
        expect(captureOtpViewModel[\.$isTorchAvailable].dropFirst()).to(emit(isTorchAvailableMock, onMainThread: true, when: { self.torchServiceMock._isTorchAvailable.send(isTorchAvailableMock) }, from: .init()))
    }
    
    func testInit_whenTorchServiceEmittingIsTorchActive_thenSetsIsTorchActive() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        let isTorchActiveMock = Bool.random()
        
        torchServiceMock._isTorchActive.send(isTorchActiveMock)
        
        expect(captureOtpViewModel[\.isTorchActive]).toEventually(equal(isTorchActiveMock))
    }
    
    func testInit_whenTorchServiceEmittingIsTorchActiveFromBackgroundThread_thenSetsIsTorchActiveFromMainThread() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        let isTorchActiveMock = Bool.random()
        
        expect(captureOtpViewModel[\.$isTorchActive].dropFirst()).to(emit(isTorchActiveMock, onMainThread: true, when: { self.torchServiceMock._isTorchActive.send(isTorchActiveMock) }, from: .init()))
    }
    
    func testCallAsFunction_whenCallingToggleTorch_thenCallsTorchService() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        
        captureOtpViewModel(.toggleTorch)
        
        expect(self.torchServiceMock).to(beCalled(.once, on: "toggleTorch()"))
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
        
        captureOtpViewModel(.captureQrResult(.failure(AVError(.deviceNotConnected))))
        
        expect(captureOtpViewModel[\.showErrorAlert]).to(beTrue())
    }
    
    func testCallAsFunction_whenCallingCancel_thenShouldDismissEmits() {
        let captureOtpViewModel: any CaptureOTPViewModelProtocol = CaptureOTPViewModel { _ in }
        
        expect(captureOtpViewModel[\.shouldDismiss]).to(emit(when: { captureOtpViewModel(.cancel) }))
    }
    
}
