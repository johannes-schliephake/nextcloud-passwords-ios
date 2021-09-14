import SwiftUI
import Combine


struct CopyToast<Content: View>: View {
    
    private let content: () -> Content
    
    @StateObject private var copyToastController = CopyToastController()
    @State private var visibility = 0.0
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    // MARK: Views
    
    var body: some View {
        layers()
            .onChange(of: copyToastController.isShowing) {
                isShowing in
                withAnimation {
                    visibility = isShowing ? 1.0 : 0.0
                }
            }
    }
    
    private func layers() -> some View {
        GeometryReader {
            geometryProxy in
            ZStack(alignment: .bottom) {
                content()
                toast()
                    .offset(x: 0, y: Double(geometryProxy.safeAreaInsets.bottom + 50 + 10) * (1 - visibility) - 10)
                    .opacity(visibility * 5)
            }
        }
    }
    
    private func toast() -> some View {
        VStack {
            Text("_valueCopied")
                .font(.footnote)
                .fontWeight(.medium)
                .frame(height: 50)
                .padding(.horizontal, 25)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .foregroundColor(Color.primary)
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.1), radius: 25, x: 0, y: 10)
        }
    }
    
}


extension CopyToast {
    
    final class CopyToastController: ObservableObject {
        
        @Published private(set) var isShowing = false
        
        private var pasteboardChangedDate = Date()
        private var subscriptions = Set<AnyCancellable>()
        
        init() {
            NotificationCenter.default.publisher(for: UIPasteboard.changedNotification)
                .sink(receiveValue: showCopyToast)
                .store(in: &subscriptions)
        }
        
        private func showCopyToast(_: Notification) {
            let notificationDate = Date()
            pasteboardChangedDate = notificationDate
            isShowing = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2200)) {
                [weak self] in
                if self?.pasteboardChangedDate == notificationDate {
                    self?.isShowing = false
                }
            }
        }
        
    }
    
}


extension View {
    
    func copyToast() -> some View {
        CopyToast {
            self
        }
    }
    
}
