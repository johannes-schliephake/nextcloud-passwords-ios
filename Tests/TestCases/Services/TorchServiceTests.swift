import XCTest
import Nimble
import Factory
@testable import Passwords
import AVFoundation


final class TorchServiceTests: XCTestCase {
    
    @MockInjected(\.videoCapturer) private var videoCapturerMock: VideoCapturerMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testIsTorchAvailable_thenCallsVideoCapturer() {
        let torchService: any TorchServiceProtocol = TorchService()
        _ = torchService.isTorchAvailable
        
        expect(self.videoCapturerMock).to(beAccessed(.once, on: "isTorchAvailablePublisher"))
    }
    
    func testIsTorchAvailable_givenMissingVideoCapturer_thenEmitsFalse() {
        Container.shared.videoCapturer.register { nil }
        let torchService: any TorchServiceProtocol = TorchService()
        
        expect(torchService.isTorchAvailable).to(emit(false))
    }
    
    func testIsTorchAvailable_whenVideoCapturerEmittingValue_thenReemitsSameValue() {
        let torchService: any TorchServiceProtocol = TorchService()
        let isTorchAvailableMock = Bool.random()
        
        expect(torchService.isTorchAvailable).to(emit(isTorchAvailableMock, when: { self.videoCapturerMock._isTorchAvailablePublisher.send(isTorchAvailableMock) }))
    }
    
    func testIsTorchActive_thenCallsVideoCapturer() {
        let torchService: any TorchServiceProtocol = TorchService()
        _ = torchService.isTorchActive
        
        expect(self.videoCapturerMock).to(beAccessed(.once, on: "isTorchActivePublisher"))
    }
    
    func testIsTorchActive_givenMissingVideoCapturer_thenEmitsFalse() {
        Container.shared.videoCapturer.register { nil }
        let torchService: any TorchServiceProtocol = TorchService()
        
        expect(torchService.isTorchActive).to(emit(false))
    }
    
    func testIsTorchActive_whenVideoCapturerEmittingValue_thenReemitsSameValue() {
        let torchService: any TorchServiceProtocol = TorchService()
        let isTorchActiveMock = Bool.random()
        
        expect(torchService.isTorchActive).to(emit(isTorchActiveMock, when: { self.videoCapturerMock._isTorchActivePublisher.send(isTorchActiveMock) }))
    }
    
    func testToggleTorch_givenMissingVideoCapturer_thenThrowsUnsupported() {
        Container.shared.videoCapturer.register { nil }
        let torchService: any TorchServiceProtocol = TorchService()
        
        expect(try torchService.toggleTorch()).to(throwError(TorchError.unsupported))
    }
    
    func testToggleTorch_givenIsTorchModeSupportedReturnsFalse_thenThrowsUnsupported() {
        let torchService: any TorchServiceProtocol = TorchService()
        videoCapturerMock._isTorchModeSupported = false
        
        expect(try torchService.toggleTorch()).to(throwError(TorchError.unsupported))
    }
    
    func testToggleTorch_givenLockForConfigurationThrows_thenThrowsFailedToAccessHardware() {
        let torchService: any TorchServiceProtocol = TorchService()
        videoCapturerMock._lockForConfiguration = .failure(AVError(.unknown))
        
        expect(try torchService.toggleTorch()).to(throwError(TorchError.failedToAccessHardware))
    }
    
    func testToggleTorch_thenCallsVideoCapturer() {
        let torchService: any TorchServiceProtocol = TorchService()
        
        try? torchService.toggleTorch()
        
        expect(self.videoCapturerMock).to(beAccessed(.twice, on: "torchMode"))
        expect(self.videoCapturerMock).to(beCalled(.once, on: "isTorchModeSupported(_:)", withParameter: "AVCaptureTorchMode(rawValue: 1)"))
        expect(self.videoCapturerMock).to(beCalled(.once, on: "lockForConfiguration()"))
        expect(self.videoCapturerMock).to(beCalled(.once, on: "unlockForConfiguration()"))
    }
    
    func testToggleTorch_thenTogglesTorchMode() {
        let torchService: any TorchServiceProtocol = TorchService()
        let torchModeMock: AVCaptureDevice.TorchMode = .random() ? .on : .off
        let expectedTorchMode: AVCaptureDevice.TorchMode = torchModeMock == .on ? .off : .on
        videoCapturerMock._torchMode = torchModeMock
        
        try? torchService.toggleTorch()
        
        expect(self.videoCapturerMock).to(beAccessed(.twice, on: "torchMode"))
        expect(self.videoCapturerMock._torchMode).to(equal(expectedTorchMode))
    }
    
}
