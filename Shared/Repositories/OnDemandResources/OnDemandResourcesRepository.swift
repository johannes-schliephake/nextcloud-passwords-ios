import Combine
import FactoryKit


protocol OnDemandResourcesRepositoryProtocol {
    
    var onDemandResources: AnyPublisher<OnDemandResources, any Error> { get }
    
}


// TODO: tests
struct OnDemandResourcesRepository: OnDemandResourcesRepositoryProtocol {
    
    @Injected(\.onDemandResourcesPropertyListDataSource) private var onDemandResourcesPropertyListDataSource
    
    var onDemandResources: AnyPublisher<OnDemandResources, any Error> {
        onDemandResourcesPropertyListDataSource.propertyListPublisher
    }
    
}
