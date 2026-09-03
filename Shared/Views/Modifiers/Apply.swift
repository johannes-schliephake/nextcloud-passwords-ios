import SwiftUI


extension View {
    
    /// Only use this modifier to apply iOS version specific code, otherwise SwiftUI's layout system will break
    @ContentBuilder func apply<Result: View>(@ContentBuilder _ transform: (Self) -> Result?) -> some View {
        if let result = transform(self) {
            result
        }
        else {
            self
        }
    }
    
}
