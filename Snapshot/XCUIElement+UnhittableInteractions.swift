import XCTest


extension XCUIElement {
    
    /// Inspired by https://github.com/devexperts/screenobject/blob/master/Sources/ScreenObject/XCTestExtensions/XCUIElement%2BExtensions.swift
    func tapUnhittable(offset: CGVector = .init(dx: 0.5, dy: 0.5)) {
        coordinate(withNormalizedOffset: offset).tap()
    }
    
    func pressUnhittable(offset: CGVector = .init(dx: 0.5, dy: 0.5), forDuration duration: TimeInterval) {
        coordinate(withNormalizedOffset: offset).press(forDuration: duration)
    }
    
}
