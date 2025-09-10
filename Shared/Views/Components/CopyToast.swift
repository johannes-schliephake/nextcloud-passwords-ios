import SwiftUI
import Combine
import Factory


private enum CopyToastConstants {
    static let targetHeight = if #available(iOS 26, *) { 48.0 } else { 50.0 }
    static let verticalDistance = if #available(iOS 26, *) { 0.0 } else { 10.0 }
}


struct CopyToast<Content: View>: View {
    
    private let content: () -> Content
    
    @State private var visibilityTask: Task<Void, any Error>?
    @State private var isVisible = false
    @State private var safeAreaBottomInset = 0.0
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    // MARK: Views
    
    var body: some View {
        layers()
            .onReceive(resolve(\.systemNotifications).publisher(for: UIPasteboard.changedNotification)) { _ in
                visibilityTask?.cancel()
                isVisible = true
                visibilityTask = .init { @MainActor in
                    try await Task.sleep(for: .milliseconds(2200), clock: .suspending)
                    isVisible = false
                }
            }
            .apply { view in
                if #available(iOS 26, *) {
                    view
                        .animation(.bouncy, value: isVisible)
                } else {
                    view
                        .animation(.easeInOut, value: isVisible)
                }
            }
    }
    
    private func layers() -> some View {
        content()
            .onGeometryChange(
                for: Double.self,
                of: { $0.safeAreaInsets.bottom },
                action: { safeAreaBottomInset = $0 }
            )
            .overlay(alignment: .bottom) {
                toast()
                    .offset(x: 0, y: isVisible ? -CopyToastConstants.verticalDistance : safeAreaBottomInset + CopyToastConstants.targetHeight)
                    .opacity(isVisible ? 1 : 0)
            }
    }
    
    private func toast() -> some View {
        Text("_valueCopied")
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundColor(Color.primary)
            .padding(.horizontal, CopyToastConstants.targetHeight / 2)
            .apply { view in
                if #available(iOS 26, *) {
                    view
                        .frame(minHeight: CopyToastConstants.targetHeight)
                        .glassEffect()
                } else {
                    view
                        .frame(height: CopyToastConstants.targetHeight)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(CopyToastConstants.targetHeight / 2)
                        .shadow(color: Color.black.opacity(0.1), radius: CopyToastConstants.targetHeight / 2, x: 0, y: 10)
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
