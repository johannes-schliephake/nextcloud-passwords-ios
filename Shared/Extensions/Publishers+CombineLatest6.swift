import Combine


extension Publishers {
    
    static func CombineLatest6<A: Publisher, B: Publisher, C: Publisher, D: Publisher, E: Publisher, F: Publisher>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> some Publisher<(A.Output, B.Output, C.Output, D.Output, E.Output, F.Output), A.Failure> where A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure, D.Failure == E.Failure, E.Failure == F.Failure { // swiftlint:disable:this identifier_name large_tuple
        Publishers.CombineLatest(
            Publishers.CombineLatest3(a, b, c),
            Publishers.CombineLatest3(d, e, f)
        )
        .map { ($0.0, $0.1, $0.2, $1.0, $1.1, $1.2) }
    }
    
}
