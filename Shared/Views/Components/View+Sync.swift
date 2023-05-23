import SwiftUI


struct Sync<Value: Hashable>: ViewModifier {
    
    @Binding var value: Value?
    @FocusState var focusState: Value?
    
    func body(content: Content) -> some View {
        content
            .initialize(focus: $focusState, with: value)
            .onChange(of: value) { value in
                focusState = value
            }
            .onChange(of: focusState) { focusState in
                guard focusState != nil else {
                    self.focusState = value
                    return
                }
                value = focusState
            }
    }
    
}


extension View {
    
    func sync<Value: Hashable>(_ value: Binding<Value?>, to focusState: FocusState<Value?>) -> some View {
        modifier(Sync(value: value, focusState: focusState))
    }
    
}
