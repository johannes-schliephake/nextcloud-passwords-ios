import XCTest
import Factory
import Combine
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
        
        XCTAssertEqual(editFolderViewModel[\.folder], folderMock)
        XCTAssertEqual(editFolderViewModel[\.isCreating], false)
        XCTAssertEqual(editFolderViewModel[\.folderLabel], folderMock.label)
        XCTAssertEqual(editFolderViewModel[\.folderFavorite], folderMock.favorite)
        XCTAssertEqual(editFolderViewModel[\.folderParent], folderMock.parent)
        XCTAssertEqual(editFolderViewModel[\.parentLabel], "")
        XCTAssertEqual(editFolderViewModel[\.showSelectFolderView], false)
        XCTAssertEqual(editFolderViewModel[\.showDeleteAlert], false)
        XCTAssertEqual(editFolderViewModel[\.showCancelAlert], false)
        XCTAssertEqual(editFolderViewModel[\.hasChanges], false)
        XCTAssertEqual(editFolderViewModel[\.editIsValid], true)
        XCTAssertEqual(editFolderViewModel[\.focusedField], nil)
    }
    
    func testInit_folderIsCreated_setsInitialState() {
        foldersServiceMock._validateFolderLabel = true
        let newFolder = Folder(label: .random(), parent: .random(), favorite: .random())
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: newFolder) { _ in }
        
        XCTAssertEqual(editFolderViewModel[\.folder], newFolder)
        XCTAssertEqual(editFolderViewModel[\.isCreating], true)
        XCTAssertEqual(editFolderViewModel[\.folderLabel], newFolder.label)
        XCTAssertEqual(editFolderViewModel[\.folderFavorite], newFolder.favorite)
        XCTAssertEqual(editFolderViewModel[\.folderParent], newFolder.parent)
        XCTAssertEqual(editFolderViewModel[\.parentLabel], "")
        XCTAssertEqual(editFolderViewModel[\.showSelectFolderView], false)
        XCTAssertEqual(editFolderViewModel[\.showDeleteAlert], false)
        XCTAssertEqual(editFolderViewModel[\.showCancelAlert], false)
        XCTAssertEqual(editFolderViewModel[\.hasChanges], false)
        XCTAssertEqual(editFolderViewModel[\.editIsValid], true)
        XCTAssertEqual(editFolderViewModel[\.focusedField], .folderLabel)
    }
    
    func testInit_setFolderParent_callsFoldersService() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let parentId = String.random()
        let newParentFolder = Folder(id: parentId, parent: nil)
        editFolderViewModel(.selectParent(newParentFolder))
        
        let calls1 = foldersServiceMock.functionCallLog(of: "folderLabel(forId:)")
        XCTAssertEqual(calls1.count, 2)
        XCTAssertEqual(calls1[1].parameters[0] as? String?, parentId)
        let calls2 = foldersServiceMock.functionCallLog(of: "validate(folderLabel:folderParent:)")
        XCTAssertEqual(calls2.count, 2)
        XCTAssertEqual(calls2[1].parameters[0] as? String, folderMock.label)
        XCTAssertEqual(calls2[1].parameters[1] as? String?, parentId)
    }
    
    func testInit_foldersServiceEmitsFolderLabel_setsParentLabel() {
        let newFolder = Folder(parent: .random())
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: newFolder) { _ in }
        
        let parentLabelMock = String.random()
        foldersServiceMock._folderLabelForIdFolderId.send(parentLabelMock)
        
        XCTAssertEqual(editFolderViewModel[\.parentLabel], parentLabelMock)
    }
    
    func testInit_changeFolderLabel_setsHasChangesToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel[\.folderLabel] = .random()
        
        XCTAssertTrue(editFolderViewModel[\.hasChanges])
    }
    
    func testInit_changeFolderFavorite_setsHasChangesToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.toggleFavorite)
        
        XCTAssertTrue(editFolderViewModel[\.hasChanges])
    }
    
    func testInit_changeFolderParent_setsHasChangesToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let newParentFolder = Folder(id: .random(), parent: nil)
        editFolderViewModel(.selectParent(newParentFolder))
        
        XCTAssertTrue(editFolderViewModel[\.hasChanges])
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
        
        XCTAssertFalse(editFolderViewModel[\.hasChanges])
    }
    
    func testInit_setFolderLabel_callsFoldersService() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let newFolderLabel = String.random()
        editFolderViewModel[\.folderLabel] = newFolderLabel
        
        let calls = foldersServiceMock.functionCallLog(of: "validate(folderLabel:folderParent:)")
        XCTAssertEqual(calls.count, 2)
        XCTAssertEqual(calls[1].parameters[0] as? String, newFolderLabel)
        XCTAssertEqual(calls[1].parameters[1] as? String?, folderMock.parent)
    }
    
    func testInit_setFolderLabel_updatesEditIsValid() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let validateFolderLabelMock = Bool.random()
        let newFolderLabel = String.random()
        foldersServiceMock._validateFolderLabel = validateFolderLabelMock
        editFolderViewModel[\.folderLabel] = newFolderLabel
        
        XCTAssertEqual(editFolderViewModel[\.editIsValid], validateFolderLabelMock)
    }
    
    func testInit_setFolderParent_updatesEditIsValid() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let validateFolderLabelMock = Bool.random()
        let parentId = String.random()
        let newParentFolder = Folder(id: parentId, parent: nil)
        foldersServiceMock._validateFolderLabel = validateFolderLabelMock
        editFolderViewModel(.selectParent(newParentFolder))
        
        XCTAssertEqual(editFolderViewModel[\.editIsValid], validateFolderLabelMock)
    }
    
    func testCallAsFunction_toggleFavorite_togglesFolderFavorite() {
        let newFavorite = Bool.random()
        folderMock.favorite = newFavorite
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.toggleFavorite)
        
        XCTAssertNotEqual(editFolderViewModel[\.folderFavorite], newFavorite)
    }
    
    func testCallAsFunction_showParentSelection_setsShowSelectFolderViewToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.showParentSelection)
        
        XCTAssertTrue(editFolderViewModel[\.showSelectFolderView])
    }
    
    func testCallAsFunction_selectParent_updatesFolderParent() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let parentId = String.random()
        let newParentFolder = Folder(id: parentId, parent: nil)
        editFolderViewModel(.selectParent(newParentFolder))
        
        XCTAssertEqual(editFolderViewModel[\.folderParent], parentId)
    }
    
    func testCallAsFunction_deleteFolder_setsShowDeleteAlertToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.deleteFolder)
        
        XCTAssertTrue(editFolderViewModel[\.showDeleteAlert])
    }
    
    func testCallAsFunction_confirmDelete_callsFoldersService() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.confirmDelete)
        
        let calls = foldersServiceMock.functionCallLog(of: "delete(folder:)")
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].parameters[0] as? Folder, folderMock)
    }
    
    func testCallAsFunction_confirmDelete_shouldDismissEmits() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let expectation = expectation(description: "shouldDismiss emitted")
        var cancellables = Set<AnyCancellable>()
        editFolderViewModel[\.shouldDismiss]
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        editFolderViewModel(.confirmDelete)

        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_applyToFolder_callsFoldersService() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.applyToFolder)
        
        let calls = foldersServiceMock.functionCallLog(of: "apply(to:folderLabel:folderFavorite:folderParent:)")
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].parameters[0] as? Folder, folderMock)
        XCTAssertEqual(calls[0].parameters[1] as? String, folderMock.label)
        XCTAssertEqual(calls[0].parameters[2] as? Bool, folderMock.favorite)
        XCTAssertEqual(calls[0].parameters[3] as? String?, folderMock.parent)
    }
    
    func testCallAsFunction_applyToFolderWithoutError_callsDidEdit() {
        let expectation = expectation(description: "didEdit closure called")
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { folder in
            expectation.fulfill()
            XCTAssertEqual(folder, self.folderMock)
        }
        
        editFolderViewModel(.applyToFolder)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_applyToFolderWithError_doesntCallDidEdit() {
        let expectation = expectation(description: "didEdit closure called")
        expectation.isInverted = true
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in expectation.fulfill() }
        
        foldersServiceMock._applyTo = .failure(.validationFailed)
        editFolderViewModel(.applyToFolder)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_applyToFolderWithoutError_shouldDismissEmits() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let expectation = expectation(description: "shouldDismiss emitted")
        var cancellables = Set<AnyCancellable>()
        editFolderViewModel[\.shouldDismiss]
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        editFolderViewModel(.applyToFolder)

        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_applyToFolderWithError_shouldDismissDoesntEmit() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        foldersServiceMock._applyTo = .failure(.validationFailed)
        let expectation = expectation(description: "shouldDismiss emitted")
        expectation.isInverted = true
        var cancellables = Set<AnyCancellable>()
        editFolderViewModel[\.shouldDismiss]
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        editFolderViewModel(.applyToFolder)

        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_cancelWithHasChangesTrue_setsShowCancelAlertToTrue() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel(.toggleFavorite)
        editFolderViewModel(.cancel)
        
        XCTAssertTrue(editFolderViewModel[\.showCancelAlert])
    }
    
    func testCallAsFunction_cancelWithHasChangesFalse_shouldDismissEmits() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let expectation = expectation(description: "shouldDismiss emitted")
        var cancellables = Set<AnyCancellable>()
        editFolderViewModel[\.shouldDismiss]
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        editFolderViewModel(.cancel)

        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_discardChanges_shouldDismissEmits() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        let expectation = expectation(description: "shouldDismiss emitted")
        var cancellables = Set<AnyCancellable>()
        editFolderViewModel[\.shouldDismiss]
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        editFolderViewModel(.discardChanges)

        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_dismissKeyboard_setsFocusedFieldToNil() {
        let editFolderViewModel: any EditFolderViewModelProtocol = EditFolderViewModel(folder: folderMock) { _ in }
        
        editFolderViewModel[\.focusedField] = .folderLabel
        editFolderViewModel(.dismissKeyboard)
        
        XCTAssertNil(editFolderViewModel[\.focusedField])
    }
    
}
