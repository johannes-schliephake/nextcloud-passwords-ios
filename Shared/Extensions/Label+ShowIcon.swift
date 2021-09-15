import SwiftUI


extension Label {
    
    @ViewBuilder func showIcon(_ show: Bool) -> some View {
        if show {
            labelStyle(.automatic)
        }
        else {
            labelStyle(.titleOnly)
        }
    }
    
}
