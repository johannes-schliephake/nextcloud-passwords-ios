import XCTest
import Nimble
import Factory
@testable import Passwords


final class EditFolderViewModelTests: XCTestCase {
    
    private let folderMock = Container.folder()
    
    private let foldersServiceMock = FoldersServiceMock()
    
    override func setUp() {
        super.setUp()
        
        Container.registerMocks()
        Container.foldersService.register { self.foldersServiceMock }
    }
    
    override func tearDown() {
        super.tearDown()
        
        Container.Registrations.reset()
    }
    
    func testInit_folderIsEdited_setsInitialState() {
        foldersServiceMock._validateFolderLabel = true
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        expect(editFolderViewModel[\.folder]).to(be(folderMock))
        expect(editFolderViewModel[\.isCreating]).to(beFalse())
        expect(editFolderViewModel[\.folderLabel]).to(equal(folderMock.label))
        expect(editFolderViewModel[\.folderFavorite]).to(equal(folderMock.favorite))
        expect(editFolderViewModel[\.folderParent]).to(equal(folderMock.parent))
        expect(editFolderViewModel[\.parentLabel]).to(beEmpty())
        expect(editFolderViewModel[\.showSelectFolderView]).to(beFalse())
        expect(editFolderViewModel[\.showDeleteAlert]).to(beFalse())
        expect(editFolderViewModel[\.showCancelAlert]).to(beFalse())
        expect(editFolderViewModel[\.hasChanges]).to(beFalse())
        expect(editFolderViewModel[\.editIsValid]).to(beTrue())
        expect(editFolderViewModel[\.focusedField]).to(beNil())
    }
    
    func testInit_folderIsCreated_setsInitialState() {
        foldersServiceMock._validateFolderLabel = true
        let newFolder = Folder(label: .random(), parent: .random(), favorite: .random())
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: newFolder) { _ in }
        
