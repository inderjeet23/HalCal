import SwiftUI

class MotionManager {
    static let shared = MotionManager()
    
    private init() {}
    
    // MARK: - Animation Parameters
    
    // Button animations
    let buttonPressAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
    let buttonScaleEffect: CGFloat = 0.96
    let buttonPressOffset: CGFloat = 2
    
    // View transitions
    let viewTransitionDuration: Double = 0.5
    let viewTransitionDamping: Double = 0.88
    
    // Tab switching
    let tabSwitchDuration: Double = 0.3
    let tabScaleEffect: CGFloat = 1.05
    
    // State changes
    let stateChangeDuration: Double = 0.2
    
    // MARK: - Animation Presets
    
    // Standard button press animation
    func buttonPressAnimationValue(isPressed: Bool) -> AnyView {
        AnyView(
            EmptyView()
                .modifier(ButtonPressAnimationModifier(isPressed: isPressed))
        )
    }
}

// MARK: - Custom Modifiers

struct ButtonPressAnimationModifier: ViewModifier {
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? MotionManager.shared.buttonScaleEffect : 1.0)
            .offset(y: isPressed ? MotionManager.shared.buttonPressOffset : 0)
            .animation(MotionManager.shared.buttonPressAnimation, value: isPressed)
    }
}

extension View {
    func buttonPressAnimation(isPressed: Bool) -> some View {
        self.modifier(ButtonPressAnimationModifier(isPressed: isPressed))
    }
    
    func standardButtonStyle() -> some View {
        self.buttonStyle(StandardButtonStyle())
    }
}

// MARK: - Custom Button Styles

struct StandardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? MotionManager.shared.buttonScaleEffect : 1.0)
            .offset(y: configuration.isPressed ? MotionManager.shared.buttonPressOffset : 0)
            .animation(MotionManager.shared.buttonPressAnimation, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    HapticManager.shared.impact(style: .medium)
                }
            }
    }
}

struct SkeuomorphicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? MotionManager.shared.buttonScaleEffect : 1.0)
            .offset(y: configuration.isPressed ? MotionManager.shared.buttonPressOffset : 0)
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.1 : 0.2), 
                    radius: configuration.isPressed ? 2 : 4, 
                    x: 0, 
                    y: configuration.isPressed ? 1 : 2)
            .animation(MotionManager.shared.buttonPressAnimation, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    HapticManager.shared.impact(style: .medium)
                }
            }
    }
} 