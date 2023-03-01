import Factory
@testable import Passwords


extension Container {
    
    static let password = Factory<Password>(scope: .shared) { .mock }
    static let passwords = Factory<[Password]>(scope: .shared) { Password.mocks }
    static let folder = Factory<Folder>(scope: .shared) { .mock }
    static let folders = Factory<[Folder]>(scope: .shared) { Folder.mocks }
    static let tag = Factory<Tag>(scope: .shared) { .mock }
    static let tags = Factory<[Tag]>(scope: .shared) { Tag.mocks }
    
}
