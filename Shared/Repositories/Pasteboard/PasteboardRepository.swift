import Factory


protocol PasteboardRepositoryProtocol {
    
    func set(string: String, sensitive: Bool)
    
}


struct PasteboardRepository: PasteboardRepositoryProtocol {
    
    @Injected(\.pasteboardDataSource) private var pasteboardDataSource
    @Injected(\.settingsService) private var settingsService
    
    func set(string: String, sensitive: Bool) {
        pasteboardDataSource.set(string: string, localOnly: !settingsService.isUniversalClipboardEnabled, sensitive: sensitive)
    }
    
}
