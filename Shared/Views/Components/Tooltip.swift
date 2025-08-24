import SwiftUI
import Factory


private enum TooltipConstants {
    static let maxSize = CGSize(width: 400, height: 400)
    static let padding = EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
    static let safeArea = EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
    static let minimumHorizontalSpacing = 19.0
    static let horizontalArrowWidth = 45.0
}


private struct Tooltip<PopoverContent: View>: ViewModifier {
    
    @Injected(\.windowSizeService) private var windowSizeService
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
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
                .apply { view in
                    if #available(iOS 17, *) {
                        view
                            .safeAreaPadding(TooltipConstants.safeArea)
                    } else {
                        view
                            .legacySafeAreaPadding(TooltipConstants.safeArea)
                    }
                }
                .frame(maxHeight: TooltipConstants.maxSize.height)
                .apply { view in
                    if let windowWidth = windowSizeService.windowSize?.width {
                        let maxWidth = TooltipConstants.maxSize.width
                        let maxWidthAvailable = windowWidth - TooltipConstants.minimumHorizontalSpacing * 2
                        let maxWidthAvailableWithoutArrow = maxWidthAvailable - TooltipConstants.horizontalArrowWidth
                        
                        let (contentWidth, forcedWidth) = if maxWidthAvailable < maxWidth {
                            (maxWidthAvailable, 10000.0)
                        } else if maxWidthAvailableWithoutArrow < maxWidth {
                            (maxWidthAvailableWithoutArrow, maxWidthAvailableWithoutArrow)
                        } else {
                            (maxWidth, maxWidth)
                        }
                        
                        view
                            .frame(width: contentWidth) // Force popover content to the maximum possible width
                            .frame(width: forcedWidth) // Force arrow to the top or bottom when popover uses the window's full width
                    }
                }
                .background(Color(.tertiarySystemBackground))
                .presentationCompactAdaptation(.popover)
                .occlude(biometricAuthenticationController.hideContents)
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
