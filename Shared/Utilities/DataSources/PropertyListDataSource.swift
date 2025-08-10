import Foundation
import Combine
import Factory


protocol PropertyListDataSource<Content> {
    
    associatedtype Content: Decodable
    
    var url: URL? { get }
    
}


// TODO: tests
extension PropertyListDataSource {
    
    func propertyList() throws -> Content {
        guard let url else {
            throw URLError(.badURL)
        }
        let data = try Data(contentsOf: url)
        let content = try resolve(\.configurationType).propertyListDecoder.decode(Content.self, from: data)
        return content
    }
    
    var propertyListPublisher: AnyPublisher<Content, any Error> {
        Deferred {
            Future { promise in
                promise(.init { try propertyList() })
            }
        }
        .eraseToAnyPublisher()
    }
    
}
