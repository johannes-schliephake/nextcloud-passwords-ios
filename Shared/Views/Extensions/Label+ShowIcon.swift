import SwiftUI


extension Label {
    
    @MainActor @ContentBuilder func showIcon(_ show: Bool) -> some View {
        if show {
            labelStyle(.automatic)
        }
        else {
            labelStyle(.titleOnly)
        }
    }
    
}
