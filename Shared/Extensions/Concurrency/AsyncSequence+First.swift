extension AsyncSequence {
    
    var first: Element? {
        get async {
            try? await first { _ in true }
        }
    }
    
}
