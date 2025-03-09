//
//  SkeuomorphicButton.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

struct SkeuomorphicButton: View {
    var icon: String
    var size: CGFloat
    var color: Color
    var action: () -> Void
    @State private var isPressed = false
    @GestureState private var isPressing = false
    
    var body: some View {
        ZStack {
            // Button shadow (visible when not pressed)
            Circle()
                .fill(Color.black.opacity(0.5))
                .blur(radius: 4)
                .offset(x: 0, y: 3)
                .scaleEffect(0.95)
                .opacity(isPressed || isPressing ? 0.0 : 1.0)
            
            // Button base
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Constants.Colors.metallicLight,
                        Constants.Colors.metallicMid,
                        Constants.Colors.metallicDark
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1),
                                    Color.black.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .scaleEffect(isPressed || isPressing ? MotionManager.shared.buttonScaleEffect : 1.0)
                .shadow(
                    color: Color.black.opacity(isPressed || isPressing ? 0.2 : 0.5),
                    radius: isPressed || isPressing ? 2 : 4,
                    x: 0,
                    y: isPressed || isPressing ? 1 : 3
                )
                .offset(x: 0, y: isPressed || isPressing ? MotionManager.shared.buttonPressOffset : 0)
            
            // Icon with color
            Image(systemName: icon)
                .font(.system(size: size/3, weight: .bold))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.6), radius: 2, x: 0, y: 0)
                .offset(x: 0, y: isPressed || isPressing ? MotionManager.shared.buttonPressOffset : 0)
        }
        .frame(width: size, height: size)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressing) { _, state, _ in
                    state = true
                }
                .onEnded { _ in
                    // Trigger haptic feedback
                    HapticManager.shared.impact(style: .medium)
                    
                    // Animate press and release
                    withAnimation(MotionManager.shared.buttonPressAnimation) {
                        isPressed = true
                    }
                    
                    // Perform the action
                    action()
                    
                    // Return to unpressed state with delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(MotionManager.shared.buttonPressAnimation) {
                            isPressed = false
                        }
                    }
                }
        )
        .onChange(of: isPressing) { oldValue, newValue in
            if newValue && !oldValue {
                // Provide immediate haptic feedback on press down
                HapticManager.shared.impact(style: .light)
            }
        }
    }
}

// MARK: - Preview
#Preview("Skeuomorphic Button") {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()
        
        VStack(spacing: 30) {
            SkeuomorphicButton(
                icon: "plus",
                size: 80,
                color: Constants.Colors.blue
            ) {
                print("Button tapped")
            }
            
            SkeuomorphicButton(
                icon: "drop.fill",
                size: 60,
                color: Constants.Colors.amber
            ) {
                print("Button tapped")
            }
        }
    }
} 