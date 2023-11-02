import XCTest
import Nimble
import Factory
@testable import Passwords


final class SelectTagsViewModelTests: XCTestCase {
    
    private let temporaryEntryMock: SelectTagsViewModel.TemporaryEntry = .password(label: .random(), username: .random(), url: .random(), tags: [.random()])
    @Injected(\.tags) private var tagMocks
    
    @MockInjected(\.tagsService) private var tagsServiceMock: TagsServiceMock
    @MockInjected(\.tagValidationService) private var tagValidationServiceMock: TagValidationServiceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_thenSetsInitialState() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        
        expect(selectTagsViewModel[\.temporaryEntry]).to(equal(temporaryEntryMock))
        expect(selectTagsViewModel[\.tagLabel]).to(beEmpty())
        expect(selectTagsViewModel[\.tagLabelIsValid]).to(beFalse())
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(beEmpty())
        expect(selectTagsViewModel[\.hasChanges]).to(beFalse())
        expect(selectTagsViewModel[\.focusedField]).to(beNil())
    }
    
    func testInit_whenChangingTagLabel_thenCallsTagValidationService() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        let newTagLabel = String.random()
        
        selectTagsViewModel[\.tagLabel] = newTagLabel
        
        expect(self.tagValidationServiceMock).to(beCalled(.twice, on: "validate(label:)", withParameters: newTagLabel, atCallIndex: 1))
    }
    
    func testInit_whenChangingTagLabel_thenUpdatesTagLabelIsValid() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        let validateTagMock = Bool.random()
        let newTagLabel = String.random()
        tagValidationServiceMock._validate = validateTagMock
        
        selectTagsViewModel[\.tagLabel] = newTagLabel
        
        expect(selectTagsViewModel[\.tagLabelIsValid]).to(equal(validateTagMock))
    }
    
    func testInit_thenCallsTagsService() {
        _ = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        
        expect(self.tagsServiceMock).to(beCalled(.once, on: "tags(for:)", withParameter: temporaryEntryMock.tags))
        expect(self.tagsServiceMock).to(beAccessed(.once, on: "tags"))
    }
    
    func testInit_whenTagsServiceEmittingTags_thenSetsSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([false, true]))
    }
    
    func testInit_whenTagsServiceEmittingChangedTags_thenUpdatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        
        tagsServiceMock._tags.send([tagMocks[0]])
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[0]], invalid: []))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([true]))
    }
    
    func testInit_givenToggledTag_whenTagsServiceEmittingChangedTags_thenUpdatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        tagsServiceMock._tags.send([tagMocks[0]])
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[0]], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([false, false]))
    }
    
    func testCallAsFunction_givenFocusedFieldIsNotNil_whenCallingAddTag_thenDoesntChangeFocusedField() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        selectTagsViewModel[\.focusedField] = .addTagLabel
        
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.focusedField]).to(equal(.addTagLabel))
    }
    
    func testCallAsFunction_givenFocusedFieldIsNotNil_whenCallingAddTagAndSettingFocusedFieldToNil_thenSetsFocusedFieldToAddTagLabel() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        selectTagsViewModel[\.focusedField] = .addTagLabel
        
        selectTagsViewModel(.addTag)
        selectTagsViewModel[\.focusedField] = nil
        expect(selectTagsViewModel[\.focusedField]).to(beNil())
        
        expect(selectTagsViewModel[\.focusedField]).toEventually(equal(.addTagLabel))
    }
    
    func testCallAsFunction_givenFocusedFieldIsNotNil_whenCallingAddTagAndSettingFocusedFieldToNilTwice_thenKeepsFocusedFieldNil() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        selectTagsViewModel[\.focusedField] = .addTagLabel
        
        selectTagsViewModel(.addTag)
        selectTagsViewModel[\.focusedField] = nil
        expect(selectTagsViewModel[\.focusedField]).toEventuallyNot(beNil())
        selectTagsViewModel[\.focusedField] = nil
        
        expect(selectTagsViewModel[\.focusedField]).toAlways(beNil())
    }
    
    func testCallAsFunction_whenCallingAddTag_thenCallsTagsService() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        
        selectTagsViewModel(.addTag)
        
        expect(self.tagsServiceMock).to(beCalled(.once, on: "addTag(label:)", withParameter: newTagLabel))
    }
    
    func testCallAsFunction_givenValidTagLabel_whenCallingAddTag_thenClearsTagLabel() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        selectTagsViewModel[\.tagLabel] = .random()
        tagsServiceMock._addTag = .success(.init())
        
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.tagLabel]).to(beEmpty())
    }
    
    func testCallAsFunction_givenInvalidTagLabel_whenCallingAddTag_thenDoesntClearTagLabel() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        selectTagsViewModel[\.tagLabel] = .random()
        tagsServiceMock._addTag = .failure(.validationFailed)
        
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.tagLabel]).toNot(beEmpty())
    }
    
    func testCallAsFunction_givenValidTagLabelAndNewTagAlreadyEmitted_whenCallingAddTag_thenUpdatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel[\.tagLabel] = .random()
        tagsServiceMock._addTag = .success(tagMocks[0])
        
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([true, false]))
    }
    
    func testCallAsFunction_givenValidTagLabel_whenCallingAddTag_thenDoesntUpdateSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        selectTagsViewModel[\.tagLabel] = String.random()
        tagsServiceMock._addTag = .failure(.validationFailed)
        
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.selectableTags]).to(beEmpty())
    }
    
    func testCallAsFunction_givenValidTag_whenCallingToggleTag_thenSetsHasChangesToTrue() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        let validTag = tagMocks[0]
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        
        selectTagsViewModel(.toggleTag(validTag))
        
        expect(selectTagsViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testCallAsFunction_givenValidTag_whenCallingToggleTagTwice_thenSetsHasChangesToFalse() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        let validTag = tagMocks[0]
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        
        selectTagsViewModel(.toggleTag(validTag))
        selectTagsViewModel(.toggleTag(validTag))
        
        expect(selectTagsViewModel[\.hasChanges]).to(beFalse())
    }
    
    func testCallAsFunction_givenValidTag_whenCallingToggleTag_thenUpdatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        let validTag = tagMocks[0]
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        
        selectTagsViewModel(.toggleTag(validTag))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([true, false]))
    }
    
    func testCallAsFunction_givenInvalidTag_whenCallingToggleTag_thenDoesntUpdateSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        let invalidTag = Tag()
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        
        selectTagsViewModel(.toggleTag(invalidTag))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([false, false]))
    }
    
    func testCallAsFunction_whenCallingSelectTags_thenCallsTagsService() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        selectTagsViewModel(.selectTags)
        
        expect(self.tagsServiceMock).to(beCalled(.once, on: "allIdsLocallyAvailable(of:)", withParameter: [tagMocks[0], tagMocks[1]]))
    }
    
    func testCallAsFunction_givenHasChangesIsTrue_whenCallingSelectTags_thenCallsSelectTagsClosure() {
        let closure = ClosureMock()
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock, selectTags: closure.log)
        let invalidTag = String.random()
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: [invalidTag]))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        selectTagsViewModel(.selectTags)
        
        expect(closure).to(beCalled(.once, withParameters: tagMocks, [invalidTag]))
    }
    
    func testCallAsFunction_givenHasChangesIsFalse_whenCallingSelectTags_thenDoesntCallSelectTagsClosure() {
        let closure = ClosureMock()
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock, selectTags: closure.log)
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: [.random()]))
        
        selectTagsViewModel(.selectTags)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenLocallyMissingId_whenCallingSelectTags_thenDoesntCallSelectTagsClosure() {
        let closure = ClosureMock()
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock, selectTags: closure.log)
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: [.random()]))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        tagsServiceMock._allIdsLocallyAvailable = false
        
        selectTagsViewModel(.selectTags)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenHasChangesIsTrue_whenCallingSelectTags_thenShouldDismissEmits() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        expect(selectTagsViewModel[\.shouldDismiss]).to(emit(when: { selectTagsViewModel(.selectTags) }))
    }
    
    func testCallAsFunction_givenHasChangesIsFalse_whenCallingSelectTags_thenShouldDismissDoesntEmit() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        
        expect(selectTagsViewModel[\.shouldDismiss]).toNot(emit(when: { selectTagsViewModel(.selectTags) }))
    }
    
    func testCallAsFunction_givenLocallyMissingId_whenCallingSelectTags_thenShouldDismissDoesntEmit() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        tagsServiceMock._allIdsLocallyAvailable = false
        
        expect(selectTagsViewModel[\.shouldDismiss]).toNot(emit(when: { selectTagsViewModel(.selectTags) }))
    }
    
    func testCallAsFunction_whenCallingCancel_thenShouldDismissEmits() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        
        expect(selectTagsViewModel[\.shouldDismiss]).to(emit(when: { selectTagsViewModel(.cancel) }))
    }
    
    func testCallAsFunction_whenCallingDismissKeyboard_thenSetsFocusedFieldToNil() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntryMock) { _, _ in }
        selectTagsViewModel[\.focusedField] = .addTagLabel
        
        selectTagsViewModel(.dismissKeyboard)
        
        expect(selectTagsViewModel[\.focusedField]).to(beNil())
    }
    
}
