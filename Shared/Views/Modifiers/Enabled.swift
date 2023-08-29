import SwiftUI


private struct Enabled: ViewModifier {
    
    let enabled: Bool
    
    func body(content: Content) -> some View {
        content
            .disabled(!enabled)
    }
    
}


extension View {
    
    func enabled(_ enabled: Bool) -> some View {
        modifier(Enabled(enabled: enabled))
    }

}
