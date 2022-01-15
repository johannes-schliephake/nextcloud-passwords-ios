import SwiftUI


private struct SizePreferenceKey: PreferenceKey {
    
    static let defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
    
}


/// Inspired by https://github.com/FiveStarsBlog/CodeSamples/tree/main/Flexible-SwiftUI
struct FlowView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    
    private let data: Data
    private let spacing: Double
    private let alignment: HorizontalAlignment
    private let content: (Data.Element) -> Content
    
    @State private var width = 0.0
    @State private var elementWidths = [Data.Element: Double]()
    
    init(_ data: Data, spacing: Double = 10, alignment: HorizontalAlignment = .center, content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
        ZStack {
            /// Detect size changes in duplicated content views to handle views which are wider than the superview
            ForEach(Array(data), id: \.self) {
                element in
                content(element)
                    .fixedSize()
                    .onSizeChange { elementWidths[element] = $0.width }
            }
            .frame(width: 1)
            .hidden()
            VStack(alignment: alignment, spacing: spacing) {
                ForEach(rows, id: \.self) {
                    row in
                    HStack(spacing: spacing) {
                        ForEach(row, id: \.self) {
                            element in
                            content(element)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: Alignment(horizontal: alignment, vertical: .center))
            .onSizeChange { width = $0.width }
        }
    }
    
    private var rows: [[Data.Element]] {
        var rows = [[Data.Element]]()
        var lastRowWidth = Double.infinity
        
        for element in data {
            let elementWidth = elementWidths[element] ?? width
            if lastRowWidth + spacing + elementWidth > width {
                rows.append([element])
                lastRowWidth = elementWidth
            }
            else {
                rows[rows.count - 1].append(element)
                lastRowWidth += spacing + elementWidth
            }
        }
        
        return rows
    }
    
}


private extension View {
    
    func onSizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader {
                geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
            .onPreferenceChange(SizePreferenceKey.self, perform: action)
    }
    
}
