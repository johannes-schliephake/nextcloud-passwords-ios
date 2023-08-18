import Foundation
import Combine
import Factory


protocol SelectFolderViewModelProtocol: ViewModel where State == SelectFolderViewModel.State, Action == SelectFolderViewModel.Action {
    
    init(entry: Entry, temporaryEntry: SelectFolderViewModel.TemporaryEntry, selectFolder: @escaping (Folder) -> Void)
    
}


final class SelectFolderViewModel: SelectFolderViewModelProtocol {
    
    final class State: ObservableObject {
        
        @Published var sheetItem: SheetItem?
        let temporaryEntry: TemporaryEntry
        @Published fileprivate(set) var tree: Node<Folder>
        @Published var selection: Folder?
        @Published fileprivate(set) var hasChanges: Bool
        @Published fileprivate(set) var selectionIsValid: Bool
        
        let shouldDismiss = PassthroughSubject<Void, Never>()
        
        init(sheetItem: SheetItem?, temporaryEntry: TemporaryEntry, tree: Node<Folder>, selection: Folder?, hasChanges: Bool, selectionIsValid: Bool) {
            self.sheetItem = sheetItem
            self.temporaryEntry = temporaryEntry
            self.tree = tree
            self.selection = selection
            self.hasChanges = hasChanges
            self.selectionIsValid = selectionIsValid
        }
        
    }
    
    enum Action {
        case showFolderCreation
        case setSelection(Folder)
        case selectFolder
        case cancel
    }
    
    enum SheetItem: Identifiable {
        
        case edit(folder: Folder)
        
        var id: String {
            switch self {
            case .edit(let folder):
                return folder.id
            }
        }
        
    }
    
    enum TemporaryEntry {
        
        case folder(label: String, parent: String)
        case password(label: String, username: String, url: String, folder: String)
        
        var parent: String {
            switch self {
            case let .folder(_, parent):
                return parent
            case let .password(_, _, _, folder):
                return folder
            }
        }
        
    }
    
    @Injected(\.foldersService) private var foldersService
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private let entry: Entry
    private let selectFolder: (Folder) -> Void
    private var cancellables = Set<AnyCancellable>()
    
    init(entry: Entry, temporaryEntry: SelectFolderViewModel.TemporaryEntry, selectFolder: @escaping (Folder) -> Void) {
        state = .init(sheetItem: nil, temporaryEntry: temporaryEntry, tree: .init(value: .init()), selection: nil, hasChanges: false, selectionIsValid: false)
        self.entry = entry
        self.selectFolder = selectFolder
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        foldersService.folders
            .compactMap { folders in
                guard let self else {
                    return nil
                }
                
                var folders = folders
                if case let .folder(folder) = self.entry {
                    folders = folders.filter { $0 !== folder }
                }
                
                return Self.makeNode(for: self.state.tree.value, with: folders)
            }
            .sink { self?.state.tree = $0 }
            .store(in: &cancellables)
        
        foldersService.folders
            .compactMap { folders in
                guard let self else {
                    return nil
                }
                
                let selectedId = self.state.selection?.id ?? self.state.temporaryEntry.parent
                return folders.first { $0.id == selectedId } ?? self.state.tree.value
            }
            .sink { self?.state.selection = $0 }
            .store(in: &cancellables)
        
        state.$selection
            .dropFirst()
            .map(\.?.id)
            .map { $0 != self?.state.temporaryEntry.parent }
            .sink { self?.state.hasChanges = $0 }
            .store(in: &cancellables)
        
        state.$selection
            .dropFirst()
            .map { $0 != nil && $0?.isIdLocallyAvailable == true }
            .sink { self?.state.selectionIsValid = $0 }
            .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .showFolderCreation:
            let parentId = state.selection?.id ?? state.tree.value.id
            let folder = foldersService.makeFolder(parentId: parentId)
            state.sheetItem = .edit(folder: folder)
        case let .setSelection(folder):
            state.selection = folder
        case .selectFolder:
            guard state.hasChanges,
                  state.selectionIsValid,
                  let selectedFolder = state.selection else {
                logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
                return
            }
            selectFolder(selectedFolder)
            state.shouldDismiss.send()
        case .cancel:
            state.shouldDismiss.send()
        }
    }
    
    private static func makeNode(for folder: Folder, with folders: [Folder]) -> Node<Folder> {
        let children = folders
            .filter { $0.parent == folder.id }
            .filter(\.isIdLocallyAvailable)
            .sortedByLabel()
            .map { makeNode(for: $0, with: folders) }
        return Node(value: folder, children: children.isEmpty ? nil : children)
    }
    
}


#if DEBUG

extension SelectFolderViewModel.SheetItem: Equatable {}

extension SelectFolderViewModel.TemporaryEntry: Equatable {}

#endif
