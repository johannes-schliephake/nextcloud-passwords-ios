import SwiftUI


private enum TooltipConstants {
    static let maxSize = CGSize(width: 400, height: 400)
    static let padding = EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
    static let safeArea = EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
}


private struct Tooltip<PopoverContent: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    let content: () -> PopoverContent
    
    func body(content anchor: Content) -> some View {
        anchor
            .popover(isPresented: $isPresented) {
                ScrollView {
                    content()
                        .padding(TooltipConstants.padding - TooltipConstants.safeArea)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollBounceBehavior(.basedOnSize)
                .safeAreaPadding(TooltipConstants.safeArea)
                .frame(
                    idealWidth: TooltipConstants.maxSize.width,
                    maxWidth: TooltipConstants.maxSize.width,
                    maxHeight: TooltipConstants.maxSize.height
                )
                .apply { view in
                    if #unavailable(iOS 26) {
                        view
                            .background(Color(.tertiarySystemBackground))
                    }
                }
                .presentationCompactAdaptation(.popover)
                .popoverArrowEdges(.vertical)
            }
    }
    
}


extension View {
    
    /// Presents an iPad-style popover when a given condition is true.
    /// - Parameters:
    ///   - isPresented: A binding to a `Bool` that determines whether to show the popover.
    ///   - content: A closure returning the content of the popover.
    func tooltip<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        modifier(Tooltip(isPresented: isPresented, content: content))
    }
    
}
