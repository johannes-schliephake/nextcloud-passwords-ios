import SwiftUI
import Combine


private struct Dismiss<P: Publisher>: ViewModifier where P.Output == Void, P.Failure == Never {
    
    let shouldDismiss: P
    
    @Environment(\.dismiss) private var dismiss
    
    func body(content: Content) -> some View {
        content
            .onReceive(shouldDismiss) { dismiss() }
    }
    
}


extension View {
    
    func dismiss<P: Publisher>(on publisher: P) -> some View where P.Output == Void, P.Failure == Never {
        modifier(Dismiss(shouldDismiss: publisher))
    }
    
}
