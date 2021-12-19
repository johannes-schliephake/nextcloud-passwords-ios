import SwiftUI


struct TagBadge: View {
    
    let tag: Tag
    let baseColor: Color /// Base color is needed for tags that are not visible against the parent view's background
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(hex: tag.color) ?? .primary)
                .frame(width: 14, height: 14)
            Text(tag.label)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary.opacity(0.6))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(baseColor)
                RoundedRectangle(cornerRadius: 5)
                    .fill((Color(hex: tag.color) ?? .primary).opacity(0.3))
            }
        )
    }
    
}
