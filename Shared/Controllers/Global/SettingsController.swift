import Foundation
import Combine


final class SettingsController: ObservableObject {
    
    static let `default` = SettingsController()
    
    @Published private var settings: Settings?
    
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        SessionController.default.$session
            .sink(receiveValue: requestSettings)
            .store(in: &subscriptions)
    }
    
    private init(settings: Settings) {
        self.settings = settings
    }
    
    private func requestSettings(session: Session?) {
        guard let session = session else {
            settings = nil
            return
        }
        
        ListSettingsRequest(session: session).send {
            [weak self] settings in
            guard let settings = settings else {
                return
            }
            self?.settings = settings
        }
    }
    
    var settingsAreAvailable: Bool {
        settings != nil
    }
    
    var userPasswordSecurityHash: Int {
        settings?.userPasswordSecurityHash ?? 40
    }
    
}


extension SettingsController: MockObject {
    
    static var mock: SettingsController {
        SettingsController(settings: Settings.mock)
    }
    
}
