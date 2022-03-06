import SwiftUI


/// Inspired by https://github.com/SwiftUIX/SwiftUIX/blob/master/Sources/Intramodular/Presentation/Popover/CocoaPopover.swift
private struct Popover<Content: View>: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    let content: () -> Content
    
    func makeCoordinator() -> Coordinator {
        Coordinator(popover: self, content: content())
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ viewController: UIViewController, context: Context) {
        let hostingController = context.coordinator.hostingController
        hostingController.rootView = content()
        hostingController.preferredContentSize = hostingController.sizeThatFits(in: CGSize(width: .greatestFiniteMagnitude, height: 200.0))
        
        if isPresented {
            guard hostingController.viewIfLoaded?.window == nil,
                  let popoverPresentationController = hostingController.popoverPresentationController else {
                return
            }
            popoverPresentationController.delegate = context.coordinator
            popoverPresentationController.sourceView = viewController.view
            popoverPresentationController.sourceRect = viewController.view.bounds
            viewController.present(hostingController, animated: true)
        }
        else {
            hostingController.dismiss(animated: true)
        }
    }
    
}


extension Popover {
    
    class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
        
        private let popover: Popover
        
        let hostingController: UIHostingController<Content>
        
        init(popover: Popover, content: Content) {
            self.popover = popover
            hostingController = UIHostingController(rootView: content)
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
    
}


extension View {
    
    func popover<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        background(
            Popover(isPresented: isPresented, content: content)
        )
    }
    
}
