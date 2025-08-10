import Combine
import Foundation
import Factory


enum PreparationResult {
    case added
    case preexisting
}


protocol OnDemandPreparationDataSource: DataSource {}


// TODO: tests
extension OnDemandPreparationDataSource {
    
    func prepareFile(tagged tagName: String, target targetUrl: URL) -> AnyPublisher<PreparationResult, any Error> {
        @Injected(\.fileManager) var fileManager
        @LazyInjected(\.bundleResourceRequestType) var bundleResourceRequestType
        
        guard !fileManager.fileExists(atPath: targetUrl.path) else {
            return Just(.preexisting).setFailureType(to: (any Error).self).eraseToAnyPublisher()
        }
        
        let resourceRequest = bundleResourceRequestType.init(tags: [tagName], bundle: Bundle.root)
        return Bridge { try await resourceRequest.beginAccessingResources() }
            .map { Bundle.root.url(forResource: tagName, withExtension: nil) }
            .replaceNil(with: URLError(.resourceUnavailable))
            .tryMap { try fileManager.copyItem(at: $0, to: targetUrl) }
            .handleEvents(receiveOutput: { resourceRequest.endAccessingResources() })
            .map { .added }
            .eraseToAnyPublisher()
    }
    
}
