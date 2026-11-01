import SwiftUI


struct ToolbarVerticalEdgeReader<Content: ToolbarContent>: ToolbarContent {
    
    @ContentBuilder let content: (HorizontalEdge?) -> Content
    
    var body: some ToolbarContent {
        if #available(iOS 27.1, *) {
            ToolbarVerticalEdgeReaderInternal(content: content)
        } else {
            content(nil)
        }
    }
    
}


extension ToolbarVerticalEdgeReader {
    
    @available(iOS 27.1, *) private struct ToolbarVerticalEdgeReaderInternal: ToolbarContent {
        
        @Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge
        
        let content: (HorizontalEdge?) -> Content
        
        var body: some ToolbarContent {
            content(toolbarVerticalEdge)
        }
        
    }
    
}
