import Combine
import SwiftUI


private struct PopoverArrowEdges: ViewModifier {
    
    let edges: Edge.Set
    
    @Environment(\.layoutDirection) private var layoutDirection
    
    func body(content: Content) -> some View {
        content
            .background(PopoverArrowDirections(directions: .init(edges, layoutDirection: layoutDirection)))
    }
    
}


extension PopoverArrowEdges {
    
    struct PopoverArrowDirections: UIViewRepresentable {
        
        let directions: UIPopoverArrowDirection
        
        func makeUIView(context: Context) -> some UIView {
            DirectionsView(directions: directions)
        }
        
        func updateUIView(_: UIViewType, context: Context) {}
        
    }
    
}


extension PopoverArrowEdges.PopoverArrowDirections {
    
    final class DirectionsView: UIView {
        
        private let directions: UIPopoverArrowDirection
        private var cancellable: AnyCancellable?
        
        private var popoverPresentationController: UIPopoverPresentationController? {
            sequence(first: self as UIResponder, next: \.next)
                .lazy
                .compactMap { ($0 as? UIViewController)?.popoverPresentationController }
                .first
        }
        
        init(directions: UIPopoverArrowDirection) {
            self.directions = directions
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented") // swiftlint:disable:this fatal_error
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
            cancellable = popoverPresentationController?.publisher(for: \.permittedArrowDirections)
                .filter { [weak self] in $0 != self?.directions }
                .sink { [weak self] _ in
                    guard let self else {
                        return
                    }
                    popoverPresentationController?.permittedArrowDirections = directions
                    // In rare case unstable, might lead to a recursive call
                    popoverPresentationController?.containerView?.layoutIfNeeded()
                }
        }
        
    }
    
}


extension View {
    
    func popoverArrowEdges(_ edges: Edge.Set) -> some View {
        modifier(PopoverArrowEdges(edges: edges))
    }
    
}
