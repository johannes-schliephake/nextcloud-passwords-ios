import SwiftUI


private struct SearchBar: UIViewControllerRepresentable {
    
    @Binding var searchTerm: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(searchBar: self)
    }
    
    func makeUIViewController(context: Context) -> OverlayViewController {
        OverlayViewController()
    }
    
    func updateUIViewController(_ overlayViewController: OverlayViewController, context: Context) {
        overlayViewController.searchController = context.coordinator.searchController
        guard overlayViewController.searchController?.searchBar.text != searchTerm else {
            return
        }
        overlayViewController.searchController?.searchBar.text = searchTerm
    }
    
    static func dismantleUIViewController(_ overlayViewController: OverlayViewController, coordinator: Coordinator) {
        overlayViewController.searchController = nil
    }
    
}


extension SearchBar {
    
    final class Coordinator: NSObject, UISearchResultsUpdating {
        
        let searchController: UISearchController
        
        private let searchBar: SearchBar
        
        init(searchBar: SearchBar) {
            searchController = UISearchController(searchResultsController: nil)
            self.searchBar = searchBar
            super.init()
            
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.autocapitalizationType = .none
            searchController.searchBar.text = searchBar.searchTerm
        }
        
        func updateSearchResults(for searchController: UISearchController) {
            guard let searchTerm = searchController.searchBar.text,
                  searchBar.searchTerm != searchTerm else {
                return
            }
            DispatchQueue.main.async {
                [self] in
                searchBar.searchTerm = searchTerm
            }
        }
        
    }
    
}


extension SearchBar {
    
    final class OverlayViewController: UIViewController {
        
        var searchController: UISearchController? {
            willSet {
                if newValue == nil,
                   parent?.navigationItem.searchController == searchController {
                    parent?.navigationItem.searchController = nil
                }
            }
            didSet {
                DispatchQueue.main.async {
                    [self] in
                    if searchController != nil {
                        parent?.navigationItem.searchController = searchController
                    }
                }
            }
        }
        
    }
    
}


extension View {
    
    func searchBar(term: Binding<String>) -> some View {
        overlay(
            SearchBar(searchTerm: term)
                .frame(width: 0, height: 0)
        )
    }
    
}
