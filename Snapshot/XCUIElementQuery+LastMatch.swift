import XCTest


extension XCUIElementQuery {
    
    var lastMatch: XCUIElement {
        element(boundBy: count - 1)
    }
    
}
