import SwiftUI


extension NavigationView {
    
    @ViewBuilder func showColumns(_ show: Bool) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad, /// Enable column navigation style only for iPad because of NavigationLink bugs
           show {
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
