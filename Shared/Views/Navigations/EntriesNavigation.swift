import SwiftUI
import Factory


struct EntriesNavigation: View {
    
    @InjectedObject(\.entriesController) private var entriesController
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            EntriesPage(entriesController: entriesController)
        }
        .apply { view in
            if UIDevice.current.userInterfaceIdiom == .pad {
                NavigationSplitView(
                    columnVisibility: .constant(.all),
                    sidebar: {
                        view
                            .apply { view in
                                if #available(iOS 17, *) {
                                    view
                                        .toolbar(removing: .sidebarToggle)
                                }
                            }
                    },
                    detail: {}
                )
                .navigationSplitViewStyle(.balanced)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
