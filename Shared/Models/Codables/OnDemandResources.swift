struct OnDemandResources: Decodable {
    
    let tagKeys: [String]
    
    private enum CodingKeys: String, CodingKey {
        case tags = "NSBundleResourceRequestTags"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tagKeys = try container.decode([String: [String: [String]]].self, forKey: .tags).map(\.key)
    }
    
}
