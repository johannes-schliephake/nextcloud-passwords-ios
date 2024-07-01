import Foundation


struct FailableDecodable<T: Decodable>: Decodable {
    
    let result: Result<T, any Error>

    init(from decoder: any Decoder) throws {
        result = Result(catching: { try T(from: decoder) })
    }
    
}
