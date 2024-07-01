@testable import Passwords


extension Node {
    
    init(value: Element, @ArrayBuilder<Node> _ children: @escaping () -> [Node]) {
        self.init(value: value, children: children())
    }
    
}
