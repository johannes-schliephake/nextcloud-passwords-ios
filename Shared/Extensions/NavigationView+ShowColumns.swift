import SwiftUI


extension NavigationView {
    
    @ViewBuilder func showColumns(_ show: Bool) -> some View {
        if show {
            navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
        else {
            navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
}
