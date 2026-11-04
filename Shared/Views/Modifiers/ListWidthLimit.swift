import SwiftUI


private struct ListWidthLimit: ViewModifier {
    
    let limit: Double?
    
    @State private var contentWidth = 300.0
    @State private var safeAreaInsets = EdgeInsets()
    
    private var margin: Double? {
        limit.map({ (contentWidth - $0) / 2 })
    }
    
    func body(content: Content) -> some View {
        content
            .onGeometryChange(
                for: Double.self,
                of: { $0.size.width },
                action: { contentWidth = $0 }
            )
            .onGeometryChange(
                for: EdgeInsets.self,
                of: { $0.safeAreaInsets },
                action: { safeAreaInsets = $0 }
            )
            .contentMargins(
                margin.map { $0 > EdgeInsets.entryRow.leading } ?? false ? .horizontal : [],
                .init(
                    top: 0,
                    leading: safeAreaInsets.leading + (margin ?? 0),
                    bottom: 0,
                    trailing: safeAreaInsets.trailing + (margin ?? 0)
                ),
                for: .scrollContent
            )
    }
    
}


extension View {
    
    func listWidthLimit(_ limit: Double?) -> some View {
        modifier(ListWidthLimit(limit: limit))
    }
    
}
