import SwiftUI


private struct RefreshGesture: UIViewControllerRepresentable {
    
    let action: (_ endRefreshing: @escaping () -> Void) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(refreshGesture: self)
    }
    
    func makeUIViewController(context: Context) -> OverlayViewController {
        OverlayViewController()
    }
    
    func updateUIViewController(_ overlayViewController: OverlayViewController, context: Context) {
        overlayViewController.refreshControl = context.coordinator.refreshControl
    }
    
    static func dismantleUIViewController(_ overlayViewController: OverlayViewController, coordinator: Coordinator) {
        overlayViewController.refreshControl = nil
    }
    
}


extension RefreshGesture {
    
    final class Coordinator {
        
        let refreshControl: UIRefreshControl
        
        private let refreshGesture: RefreshGesture
        
        init(refreshGesture: RefreshGesture) {
            refreshControl = UIRefreshControl()
            self.refreshGesture = refreshGesture
            
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        }
        
        @objc private func refresh() {
            refreshGesture.action {
                [weak self] in
                self?.refreshControl.endRefreshing()
            }
        }
        
    }
    
}


extension RefreshGesture {
    
    final class OverlayViewController: UIViewController {
        
        var refreshControl: UIRefreshControl? {
            willSet {
                if newValue == nil,
                   let view = parent?.view,
                   let tableView = tableView(inside: view),
                   tableView.refreshControl == refreshControl {
                    tableView.refreshControl = nil
                }
            }
            didSet {
                DispatchQueue.main.async {
                    [self] in
                    if refreshControl != nil,
                       let view = parent?.view,
                       let tableView = tableView(inside: view) {
                        tableView.refreshControl = refreshControl
                    }
                }
            }
        }
        
        private func tableView(inside view: UIView) -> UITableView? {
            if let tableView = view as? UITableView {
                return tableView
            }
            for subview in view.subviews.reversed() {
                if let tableView = tableView(inside: subview) {
                    return tableView
                }
            }
            return nil
        }
        
    }
    
}


extension View {
    
    func refreshGesture(action: @escaping (_ endRefreshing: @escaping () -> Void) -> Void) -> some View {
        overlay(
            RefreshGesture(action: action)
                .frame(width: 0, height: 0)
        )
    }
    
}
