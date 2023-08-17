import Foundation


protocol ProductIdentifiersPropertyListDataSourceProtocol: PropertyListDataSource<[String]> {} // swiftlint:disable:this type_name


// TODO: tests
struct ProductIdentifiersPropertyListDataSource: ProductIdentifiersPropertyListDataSourceProtocol {
    
    let url = Bundle.main.url(forResource: "IAP", withExtension: "plist")
    
}
