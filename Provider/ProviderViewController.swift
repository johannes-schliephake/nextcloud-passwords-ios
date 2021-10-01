import AuthenticationServices
import SwiftUI


final class ProviderViewController: ASCredentialProviderViewController {
    
    private let autoFillController = AutoFillController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIAlertController.rootViewController = self
        
        autoFillController.complete = {
            [self] username, password in
            let passwordCredential = ASPasswordCredential(user: username, password: password)
            extensionContext.completeRequest(withSelectedCredential: passwordCredential)
        }
        autoFillController.cancel = {
            [self] in
            extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
        }
        
        let mainView = MainView().environmentObject(autoFillController)
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
    
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        autoFillController.serviceURLs = serviceIdentifiers.compactMap { URL(string: $0.identifier) }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
}
