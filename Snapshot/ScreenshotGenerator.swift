import XCTest


class ScreenshotGenerator: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            XCUIDevice.shared.orientation = .landscapeLeft
        default:
            XCUIDevice.shared.orientation = .portrait
        }
        
        app = XCUIApplication()
        app.launchEnvironment = ["TEST": "true"]
        setupSnapshot(app)
        app.launch()
    }
    
    func test_entriesPage_searchBarVisible_filterByFolders() throws {
        /// Swipe down to show search bar, filter by folders
        app.tables.firstMatch.cells.firstMatch.swipeDown()
        app.navigationBars.buttons["filterSortMenu"].tap()
        app.collectionViews.firstMatch.buttons.element(boundBy: 1).tap()
        
        snapshot("1")
    }
    
    func test_entriesPage_searchBarVisible_filterByFavorites_sortingOptionsVisible() throws {
        /// Swipe down to show search bar, filter by favorites, show sort menu again
        app.tables.firstMatch.cells.firstMatch.swipeDown()
        app.navigationBars.buttons["filterSortMenu"].tap()
        app.collectionViews.firstMatch.buttons.element(boundBy: 2).tap()
        app.navigationBars.buttons["filterSortMenu"].tap()
        
        snapshot("2")
    }
    
    func test_entriesPage_filterByFavorites_passwordContextMenuVisible() throws {
        /// Filter by favorites, long tap last entry (has to be a password)
        app.navigationBars.buttons["filterSortMenu"].tap()
        app.collectionViews.firstMatch.buttons.element(boundBy: 2).tap()
        app.tables.firstMatch.cells.lastMatch.buttons.firstMatch.press(forDuration: 1)
        
        snapshot("3")
    }
    
    func test_passwordDetailPage() throws {
        /// Filter by favorites, open last entry (has to be a password)
        app.navigationBars.buttons["filterSortMenu"].tap()
        app.collectionViews.firstMatch.buttons.element(boundBy: 2).tap()
        app.tables.firstMatch.cells.lastMatch.buttons.firstMatch.tap()
        
        snapshot("4")
    }
    
    func test_editPasswordPage() throws {
        /// Filter by favorites, open last entry (has to be a password), open edit page, show password and password generator, scroll down
        app.navigationBars.buttons["filterSortMenu"].tap()
        app.collectionViews.firstMatch.buttons.element(boundBy: 2).tap()
        app.tables.firstMatch.cells.lastMatch.buttons.firstMatch.tap()
        app.navigationBars.lastMatch.buttons.lastMatch.tap()
        app.tables.buttons["showPasswordButton"].tap()
        app.tables.buttons["passwordGenerator"].tap()
        // app.tables.lastMatch.swipeUp(velocity: 280)
        
        snapshot("5")
    }
    
}
