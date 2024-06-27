import SwiftUI


extension Color {
    
    var hex: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        red = red.clamped(to: 0...1)
        green = green.clamped(to: 0...1)
        blue = blue.clamped(to: 0...1)
        
        let intHex = (Int(red * 255) << 16) + (Int(green * 255) << 8) + Int(blue * 255)
        var hex = String(intHex, radix: 16, uppercase: true)
        hex = "#\(String(repeating: "0", count: 6 - hex.count))\(hex)"
        
        return hex
    }
    
}
