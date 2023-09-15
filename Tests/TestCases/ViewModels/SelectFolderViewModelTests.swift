import XCTest
import Nimble
import Factory
@testable import Passwords


final class SelectFolderViewModelTests: XCTestCase {
    
    private let temporaryEntryMock: SelectFolderViewModel.TemporaryEntry = .password(label: .random(), username: .random(), url: .random(), folder: .random())
    private lazy var entryMock = Entry.password(passwordMock)
    @Injected(\.password) private var passwordMock
    @Injected(\.folders) private var folderMocks
    
    @MockInjected(\.foldersService) private var foldersServiceMock: FoldersServiceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testSheetItem_givenEditCase_thenIdReturnsFoldersId() {
        let folderMock = Folder(id: .random(), parent: nil)
        let sheetItem = SelectFolderViewModel.SheetItem.edit(folder: folderMock)
        
        expect(sheetItem.id).to(equal(folderMock.id))
    }
    
    func testInit_thenSetsInitialState() {
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        expect(selectFolderViewModel[\.sheetItem]).to(beNil())
        expect(selectFolderViewModel[\.temporaryEntry]).to(equal(temporaryEntryMock))
        expect(selectFolderViewModel[\.tree]).to(equal(.init(value: .init())))
        expect(selectFolderViewModel[\.selection]).to(beNil())
        expect(selectFolderViewModel[\.hasChanges]).to(beFalse())
        expect(selectFolderViewModel[\.selectionIsValid]).to(beFalse())
    }
    
    func testInit_thenCallsFoldersService() {
        _ = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        expect(self.foldersServiceMock).to(beAccessed(.twice, on: "folders"))
    }
    
    func testInit_whenFoldersServiceEmittingFolders_thenSetsTree() {
        let entryFolder = Folder(id: .random(), parent: Entry.baseId)
        let entryMock = Entry.folder(entryFolder)
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        let folderWithLocallyMissingId = Folder(parent: Entry.baseId)
        let unreachableFolder = Folder(id: .random(), parent: .random())
        let entryChildFolder = Folder(id: .random(), parent: entryFolder.id)
        folderMocks.append(contentsOf: [entryFolder, entryChildFolder, folderWithLocallyMissingId, unreachableFolder])
        foldersServiceMock._folders.send(folderMocks.shuffled())
        
        let expectedTree = Node(value: Folder()) {
            Node(value: self.folderMocks[1])
            Node(value: self.folderMocks[0])
            Node(value: self.folderMocks[2])
        }
        expect(selectFolderViewModel[\.tree]).to(equal(expectedTree))
    }
    
    func testInit_givenValidParentId_whenFoldersServiceEmittingFolders_thenSetsSelectionToMatchingFolder() {
        let temporaryEntryMock = SelectFolderViewModel.TemporaryEntry.folder(label: .random(), parent: folderMocks[0].id)
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        foldersServiceMock._folders.send(folderMocks.shuffled())
        
        expect(selectFolderViewModel[\.selection]).to(be(folderMocks[0]))
    }
    
    func testInit_givenInvalidParentId_whenFoldersServiceEmittingFolders_thenSetsSelectionToBaseFolder() {
        let temporaryEntryMock = SelectFolderViewModel.TemporaryEntry.folder(label: .random(), parent: .random())
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        foldersServiceMock._folders.send(folderMocks.shuffled())
        
        expect(selectFolderViewModel[\.selection]).to(equal(.init()))
    }
    
    func testInit_givenValidSelection_whenFoldersServiceEmittingFolders_thenKeepsSelection() {
        let temporaryEntryMock = SelectFolderViewModel.TemporaryEntry.folder(label: .random(), parent: .random())
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        selectFolderViewModel[\.selection] = folderMocks[0]
        
        foldersServiceMock._folders.send(folderMocks.shuffled())
        
        expect(selectFolderViewModel[\.selection]).to(be(folderMocks[0]))
    }
    
    func testInit_givenInvalidSelection_whenFoldersServiceEmittingFolders_thenSetsSelectionToBaseFolder() {
        let temporaryEntryMock = SelectFolderViewModel.TemporaryEntry.folder(label: .random(), parent: folderMocks[0].id)
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        selectFolderViewModel[\.selection] = .init(id: .random(), parent: Entry.baseId)
        
        foldersServiceMock._folders.send(folderMocks.shuffled())
        
        expect(selectFolderViewModel[\.selection]).to(equal(.init()))
    }
    
