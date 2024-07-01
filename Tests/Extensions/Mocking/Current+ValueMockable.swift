@testable import Passwords
import Combine


extension Current: ValueMockable {
    
    func mockValue(_ value: Any) {
        let mirror = Mirror(reflecting: self)
        guard let child = mirror.children.first(where: { $0.label == "subject" }),
              let subject = child.value as? CurrentValueSubject<Result<Value, Failure>?, Never>,
              let value = value as? Result<Value, Failure>? else {
            fatalError("Failed to mock subject value") // swiftlint:disable:this fatal_error
        }
        subject.value = value
    }
    
}
