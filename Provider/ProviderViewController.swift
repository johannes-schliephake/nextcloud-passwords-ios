import AuthenticationServices
import SwiftUI
import Factory


final class ProviderViewController: ASCredentialProviderViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        _ = resolve(\.logger)
        _ = resolve(\.windowSizeDataSource)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // swiftlint:disable:this fatal_error
    }
    
    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        provideCredential(mode: .provider, recordIdentifier: credentialIdentity.recordIdentifier)
    }
    
    @available(iOS 17, *) override func provideCredentialWithoutUserInteraction(for credentialRequest: any ASCredentialRequest) {
        let recordIdentifier = credentialRequest.credentialIdentity.recordIdentifier
        switch credentialRequest.type {
        case .password:
            provideCredential(mode: .provider, recordIdentifier: recordIdentifier)
        case .oneTimeCode:
            provideCredential(mode: .extension, recordIdentifier: recordIdentifier)
        default:
            extensionContext.cancelRequest(withError: ASExtensionError(.failed))
        }
    }
    
    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        showCredentialList(mode: .provider, serviceIdentifiers: [credentialIdentity.serviceIdentifier], recordIdentifier: credentialIdentity.recordIdentifier)
    }
    
    @available(iOS 17, *) override func prepareInterfaceToProvideCredential(for credentialRequest: any ASCredentialRequest) {
        let serviceIdentifiers = [credentialRequest.credentialIdentity.serviceIdentifier]
        let recordIdentifier = credentialRequest.credentialIdentity.recordIdentifier
        switch credentialRequest.type {
        case .password:
            showCredentialList(mode: .provider, serviceIdentifiers: serviceIdentifiers, recordIdentifier: recordIdentifier)
        case .oneTimeCode:
            showCredentialList(mode: .extension, serviceIdentifiers: serviceIdentifiers, recordIdentifier: recordIdentifier)
        default:
            extensionContext.cancelRequest(withError: ASExtensionError(.failed))
        }
    }
    
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        showCredentialList(mode: .provider, serviceIdentifiers: serviceIdentifiers, recordIdentifier: nil)
    }
    
    override func prepareOneTimeCodeCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        showCredentialList(mode: .extension, serviceIdentifiers: serviceIdentifiers, recordIdentifier: nil)
    }
    
    private func provideCredential(mode: AutoFillController.Mode, recordIdentifier: String?) {
        AutoFillController.default.mode = mode
        AutoFillController.default.serviceURLs = []
        AutoFillController.default.credentialIdentifier = recordIdentifier
        AutoFillController.default.hasField = true
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            if let offlineKeychain = Keychain.default.load(key: "offlineKeychain") {
                guard let challengePassword = Keychain.default.load(key: "challengePassword"),
                      let keychain = Crypto.CSEv1r1.decrypt(keys: offlineKeychain, password: challengePassword) else {
                    self?.extensionContext.cancelRequest(withError: ASExtensionError(.userInteractionRequired))
                    return
                }
                AutoFillController.default.keychain = keychain
            }
            
            let request = OfflineContainer.request()
            guard let offlineContainers = CoreData.default.fetch(request: request) else {
                self?.extensionContext.cancelRequest(withError: ASExtensionError(.failed))
                return
            }
            
            let key = Crypto.AES256.getKey(named: "offlineKey")
            let passwordOfflineContainers = offlineContainers.filter { $0.type == .password }
            guard let passwords = try? Crypto.AES256.decrypt(offlineContainers: passwordOfflineContainers, key: key).passwords else {
                self?.extensionContext.cancelRequest(withError: ASExtensionError(.failed))
                return
            }
            
            guard let password = passwords.first(where: { $0.id == recordIdentifier }) else {
                self?.extensionContext.cancelRequest(withError: ASExtensionError(.credentialIdentityNotFound))
                return
            }
            switch mode {
            case .app:
                self?.extensionContext.cancelRequest(withError: ASExtensionError(.failed))
            case .provider:
                self?.extensionContext.completeRequest(withSelectedCredential: .init(user: password.username, password: password.password))
            case .extension:
                guard let currentOtp = password.otp?.current else {
                    self?.extensionContext.cancelRequest(withError: ASExtensionError(.credentialIdentityNotFound))
                    return
                }
                guard #available(iOS 18, *) else {
                    self?.extensionContext.cancelRequest(withError: ASExtensionError(.failed))
                    return
                }
                self?.extensionContext.completeOneTimeCodeRequest(using: .init(code: currentOtp))
            }
            
        }
    }
    
    private func showCredentialList(mode: AutoFillController.Mode, serviceIdentifiers: [ASCredentialServiceIdentifier], recordIdentifier: String?) {
        AutoFillController.default.mode = mode
        AutoFillController.default.serviceURLs = serviceIdentifiers.compactMap { .init(string: $0.identifier) }
        AutoFillController.default.credentialIdentifier = recordIdentifier
        AutoFillController.default.hasField = true
        AutoFillController.default.complete = { [weak self] username, secret in
            switch mode {
            case .app:
                self?.extensionContext.cancelRequest(withError: ASExtensionError(.failed))
            case .provider:
                self?.extensionContext.completeRequest(withSelectedCredential: .init(user: username, password: secret))
            case .extension:
                guard #available(iOS 18, *) else {
                    self?.extensionContext.cancelRequest(withError: ASExtensionError(.failed))
                    return
                }
                self?.extensionContext.completeOneTimeCodeRequest(using: .init(code: secret))
            }
        }
        AutoFillController.default.cancel = { [weak self] in
            self?.extensionContext.cancelRequest(withError: ASExtensionError(.userCanceled))
        }
        
        UIAlertController.rootViewController = self
        
        let mainView = MainView().environmentObject(AutoFillController.default)
        let hostingController = UIHostingController(rootView: mainView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.post(name: UIScene.didActivateNotification, object: view.window?.windowScene)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
}
