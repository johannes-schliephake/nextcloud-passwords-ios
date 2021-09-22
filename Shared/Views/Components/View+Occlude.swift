import SwiftUI


extension View {
    
    @ViewBuilder func occlude(_ isOccluded: Bool) -> some View {
        if #available(iOS 15, *) {
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
        else {
            self
                .blur(radius: isOccluded ? 20 : 0)
                .animation(.easeOut(duration: 0.2))
                .disabled(isOccluded)
        }
    }
    
}
