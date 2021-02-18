import SwiftUI


extension View {
    
    @ViewBuilder func occlude(_ isOccluded: Bool) -> some View {
        blur(radius: isOccluded ? 20 : 0)
        .animation(.easeOut(duration: 0.2))
        .disabled(isOccluded)
    }
    
}
