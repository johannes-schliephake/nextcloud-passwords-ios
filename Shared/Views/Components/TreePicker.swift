import SwiftUI


private enum TreePickerConstants {
    static let rowHorizontalContentPadding = 12.0
    static let rowHorizontalBackgroundPadding = 10.0
    static let rowDepthInset = 20.0
}


struct Node<Element> {
    
    let value: Element
    let children: [Self]?
    
    init(value: Element, children: [Self]? = nil) {
        self.value = value
        self.children = children
    }
    
}


struct TreePicker<Element: Identifiable, Content: View>: View {
    
    private let node: Node<Element>
    @State private var isExpanded: Bool
    @Binding private var selection: Element?
    private let depth: Int
    private let content: (Element) -> Content
    
    init(_ root: Node<Element>, selection: Binding<Element?>, @ViewBuilder content: @escaping (Element) -> Content) {
        self.init(root, isExpanded: true, selection: selection, depth: 0, content: content)
    }
    
    private init(_ node: Node<Element>, isExpanded: Bool, selection: Binding<Element?>, depth: Int, @ViewBuilder content: @escaping (Element) -> Content) {
        self.node = node
        _isExpanded = .init(wrappedValue: isExpanded)
        _selection = selection
        self.depth = depth
        self.content = content
    }
    
    // MARK: Views
    
    var body: some View {
        tree()
            .apply { view in
                let isSelected = node.value.id == selection?.id
                if #available(iOS 26, *) {
                    view
                        .padding(.horizontal, depth == 0 ? TreePickerConstants.rowHorizontalContentPadding : 0)
                        .listRowBackground(
                            Capsule()
                                .fill(isSelected ? Color(white: 0.49, opacity: 0.22) : Color.clear)
                                .padding(.leading, Double(depth) * TreePickerConstants.rowDepthInset + TreePickerConstants.rowHorizontalBackgroundPadding)
                                .padding(.trailing, TreePickerConstants.rowHorizontalBackgroundPadding)
                        )
                        .listRowSeparator(isSelected ? .hidden : .automatic)
                } else {
                    view
                        .listRowBackground(isSelected ? Color(white: 0.5, opacity: 0.35) : Color.clear)
                }
            }
    }
    
    @ViewBuilder func tree() -> some View {
        if let children = node.children {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(children, id: \.value.id) { child in
                    let isExpanded = selection.map { Self.treeContainsElement(node: child, value: $0) } == true
                    Self(child, isExpanded: isExpanded, selection: $selection, depth: depth + 1, content: content)
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
            .apply { view in
                if #available(iOS 26, *) {
                    view
                        .id(UUID()) /// Required to rerender separators, scroll view proxy somehow still finds the view without node ID set
                } else {
                    view
                        .id(node.value.id)
                }
            }
            .onTapGesture { selection = node.value }
    }
    
    // MARK: Functions
    
    private static func treeContainsElement(node: Node<Element>, value: Element) -> Bool {
        node.children?.contains { $0.value.id == value.id || treeContainsElement(node: $0, value: value) } == true
    }
    
}


#if DEBUG

extension Node: Equatable where Element: Equatable {}

#endif
