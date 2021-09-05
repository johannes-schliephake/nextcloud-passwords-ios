import SwiftUI


extension View {
    
    @ViewBuilder func apply<Result: View>(@ViewBuilder _ transform: (Self) -> Result?) -> some View {
        if let result = transform(self) {
            result
        }
        else {
            self
        }
    }
    
}
