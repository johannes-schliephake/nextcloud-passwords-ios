import SwiftUI
import FactoryKit
import UniformTypeIdentifiers


class ExtensionViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        _ = dependency(\.logger)
        _ = dependency(\.windowDataSource)
        _ = dependency(\.biometricAuthenticationController)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // swiftlint:disable:this fatal_error
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dependency(\.autoFillController).mode = .extension
        dependency(\.autoFillController).serviceURLs = []
        dependency(\.autoFillController).credentialIdentifier = nil
        dependency(\.autoFillController).hasField = false
        
        if let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] {
            extensionItems
                .compactMap { $0.attachments }
                .flatMap { $0 }
                .filter { $0.hasItemConformingToTypeIdentifier(UTType.propertyList.identifier) }
                .forEach {
                    itemProvider in
                    itemProvider.loadItem(forTypeIdentifier: UTType.propertyList.identifier) {
                        item, error in
                        guard error == nil,
                              let dictionary = item as? NSDictionary,
                              let jsDictionary = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? [String: Any],
                              let urlString = jsDictionary["url"] as? String,
                              let url = URL(string: urlString),
                              let hasField = jsDictionary["hasField"] as? Bool else {
                            return
                        }
                        DispatchQueue.main.async {
                            dependency(\.autoFillController).serviceURLs = [url]
                            dependency(\.autoFillController).hasField = hasField
                        }
                    }
                }
        }
        
        dependency(\.autoFillController).complete = {
            [weak self] _, currentOtp in
            if dependency(\.autoFillController).hasField {
                let jsDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: ["currentOtp": currentOtp]]
                let otpItem = NSExtensionItem()
                otpItem.attachments = [NSItemProvider(item: jsDictionary as NSDictionary, typeIdentifier: UTType.propertyList.identifier)]
                self?.extensionContext?.completeRequest(returningItems: [otpItem])
            }
            else {
                dependency(\.pasteboardService).set(string: currentOtp, sensitive: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self?.extensionContext?.completeRequest(returningItems: nil)
                }
            }
        }
        dependency(\.autoFillController).cancel = {
            [weak self] in
            self?.extensionContext?.cancelRequest(withError: NSError(domain: Configuration.appService, code: 0))
        }
        
        Container.shared.rootViewController.register { self }
        
        let hostingController = UIHostingController(rootView: MainView())
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: UIScene.willConnectNotification, object: view.window?.windowScene)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.post(name: UIScene.didActivateNotification, object: view.window?.windowScene)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.post(name: UIScene.willDeactivateNotification, object: view.window?.windowScene)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.post(name: UIScene.didEnterBackgroundNotification, object: view.window?.windowScene)
        Container.shared.reset()
    }
    
}
