import Foundation


protocol MockObject {
    
    associatedtype ObjectType
    static var mock: ObjectType { get }
    static var mocks: [ObjectType] { get }
    
}


extension MockObject {
    
    static var mocks: [ObjectType] {
        []
    }
    
}
