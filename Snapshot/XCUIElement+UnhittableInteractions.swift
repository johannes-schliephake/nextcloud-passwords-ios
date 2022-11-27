import XCTest


extension XCUIElement {
    
    /// Inspired by https://github.com/devexperts/screenobject/blob/master/Sources/ScreenObject/XCTestExtensions/XCUIElement%2BExtensions.swift
    func tapUnhittable() {
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
    
    func pressUnhittable(forDuration duration: TimeInterval) {
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: duration)
    }
    
}
