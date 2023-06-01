import SwiftUI


private struct Occlude: ViewModifier {
    
    let isOccluded: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isOccluded)
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.ultraThinMaterial)
                .opacity(isOccluded ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isOccluded)
        }
    }
    
}


extension View {
    
    func occlude(_ isOccluded: Bool) -> some View {
        modifier(Occlude(isOccluded: isOccluded))
    }
    
}
