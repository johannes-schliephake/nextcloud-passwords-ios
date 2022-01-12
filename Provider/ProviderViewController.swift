import AuthenticationServices
import SwiftUI


final class ProviderViewController: ASCredentialProviderViewController {
    
    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        DispatchQueue.global(qos: .utility).async {
            [weak self] in
            if let offlineKeychain = Keychain.default.load(key: "offlineKeychain") {
                guard let challengePassword = Keychain.default.load(key: "challengePassword"),
                      let keychain = Crypto.CSEv1r1.decrypt(keys: offlineKeychain, password: challengePassword) else {
                    self?.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userInteractionRequired.rawValue))
                    return
                }
                AutoFillController.default.keychain = keychain
            }
            
            let request = OfflineContainer.request()
            guard let offlineContainers = CoreData.default.fetch(request: request) else {
                self?.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.failed.rawValue))
                return
            }
            
            let key = Crypto.AES256.getKey(named: "offlineKey")
            let passwordOfflineContainers = offlineContainers.filter { $0.type == .password }
            guard let passwords = try? Crypto.AES256.decrypt(offlineContainers: passwordOfflineContainers, key: key).passwords else {
                self?.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.failed.rawValue))
                return
            }
            
            guard let password = passwords.first(where: { $0.id == credentialIdentity.recordIdentifier }) else {
                self?.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.credentialIdentityNotFound.rawValue))
                return
            }
            let passwordCredential = ASPasswordCredential(user: password.username, password: password.password)
            self?.extensionContext.completeRequest(withSelectedCredential: passwordCredential)
        }
    }
    
    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        AutoFillController.default.credentialIdentifier = credentialIdentity.recordIdentifier
        prepareCredentialList(for: [credentialIdentity.serviceIdentifier])
    }
    
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        UIAlertController.rootViewController = self
        
        AutoFillController.default.complete = {
            [weak self] username, password in
            let passwordCredential = ASPasswordCredential(user: username, password: password)
            self?.extensionContext.completeRequest(withSelectedCredential: passwordCredential)
        }
        AutoFillController.default.cancel = {
            [weak self] in
            self?.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
        }
        AutoFillController.default.serviceURLs = serviceIdentifiers.compactMap { URL(string: $0.identifier) }
        
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
    }
    
}
