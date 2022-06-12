import SwiftUI


extension NavigationView {
    
    @ViewBuilder func showColumns(_ show: Bool) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad, /// Enable column navigation style only for iPad because of NavigationLink bugs
           show {
            navigationViewStyle(.columns)
        }
        else {
            navigationViewStyle(.stack)
        }
    }
    
}
