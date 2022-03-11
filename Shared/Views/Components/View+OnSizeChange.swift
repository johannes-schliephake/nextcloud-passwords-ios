import SwiftUI


struct SizePreferenceKey: PreferenceKey {
    
    static let defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
    
}


extension View {
    
    func onSizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader {
                geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
            .onPreferenceChange(SizePreferenceKey.self, perform: action)
    }
    
}
