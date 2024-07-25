import XCTest
import Nimble
import Factory
@testable import Passwords


final class WindowSizeDataSourceTests: XCTestCase {
    
    @MockInjected(\.systemNotifications) private var systemNotificationsMock: NotificationsMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_thenCallsSystemNotifications() {
        _ = WindowSizeDataSource()
        
        expect(self.systemNotificationsMock).to(beCalled(.once, on: "publisher(for:object:)", withParameters: UIScene.didActivateNotification, "nil"))
    }
    
    func testWindowSize_thenDoesntEmit() {
        let windowSizeDataSource: any WindowSizeDataSourceProtocol = WindowSizeDataSource()
        
        expect(windowSizeDataSource.windowSize).toNot(emit())
    }
    
    func testWindowSize_whenSystemNotificationsEmitsWithFullWindowSceneObject_thenEmits() {
        let windowSizeDataSource: any WindowSizeDataSourceProtocol = WindowSizeDataSource()
        let windowSceneMock = WindowSceneMock()
        let windowMock = WindowMock()
        let windowSizeMock = CGSize(width: .random(in: 0..<1000), height: .random(in: 0..<1000))
        let notificationMock = Notification(name: UIScene.didActivateNotification, object: windowSceneMock)
        windowSceneMock._keyWindow = windowMock
        
        expect(windowSizeDataSource.windowSize).to(emit(windowSizeMock, when: {
            self.systemNotificationsMock._publisher.send(notificationMock)
            windowMock._framePublisher.send(.init(origin: .zero, size: windowSizeMock))
        }))
    }
    
    func testWindowSize_whenSystemNotificationsEmitsWithoutObject_thenDoesntEmit() {
        let windowSizeDataSource: any WindowSizeDataSourceProtocol = WindowSizeDataSource()
        let notificationMock = Notification(name: UIScene.didActivateNotification)
        
        expect(windowSizeDataSource.windowSize).toNot(emit(when: { self.systemNotificationsMock._publisher.send(notificationMock) }))
    }
    
    func testWindowSize_whenSystemNotificationsEmitsWithUnrelatedObject_thenDoesntEmit() {
        let windowSizeDataSource: any WindowSizeDataSourceProtocol = WindowSizeDataSource()
        let notificationMock = Notification(name: UIScene.didActivateNotification, object: ObjectMock())
        
        expect(windowSizeDataSource.windowSize).toNot(emit(when: { self.systemNotificationsMock._publisher.send(notificationMock) }))
    }
    
    func testWindowSize_whenSystemNotificationsEmitsWithoutKeyWindow_thenDoesntEmit() {
        let windowSizeDataSource: any WindowSizeDataSourceProtocol = WindowSizeDataSource()
        let windowSceneMock = WindowSceneMock()
        let notificationMock = Notification(name: UIScene.didActivateNotification, object: windowSceneMock)
        
        expect(windowSizeDataSource.windowSize).toNot(emit(when: { self.systemNotificationsMock._publisher.send(notificationMock) }))
    }
    
    func testWindowSize_whenSystemNotificationsEmitsWithoutFramePublisher_thenDoesntEmit() {
        let windowSizeDataSource: any WindowSizeDataSourceProtocol = WindowSizeDataSource()
        let windowSceneMock = WindowSceneMock()
        let windowMock = WindowMock()
        let notificationMock = Notification(name: UIScene.didActivateNotification, object: windowSceneMock)
        windowSceneMock._keyWindow = windowMock
        
        expect(windowSizeDataSource.windowSize).toNot(emit(when: { self.systemNotificationsMock._publisher.send(notificationMock) }))
    }
    
