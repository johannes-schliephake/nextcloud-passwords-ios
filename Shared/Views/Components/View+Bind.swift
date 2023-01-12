import SwiftUI


struct Bind<Value: Hashable>: ViewModifier {
    
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
    
    func bind<Value: Hashable>(_ value: Binding<Value?>, to focusState: FocusState<Value?>) -> some View {
        modifier(Bind(value: value, focusState: focusState))
    }
    
}
