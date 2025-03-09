import SwiftUI

// MARK: - View Extensions for Metallic Styling
extension View {
    func metallicTextField() -> some View {
        self
            .textFieldStyle(.plain)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Constants.Colors.surfaceMid)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                            .stroke(Constants.Gradients.metallicRim, lineWidth: Constants.Layout.borderWidth)
                    )
                    .shadow(
                        color: Constants.Shadows.insetShadow.color,
                        radius: Constants.Shadows.insetShadow.radius,
                        x: Constants.Shadows.insetShadow.x,
                        y: Constants.Shadows.insetShadow.y
                    )
            )
    }
    
    func metallicSegmentedStyle() -> some View {
        self
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Constants.Colors.surfaceMid)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                            .stroke(Constants.Gradients.metallicRim, lineWidth: Constants.Layout.borderWidth)
                    )
            )
    }
    
    func metallicPickerStyle() -> some View {
        self
            .pickerStyle(.wheel)
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Constants.Colors.surfaceMid)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                            .stroke(Constants.Gradients.metallicRim, lineWidth: Constants.Layout.borderWidth)
                    )
                    .shadow(
                        color: Constants.Shadows.insetShadow.color,
                        radius: Constants.Shadows.insetShadow.radius,
                        x: Constants.Shadows.insetShadow.x,
                        y: Constants.Shadows.insetShadow.y
                    )
            )
            .compositingGroup()
    }
    
    func addCornerRivets() -> some View {
        self.overlay(
            ZStack {
                // Top left rivet
                Circle()
                    .fill(Constants.Gradients.metallicButton)
                    .frame(width: 8, height: 8)
                    .offset(x: 4, y: 4)
                
                // Top right rivet
                Circle()
                    .fill(Constants.Gradients.metallicButton)
                    .frame(width: 8, height: 8)
                    .offset(x: -4, y: 4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                // Bottom left rivet
                Circle()
                    .fill(Constants.Gradients.metallicButton)
                    .frame(width: 8, height: 8)
                    .offset(x: 4, y: -4)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                
                // Bottom right rivet
                Circle()
                    .fill(Constants.Gradients.metallicButton)
                    .frame(width: 8, height: 8)
                    .offset(x: -4, y: -4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        )
    }
    
    func glassOverlay() -> some View {
        self.overlay(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.1),
                    Color.clear,
                    Color.black.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    func glassPanelEffect() -> some View {
        self.background(
            ZStack {
                // Dark glass background
                Constants.Colors.surfaceLight.opacity(0.7)
                
                // Subtle reflection
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.15),
                        Color.clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
    }
    
    // Extension to apply different corner radii to different corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// Shape for applying rounded corners to specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Haptic Feedback
extension UIImpactFeedbackGenerator {
    static func generateFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func generateSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    static func generateNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
} 