import SwiftUI


struct SearchBar: UIViewControllerRepresentable {
    
    @Binding private var searchTerm: String
    
    init(searchTerm: Binding<String>) {
        _searchTerm = searchTerm
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(searchBar: self)
    }
    
    func makeUIViewController(context: Context) -> OverlayViewController {
        OverlayViewController()
    }
    
    func updateUIViewController(_ overlayViewController: OverlayViewController, context: Context) {
        overlayViewController.searchController = context.coordinator.searchController
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
            guard let searchTerm = searchController.searchBar.text else {
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
                if newValue == nil {
                    parent?.navigationItem.searchController = nil
                }
            }
            didSet {
                DispatchQueue.main.async {
                    [self] in
                    parent?.navigationItem.searchController = searchController
                }
            }
        }
        
    }
    
}


extension View {
    
    @ViewBuilder func searchBar(term: Binding<String>) -> some View {
        overlay(SearchBar(searchTerm: term)
                    .frame(width: 0, height: 0))
    }
    
}
