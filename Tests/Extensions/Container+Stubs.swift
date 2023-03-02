import Factory
@testable import Passwords


extension Container {
    
    var password: Factory<Password> {
        self { .mock }
            .shared
    }
    var passwords: Factory<[Password]> {
        self { Password.mocks }
            .shared
    }
    var folder: Factory<Folder> {
        self { .mock }
            .shared
    }
    var folders: Factory<[Folder]> {
        self { Folder.mocks }
            .shared
    }
    var tag: Factory<Tag> {
        self { .mock }
            .shared
    }
    var tags: Factory<[Tag]> {
        self { Tag.mocks }
            .shared
    }
    
}
