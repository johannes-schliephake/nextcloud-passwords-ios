import SwiftUI
import UniformTypeIdentifiers


class ExtensionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AutoFillController.default.mode = .extension
        AutoFillController.default.serviceURLs = []
        AutoFillController.default.credentialIdentifier = nil
        
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
                              let jsDictionary = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? [String: String],
                              let urlString = jsDictionary["url"],
                              let url = URL(string: urlString) else {
                            return
                        }
                        DispatchQueue.main.async {
                            AutoFillController.default.serviceURLs = [url]
                        }
                    }
                }
        }
        
        AutoFillController.default.complete = {
            [weak self] _, currentOtp in
            let jsDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: ["currentOtp": currentOtp]]
            let otpItem = NSExtensionItem()
            otpItem.attachments = [NSItemProvider(item: jsDictionary as NSDictionary, typeIdentifier: UTType.propertyList.identifier)]
            self?.extensionContext?.completeRequest(returningItems: [otpItem])
        }
        AutoFillController.default.cancel = {
            [weak self] in
            self?.extensionContext?.cancelRequest(withError: NSError(domain: Configuration.appService, code: 0))
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)
    }

}
