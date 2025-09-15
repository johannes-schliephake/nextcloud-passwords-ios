import Foundation
import Factory
import Combine
import FoundationModels


@available(iOS 26, *) @Generable private struct Suggestion {

    @Guide(description: "The title of a website or the name of the company that owns the website.") let label: String
    
}


@available(iOS 26, *) protocol UrlLabelSuggestionLanguangeModelDataSourceProtocol: DataSource where State == UrlLabelSuggestionLanguangeModelDataSource.State, Action == UrlLabelSuggestionLanguangeModelDataSource.Action {} // swiftlint:disable:this type_name


// TODO: tests
@available(iOS 26, *) final class UrlLabelSuggestionLanguangeModelDataSource: UrlLabelSuggestionLanguangeModelDataSourceProtocol { // swiftlint:disable:this type_name
    
    final class State {
        
        @Current<String, any Error> fileprivate(set) var suggestedLabel
        
    }
    
    enum Action {
        case setUrl(URL)
    }
    
    private static let instructions = """
        Extract a clean, user-friendly service name from URLs for password manager entries.
                
        Rules:
        1. Return the primary service/company name (e.g., "Apple", "Google", "Netflix")
        2. Use proper capitalization and spacing
        3. For subdomains, prioritize the main service (accounts.google.com → "Google")
        4. For auth/login URLs, identify the target service
        5. Keep names concise but recognizable
        6. For unknown services, use the domain name without TLD
        
        Examples:
        - apple.com → "Apple"
        - accounts.google.com → "Google"
        - auth.wikimedia.org → "Wikipedia"
        - login.microsoftonline.com → "Microsoft"
        - subdomain.unknown-site.com → "Unknown Site
        
        Special Cases:
        - IP addresses → "Local Service"
        - localhost/127.0.0.1 → "Local Development"
        - .local domains → "Local Network"
        - Unknown domains → Use domain name, capitalize first letter
        
        Avoid:
        - Technical terms (OAuth, SAML, API)
        - URLs paths or parameters
        - File extensions
        - Protocol names (https, ftp)
    """
    
    @Injected(\.defaultLanguageModelType) private var defaultLanguageModelType
    
    let state: State
    
    private var cancellable: AnyCancellable?
    
    init() {
        state = .init()
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setUrl(url):
            let defaultLanguageModel = defaultLanguageModelType.init(instructions: Self.instructions)
            
            cancellable = Bridge {
                try await defaultLanguageModel.respond(
                    to: "URL: `\(url.absoluteString)`",
                    generating: Suggestion.self,
                    includeSchemaInPrompt: false,
                    options: .init(
                        sampling: .greedy,
                        temperature: 0
                    )
                )
            }
            .map(\.content.label)
            .resultize()
            .sink { [weak self] in self?.state.suggestedLabel = $0 }
        }
    }
    
}
