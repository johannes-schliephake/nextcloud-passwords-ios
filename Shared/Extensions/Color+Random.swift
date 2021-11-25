import SwiftUI


extension Color {
    
    static func random() -> Color {
        Color(UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)) /// Initialize as UIColor first for correct color space
    }
    
}
