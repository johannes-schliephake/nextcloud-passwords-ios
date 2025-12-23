import SwiftUI
import Factory


extension EdgeInsets {
    
    private static var horizontalInset: Double {
        switch (
            UIDevice.current.userInterfaceIdiom,
            resolve(\.windowSizeUseCase)[\.windowSize]?.width ?? 0,
            UIDevice.current.orientation.isLandscape
        ) {
        case (.pad, 668..., _): /// iPad split view
            if #available(iOS 26, *) { 26 } else { 16 }
        case (.phone, 736, true): /// iPhone 8 Plus in landscape
            20
        case (.phone, 404..., false), /// iPhone in portrait ...
            (.pad, 404..., _): /// ... or iPad above threshold
            20
        default:
            16
        }
    }
    
    private static let verticalInset: Double = if #available(iOS 26, *) { 10 } else { 8 }
    
    static var entryRow: Self {
        .init(
            top: verticalInset,
            leading: horizontalInset,
            bottom: verticalInset,
            trailing: horizontalInset
        )
    }
    
}
