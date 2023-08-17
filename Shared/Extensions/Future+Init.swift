import Combine


extension Future where Failure == Never {
    
    convenience init(work: @escaping () async -> Output) {
        self.init { promise in
            Task {
                promise(.success(await work()))
            }
        }
    }
    
}


extension Future where Failure == Error {
    
    convenience init(work: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    promise(.success(try await work()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
}
