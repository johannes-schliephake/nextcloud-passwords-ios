import XCTest
@testable import Passwords
import Factory
import Combine


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
        
        XCTAssertEqual(selectTagsViewModel[\.temporaryEntry], temporaryEntry)
        XCTAssertEqual(selectTagsViewModel[\.tagLabel], "")
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.tag), [])
        XCTAssertEqual(selectTagsViewModel[\.hasChanges], false)
        XCTAssertEqual(selectTagsViewModel[\.focusedField], nil)
    }
    
    func testInit_tagsServiceEmitsTags_setsSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.tag), [tagMocks[0], tagMocks[1]])
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.isSelected), [false, true])
    }
    
    func testInit_tagsServiceEmitsChangedTags_updatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        tagsServiceMock._tags.send([tagMocks[0]])
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[0]], invalid: []))
        
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.tag), [tagMocks[0]])
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.isSelected), [true])
    }
    
    func testInit_tagsServiceEmitsChangedTagsAfterToggleTag_updatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send([tagMocks[0]])
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[0]], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: []))
        
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.tag), [tagMocks[0], tagMocks[1]])
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.isSelected), [false, false])
    }
    
    func testCallAsFunction_addTag_doesntChangeFocusedField() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        selectTagsViewModel[\.focusedField] = .addTagLabel
        selectTagsViewModel(.addTag)
        
        XCTAssertEqual(selectTagsViewModel[\.focusedField], .addTagLabel)
    }
    
    func testCallAsFunction_addTag_callsTagLabelValidator() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        selectTagsViewModel(.addTag)
        
        let calls = tagLabelValidatorMock.functionCallLog(of: "validate(_:)")
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].parameters[0] as? String, newTagLabel)
    }
    
    func testCallAsFunction_addTagWithValidTagLabel_clearsTagLabel() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        selectTagsViewModel[\.tagLabel] = .random()
        tagLabelValidatorMock._validateEntity = true
        selectTagsViewModel(.addTag)
        
        XCTAssertTrue(selectTagsViewModel[\.tagLabel].isEmpty)
    }
    
    func testCallAsFunction_addTagWithInvalidTagLabel_doesntClearTagLabel() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        selectTagsViewModel[\.tagLabel] = .random()
        tagLabelValidatorMock._validateEntity = false
        selectTagsViewModel(.addTag)
        
        XCTAssertFalse(selectTagsViewModel[\.tagLabel].isEmpty)
    }
    
    func testCallAsFunction_addTagWithValidTagLabel_callsTagService() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        tagLabelValidatorMock._validateEntity = true
        selectTagsViewModel(.addTag)
        
        let calls = tagsServiceMock.functionCallLog(of: "add(tag:)")
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual((calls[0].parameters[0] as? Tag)?.label, newTagLabel)
    }
    
    func testCallAsFunction_addTagWithInvalidTagLabel_doesntCallTagService() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        let initialFunctionCallCount = tagsServiceMock.functionCallLog.count
        
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        tagLabelValidatorMock._validateEntity = false
        selectTagsViewModel(.addTag)
        
        XCTAssertEqual(tagsServiceMock.functionCallLog.count, initialFunctionCallCount)
    }
    
    func testCallAsFunction_addTagWithValidTagLabel_updatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        tagLabelValidatorMock._validateEntity = true
        selectTagsViewModel(.addTag)
        
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.tag.label), [newTagLabel])
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.isSelected), [true])
    }
    
    func testCallAsFunction_addTagWithValidTagLabel_doesntUpdateSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        let newTagLabel = String.random()
        selectTagsViewModel[\.tagLabel] = newTagLabel
        tagLabelValidatorMock._validateEntity = false
        selectTagsViewModel(.addTag)
        
        XCTAssertTrue(selectTagsViewModel[\.selectableTags].isEmpty)
    }
    
    func testCallAsFunction_toggleTagWithValidTag_setsHasChangesToTrue() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        XCTAssertTrue(selectTagsViewModel[\.hasChanges])
    }
    
    func testCallAsFunction_toggleTagTwiceWithValidTag_setsHasChangesToFalse() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        XCTAssertFalse(selectTagsViewModel[\.hasChanges])
    }
    
    func testCallAsFunction_toggleTagWithValidTag_updatesSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.tag), [tagMocks[0], tagMocks[1]])
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.isSelected), [true, false])
    }
    
    func testCallAsFunction_toggleTagWithInvalidTag_doesntUpdateSelectableTags() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(.init()))
        
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.tag), [tagMocks[0], tagMocks[1]])
        XCTAssertEqual(selectTagsViewModel[\.selectableTags].map(\.isSelected), [false, false])
    }
    
    func testCallAsFunction_selectTagsWithHasChangesTrue_callsSelectTagsClosure() {
        let invalidTag = String.random()
        let expectation = expectation(description: "selectTags closure called")
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { selectedTags, invalidTags in
            expectation.fulfill()
            XCTAssertEqual(selectedTags, self.tagMocks)
            XCTAssertEqual(invalidTags, [invalidTag])
        }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: [invalidTag]))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        selectTagsViewModel(.selectTags)

        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_selectTagsWithHasChangesFalse_doesntCallSelectTagsClosure() {
        let expectation = expectation(description: "selectTags closure called")
        expectation.isInverted = true
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in expectation.fulfill() }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: [.random()]))
        selectTagsViewModel(.selectTags)

        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_selectTagsWithoutLocallyAvailableId_doesntCallSelectTagsClosure() {
        let expectation = expectation(description: "selectTags closure called")
        expectation.isInverted = true
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in expectation.fulfill() }
        
        tagMocks[0].id = ""
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [tagMocks[1]], invalid: [.random()]))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        selectTagsViewModel(.selectTags)

        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_selectTagsWithHasChangesTrue_shouldDismissEmits() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        let expectation = expectation(description: "shouldDismiss emitted")
        var cancellables = Set<AnyCancellable>()
        selectTagsViewModel[\.shouldDismiss]
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        selectTagsViewModel(.selectTags)

        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_selectTagsWithHasChangesFalse_shouldDismissDoesntEmit() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        let expectation = expectation(description: "shouldDismiss emitted")
        expectation.isInverted = true
        var cancellables = Set<AnyCancellable>()
        selectTagsViewModel[\.shouldDismiss]
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        selectTagsViewModel(.selectTags)

        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_selectTagsWithoutLocallyAvailableId_shouldDismissDoesntEmit() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        tagMocks[0].id = ""
        tagsServiceMock._tags.send(tagMocks.shuffled())
        tagsServiceMock._tagsForTagIds.send((valid: [], invalid: []))
        selectTagsViewModel(.toggleTag(tagMocks[0]))
        let expectation = expectation(description: "shouldDismiss emitted")
        expectation.isInverted = true
        var cancellables = Set<AnyCancellable>()
        selectTagsViewModel[\.shouldDismiss]
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        selectTagsViewModel(.selectTags)

        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_cancel_shouldDismissEmits() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        let expectation = expectation(description: "shouldDismiss emitted")
        var cancellables = Set<AnyCancellable>()
        selectTagsViewModel[\.shouldDismiss]
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        selectTagsViewModel(.cancel)

        waitForExpectations(timeout: 0.1)
    }
    
    func testCallAsFunction_dismissKeyboard_setsFocusedFieldToNil() {
        let selectTagsViewModel: any SelectTagsViewModelProtocol = SelectTagsViewModel(temporaryEntry: temporaryEntry) { _, _ in }
        
        selectTagsViewModel[\.focusedField] = .addTagLabel
        selectTagsViewModel(.dismissKeyboard)
        
        XCTAssertNil(selectTagsViewModel[\.focusedField])
    }

}
