import SwiftUI
import FactoryKit


extension EdgeInsets {
    
    private static let verticalInset: Double = if #available(iOS 26, *) { 10 } else { 8 }
    
    static var entryRow: Self {
        @Injected(\.rootViewController) var rootViewController
        return .init(
            top: verticalInset,
            leading: rootViewController?.systemMinimumLayoutMargins.leading ?? 16,
            bottom: verticalInset,
            trailing: rootViewController?.systemMinimumLayoutMargins.trailing ?? 16
        )
    }
    
}