        expect(editFolderViewModel[\.folder]).to(be(newFolder))
        expect(editFolderViewModel[\.isCreating]).to(beTrue())
        expect(editFolderViewModel[\.folderLabel]).to(equal(newFolder.label))
        expect(editFolderViewModel[\.folderFavorite]).to(equal(newFolder.favorite))
        expect(editFolderViewModel[\.folderParent]).to(equal(newFolder.parent))
        expect(editFolderViewModel[\.parentLabel]).to(beEmpty())
        expect(editFolderViewModel[\.showSelectFolderView]).to(beFalse())
        expect(editFolderViewModel[\.showDeleteAlert]).to(beFalse())
        expect(editFolderViewModel[\.showCancelAlert]).to(beFalse())
        expect(editFolderViewModel[\.hasChanges]).to(beFalse())
        expect(editFolderViewModel[\.editIsValid]).to(beTrue())
        expect(editFolderViewModel[\.focusedField]).to(equal(.folderLabel))
    }
    
    func testInit_setFolderParent_callsFoldersService() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let parentId = String.random()
        let newParentFolder = Folder(id: parentId, parent: nil)
        editFolderViewModel(.selectParent(newParentFolder))
        
        expect(self.foldersServiceMock).to(beCalled(.twice, on: "folderLabel(forId:)", withParameters: [parentId], onCallIndex: 1))
        expect(self.foldersServiceMock).to(beCalled(.twice, on: "validate(folderLabel:folderParent:)", withParameters: [folderMock.label, parentId], onCallIndex: 1))
    }
    
    func testInit_foldersServiceEmitsFolderLabel_setsParentLabel() {
        let newFolder = Folder(parent: .random())
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: newFolder) { _ in }
        
        let parentLabelMock = String.random()
        foldersServiceMock._folderLabelForIdFolderId.send(parentLabelMock)
        
        expect(editFolderViewModel[\.parentLabel]).to(equal(parentLabelMock))
    }
    
    func testInit_changeFolderLabel_setsHasChangesToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel[\.folderLabel] = .random()
        
        expect(editFolderViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_changeFolderFavorite_setsHasChangesToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.toggleFavorite)
        
        expect(editFolderViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_changeFolderParent_setsHasChangesToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let newParentFolder = Folder(id: .random(), parent: nil)
        editFolderViewModel(.selectParent(newParentFolder))
        
        expect(editFolderViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_doAndUndoChanges_setsHasChangesToFalse() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel[\.folderLabel] = .random()
        editFolderViewModel(.toggleFavorite)
        let newParentFolder = Folder(id: .random(), parent: nil)
        editFolderViewModel(.selectParent(newParentFolder))
        editFolderViewModel[\.folderLabel] = folderMock.label
        editFolderViewModel(.toggleFavorite)
        let initialParentFolder = Folder(id: folderMock.parent!, parent: nil)
        editFolderViewModel(.selectParent(initialParentFolder))
        
        expect(editFolderViewModel[\.hasChanges]).to(beFalse())
    }
    
    func testInit_setFolderLabel_callsFoldersService() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let newFolderLabel = String.random()
        editFolderViewModel[\.folderLabel] = newFolderLabel
        
        expect(self.foldersServiceMock).to(beCalled(.twice, on: "validate(folderLabel:folderParent:)", withParameters: [newFolderLabel, folderMock.parent as Any], onCallIndex: 1))
    }
    
    func testInit_setFolderLabel_updatesEditIsValid() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let validateFolderLabelMock = Bool.random()
        let newFolderLabel = String.random()
        foldersServiceMock._validateFolderLabel = validateFolderLabelMock
        editFolderViewModel[\.folderLabel] = newFolderLabel
        
        expect(editFolderViewModel[\.editIsValid]).to(equal(validateFolderLabelMock))
    }
    
    func testInit_setFolderParent_updatesEditIsValid() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let validateFolderLabelMock = Bool.random()
        let parentId = String.random()
        let newParentFolder = Folder(id: parentId, parent: nil)
        foldersServiceMock._validateFolderLabel = validateFolderLabelMock
        editFolderViewModel(.selectParent(newParentFolder))
        
        expect(editFolderViewModel[\.editIsValid]).to(equal(validateFolderLabelMock))
    }
    
    func testCallAsFunction_toggleFavorite_togglesFolderFavorite() {
        let newFavorite = Bool.random()
        folderMock.favorite = newFavorite
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.toggleFavorite)
        
        expect(editFolderViewModel[\.folderFavorite]).toNot(equal(newFavorite))
    }
    
    func testCallAsFunction_showParentSelection_setsShowSelectFolderViewToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.showParentSelection)
        
        expect(editFolderViewModel[\.showSelectFolderView]).to(beTrue())
    }
    
    func testCallAsFunction_selectParent_updatesFolderParent() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let parentId = String.random()
        let newParentFolder = Folder(id: parentId, parent: nil)
        editFolderViewModel(.selectParent(newParentFolder))
        
        expect(editFolderViewModel[\.folderParent]).to(equal(parentId))
    }
    
    func testCallAsFunction_deleteFolder_setsShowDeleteAlertToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.deleteFolder)
        
        expect(editFolderViewModel[\.showDeleteAlert]).to(beTrue())
    }
    
    func testCallAsFunction_confirmDelete_callsFoldersService() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.confirmDelete)
        
        expect(self.foldersServiceMock).to(beCalled(.once, on: "delete(folder:)", withParameters: [folderMock]))
    }
    
    func testCallAsFunction_confirmDelete_shouldDismissEmits() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        expect(editFolderViewModel[\.shouldDismiss]).to(emit(when: { editFolderViewModel(.confirmDelete) }))
    }
    
    func testCallAsFunction_applyToFolder_callsFoldersService() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.applyToFolder)
        
        expect(self.foldersServiceMock).to(beCalled(.once, on: "apply(to:folderLabel:folderFavorite:folderParent:)", withParameters: [folderMock, folderMock.label, folderMock.favorite, folderMock.parent as Any]))
    }
    
    func testCallAsFunction_applyToFolderWithoutError_callsDidEdit() {
        let closure = ClosureMock()
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock, didEdit: closure.log)
        
        editFolderViewModel(.applyToFolder)
        
        expect(closure).to(beCalled(.once, withParameters: [folderMock]))
    }
    
    func testCallAsFunction_applyToFolderWithError_doesntCallDidEdit() {
        let closure = ClosureMock()
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock, didEdit: closure.log)
        
        foldersServiceMock._applyTo = .failure(.validationFailed)
        editFolderViewModel(.applyToFolder)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_applyToFolderWithoutError_shouldDismissEmits() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        expect(editFolderViewModel[\.shouldDismiss]).to(emit(when: { editFolderViewModel(.applyToFolder) }))
    }
    
    func testCallAsFunction_applyToFolderWithError_shouldDismissDoesntEmit() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        foldersServiceMock._applyTo = .failure(.validationFailed)
        
        expect(editFolderViewModel[\.shouldDismiss]).to(notEmit(when: { editFolderViewModel(.applyToFolder) }))
    }
    
    func testCallAsFunction_cancelWithHasChangesTrue_setsShowCancelAlertToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.toggleFavorite)
        editFolderViewModel(.cancel)
        
        expect(editFolderViewModel[\.showCancelAlert]).to(beTrue())
    }
    
    func testCallAsFunction_cancelWithHasChangesFalse_shouldDismissEmits() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        expect(editFolderViewModel[\.shouldDismiss]).to(emit(when: { editFolderViewModel(.cancel) }))
    }
    
    func testCallAsFunction_discardChanges_shouldDismissEmits() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        expect(editFolderViewModel[\.shouldDismiss]).to(emit(when: { editFolderViewModel(.discardChanges) }))
    }
    
    func testCallAsFunction_dismissKeyboard_setsFocusedFieldToNil() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel[\.focusedField] = .folderLabel
        editFolderViewModel(.dismissKeyboard)
        
        expect(editFolderViewModel[\.focusedField]).to(beNil())
    }
    
}
