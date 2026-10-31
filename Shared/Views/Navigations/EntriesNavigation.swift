import SwiftUI
import FactoryKit


struct EntriesNavigation: View {
    
    @InjectedObject(\.entriesController) private var entriesController
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // MARK: Views
    
    var body: some View {
        NavigationSplitView(
            columnVisibility: .constant(.all),
            sidebar: {
                NavigationStack {
                    EntriesPage(entriesController: entriesController)
                }
            },
            detail: {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            }
        )
        .navigationSplitViewStyle(.balanced)
        .apply { view in
            if #available(iOS 26, *) {
                view
                    .scrollEdgeEffectStyle(.soft, for: .top)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .environment(\.hasMultiColumnLayout, horizontalSizeClass == .regular)
    }
    
}
