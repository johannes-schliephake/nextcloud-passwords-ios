import FoundationModels


@available(iOS 26, *) protocol DefaultLanguageModel {
    
    init(instructions: String?)
    
    func respond<Content: Generable>(
        to prompt: String,
        generating type: Content.Type,
        includeSchemaInPrompt: Bool,
        options: GenerationOptions
    ) async throws -> LanguageModelSession.Response<Content>
    
}


@available(iOS 26, *) extension LanguageModelSession: DefaultLanguageModel {
    
    convenience init(instructions: String?) {
        self.init(model: .default, instructions: instructions)
    }
    
}
