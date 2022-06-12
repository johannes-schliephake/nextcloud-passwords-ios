import SwiftUI


extension PreviewDevice {
    
    /// Generate a few interesting preview configurations and insert a view into each
    static func generate<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        let deviceNames = ["iPhone 13 Pro", "iPhone 13 Pro Max", "iPhone SE (2nd generation)", "iPhone 8 Plus", "iPhone SE (1st generation)", "iPad Air (4th generation)"]
        let colorSchemes = ColorScheme.allCases
        let locales = Bundle.main.localizations.map(Locale.init)
        return Group {
            ForEach(colorSchemes.dropFirst(), id: \.self) {
                colorScheme in
                content()
                    .previewDevice(PreviewDevice(stringLiteral: deviceNames.first!))
                    .previewDisplayName("\(deviceNames.first!) (\(locales.first!.identifier.uppercased()), \(colorScheme))")
                    .environment(\.locale, locales.first!)
                    .preferredColorScheme(colorScheme)
                    .previewInterfaceOrientation(deviceNames.first!.contains("iPad") ? .landscapeLeft : .portrait)
            }
            ForEach(locales, id: \.identifier) {
                locale in
                content()
                    .previewDevice(PreviewDevice(stringLiteral: deviceNames.first!))
                    .previewDisplayName("\(deviceNames.first!) (\(locale.identifier.uppercased()), \(colorSchemes.first!))")
                    .environment(\.locale, locale)
                    .preferredColorScheme(colorSchemes.first!)
                    .previewInterfaceOrientation(deviceNames.first!.contains("iPad") ? .landscapeLeft : .portrait)
            }
            ForEach(deviceNames.dropFirst(), id: \.self) {
                deviceName in
                content()
                    .previewDevice(PreviewDevice(stringLiteral: deviceName))
                    .previewDisplayName("\(deviceName) (\(locales.first!.identifier.uppercased()), \(colorSchemes.first!))")
                    .environment(\.locale, locales.first!)
                    .preferredColorScheme(colorSchemes.first!)
                    .previewInterfaceOrientation(deviceName.contains("iPad") ? .landscapeLeft : .portrait)
            }
        }
    }
    
}
