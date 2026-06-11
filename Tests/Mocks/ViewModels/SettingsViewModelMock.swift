@testable import Passwords
import FactoryKit


final class SettingsViewModelMock: ViewModelMock<SettingsViewModel.State, SettingsViewModel.Action>, SettingsViewModelProtocol {}


extension SettingsViewModel.State: Mock {
    
    convenience init() {
        let sessionMock = dependency(\.session)
        let configurationTypeMock = dependency(\.configurationType)
        self.init(username: sessionMock.user, server: sessionMock.server, isChallengePasswordStored: true, wasChallengePasswordCleared: false, showLogoutAlert: false, isOfflineStorageEnabled: true, isOnDevicePasswordGeneratorEnabled: true, isAutomaticPasswordGenerationEnabled: true, isUniversalClipboardEnabled: false, canPurchaseTip: true, tipProducts: nil, isTipTransactionRunning: false, isTestFlight: false, betaUrl: .init(string: "."), reviewUrl: .init(string: "."), reportIssueUrl: .init(string: "."), isLogAvailable: true, versionName: configurationTypeMock.shortVersionString, sourceCodeUrl: .init(string: "."))
    }
    
}
