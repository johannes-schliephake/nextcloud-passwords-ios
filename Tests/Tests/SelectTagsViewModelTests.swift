import XCTest
import Nimble
import Factory
@testable import Passwords


final class SelectTagsViewModelTests: XCTestCase {
    
    private let temporaryEntry: SelectTagsViewModel.TemporaryEntry = .password(label: .random(), username: .random(), url: .random(), tags: [.random()])
    private let tagMocks = Container.shared.tags()
    
    private let tagsServiceMock = TagsServiceMock()
    private let tagValidationServiceMock = TagValidationServiceMock()
    
    override func setUp() {
        super.setUp()
        
        Container.shared.registerMocks()
        Container.shared.tagsService.register { self.tagsServiceMock }
        Container.shared.tagValidationService.register { self.tagValidationServiceMock }
    }
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.manager.reset()
    }
    
    func testInit_thenSetsInitialState() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        expect(selectTagsViewModel[\.temporaryEntry]).to(equal(temporaryEntry))
        expect(selectTagsViewModel[\.tagLabel]).to(beEmpty())
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(beEmpty())
        expect(selectTagsViewModel[\.hasChanges]).to(beFalse())
        expect(selectTagsViewModel[\.focusedField]).to(beNil())
    }
    
    func testInit_whenTagsServiceEmittingTags_thenSetsSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([false, true]))
    }
    
    func testInit_whenTagsServiceEmittingChangedTags_thenUpdatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        
        tagsServiceMock._tags.send([tagMocks[0]])
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[0]], invalid: []))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([true]))
    }
    
    func testInit_givenToggledTag_whenTagsServiceEmittingChangedTags_thenUpdatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        tagsServiceMock._tags.send([tagMocks[0]])
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[0]], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([false, false]))
    }
    
    func testCallAsFunction_givenFocusedFieldIsNotNil_whenCallingAddTag_thenDoesntChangeFocusedField() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        selectTagsViewModel[\.focusedField] = .addTagLabel
        
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.focusedField]).to(equal(.addTagLabel))
    }
    
    func testCallAsFunction_whenCallingAddTag_thenCallsTagValidationService() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        
        selectTagsViewModel(.addTag)
        
        expect(self.tagValidationServiceMock).to(beCalled(.once, on: "validate(label:)", withParameters: [newTagLabel]))
    }
    
    func testCallAsFunction_givenValidTagLabel_whenCallingAddTag_thenClearsTagLabel() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        selectTagsViewModel[\.tagLabel] = .random()
        tagValidationServiceMock._validate = true
        
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.tagLabel]).to(beEmpty())
    }
    
    func testCallAsFunction_givenInvalidTagLabel_whenCallingAddTag_thenDoesntClearTagLabel() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        selectTagsViewModel[\.tagLabel] = .random()
        tagValidationServiceMock._validate = false
        
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.tagLabel]).toNot(beEmpty())
    }
    
    func testCallAsFunction_givenValidTagLabel_whenCallingAddTag_thenCallsTagService() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        tagValidationServiceMock._validate = true
        
        selectTagsViewModel(.addTag)
        
        expect(self.tagsServiceMock).to(beCalled(.once, on: "add(tag:)", withParameters: [newTagLabel])) // TODO: check tag label against newTagLabel
    }
    
    func testCallAsFunction_givenInvalidTagLabel_whenCallingAddTag_thenDoesntCallTagService() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        let initialFunctionCallCount = tagsServiceMock.functionCallLog.count
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        tagValidationServiceMock._validate = false
        
        selectTagsViewModel(.addTag)
        
        expect(self.tagsServiceMock).to(beCalled(.aSpecifiedAmount(initialFunctionCallCount)))
    }
    
    func testCallAsFunction_givenValidTagLabel_whenCallingAddTag_thenUpdatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        tagValidationServiceMock._validate = true
        
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag.label)).to(equal([newTagLabel]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([true]))
    }
    
    func testCallAsFunction_givenValidTagLabel_whenCallingAddTag_thenDoesntUpdateSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        tagValidationServiceMock._validate = false
        
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.selectableTags]).to(beEmpty())
    }
    
    func testCallAsFunction_givenValidTag_whenCallingToggleTag_thenSetsHasChangesToTrue() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        let validTag = tagMocks[0]
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        
        selectTagsViewModel(.toggleTag(validTag))
        
        expect(selectTagsViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testCallAsFunction_givenValidTag_whenCallingToggleTagTwice_thenSetsHasChangesToFalse() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        let validTag = tagMocks[0]
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        
        selectTagsViewModel(.toggleTag(validTag))
        selectTagsViewModel(.toggleTag(validTag))
        
        expect(selectTagsViewModel[\.hasChanges]).to(beFalse())
    }
    
    func testCallAsFunction_givenValidTag_whenCallingToggleTag_thenUpdatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        let validTag = tagMocks[0]
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        
        selectTagsViewModel(.toggleTag(validTag))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([true, false]))
    }
    
    func testCallAsFunction_givenInvalidTag_whenCallingToggleTag_thenDoesntUpdateSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        let invalidTag = Tag()
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        
        selectTagsViewModel(.toggleTag(invalidTag))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([false, false]))
    }
    
    func testCallAsFunction_givenHasChangesIsTrue_whenCallingSelectTags_thenCallsSelectTagsClosure() {
        let closure = ClosureMock()
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry, selectTags: closure.log)
        let invalidTag = String.random()
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: [invalidTag]))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        selectTagsViewModel(.selectTags)
        
        expect(closure).to(beCalled(.once, withParameters: [tagMocks, [invalidTag]]))
    }
    
    func testCallAsFunction_givenHasChangesIsFalse_whenCallingSelectTags_thenDoesntCallSelectTagsClosure() {
        let closure = ClosureMock()
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry, selectTags: closure.log)
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: [.random()]))
        
        selectTagsViewModel(.selectTags)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenLocallyMissingId_whenCallingSelectTags_thenDoesntCallSelectTagsClosure() {
        let closure = ClosureMock()
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry, selectTags: closure.log)
        tagMocks[0].id = ""
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: [.random()]))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        selectTagsViewModel(.selectTags)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenHasChangesIsTrue_whenCallingSelectTags_thenShouldDismissEmits() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        expect(selectTagsViewModel[\.shouldDismiss]).to(emit(when: { selectTagsViewModel(.selectTags) }))
    }
    
    func testCallAsFunction_givenHasChangesIsFalse_whenCallingSelectTags_thenShouldDismissDoesntEmit() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        
        expect(selectTagsViewModel[\.shouldDismiss]).toNot(emit(when: { selectTagsViewModel(.selectTags) }))
    }
    
    func testCallAsFunction_givenLocallyMissingId_whenCallingSelectTags_thenShouldDismissDoesntEmit() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        tagMocks[0].id = ""
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        expect(selectTagsViewModel[\.shouldDismiss]).toNot(emit(when: { selectTagsViewModel(.selectTags) }))
    }
    
    func testCallAsFunction_whenCallingCancel_thenShouldDismissEmits() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        expect(selectTagsViewModel[\.shouldDismiss]).to(emit(when: { selectTagsViewModel(.cancel) }))
    }
    
    func testCallAsFunction_whenCallingDismissKeyboard_thenSetsFocusedFieldToNil() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        selectTagsViewModel[\.focusedField] = .addTagLabel
        
        selectTagsViewModel(.dismissKeyboard)
        
        expect(selectTagsViewModel[\.focusedField]).to(beNil())
    }
    
}
