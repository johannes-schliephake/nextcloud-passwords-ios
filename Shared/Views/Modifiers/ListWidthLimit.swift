import SwiftUI


@available(iOS 17, *) private struct ListWidthLimit: ViewModifier {
    
    let limit: Double
    
    @State private var contentWidth = 300.0
    @State private var safeAreaInsets = EdgeInsets()
    
    private var margin: Double {
        (contentWidth - limit) / 2
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
                margin > EdgeInsets.entryRow.leading ? .horizontal : [],
                .init(
                    top: 0,
                    leading: safeAreaInsets.leading + margin,
                    bottom: 0,
                    trailing: safeAreaInsets.trailing + margin
                ),
                for: .scrollContent
            )
    }
    
}


@available(iOS 17, *) extension View {
    
    func listWidthLimit(_ limit: Double) -> some View {
        modifier(ListWidthLimit(limit: limit))
    }
    
}
