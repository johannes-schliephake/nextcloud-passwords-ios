import XCTest
import Nimble
import Factory
@testable import Passwords


final class EditFolderViewModelTests: XCTestCase {
    
    @Injected(\.folder) private var folderMock
    
    @MockInjected(\.foldersService) private var foldersServiceMock: FoldersServiceMock
    @MockInjected(\.folderValidationService) private var folderValidationServiceMock: FolderValidationServiceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.manager.reset()
    }
    
    func testInit_givenExistingFolder_thenSetsInitialState() {
        folderValidationServiceMock._validate = true
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
    
    func testInit_givenNewlyCreatedFolder_thenSetsInitialState() {
        folderValidationServiceMock._validate = true
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
    
    func testInit_whenChangingFolderParent_thenCallsFoldersService() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        let parentId = String.random()
        let newParentFolder = Folder(id: parentId, parent: nil)
        
        editFolderViewModel(.selectParent(newParentFolder))
        
        expect(self.foldersServiceMock).to(beCalled(.twice, on: "folderLabel(forId:)", withParameters: [parentId], atCallIndex: 1))
        expect(self.folderValidationServiceMock).to(beCalled(.twice, on: "validate(label:parent:)", withParameters: [folderMock.label, parentId], atCallIndex: 1))
    }
    
    func testInit_whenFoldersServiceEmittingFolderLabel_thenSetsParentLabel() {
        let newFolder = Folder(parent: .random())
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: newFolder) { _ in }
        let parentLabelMock = String.random()
        
        foldersServiceMock._folderLabel.send(parentLabelMock)
        
        expect(editFolderViewModel[\.parentLabel]).to(equal(parentLabelMock))
    }
    
    func testInit_whenChangingFolderLabel_thenSetsHasChangesToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel[\.folderLabel] = .random()
        
        expect(editFolderViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_whenChangingFolderFavorite_thenSetsHasChangesToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.toggleFavorite)
        
        expect(editFolderViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_whenChangingFolderParent_thenSetsHasChangesToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        let newParentFolder = Folder(id: .random(), parent: nil)
        
        editFolderViewModel(.selectParent(newParentFolder))
        
        expect(editFolderViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_whenDoingAndUndoingChanges_thenSetsHasChangesToFalse() {
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
    
    func testInit_whenChangingFolderLabel_thenCallsFoldersService() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        let newFolderLabel = String.random()
        
        editFolderViewModel[\.folderLabel] = newFolderLabel
        
        expect(self.folderValidationServiceMock).to(beCalled(.twice, on: "validate(label:parent:)", withParameters: [newFolderLabel, folderMock.parent], atCallIndex: 1))
    }
    
    func testInit_whenChangingFolderLabel_thenUpdatesEditIsValid() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        let validateFolderLabelMock = Bool.random()
        let newFolderLabel = String.random()
        folderValidationServiceMock._validate = validateFolderLabelMock
        
        editFolderViewModel[\.folderLabel] = newFolderLabel
        
        expect(editFolderViewModel[\.editIsValid]).to(equal(validateFolderLabelMock))
    }
    
    func testInit_whenChangingFolderParent_thenUpdatesEditIsValid() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        let validateFolderLabelMock = Bool.random()
        let parentId = String.random()
        let newParentFolder = Folder(id: parentId, parent: nil)
        folderValidationServiceMock._validate = validateFolderLabelMock
        
        editFolderViewModel(.selectParent(newParentFolder))
        
        expect(editFolderViewModel[\.editIsValid]).to(equal(validateFolderLabelMock))
    }
    
    func testCallAsFunction_whenCallingToggleFavorite_thenTogglesFolderFavorite() {
        let newFavorite = Bool.random()
        folderMock.favorite = newFavorite
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.toggleFavorite)
        
        expect(editFolderViewModel[\.folderFavorite]).toNot(equal(newFavorite))
    }
    
    func testCallAsFunction_whenCallingShowParentSelection_thenSetsShowSelectFolderViewToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.showParentSelection)
        
        expect(editFolderViewModel[\.showSelectFolderView]).to(beTrue())
    }
    
    func testCallAsFunction_whenCallingSelectParent_thenUpdatesFolderParent() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        let parentId = String.random()
        let newParentFolder = Folder(id: parentId, parent: nil)
        
        editFolderViewModel(.selectParent(newParentFolder))
        
        expect(editFolderViewModel[\.folderParent]).to(equal(parentId))
    }
    
    func testCallAsFunction_whenCallingDeleteFolder_thenSetsShowDeleteAlertToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.deleteFolder)
        
        expect(editFolderViewModel[\.showDeleteAlert]).to(beTrue())
    }
    
    func testCallAsFunction_whenCallingConfirmDelete_thenCallsFoldersService() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.confirmDelete)
        
        expect(self.foldersServiceMock).to(beCalled(.once, on: "delete(folder:)", withParameters: [folderMock]))
    }
    
    func testCallAsFunction_whenCallingConfirmDelete_thenShouldDismissEmits() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        expect(editFolderViewModel[\.shouldDismiss]).to(emit(when: { editFolderViewModel(.confirmDelete) }))
    }
    
    func testCallAsFunction_whenCallingApplyToFolder_thenCallsFoldersService() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.applyToFolder)
        
        expect(self.foldersServiceMock).to(beCalled(.once, on: "apply(to:folderLabel:folderFavorite:folderParent:)", withParameters: [folderMock, folderMock.label, folderMock.favorite, folderMock.parent]))
    }
    
    func testCallAsFunction_givenNoError_whenCallingApplyToFolder_thenCallsDidEdit() {
        let closure = ClosureMock()
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock, didEdit: closure.log)
        
        editFolderViewModel(.applyToFolder)
        
        expect(closure).to(beCalled(.once, withParameters: [folderMock]))
    }
    
    func testCallAsFunction_givenError_whenCallingApplyToFolder_thenDoesntCallDidEdit() {
        let closure = ClosureMock()
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock, didEdit: closure.log)
        foldersServiceMock._apply = .failure(.validationFailed)
        
        editFolderViewModel(.applyToFolder)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenNoError_whenCallingApplyToFolder_thenShouldDismissEmits() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        expect(editFolderViewModel[\.shouldDismiss]).to(emit(when: { editFolderViewModel(.applyToFolder) }))
    }
    
    func testCallAsFunction_givenError_whenCallingApplyToFolder_thenShouldDismissDoesntEmit() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        foldersServiceMock._apply = .failure(.validationFailed)
        
        expect(editFolderViewModel[\.shouldDismiss]).toNot(emit(when: { editFolderViewModel(.applyToFolder) }))
    }
    
    func testCallAsFunction_givenHasChangesIsTrue_whenCallingCancel_thenSetsShowCancelAlertToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        editFolderViewModel(.toggleFavorite)
        
        editFolderViewModel(.cancel)
        
        expect(editFolderViewModel[\.showCancelAlert]).to(beTrue())
    }
    
    func testCallAsFunction_givenHasChangesIsFalse_whenCallingCancel_thenShouldDismissEmits() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        expect(editFolderViewModel[\.shouldDismiss]).to(emit(when: { editFolderViewModel(.cancel) }))
    }
    
    func testCallAsFunction_whenCallingDiscardChanges_thenShouldDismissEmits() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        expect(editFolderViewModel[\.shouldDismiss]).to(emit(when: { editFolderViewModel(.discardChanges) }))
    }
    
    func testCallAsFunction_whenCallingDismissKeyboard_thenSetsFocusedFieldToNil() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        editFolderViewModel[\.focusedField] = .folderLabel
        
        editFolderViewModel(.dismissKeyboard)
        
        expect(editFolderViewModel[\.focusedField]).to(beNil())
    }
    
}
