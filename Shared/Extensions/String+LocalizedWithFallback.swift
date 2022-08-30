import Foundation


extension String {
    
    var localizedWithFallback: String {
        var localizedString = NSLocalizedString(self, comment: "")
        if localizedString == self,
           let url = Bundle.main.url(forResource: "en", withExtension: "lproj"),
           let bundle = Bundle(url: url) {
            localizedString = NSLocalizedString(self, bundle: bundle, comment: "")
        }
        return localizedString
    }
    
}
