import SwiftUI
import FactoryKit


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
                    sidebar: { view },
                    detail: {}
                )
                .navigationSplitViewStyle(.balanced)
            }
        }
        .apply { view in
            if #available(iOS 26, *) {
                view
                    .scrollEdgeEffectStyle(.soft, for: .top)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}