    func testInit_whenChangingSelection_thenSetsHasChangesToTrue() {
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        selectFolderViewModel[\.selection] = .init()
        
        expect(selectFolderViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_whenDoingAndUndoingChanges_thenSetsHasChangesToFalse() {
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        selectFolderViewModel[\.selection] = .init()
        selectFolderViewModel[\.selection] = .init(id: temporaryEntryMock.parent, parent: nil)
        
        expect(selectFolderViewModel[\.hasChanges]).to(beFalse())
    }
    
    func testInit_whenSettingValidSelection_thenUpdatesSelectionIsValidToTrue() {
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        selectFolderViewModel[\.selection] = .init()
        
        expect(selectFolderViewModel[\.selectionIsValid]).to(beTrue())
    }
    
    func testInit_whenSettingInvalidSelection_thenUpdatesSelectionIsValidToTrue() {
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        selectFolderViewModel[\.selection] = .init(id: "", parent: nil)
        
        expect(selectFolderViewModel[\.selectionIsValid]).to(beFalse())
    }
    
    func testInit_whenRemovingSelection_thenUpdatesSelectionIsValidToFalse() {
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        selectFolderViewModel[\.selection] = nil
        
        expect(selectFolderViewModel[\.selectionIsValid]).to(beFalse())
    }
    
    func testCallAsFunction_givenSelection_whenCallingShowFolderCreation_thenCallsFoldersService() {
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        selectFolderViewModel[\.selection] = folderMocks[0]
        
        selectFolderViewModel(.showFolderCreation)
        
        expect(self.foldersServiceMock).to(beCalled(.once, on: "makeFolder(parentId:)", withParameter: folderMocks[0].id))
        expect(selectFolderViewModel[\.sheetItem]).to(equal(.edit(folder: foldersServiceMock._makeFolder)))
    }
    
    func testCallAsFunction_givenMissingSelection_whenCallingShowFolderCreation_thenCallsFoldersService() {
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        selectFolderViewModel(.showFolderCreation)
        
        expect(self.foldersServiceMock).to(beCalled(.once, on: "makeFolder(parentId:)", withParameter: Entry.baseId))
        expect(selectFolderViewModel[\.sheetItem]).to(equal(.edit(folder: foldersServiceMock._makeFolder)))
    }
    
    func testCallAsFunction_givenSelection_whenCallingShowFolderCreation_thenSetsSheetItem() {
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        selectFolderViewModel[\.selection] = folderMocks[0]
        
        selectFolderViewModel(.showFolderCreation)
        
        expect(selectFolderViewModel[\.sheetItem]).to(equal(.edit(folder: foldersServiceMock._makeFolder)))
    }
    
    func testCallAsFunction_givenMissingSelection_whenCallingShowFolderCreation_thenSetsSheetItem() {
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        selectFolderViewModel(.showFolderCreation)
        
        expect(selectFolderViewModel[\.sheetItem]).to(equal(.edit(folder: foldersServiceMock._makeFolder)))
    }
    
    func testCallAsFunction_whenCallingSetSelection_thenSetsSelection() {
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        selectFolderViewModel(.setSelection(folderMocks[0]))
        
        expect(selectFolderViewModel[\.selection]).to(be(folderMocks[0]))
    }
    
    func testCallAsFunction_givenHasChangesAndSelectionIsValidAreTrue_whenCallingSelectFolder_thenCallsSelectFolderClosure() {
        let closure = ClosureMock()
        let temporaryEntryMock = SelectFolderViewModel.TemporaryEntry.folder(label: .random(), parent: folderMocks[0].id)
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock, selectFolder: closure.log)
        let selectionMock = Folder()
        foldersServiceMock._folders.send(folderMocks.shuffled())
        selectFolderViewModel[\.selection] = selectionMock
        
        selectFolderViewModel(.selectFolder)
        
        expect(closure).to(beCalled(.once, withParameter: selectionMock))
    }
    
    func testCallAsFunction_givenHasChangesIsFalse_whenCallingSelectFolder_thenDoesntCallSelectFolderClosure() {
        let closure = ClosureMock()
        let temporaryEntryMock = SelectFolderViewModel.TemporaryEntry.folder(label: .random(), parent: folderMocks[0].id)
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock, selectFolder: closure.log)
        foldersServiceMock._folders.send(folderMocks.shuffled())
        
        selectFolderViewModel(.selectFolder)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenSelectionIsValidIsFalse_whenCallingSelectFolder_thenDoesntCallSelectFolderClosure() {
        let closure = ClosureMock()
        let temporaryEntryMock = SelectFolderViewModel.TemporaryEntry.folder(label: .random(), parent: folderMocks[0].id)
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock, selectFolder: closure.log)
        foldersServiceMock._folders.send(folderMocks.shuffled())
        selectFolderViewModel[\.selection] = nil
        
        selectFolderViewModel(.selectFolder)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenHasChangesAndSelectionIsValidAreTrue_whenCallingSelectFolder_thenShouldDismissEmits() {
        let temporaryEntryMock = SelectFolderViewModel.TemporaryEntry.folder(label: .random(), parent: folderMocks[0].id)
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        let selectionMock = Folder()
        foldersServiceMock._folders.send(folderMocks.shuffled())
        selectFolderViewModel[\.selection] = selectionMock
        
        expect(selectFolderViewModel[\.shouldDismiss]).to(emit(when: { selectFolderViewModel(.selectFolder) }))
    }
    
    func testCallAsFunction_givenHasChangesIsFalse_whenCallingSelectFolder_thenShouldDismissDoesntEmit() {
        let temporaryEntryMock = SelectFolderViewModel.TemporaryEntry.folder(label: .random(), parent: folderMocks[0].id)
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        foldersServiceMock._folders.send(folderMocks.shuffled())
        
        expect(selectFolderViewModel[\.shouldDismiss]).toNot(emit(when: { selectFolderViewModel(.selectFolder) }))
    }
    
    func testCallAsFunction_givenSelectionIsValidIsFalse_whenCallingSelectFolder_thenShouldDismissDoesntEmit() {
        let temporaryEntryMock = SelectFolderViewModel.TemporaryEntry.folder(label: .random(), parent: folderMocks[0].id)
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        foldersServiceMock._folders.send(folderMocks.shuffled())
        selectFolderViewModel[\.selection] = nil
        
        expect(selectFolderViewModel[\.shouldDismiss]).toNot(emit(when: { selectFolderViewModel(.selectFolder) }))
    }
    
    func testCallAsFunction_whenCallingCancel_thenShouldDismissEmits() {
        let selectFolderViewModel: any SelectFolderViewModelProtocol = SelectFolderViewModel(entry: entryMock, temporaryEntry: temporaryEntryMock) { _ in }
        
        expect(selectFolderViewModel[\.shouldDismiss]).to(emit(when: { selectFolderViewModel(.cancel) }))
    }
    
}