    func testWindowSize_whenSystemNotificationsEmitsAndFramePublisherEmitsMultipleValues_thenEmitsMultipleValues() {
        let windowSizeDataSource: any WindowSizeDataSourceProtocol = WindowSizeDataSource()
        let windowSceneMock = WindowSceneMock()
        let windowMock = WindowMock()
        let windowSizeMock1 = CGSize(width: .random(in: 0..<1000), height: .random(in: 0..<1000))
        let windowSizeMock2 = CGSize(width: .random(in: 1000..<2000), height: .random(in: 1000..<2000))
        let notificationMock = Notification(name: UIScene.didActivateNotification, object: windowSceneMock)
        windowSceneMock._keyWindow = windowMock
        
        expect(windowSizeDataSource.windowSize).to(emit(windowSizeMock1, windowSizeMock2, when: {
            self.systemNotificationsMock._publisher.send(notificationMock)
            windowMock._framePublisher.send(.init(origin: .zero, size: windowSizeMock1))
            windowMock._framePublisher.send(.init(origin: .zero, size: windowSizeMock2))
        }))
    }
    
    func testWindowSize_whenSystemNotificationsEmitsMultipleTimesWithFullWindowSceneObject_thenEmitsMultipleValues() {
        let windowSizeDataSource: any WindowSizeDataSourceProtocol = WindowSizeDataSource()
        let windowSceneMock1 = WindowSceneMock()
        let windowMock1 = WindowMock()
        let windowSizeMock1 = CGSize(width: .random(in: 0..<1000), height: .random(in: 0..<1000))
        let notificationMock1 = Notification(name: UIScene.didActivateNotification, object: windowSceneMock1)
        windowSceneMock1._keyWindow = windowMock1
        let windowSceneMock2 = WindowSceneMock()
        let windowMock2 = WindowMock()
        let windowSizeMock2 = CGSize(width: .random(in: 1000..<2000), height: .random(in: 1000..<2000))
        let notificationMock2 = Notification(name: UIScene.didActivateNotification, object: windowSceneMock2)
        windowSceneMock2._keyWindow = windowMock2
        
        expect(windowSizeDataSource.windowSize).to(emit(windowSizeMock1, windowSizeMock2, when: {
            self.systemNotificationsMock._publisher.send(notificationMock1)
            windowMock1._framePublisher.send(.init(origin: .zero, size: windowSizeMock1))
            self.systemNotificationsMock._publisher.send(notificationMock2)
            windowMock2._framePublisher.send(.init(origin: .zero, size: windowSizeMock2))
        }))
    }
    
    func testWindowSize_whenSystemNotificationsEmitsAndFramePublisherEmitsSameValueMultipleTimes_thenEmitsOnce() {
        let windowSizeDataSource: any WindowSizeDataSourceProtocol = WindowSizeDataSource()
        let windowSceneMock = WindowSceneMock()
        let windowMock = WindowMock()
        let windowSizeMock = CGSize(width: .random(in: 0..<1000), height: .random(in: 0..<1000))
        let notificationMock = Notification(name: UIScene.didActivateNotification, object: windowSceneMock)
        windowSceneMock._keyWindow = windowMock
        
        expect(windowSizeDataSource.windowSize.dropFirst()).toNot(emit(when: {
            self.systemNotificationsMock._publisher.send(notificationMock)
            windowMock._framePublisher.send(.init(origin: .zero, size: windowSizeMock))
            windowMock._framePublisher.send(.init(origin: .zero, size: windowSizeMock))
            windowMock._framePublisher.send(.init(origin: .zero, size: windowSizeMock))
        }))
    }
    
    func testWindowSize_givenSystemNotificationsEmittedWithFullWindowSceneObject_thenEmits() {
        let windowSizeDataSource: any WindowSizeDataSourceProtocol = WindowSizeDataSource()
        let windowSceneMock = WindowSceneMock()
        let windowMock = WindowMock()
        let windowSizeMock = CGSize(width: .random(in: 0..<1000), height: .random(in: 0..<1000))
        let notificationMock = Notification(name: UIScene.didActivateNotification, object: windowSceneMock)
        windowSceneMock._keyWindow = windowMock
        systemNotificationsMock._publisher.send(notificationMock)
        windowMock._framePublisher.send(.init(origin: .zero, size: windowSizeMock))
        
        expect(windowSizeDataSource.windowSize).to(emit(windowSizeMock))
    }
    
}
