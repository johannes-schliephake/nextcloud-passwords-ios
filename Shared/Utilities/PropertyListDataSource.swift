import Foundation
import Combine
import Factory


protocol PropertyListDataSource<Content> {
    
    associatedtype Content: Decodable
    
    var url: URL? { get }
    
}


// TODO: tests
extension PropertyListDataSource {
    
    var propertyList: AnyPublisher<Content, any Error> {
        Deferred {
            Future { promise in
                guard let url else {
                    promise(.failure(URLError(.badURL)))
                    return
                }
                do {
                    let data = try Data(contentsOf: url)
                    let content = try resolve(\.configurationType).propertyListDecoder.decode(Content.self, from: data)
                    promise(.success(content))
                } catch {
                    promise(.failure(error))
                    return
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
}
