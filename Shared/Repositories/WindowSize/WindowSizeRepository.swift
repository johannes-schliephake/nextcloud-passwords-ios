import Combine
import Factory
import Foundation


protocol WindowSizeRepositoryProtocol {
    
    var windowSize: AnyPublisher<CGSize, Never> { get }
    
}


struct WindowSizeRepository: WindowSizeRepositoryProtocol {
    
    @Injected(\.windowSizeDataSource) private var windowSizeDataSource
    
    var windowSize: AnyPublisher<CGSize, Never> {
        windowSizeDataSource.windowSize
    }
    
}
