import SwiftUI


extension NavigationView {
    
    @ViewBuilder func showColumns(_ show: Bool) -> some View {
        if show {
            if #available(iOS 15, *) {
                navigationViewStyle(.columns)
            }
            else {
                navigationViewStyle(DoubleColumnNavigationViewStyle())
            }
        }
        else {
            navigationViewStyle(.stack)
        }
    }
    
}
