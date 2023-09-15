import XCTest
import Nimble
import Factory
@testable import Passwords


final class BridgeTests: XCTestCase {
    
    private let errorMock = ErrorMock.standard
    private let sequenceMock = Array(repeating: (), count: 10).map { Int.random(in: -1000...1000) }
    private var asyncSequenceCounter = 0
    private var asyncSequenceShouldFailAfter = Int.max
    private lazy var asyncSequenceMock = AsyncStream {
        let value = self.sequenceMock[safe: self.asyncSequenceCounter]
        self.asyncSequenceCounter += 1
        return value
    }
    private lazy var throwingAsyncSequenceMock = AsyncThrowingStream {
        guard self.asyncSequenceCounter < self.asyncSequenceShouldFailAfter else {
            throw self.errorMock
        }
        let value = self.sequenceMock[safe: self.asyncSequenceCounter]
        self.asyncSequenceCounter += 1
        return value
    }
    private let taskPriorities: [TaskPriority] = [.background, .utility, .low, .medium, .high, .userInitiated]
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testReceive_givenNonthrowingOperation_whenReturningValue_thenEmitsValue() {
        let valueMock = String.random()
        let bridge = Bridge { valueMock }
        
        expect(bridge).to(emit(valueMock))
    }
    
    func testReceive_givenThrowingOperation_whenReturningValue_thenEmitsValue() {
        let valueMock = String.random()
        let bridge = Bridge { () throws in  valueMock }
        
        expect(bridge).to(emit(valueMock))
    }
    
    func testReceive_givenNonthrowingSequence_whenReturningValues_thenEmitsAllValues() {
        let bridge = Bridge(nonthrowing: asyncSequenceMock)
        
        expect(bridge.collect()).to(emit(sequenceMock))
    }
    
    func testReceive_givenThrowingSequence_whenReturningValues_thenEmitsAllValues() {
        let bridge = Bridge(throwing: throwingAsyncSequenceMock)
        
        expect(bridge.collect()).to(emit(sequenceMock))
    }
    
    func testReceive_givenNonthrowingOperation_whenReturning_thenFinishesAfterEmittingSingleValue() {
        let bridge = Bridge {}
        
        expect(bridge.dropFirst()).to(finish())
    }
    
    func testReceive_givenThrowingOperation_whenReturning_thenFinishesAfterEmittingSingleValue() {
        let bridge = Bridge { () throws in }
        
        expect(bridge.dropFirst()).to(finish())
    }
    
    func testReceive_givenNonthrowingSequence_whenReturningValues_thenFinishesAfterEmittingAllValues() {
        let bridge = Bridge(nonthrowing: asyncSequenceMock)
        
        expect(bridge.dropFirst(self.sequenceMock.count)).to(finish())
    }
    
    func testReceive_givenThrowingSequence_whenReturningValues_thenFinishesAfterEmittingAllValues() {
        let bridge = Bridge(throwing: throwingAsyncSequenceMock)
        
        expect(bridge.dropFirst(self.sequenceMock.count)).to(finish())
    }
    
    func testReceive_givenThrowingOperation_whenThrowing_thenFails() {
        let bridge = Bridge { throw self.errorMock }
        
        expect(bridge.mapError { $0 as! ErrorMock }).to(fail(errorMock)) // swiftlint:disable:this force_cast
    }
    
    func testReceive_givenNonthrowingSequence_whenThrowingImmediately_thenFinishes() {
        asyncSequenceShouldFailAfter = 0
        let bridge = Bridge(nonthrowing: throwingAsyncSequenceMock)
        
        expect(bridge).to(finish())
    }
    
    func testReceive_givenNonthrowingSequence_whenThrowingAfterFiveValues_thenEmitsFiveValues() {
        asyncSequenceShouldFailAfter = 5
        let bridge = Bridge(nonthrowing: throwingAsyncSequenceMock)
        
        expect(bridge.collect()).to(emit(.init(sequenceMock.prefix(5))))
    }
    
    func testReceive_givenNonthrowingSequence_whenThrowingAfterFiveValues_thenFinishesAfterEmittingFiveValues() {
        asyncSequenceShouldFailAfter = 5
        let bridge = Bridge(nonthrowing: throwingAsyncSequenceMock)
        
        expect(bridge.dropFirst(5)).to(finish())
    }
    
    func testReceive_givenThrowingSequence_whenThrowingImmediately_thenFails() {
        asyncSequenceShouldFailAfter = 0
        let bridge = Bridge(throwing: throwingAsyncSequenceMock)
        
        expect(bridge.mapError { $0 as! ErrorMock }).to(fail(errorMock)) // swiftlint:disable:this force_cast
    }
    
