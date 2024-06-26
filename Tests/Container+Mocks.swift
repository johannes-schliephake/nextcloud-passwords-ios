import Factory
@testable import Passwords
import Foundation
import CombineSchedulers


extension Container {
    
    var folder: Factory<Folder> {
        self { .mock }
            .shared
    }
    var folders: Factory<[Folder]> {
        self { Folder.mocks }
            .shared
    }
    var logEvent: Factory<LogEvent> {
        self { .mock }
            .shared
    }
    var logEvents: Factory<[LogEvent]> {
        self { LogEvent.mocks }
            .shared
    }
    var otp: Factory<OTP> {
        self { .mock }
            .shared
    }
    var otps: Factory<[OTP]> {
        self { OTP.mocks }
            .shared
    }
    var password: Factory<Password> {
        self { .mock }
            .shared
    }
    var passwords: Factory<[Password]> {
        self { Password.mocks }
            .shared
    }
    var session: Factory<Session> {
        self { .mock }
            .shared
    }
    var tag: Factory<Tag> {
        self { .mock }
            .shared
    }
    var tags: Factory<[Tag]> {
        self { Tag.mocks }
            .shared
    }
    
    var userInitiatedSchedulerMock: Factory<TestSchedulerOf<DispatchQueue>> {
        self { DispatchQueue.test }
            .cached
    }
    
}
