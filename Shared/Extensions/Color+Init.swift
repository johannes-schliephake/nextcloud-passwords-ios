import SwiftUI


extension Color {
    
    init?(hex: String) {
        guard hex.hasPrefix("#"),
              hex.count == 7,
              let intHex = Int(hex.suffix(6), radix: 16) else {
            return nil
        }
        
        let red = Double((intHex >> 16) & 0xFF) / 255
        let green = Double((intHex >> 8) & 0xFF) / 255
        let blue = Double(intHex & 0xFF) / 255
        
        self.init(UIColor(red: red, green: green, blue: blue, alpha: 1)) /// Initialize as UIColor first for correct color space
    }
    
}
