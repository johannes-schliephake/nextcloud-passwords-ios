import Factory


protocol PasteboardServiceProtocol {
    
    func set(string: String, sensitive: Bool)
    
}


struct PasteboardService: PasteboardServiceProtocol {
    
    @Injected(\.pasteboardRepository) private var pasteboardRepository
    
    func set(string: String, sensitive: Bool) {
        pasteboardRepository.set(string: string, sensitive: sensitive)
    }
    
}
