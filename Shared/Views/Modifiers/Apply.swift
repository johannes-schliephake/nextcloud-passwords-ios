import SwiftUI


extension View {
    
    /// Only use this modifier to apply iOS version specific code, otherwise SwiftUI's layout system will break
    @ViewBuilder func apply<Result: View>(@ViewBuilder _ transform: (Self) -> Result?) -> some View {
        if let result = transform(self) {
            result
        }
        else {
            self
        }
    }
    
}
