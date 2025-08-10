import Foundation


protocol OnDemandResourcesPropertyListDataSourceProtocol: PropertyListDataSource<OnDemandResources> {} // swiftlint:disable:this type_name


// TODO: tests
struct OnDemandResourcesPropertyListDataSource: OnDemandResourcesPropertyListDataSourceProtocol {
    
    let url = Bundle.root.url(forResource: "OnDemandResources", withExtension: "plist")
    
}
