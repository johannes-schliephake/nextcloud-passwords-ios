import Combine


extension PassthroughSubject where Failure == Never {
    
    convenience init<Sequence: AsyncSequence>(_ sequence: Sequence) where Sequence.Element == Output {
        self.init()
        
        Task {
            for try await value in sequence {
                send(value)
            }
            send(completion: .finished)
        }
    }
    
}


extension PassthroughSubject where Failure == Error {
    
    convenience init<Sequence: AsyncSequence>(_ sequence: Sequence) where Sequence.Element == Output {
        self.init()
        
        Task {
            do {
                for try await value in sequence {
                    send(value)
                }
                send(completion: .finished)
            } catch {
                send(completion: .failure(error))
            }
        }
    }
    
}
