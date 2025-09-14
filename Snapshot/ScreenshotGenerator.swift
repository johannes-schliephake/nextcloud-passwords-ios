import XCTest


@MainActor class ScreenshotGenerator: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            XCUIDevice.shared.orientation = .landscapeLeft
        default:
            XCUIDevice.shared.orientation = .portrait
        }
        
        app.launchEnvironment = ["TEST": "true"]
        setupSnapshot(app)
        app.launch()
    }
    
    func test_entriesPage_searchBarVisible_filterByFolders() throws {
        /// Swipe down to show search bar, filter by folders
        if #unavailable(iOS 26) {
            app.collectionViews.firstMatch.cells.firstMatch.swipeDown()
        }
        app.buttons["filterSortMenu"].tapUnhittable()
        app.collectionViews.firstMatch.buttons.element(boundBy: 1).tap()
        if #available(iOS 26, *) {
            app.collectionViews.firstMatch.tapUnhittable(offset: .init(dx: -0.01, dy: -0.01))
        } else {
            app.buttons["filterSortMenu"].tapUnhittable()
        }
        
        snapshot("1")
    }
    
    func test_entriesPage_searchBarVisible_filterByFavorites_sortingOptionsVisible() throws {
        /// Swipe down to show search bar, filter by favorites, show sort menu again
        if #unavailable(iOS 26) {
            app.collectionViews.firstMatch.cells.firstMatch.swipeDown()
        }
        app.buttons["filterSortMenu"].tapUnhittable()
        app.collectionViews.firstMatch.buttons.element(boundBy: 2).tap()
        
        snapshot("2")
    }
    
    func test_entriesPage_filterByFavorites_passwordContextMenuVisible() throws {
        /// Filter by favorites, long tap last entry (has to be a password)
        app.buttons["filterSortMenu"].tapUnhittable()
        app.collectionViews.firstMatch.buttons.element(boundBy: 2).tap()
        if #available(iOS 26, *) {
            app.collectionViews.firstMatch.tapUnhittable(offset: .init(dx: -0.01, dy: -0.01))
        } else {
            app.buttons["filterSortMenu"].tapUnhittable()
        }
        app.collectionViews.firstMatch.cells.lastMatch.buttons.firstMatch.pressUnhittable(forDuration: 1)
        
        snapshot("3")
    }
    
    func test_passwordDetailPage() throws {
        /// Filter by favorites, open last entry (has to be a password)
        app.buttons["filterSortMenu"].tapUnhittable()
        app.collectionViews.firstMatch.buttons.element(boundBy: 2).tap()
        if #available(iOS 26, *) {
            app.collectionViews.firstMatch.tapUnhittable(offset: .init(dx: -0.01, dy: -0.01))
        } else {
            app.buttons["filterSortMenu"].tapUnhittable()
        }
        app.collectionViews.firstMatch.cells.lastMatch.buttons.firstMatch.tapUnhittable()
        
        snapshot("4")
    }
    
    func test_editPasswordPage() throws {
        /// Filter by favorites, open last entry (has to be a password), open edit page, show password generator
        app.buttons["filterSortMenu"].tapUnhittable()
        app.collectionViews.firstMatch.buttons.element(boundBy: 2).tap()
        if #available(iOS 26, *) {
            app.collectionViews.firstMatch.tapUnhittable(offset: .init(dx: -0.01, dy: -0.01))
        } else {
            app.buttons["filterSortMenu"].tapUnhittable()
        }
        app.collectionViews.firstMatch.cells.lastMatch.buttons.firstMatch.tapUnhittable()
        app.buttons["editPasswordButton"].tap()
        app.buttons["passwordGenerator"].tap()
        
        snapshot("5")
    }
    
}