    func testReceive_givenThrowingSequence_whenThrowingAfterFiveValues_thenEmitsFiveValues() {
        asyncSequenceShouldFailAfter = 5
        let bridge = Bridge(throwing: throwingAsyncSequenceMock)
        
        expect(bridge.collect(5)).to(emit(.init(sequenceMock.prefix(5))))
    }
    
    func testReceive_givenThrowingSequence_whenThrowingAfterFiveValues_thenFailsAfterEmittingFiveValues() {
        asyncSequenceShouldFailAfter = 5
        let bridge = Bridge(throwing: throwingAsyncSequenceMock)
        
        expect(bridge.dropFirst(5).mapError { $0 as! ErrorMock }).to(fail(errorMock)) // swiftlint:disable:this force_cast
    }
    
    func testReceive_givenNonthrowingOperation_whenReturning_thenEmitsOnBackgroundThread() {
        let bridge = Bridge {}
        
        expect(bridge).to(emit(onMainThread: false))
    }
    
    func testReceive_givenThrowingOperation_whenReturning_thenEmitsOnBackgroundThread() {
        let bridge = Bridge { () throws in }
        
        expect(bridge).to(emit(onMainThread: false))
    }
    
    func testReceive_givenNonthrowingSequence_whenReturningValues_thenEmitsOnBackgroundThread() {
        let bridge = Bridge(nonthrowing: asyncSequenceMock)
        
        expect(bridge.collect()).to(emit(sequenceMock, onMainThread: false))
    }
    
    func testReceive_givenThrowingSequence_whenReturningValues_thenEmitsOnBackgroundThread() {
        let bridge = Bridge(throwing: throwingAsyncSequenceMock)
        
        expect(bridge.collect()).to(emit(sequenceMock, onMainThread: false))
    }
    
    func testReceive_givenNonthrowingOperation_whenReturning_thenDoesntLeak() {
        let objectMock = ObjectMock()
        let bridge = Bridge { objectMock }
        
        expect(bridge.dropFirst()).to(finish())
        
        addTeardownBlock { [weak objectMock] in
            withExtendedLifetime(bridge) {
                _ = expect(objectMock).to(beNil())
            }
        }
    }
    
    func testReceive_givenThrowingOperation_whenReturning_thenDoesntLeak() {
        let objectMock = ObjectMock()
        let bridge = Bridge { () throws in objectMock }
        
        expect(bridge.dropFirst()).to(finish())
        
        addTeardownBlock { [weak objectMock] in
            withExtendedLifetime(bridge) {
                _ = expect(objectMock).to(beNil())
            }
        }
    }
    
    func testReceive_givenNonthrowingSequence_whenReturningValues_thenDoesntLeak() {
        let objectMock = ObjectMock()
        let bridge = Bridge(nonthrowing: AsyncStream { objectMock })
        
        expect(bridge.first().dropFirst()).to(finish())
        
        addTeardownBlock { [weak objectMock] in
            withExtendedLifetime(bridge) {
                _ = expect(objectMock).to(beNil())
            }
        }
    }
    
    func testReceive_givenThrowingSequence_whenReturningValues_thenDoesntLeak() {
        let objectMock = ObjectMock()
        let bridge = Bridge(throwing: AsyncThrowingStream { objectMock })
        
        expect(bridge.first().dropFirst()).to(finish())
        
        addTeardownBlock { [weak objectMock] in
            withExtendedLifetime(bridge) {
                _ = expect(objectMock).to(beNil())
            }
        }
    }
    
    func testPriority_givenNonthrowingOperationWithExplicitPriority_thenTaskHasGivenPriority() {
        let priorityMock = taskPriorities.randomElement()!
        let bridge = Bridge(priority: priorityMock) { Task.currentPriority }
        
        expect(bridge).to(emit(priorityMock))
    }
    
    func testPriority_givenThrowingOperationWithExplicitPriority_thenTaskHasGivenPriority() {
        let priorityMock = taskPriorities.randomElement()!
        let bridge = Bridge(priority: priorityMock) { Task.currentPriority }
        
        expect(bridge).to(emit(priorityMock))
    }
    
    func testPriority_givenNonthrowingSequenceWithExplicitPriority_thenTaskHasGivenPriority() {
        let priorityMock = taskPriorities.randomElement()!
        let bridge = Bridge(priority: priorityMock, nonthrowing: AsyncStream { Task.currentPriority })
        
        expect(bridge.first()).to(emit(priorityMock))
    }
    
    func testPriority_givenThrowingSequenceWithExplicitPriority_thenTaskHasGivenPriority() {
        let priorityMock = taskPriorities.randomElement()!
        let bridge = Bridge(priority: priorityMock, throwing: AsyncThrowingStream { Task.currentPriority })
        
        expect(bridge.first()).to(emit(priorityMock))
    }
    
}
