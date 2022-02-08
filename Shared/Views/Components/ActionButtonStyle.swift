import SwiftUI


struct ActionButtonStyle: ButtonStyle {
    
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        ActionButton(configuration: configuration)
    }
    
}


extension ActionButtonStyle {
    
    private struct ActionButton: View {
        
        let configuration: ButtonStyle.Configuration
        
        @Environment(\.isEnabled) private var isEnabled: Bool
        
        // MARK: Views
        
        var body: some View {
            configuration.label
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(isEnabled ? configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue : Color.gray)
                .cornerRadius(9)
        }
        
    }
    
}


extension ButtonStyle where Self == ActionButtonStyle {
    
    static var action: ActionButtonStyle {
        ActionButtonStyle()
    }
    
}
