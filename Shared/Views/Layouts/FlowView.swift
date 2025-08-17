import SwiftUI


struct FlowView: Layout {
    
    let spacing: Double
    let alignment: HorizontalAlignment
    
    init(spacing: Double = 10, alignment: HorizontalAlignment = .center) {
        self.spacing = spacing
        self.alignment = alignment
    }
    
    static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .vertical
        return properties
    }
    
    func makeCache(subviews: Subviews) -> [CGPoint] {
        []
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout [CGPoint]) -> CGSize {
        cache.removeAll()
        
        let availableWidth = proposal.width ?? .infinity
        var rows = [(subviewSizes: [CGSize], size: CGSize)]()
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(proposal)
            if let lastWidth = rows.last?.size.width,
               lastWidth + spacing + subviewSize.width <= availableWidth {
                rows[rows.count - 1].subviewSizes.append(subviewSize)
                rows[rows.count - 1].size.width += spacing + subviewSize.width
                rows[rows.count - 1].size.height = max(rows[rows.count - 1].size.height, subviewSize.height)
            } else {
                rows.append((subviewSizes: [subviewSize], size: subviewSize))
            }
        }
        
        var offsetY = 0.0
        for row in rows {
            if offsetY != 0 {
                offsetY += spacing
            }
            var offsetX: Double
            switch alignment {
            case .leading, .listRowSeparatorLeading:
                offsetX = 0
            case .trailing, .listRowSeparatorTrailing:
                offsetX = availableWidth - row.size.width
            default:
                offsetX = (availableWidth - row.size.width) / 2
            }
            for subviewSize in row.subviewSizes {
                cache.append(.init(x: offsetX + subviewSize.width / 2, y: offsetY + row.size.height / 2))
                offsetX += subviewSize.width + spacing
            }
            offsetY += row.size.height
        }
        
        let width = rows.map(\.size.width).max() ?? 0
        let height = offsetY
        return .init(width: proposal.replacingUnspecifiedDimensions(by: .init(width: width, height: height)).width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout [CGPoint]) {
        zip(subviews, cache)
            .forEach { $0.place(at: $1 + bounds.origin, anchor: .center, proposal: proposal) }
    }
    
}
