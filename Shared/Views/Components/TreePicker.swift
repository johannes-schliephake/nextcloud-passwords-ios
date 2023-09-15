import SwiftUI


struct Node<Element> {
    
    let value: Element
    let children: [Node]?
    
    init(value: Element, children: [Node]? = nil) {
        self.value = value
        self.children = children
    }
    
}


struct TreePicker<Element: Identifiable, Content: View>: View {
    
    private let node: Node<Element>
    @State private var isExpanded: Bool
    @Binding private var selection: Element?
    private let content: (Element) -> Content
    
    init(_ root: Node<Element>, selection: Binding<Element?>, @ViewBuilder content: @escaping (Element) -> Content) {
        self.init(root, isExpanded: true, selection: selection, content: content)
    }
    
    private init(_ node: Node<Element>, isExpanded: Bool, selection: Binding<Element?>, @ViewBuilder content: @escaping (Element) -> Content) {
        self.node = node
        _isExpanded = .init(wrappedValue: isExpanded)
        _selection = selection
        self.content = content
    }
    
    // MARK: Views
    
    var body: some View {
        tree()
            .listRowBackground(node.value.id == selection?.id ? Color(white: 0.5, opacity: 0.35) : Color.clear)
    }
    
    @ViewBuilder func tree() -> some View {
        if let children = node.children {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(children, id: \.value.id) { child in
                    let isExpanded = selection.map { Self.treeContainsElement(node: child, value: $0) } == true
                    Self(child, isExpanded: isExpanded, selection: $selection, content: content)
                }
            } label: {
                label()
            }
        } else {
            label()
        }
    }
    
    private func label() -> some View {
        content(node.value)
            .contentShape(Rectangle())
            .onTapGesture { selection = node.value }
    }
    
    // MARK: Functions
    
    private static func treeContainsElement<Element: Identifiable>(node: Node<Element>, value: Element) -> Bool {
        node.children?.contains { $0.value.id == value.id || treeContainsElement(node: $0, value: value) } == true
    }
    
}


#if DEBUG

extension Node: Equatable where Element: Equatable {}

extension Node {
    
    init(value: Element, @ArrayBuilder<Node> _ children: @escaping () -> [Node]) {
        self.init(value: value, children: children())
    }
    
}

#endif
