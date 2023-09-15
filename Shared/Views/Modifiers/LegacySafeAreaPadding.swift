import SwiftUI


private struct LegacySafeAreaPadding: ViewModifier {
    
    let insets: EdgeInsets
    
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear
                    .frame(height: insets.top)
            }
            .safeAreaInset(edge: .leading, spacing: 0) {
                Color.clear
                    .frame(width: insets.leading)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                    .frame(height: insets.bottom)
            }
            .safeAreaInset(edge: .trailing, spacing: 0) {
                Color.clear
                    .frame(width: insets.trailing)
            }
    }
    
}


extension View {
    
    func legacySafeAreaPadding(_ insets: EdgeInsets) -> some View {
        modifier(LegacySafeAreaPadding(insets: insets))
    }
    
}
