import XCTest


class ScreenshotGenerator: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchEnvironment = ["TEST": "true"]
        setupSnapshot(app)
        app.launch()
    }
    
    func test_entriesPage_searchBarVisible_filterByFolders() throws {
        /// Swipe down to show search bar, filter by folders
        app.tables.buttons.firstMatch.swipeDown()
        app.navigationBars.firstMatch.buttons["arrow.up.arrow.down"].tap()
        app.collectionViews.buttons.element(boundBy: 1).tap()
        
        snapshot("1")
    }
    
    func test_entriesPage_searchBarVisible_filterByFavorites_sortingOptionsVisible() throws {
        /// Swipe down to show search bar, filter by favorites, show sort menu again
        app.tables.buttons.firstMatch.swipeDown()
        app.navigationBars.firstMatch.buttons["arrow.up.arrow.down"].tap()
        app.collectionViews.buttons.element(boundBy: 2).tap()
        app.navigationBars.firstMatch.buttons["arrow.up.arrow.down"].tap()
        
        snapshot("2")
    }
    
    func test_entriesPage_filterByFavorites_passwordContextMenuVisible() throws {
        /// Filter by favorites, long tap last entry (has to be a password)
        app.navigationBars.firstMatch.buttons["arrow.up.arrow.down"].tap()
        app.collectionViews.buttons.element(boundBy: 2).tap()
        app.tables.buttons.element(boundBy: app.tables.buttons.count - 1).press(forDuration: 1)
        
        snapshot("3")
    }
    
    func test_passwordDetailPage() throws {
        /// Filter by favorites, open last entry (has to be a password)
        app.navigationBars.firstMatch.buttons["arrow.up.arrow.down"].tap()
        app.collectionViews.buttons.element(boundBy: 2).tap()
        app.tables.buttons.element(boundBy: app.tables.buttons.count - 1).tap()
        
        snapshot("4")
    }
    
    func test_editPasswordPage() throws {
        /// Filter by favorites, open last entry (has to be a password), open edit page
        app.navigationBars.firstMatch.buttons["arrow.up.arrow.down"].tap()
        app.collectionViews.buttons.element(boundBy: 2).tap()
        app.tables.buttons.element(boundBy: app.tables.buttons.count - 1).tap()
        app.navigationBars.firstMatch.buttons.element(boundBy: app.navigationBars.firstMatch.buttons.count - 1).tap()
        
        snapshot("5")
    }
    
}
