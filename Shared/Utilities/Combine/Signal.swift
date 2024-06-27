import Combine


typealias Signal = PassthroughSubject<Void, Never>


extension Signal {
    
    func callAsFunction() {
        send()
    }
    
}
