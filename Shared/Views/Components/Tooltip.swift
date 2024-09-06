import SwiftUI
import Factory


private enum TooltipConstants {
    static let maxSize = CGSize(width: 400, height: 400)
    static let padding = EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
    static let safeArea = EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
}


@available(iOS 16.4, *) private struct Tooltip<PopoverContent: View>: ViewModifier { // swiftlint:disable:this file_types_order
    
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
                        let maxWidthAvailableToTooltip = windowWidth - 19 * 2
                        view
                            .frame(width: min(TooltipConstants.maxSize.width, maxWidthAvailableToTooltip)) // Force popover content to the maximum possible width
                            .frame(width: TooltipConstants.maxSize.width < maxWidthAvailableToTooltip ? TooltipConstants.maxSize.width : 10000) // Force arrow to the top or bottom when popover uses the window's full width
                    }
                }
                .background(Color(.tertiarySystemBackground))
                .presentationCompactAdaptation(.popover)
                .occlude(biometricAuthenticationController.hideContents)
            }
    }
    
}


private struct LegacyTooltip<PopoverContent: View>: View {
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    @Binding var isPresented: Bool
    let arrowDirections: UIPopoverArrowDirection
    let content: () -> PopoverContent
    
    @State private var containerHeight = 0.0
    @State private var contentHeight = 0.0
    
    var body: some View {
        Popover(isPresented: $isPresented, maxSize: CGSize(width: TooltipConstants.maxSize.width, height: contentHeight.clamped(to: 1...TooltipConstants.maxSize.height)), arrowDirections: arrowDirections) {
            content()
                .padding(TooltipConstants.padding - TooltipConstants.safeArea)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onSizeChange { contentHeight = $0.height + TooltipConstants.safeArea.top + TooltipConstants.safeArea.bottom }
                .apply {
                    view in
                    if #available(iOS 16, *) {
                        ScrollView {
                            view
                        }
                        .scrollDisabled(contentHeight - 0.1 <= containerHeight)
                    }
                    else {
                        ScrollView(contentHeight - 0.1 > containerHeight ? .vertical : []) {
                            view
                                .apply { $0 } // Apply fixes layout issues on iOS 15
                        }
                    }
                }
                .legacySafeAreaPadding(TooltipConstants.safeArea)
                .occlude(biometricAuthenticationController.hideContents)
                .onSizeChange { containerHeight = $0.height }
        }
    }
    
}


extension LegacyTooltip {
    
    /// Inspired by https://github.com/SwiftUIX/SwiftUIX/blob/master/Sources/Intramodular/Presentation/Popover/CocoaPopover.swift
    private struct Popover<Content: View>: UIViewControllerRepresentable {
        
        @Binding var isPresented: Bool
        let maxSize: CGSize
        let arrowDirections: UIPopoverArrowDirection
        @ViewBuilder let content: () -> Content
        
        func makeCoordinator() -> Coordinator {
            Coordinator(popover: self, content: content())
        }
        
        func makeUIViewController(context: Context) -> UIViewController {
            UIViewController()
        }
        
        func updateUIViewController(_ viewController: UIViewController, context: Context) {
            let hostingController = context.coordinator.hostingController
            hostingController.rootView = content()
            hostingController.maxSize = maxSize
            
            if isPresented {
                guard hostingController.presentingViewController == nil,
                      let popoverPresentationController = hostingController.popoverPresentationController else {
                    return
                }
                popoverPresentationController.delegate = context.coordinator
                popoverPresentationController.sourceView = viewController.view
                popoverPresentationController.sourceRect = viewController.view.bounds
                popoverPresentationController.permittedArrowDirections = arrowDirections
                viewController.present(hostingController, animated: true)
            }
            else {
                hostingController.dismiss(animated: true)
            }
        }
        
        final class Coordinator: NSObject, UIPopoverPresentationControllerDelegate { // swiftlint:disable:this nesting
            
            private let popover: Popover
            
            let hostingController: SelfSizingHostingController
            
            init(popover: Popover, content: Content) {
                self.popover = popover
                hostingController = SelfSizingHostingController(rootView: content)
                super.init()
                
                hostingController.modalPresentationStyle = .popover
                hostingController.view.backgroundColor = .tertiarySystemBackground
            }
            
            func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
                .none
            }
            
            func adaptivePresentationStyle(for _: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
                .none
            }
            
            func presentationControllerWillDismiss(_: UIPresentationController) {
                popover.isPresented = false
            }
            
        }
        
        final class SelfSizingHostingController: UIHostingController<Content> { // swiftlint:disable:this nesting
            
            var maxSize = CGSize(width: .max, height: .max)
            
            override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                preferredContentSize = sizeThatFits(in: maxSize)
            }
            
        }
        
    }
    
}


extension View {
    
    /// Presents an iPad-style popover when a given condition is true.
    /// - Parameters:
    ///   - isPresented: A binding to a `Bool` that determines whether to show the popover.
    ///   - arrowDirections: A set of allowed arrow directions. iOS 16.4+ manages the popover's arrow direction automatically and will ignore this parameter.
    ///   - content: A closure returning the content of the popover.
    @ViewBuilder func tooltip<Content: View>(isPresented: Binding<Bool>, arrowDirections: UIPopoverArrowDirection = .any, content: @escaping () -> Content) -> some View {
        if #available(iOS 16.4, *) {
            modifier(Tooltip(isPresented: isPresented, content: content))
        } else {
            background(LegacyTooltip(isPresented: isPresented, arrowDirections: arrowDirections, content: content))
        }
    }
    
}
