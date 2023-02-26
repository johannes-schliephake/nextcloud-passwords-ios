import XCTest
import Nimble
import Factory
@testable import Passwords


final class SelectTagsViewModelTests: XCTestCase {
    
    private let temporaryEntry: SelectTagsViewModel.TemporaryEntry = .password(label: .random(), username: .random(), url: .random(), tags: [.random()])
    private let tagMocks = Container.tags()
    
    private let tagLabelValidatorMock = TagLabelValidatorMock()
    private let tagsServiceMock = TagsServiceMock()
    
    override func setUp() {
        super.setUp()
        
        Container.registerMocks()
        Container.tagLabelValidator.register { self.tagLabelValidatorMock }
        Container.tagsService.register { self.tagsServiceMock }
    }
    
    override func tearDown() {
        super.tearDown()
        
        Container.Registrations.reset()
    }
    
    func testInit_noFurtherAction_setsInitialState() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        expect(selectTagsViewModel[\.temporaryEntry]).to(equal(temporaryEntry))
        expect(selectTagsViewModel[\.tagLabel]).to(beEmpty())
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(beEmpty())
        expect(selectTagsViewModel[\.hasChanges]).to(beFalse())
        expect(selectTagsViewModel[\.focusedField]).to(beNil())
    }
    
    func testInit_tagsServiceEmitsTags_setsSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([false, true]))
    }
    
    func testInit_tagsServiceEmitsChangedTags_updatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        tagsServiceMock._tags.send([tagMocks[0]])
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[0]], invalid: []))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([true]))
    }
    
    func testInit_tagsServiceEmitsChangedTagsAfterToggleTag_updatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send([tagMocks[0]])
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[0]], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([false, false]))
    }
    
    func testCallAsFunction_addTag_doesntChangeFocusedField() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        selectTagsViewModel[\.focusedField] = .addTagLabel
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.focusedField]).to(equal(.addTagLabel))
    }
    
    func testCallAsFunction_addTag_callsTagLabelValidator() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        selectTagsViewModel(.addTag)
        
        expect(self.tagLabelValidatorMock).to(beCalled(.once, on: "validate(_:)", withParameters: [newTagLabel]))
    }
    
    func testCallAsFunction_addTagWithValidTagLabel_clearsTagLabel() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        selectTagsViewModel[\.tagLabel] = .random()
        tagLabelValidatorMock._validateEntity = true
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.tagLabel]).to(beEmpty())
    }
    
    func testCallAsFunction_addTagWithInvalidTagLabel_doesntClearTagLabel() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        selectTagsViewModel[\.tagLabel] = .random()
        tagLabelValidatorMock._validateEntity = false
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.tagLabel]).toNot(beEmpty())
    }
    
    func testCallAsFunction_addTagWithValidTagLabel_callsTagService() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        tagLabelValidatorMock._validateEntity = true
        selectTagsViewModel(.addTag)
        
        expect(self.tagsServiceMock).to(beCalled(.once, on: "add(tag:)", withParameters: [newTagLabel])) // TODO: check tag label against newTagLabel
    }
    
    func testCallAsFunction_addTagWithInvalidTagLabel_doesntCallTagService() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        let initialFunctionCallCount = tagsServiceMock.functionCallLog.count
        
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        tagLabelValidatorMock._validateEntity = false
        selectTagsViewModel(.addTag)
        
        expect(self.tagsServiceMock).to(beCalled(.aSpecifiedAmount(initialFunctionCallCount)))
    }
    
    func testCallAsFunction_addTagWithValidTagLabel_updatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        tagLabelValidatorMock._validateEntity = true
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag.label)).to(equal([newTagLabel]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([true]))
    }
    
    func testCallAsFunction_addTagWithValidTagLabel_doesntUpdateSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        tagLabelValidatorMock._validateEntity = false
        selectTagsViewModel(.addTag)
        
        expect(selectTagsViewModel[\.selectableTags]).to(beEmpty())
    }
    
    func testCallAsFunction_toggleTagWithValidTag_setsHasChangesToTrue() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        expect(selectTagsViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testCallAsFunction_toggleTagTwiceWithValidTag_setsHasChangesToFalse() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        expect(selectTagsViewModel[\.hasChanges]).to(beFalse())
    }
    
    func testCallAsFunction_toggleTagWithValidTag_updatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([true, false]))
    }
    
    func testCallAsFunction_toggleTagWithInvalidTag_doesntUpdateSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(.init()))
        
        expect(selectTagsViewModel[\.selectableTags].map(\.tag)).to(equal([tagMocks[0], tagMocks[1]]))
        expect(selectTagsViewModel[\.selectableTags].map(\.isSelected)).to(equal([false, false]))
    }
    
    func testCallAsFunction_selectTagsWithHasChangesTrue_callsSelectTagsClosure() {
        let invalidTag = String.random()
        let closure = ClosureMock()
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry, selectTags: closure.log)
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: [invalidTag]))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        selectTagsViewModel(.selectTags)
        
        expect(closure).to(beCalled(.once, withParameters: [tagMocks, [invalidTag]]))
    }
    
    func testCallAsFunction_selectTagsWithHasChangesFalse_doesntCallSelectTagsClosure() {
        let closure = ClosureMock()
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry, selectTags: closure.log)
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: [.random()]))
        selectTagsViewModel(.selectTags)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_selectTagsWithoutLocallyAvailableId_doesntCallSelectTagsClosure() {
        let closure = ClosureMock()
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry, selectTags: closure.log)
        
        tagMocks[0].id = ""
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: [.random()]))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        selectTagsViewModel(.selectTags)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_selectTagsWithHasChangesTrue_shouldDismissEmits() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        expect(selectTagsViewModel[\.shouldDismiss]).to(emit(when: { selectTagsViewModel(.selectTags) }))
    }
    
    func testCallAsFunction_selectTagsWithHasChangesFalse_shouldDismissDoesntEmit() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        
        expect(selectTagsViewModel[\.shouldDismiss]).to(notEmit(when: { selectTagsViewModel(.selectTags) }))
    }
    
    func testCallAsFunction_selectTagsWithoutLocallyAvailableId_shouldDismissDoesntEmit() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagMocks[0].id = ""
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        expect(selectTagsViewModel[\.shouldDismiss]).to(notEmit(when: { selectTagsViewModel(.selectTags) }))
    }
    
    func testCallAsFunction_cancel_shouldDismissEmits() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        expect(selectTagsViewModel[\.shouldDismiss]).to(emit(when: { selectTagsViewModel(.cancel) }))
    }
    
    func testCallAsFunction_dismissKeyboard_setsFocusedFieldToNil() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        selectTagsViewModel[\.focusedField] = .addTagLabel
        selectTagsViewModel(.dismissKeyboard)
        
        expect(selectTagsViewModel[\.focusedField]).to(beNil())
    }
    
}
