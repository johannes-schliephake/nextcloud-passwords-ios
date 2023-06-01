import SwiftUI
import Combine


private struct Dismiss: ViewModifier {
    
    let shouldDismiss: AnyPublisher<Void, Never>
    
    @Environment(\.dismiss) private var dismiss
    
    func body(content: Content) -> some View {
        content
            .onReceive(shouldDismiss) { dismiss() }
    }
    
}


extension View {
    
    func dismiss(on publisher: AnyPublisher<Void, Never>) -> some View {
        modifier(Dismiss(shouldDismiss: publisher))
    }
    
}
