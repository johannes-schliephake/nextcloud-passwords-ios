extension AsyncSequence {
    
    var first: Element? {
        get async {
            try? await first()
        }
    }
    
    func first() async rethrows -> Element? {
        try await first { _ in true }
    }
    
}
