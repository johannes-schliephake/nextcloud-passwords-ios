import SwiftUI


private struct SizePreferenceKey: PreferenceKey {
    
    static let defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
    
}


private struct OnSizeChange: ViewModifier {
    
    let action: (CGSize) -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometryProxy in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self, perform: action)
    }
    
}


extension View {
    
    func onSizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        modifier(OnSizeChange(action: action))
    }
    
}
