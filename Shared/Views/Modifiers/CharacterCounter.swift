import SwiftUI


private struct CharacterCounter: ViewModifier {
    
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .environment(\.enableCharacterCounter, isEnabled)
    }
    
}


extension View {
    
    func characterCounter(_ isEnabled: Bool) -> some View {
        modifier(CharacterCounter(isEnabled: isEnabled))
    }

}
