import SwiftUI


/// Initially sets a FocusState, which isn't possible from e.g. onAppear
private struct Initialize<Value: Hashable>: ViewModifier {
    
    let binding: FocusState<Value?>.Binding
    let initial: Value?
    
    @State private var didInitialize = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                initialize()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                /// Retry initialization when app returns from background
                initialize()
            }
    }
    
    private func initialize() {
        guard let initial,
              !didInitialize else {
            return
        }
        Task {
            /// Try to set the initial value for two seconds. If this doesn't work, the view probably doesn't exist anymore or the app is in background
            for _ in 0..<20 {
                guard binding.wrappedValue == nil else {
                    didInitialize = true
                    break
                }
                await MainActor.run {
                    binding.wrappedValue = initial
                }
                try await Task.sleep(for: .milliseconds(100), clock: .suspending)
            }
        }
    }
    
}


extension View {
    
    func initialize<Value: Hashable>(focus binding: FocusState<Value?>.Binding, with initial: Value?) -> some View {
        modifier(Initialize(binding: binding, initial: initial))
    }
    
}
