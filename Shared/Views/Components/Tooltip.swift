import SwiftUI


private struct Tooltip<Content: View>: View {
    
    private static var maxSize: CGSize {
        CGSize(width: 400, height: 240)
    }
    
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    
    @Binding var isPresented: Bool
    let arrowDirections: UIPopoverArrowDirection
    let content: () -> Content
    
    @State private var height = 0.0
    
    var body: some View {
        Popover(isPresented: $isPresented, size: CGSize(width: Tooltip.maxSize.width, height: height.clamped(to: 1...Tooltip.maxSize.height)), arrowDirections: arrowDirections) {
            ScrollView(height < Tooltip.maxSize.height ? [] : .vertical) {
                content()
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onSizeChange { height = $0.height }
                    .occlude(!biometricAuthenticationController.isUnlocked)
            }
        }
    }
    
}


extension Tooltip {

    /// Inspired by https://github.com/SwiftUIX/SwiftUIX/blob/master/Sources/Intramodular/Presentation/Popover/CocoaPopover.swift
    private struct Popover<Content: View>: UIViewControllerRepresentable {
        
        @Binding var isPresented: Bool
        let size: CGSize
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
            hostingController.maxSize = size
            
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
    
    func tooltip<Content: View>(isPresented: Binding<Bool>, arrowDirections: UIPopoverArrowDirection = .any, content: @escaping () -> Content) -> some View {
        background(
            Tooltip(isPresented: isPresented, arrowDirections: arrowDirections, content: content)
        )
    }
    
}
