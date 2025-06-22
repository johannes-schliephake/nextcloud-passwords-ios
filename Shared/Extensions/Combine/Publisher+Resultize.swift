import Combine


extension Publisher {
    
    func resultize() -> some Publisher<Result<Output, Failure>, Never> {
        map { .success($0) }
            .catch { Just(.failure($0)) }
    }
    
}
