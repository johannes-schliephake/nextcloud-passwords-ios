import SwiftUI


extension View {
    
    func occlude(_ isOccluded: Bool) -> some View {
        ZStack {
            self
                .disabled(isOccluded)
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.ultraThinMaterial)
                .opacity(isOccluded ? 1 : 0)
                .animation(.easeInOut(duration: 0.2))
        }
    }
    
}
