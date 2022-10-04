import SwiftUI
import LinkPresentation


struct ShareSheet: UIViewControllerRepresentable {
    
    let activityItems: [Any]
    
    var metadata: LPLinkMetadata? {
        guard let image = activityItems.first(where: { $0 is UIImage }) as? UIImage else {
            return nil
        }
        let metadata = LPLinkMetadata()
        metadata.imageProvider = NSItemProvider(object: image)
        metadata.title = activityItems.first(where: { $0 is String }) as? String
        return metadata
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(shareSheet: self)
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityItems = metadata != nil ? activityItems.filter { !($0 is String) } + [context.coordinator] : activityItems
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_: UIActivityViewController, context: Context) {}
    
}


extension ShareSheet {
    
    final class Coordinator: NSObject, UIActivityItemSource {
        
        private let shareSheet: ShareSheet
        
        init(shareSheet: ShareSheet) {
            self.shareSheet = shareSheet
        }
        
        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            ""
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            nil
        }
        
        func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
            shareSheet.metadata
        }
        
    }
    
}
