import SwiftUI


extension UIPopoverArrowDirection {
    
    init(_ edges: Edge.Set, layoutDirection: LayoutDirection) {
        self = []
        if edges.contains(.top) { insert(.up) }
        if edges.contains(.bottom) { insert(.down) }
        if edges.contains(.leading) { insert(layoutDirection == .leftToRight ? .left : .right) }
        if edges.contains(.trailing) { insert(layoutDirection == .leftToRight ? .right : .left) }
    }
    
}
