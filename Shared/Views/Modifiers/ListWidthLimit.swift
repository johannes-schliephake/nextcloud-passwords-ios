import SwiftUI


@available(iOS 17.0, *) private struct ListWidthLimit: ViewModifier {
    
    let limit: Double
    
    func body(content: Content) -> some View {
        GeometryReader { geometryProxy in
            let margin = (geometryProxy.size.width - limit) / 2
            content
                .contentMargins(margin > 16 + UIDevice.current.deviceSpecificPadding ? .horizontal : [], .init(top: 0, leading: geometryProxy.safeAreaInsets.leading + margin, bottom: 0, trailing: geometryProxy.safeAreaInsets.trailing + margin), for: .scrollContent)
        }
    }
    
}


@available(iOS 17.0, *) extension View {
    
    func listWidthLimit(_ limit: Double) -> some View {
        modifier(ListWidthLimit(limit: limit))
    }
    
}
