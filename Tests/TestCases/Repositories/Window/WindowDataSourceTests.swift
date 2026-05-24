import XCTest
import Nimble
import FactoryKit
@testable import Passwords


final class WindowDataSourceTests: XCTestCase {
    
    @MockInjected(\.systemNotifications) private var systemNotificationsMock: NotificationsMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_thenSetsInitialState() {
        let windowDataSource: any WindowDataSourceProtocol = WindowDataSource()
        
        expect(windowDataSource[\.window]).to(beNil())
    }
    
    func testInit_thenCallsSystemNotifications() {
        _ = WindowDataSource()
        
        expect(self.systemNotificationsMock).to(beCalled(.once, on: "publisher(for:object:)", withParameters: UIScene.didActivateNotification, "nil"))
    }
    
    func testInit_whenSystemNotificationsEmittingFullWindowSceneObject_thenSetsWindow() {
        let windowDataSource: any WindowDataSourceProtocol = WindowDataSource()
        let windowSceneMock = WindowSceneMock()
        let windowMock = WindowMock()
        let notificationMock = Notification(name: UIScene.didActivateNotification, object: windowSceneMock)
        windowSceneMock._keyWindow = windowMock
        
        systemNotificationsMock._publisher.send(notificationMock)
        
        expect(windowDataSource[\.window]).to(be(windowMock))
    }
    
    func testInit_whenSystemNotificationsEmittingWithoutObject_thenDoesntSetWindow() {
        let windowDataSource: any WindowDataSourceProtocol = WindowDataSource()
        let notificationMock = Notification(name: UIScene.didActivateNotification)
        
        systemNotificationsMock._publisher.send(notificationMock)
        
        expect(windowDataSource[\.window]).to(beNil())
    }
    
    func testInit_whenSystemNotificationsEmittingUnrelatedObject_thenDoesntSetWindow() {
        let windowDataSource: any WindowDataSourceProtocol = WindowDataSource()
        let notificationMock = Notification(name: UIScene.didActivateNotification, object: ObjectMock())
        
        systemNotificationsMock._publisher.send(notificationMock)
        
        expect(windowDataSource[\.window]).to(beNil())
    }
    
    func testInit_whenSystemNotificationsEmittingWithoutKeyWindow_thenDoesntSetWindow() {
        let windowDataSource: any WindowDataSourceProtocol = WindowDataSource()
        let windowSceneMock = WindowSceneMock()
        let notificationMock = Notification(name: UIScene.didActivateNotification, object: windowSceneMock)
        
        systemNotificationsMock._publisher.send(notificationMock)
        
        expect(windowDataSource[\.window]).to(beNil())
    }
    
}
