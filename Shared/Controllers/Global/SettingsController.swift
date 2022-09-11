import Combine
import SwiftUI


final class SettingsController: ObservableObject {
    
    static let `default` = SettingsController()
    
    @Published private var settings: Settings? /// Published private value will still refresh views
    
    private var settingsFetchDate: Date?
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        SessionController.default.$session
            .sink(receiveValue: requestSettings)
            .store(in: &subscriptions)
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink(receiveValue: refresh)
            .store(in: &subscriptions)
    }
    
    private init(settings: Settings) {
        self.settings = settings
    }
    
    private func requestSettings(session: Session?) {
        guard let session else {
            settings = nil
            settingsFetchDate = nil
            Crypto.AES256.removeKey(named: "settingsKey")
            Configuration.userDefaults.removeObject(forKey: "settings")
            return
        }
        
        fetchOfflineSettings()
        fetchOnlineSettings(session: session)
    }
    
    private func refresh(_: Notification) {
        if let settingsFetchDate {
            guard settingsFetchDate.advanced(by: 5 * 60) < Date() else {
                return
            }
        }
        
        guard let session = SessionController.default.session else {
            return
        }
        fetchOnlineSettings(session: session)
    }
    
    private func fetchOnlineSettings(session: Session) {
        settingsFetchDate = Date()
        
        ListSettingsRequest(session: session).send {
            [weak self] settings in
            guard let settings else {
                self?.settingsFetchDate = nil
                return
            }
            self?.settings = settings
            
            DispatchQueue.global(qos: .utility).async {
                let key = Crypto.AES256.getKey(named: "settingsKey")
                guard let data = Crypto.AES256.encrypt(settings: settings, key: key) else {
                    return
                }
                Configuration.userDefaults.set(data, forKey: "settings")
            }
        }
    }
    
    private func fetchOfflineSettings() {
        DispatchQueue.global(qos: .utility).async {
            [weak self] in
            guard let offlineSettings = Configuration.userDefaults.data(forKey: "settings") else {
                return
            }
            
            let key = Crypto.AES256.getKey(named: "settingsKey")
            do {
                let settings = try Crypto.AES256.decrypt(offlineSettings: offlineSettings, key: key)
                DispatchQueue.main.async {
                    guard self?.settings == nil else {
                        return
                    }
                    self?.settings = settings
                }
            }
            catch {
                Configuration.userDefaults.removeObject(forKey: "settings")
                LoggingController.shared.log(error: error)
                return
            }
        }
    }
    
    var settingsAreAvailable: Bool {
        settings != nil
    }
    
    var userPasswordSecurityHash: Int {
        settings?.userPasswordSecurityHash ?? 40
    }
    
    var userSessionLifetime: Int {
        settings?.userSessionLifetime ?? 600
    }
    
}


extension SettingsController: MockObject {
    
    static var mock: SettingsController {
        SettingsController(settings: Settings.mock)
    }
    
}
