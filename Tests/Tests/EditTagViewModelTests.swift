import XCTest
import Nimble
import Factory
import SwiftUI
@testable import Passwords


final class EditTagViewModelTests: XCTestCase {
    
    @Injected(\.tag) private var tagMock
    
    @MockInjected(\.tagsService) private var tagsServiceMock: TagsServiceMock
    @MockInjected(\.tagValidationService) private var tagValidationServiceMock: TagValidationServiceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.manager.reset()
    }
    
    func testInit_givenExistingTag_thenSetsInitialState() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        expect(editTagViewModel[\.tag]).to(be(tagMock))
        expect(editTagViewModel[\.isCreating]).to(beFalse())
        expect(editTagViewModel[\.tagLabel]).to(equal(tagMock.label))
        expect(editTagViewModel[\.tagColor]).to(equal(.init(hex: tagMock.color)!))
        expect(editTagViewModel[\.tagFavorite]).to(equal(tagMock.favorite))
        expect(editTagViewModel[\.showDeleteAlert]).to(beFalse())
        expect(editTagViewModel[\.showCancelAlert]).to(beFalse())
        expect(editTagViewModel[\.hasChanges]).to(beFalse())
        expect(editTagViewModel[\.editIsValid]).to(beFalse())
        expect(editTagViewModel[\.focusedField]).to(beNil())
    }
    
    func testInit_givenNewlyCreatedTag_thenSetsInitialState() {
        let newTag = Tag(label: .random(), color: Color.random().hex, favorite: .random())
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: newTag)
        
        expect(editTagViewModel[\.tag]).to(be(newTag))
        expect(editTagViewModel[\.isCreating]).to(beTrue())
        expect(editTagViewModel[\.tagLabel]).to(equal(newTag.label))
        expect(editTagViewModel[\.tagColor]).to(equal(.init(hex: newTag.color)!))
        expect(editTagViewModel[\.tagFavorite]).to(equal(newTag.favorite))
        expect(editTagViewModel[\.showDeleteAlert]).to(beFalse())
        expect(editTagViewModel[\.showCancelAlert]).to(beFalse())
        expect(editTagViewModel[\.hasChanges]).to(beFalse())
        expect(editTagViewModel[\.editIsValid]).to(beFalse())
        expect(editTagViewModel[\.focusedField]).to(equal(.tagLabel))
    }
    
    func testInit_whenChangingTagLabel_thenSetsHasChangesToTrue() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        editTagViewModel[\.tagLabel] = .random()
        
        expect(editTagViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_whenChangingTagColor_thenSetsHasChangesToTrue() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        editTagViewModel[\.tagColor] = .random()
        
        expect(editTagViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_whenChangingTagFavorite_thenSetsHasChangesToTrue() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        editTagViewModel(.toggleFavorite)
        
        expect(editTagViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_whenDoingAndUndoingChanges_thenSetsHasChangesToFalse() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        editTagViewModel[\.tagLabel] = .random()
        editTagViewModel[\.tagColor] = .random()
        editTagViewModel(.toggleFavorite)
        editTagViewModel[\.tagLabel] = tagMock.label
        editTagViewModel[\.tagColor] = .init(hex: tagMock.color)!
        editTagViewModel(.toggleFavorite)
        
        expect(editTagViewModel[\.hasChanges]).to(beFalse())
    }
    
    func testInit_whenChangingTagLabel_thenCallsTagValidationService() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        let newTagLabel = String.random()
        
        editTagViewModel[\.tagLabel] = newTagLabel
        
        expect(self.tagValidationServiceMock).to(beCalled(.twice, on: "validate(label:)", withParameters: newTagLabel, atCallIndex: 1))
    }
    
    func testInit_whenChangingTagLabel_thenUpdatesEditIsValid() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        let validateTagMock = Bool.random()
        let newTagLabel = String.random()
        tagValidationServiceMock._validate = validateTagMock
        
        editTagViewModel[\.tagLabel] = newTagLabel
        
        expect(editTagViewModel[\.editIsValid]).to(equal(validateTagMock))
    }
    
    func testCallAsFunction_whenCallingToggleFavorite_thenTogglesTagFavorite() {
        let newFavorite = Bool.random()
        tagMock.favorite = newFavorite
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        editTagViewModel(.toggleFavorite)
        
        expect(editTagViewModel[\.tagFavorite]).toNot(equal(newFavorite))
    }
    
    func testCallAsFunction_whenCallingDeleteTag_thenSetsShowDeleteAlertToTrue() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        editTagViewModel(.deleteTag)
        
        expect(editTagViewModel[\.showDeleteAlert]).to(beTrue())
    }
    
    func testCallAsFunction_whenCallingConfirmDelete_thenCallsTagsService() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        editTagViewModel(.confirmDelete)
        
        expect(self.tagsServiceMock).to(beCalled(.once, on: "delete(tag:)", withParameter: tagMock))
    }
    
    func testCallAsFunction_whenCallingConfirmDelete_thenShouldDismissEmits() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        expect(editTagViewModel[\.shouldDismiss]).to(emit(when: { editTagViewModel(.confirmDelete) }))
    }
    
    func testCallAsFunction_whenCallingApplyToTag_thenCallsTagsService() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        editTagViewModel(.applyToTag)
        
        expect(self.tagsServiceMock).to(beCalled(.once, on: "apply(to:tagLabel:tagColor:tagFavorite:)", withParameters: tagMock, tagMock.label, Color(hex: tagMock.color), tagMock.favorite))
    }
    
    func testCallAsFunction_givenNoError_whenCallingApplyToTag_thenShouldDismissEmits() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        expect(editTagViewModel[\.shouldDismiss]).to(emit(when: { editTagViewModel(.applyToTag) }))
    }
    
    func testCallAsFunction_givenError_whenCallingApplyToTag_thenShouldDismissDoesntEmit() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        tagsServiceMock._apply = .failure(.validationFailed)
        
        expect(editTagViewModel[\.shouldDismiss]).toNot(emit(when: { editTagViewModel(.applyToTag) }))
    }
    
    func testCallAsFunction_givenHasChangesIsTrue_whenCallingCancel_thenSetsShowCancelAlertToTrue() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        editTagViewModel(.toggleFavorite)
        
        editTagViewModel(.cancel)
        
        expect(editTagViewModel[\.showCancelAlert]).to(beTrue())
    }
    
    func testCallAsFunction_givenHasChangesIsFalse_whenCallingCancel_thenShouldDismissEmits() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        expect(editTagViewModel[\.shouldDismiss]).to(emit(when: { editTagViewModel(.cancel) }))
    }
    
    func testCallAsFunction_givenHasChangesIsTrue_whenCallingDiscardChanges_thenShouldDismissEmits() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        editTagViewModel(.toggleFavorite)
        
        expect(editTagViewModel[\.shouldDismiss]).to(emit(when: { editTagViewModel(.discardChanges) }))
    }
    
    func testCallAsFunction_givenHasChangesIsFalse_whenCallingDiscardChanges_thenShouldDismissEmits() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        
        expect(editTagViewModel[\.shouldDismiss]).to(emit(when: { editTagViewModel(.discardChanges) }))
    }
    
    func testCallAsFunction_whenCallingDismissKeyboard_thenSetsFocusedFieldToNil() {
        let editTagViewModel: any EditTagViewModelProtocol = EditTagViewModel(tag: tagMock)
        editTagViewModel[\.focusedField] = .tagLabel
        
        editTagViewModel(.dismissKeyboard)
        
        expect(editTagViewModel[\.focusedField]).to(beNil())
    }
    
}
