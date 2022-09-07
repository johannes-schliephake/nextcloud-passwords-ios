import Foundation


struct FailableDecodable<T: Decodable>: Decodable {
    
    let result: Result<T, Error>

    init(from decoder: Decoder) throws {
        result = Result(catching: { try T(from: decoder) })
    }
    
}
