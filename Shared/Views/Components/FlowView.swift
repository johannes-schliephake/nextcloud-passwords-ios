import SwiftUI


@available(iOS 16, *) struct FlowView: Layout {
    
    @Environment(\.layoutDirection) private var layoutDirection // Use environment value because Subviews.layoutDirection is out of sync
    
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
            }
            else {
                rows.append((subviewSizes: [subviewSize], size: subviewSize))
            }
        }
        
        var offsetY = 0.0
        for row in rows {
            if offsetY != 0 {
                offsetY += spacing
            }
            var offsetX: Double
            switch (alignment, layoutDirection) {
            case (.leading, .leftToRight), (.listRowSeparatorLeading, .leftToRight),
                (.trailing, .rightToLeft), (.listRowSeparatorTrailing, .rightToLeft):
                offsetX = 0
            case (.trailing, .leftToRight), (.listRowSeparatorTrailing, .leftToRight),
                (.leading, .rightToLeft), (.listRowSeparatorLeading, .rightToLeft):
                offsetX = availableWidth - row.size.width
            default:
                offsetX = (availableWidth - row.size.width) / 2
            }
            let subviewSizes = layoutDirection == .leftToRight ? row.subviewSizes : row.subviewSizes.reversed()
            for subviewSize in subviewSizes {
                cache.append(CGPoint(x: offsetX, y: offsetY + row.size.height / 2))
                offsetX += subviewSize.width + spacing
            }
            offsetY += row.size.height
        }
        
        let width = rows.map(\.size.width).max() ?? 0
        let height = offsetY
        return proposal.replacingUnspecifiedDimensions(by: CGSize(width: width, height: height))
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout [CGPoint]) {
        zip(subviews, cache)
            .forEach { $0.place(at: $1 + bounds.origin, anchor: .leading, proposal: proposal) }
    }
    
}
