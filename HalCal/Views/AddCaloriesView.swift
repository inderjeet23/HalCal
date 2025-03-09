//
//  AddCaloriesView.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI
import UIKit

struct AddCaloriesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var calorieModel: CalorieModel
    @State private var calorieAmount: String = ""
    @State private var keypadButtonStates: [String: Bool] = [:]
    
    // Create a custom transition manager
    private let transitionManager = CustomTransitionManager()
    
    var body: some View {
        ZStack {
            // Background
            Constants.Colors.background
                .ignoresSafeArea()
                .overlay(
                    // Subtle noise texture
                    Image("noiseTexture")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .blendMode(.overlay)
                        .opacity(0.03)
                        .ignoresSafeArea()
                )
            
            // Main content
            VStack(spacing: Constants.Layout.componentSpacing * 1.5) {
                // Header with close button
                HStack {
                    Button {
                        HapticManager.shared.impact(style: .medium)
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Constants.Colors.primaryText)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Constants.Colors.surfaceLight)
                                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(SkeuomorphicButtonStyle())
                    
                    Spacer()
                    
                    Text("ADD CALORIES")
                        .font(Constants.Fonts.sectionHeader)
                        .foregroundColor(Constants.Colors.primaryText)
                        .tracking(2)
                    
                    Spacer()
                    
                    // Invisible element for balance
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, Constants.Layout.screenMargin)
                .padding(.top, Constants.Layout.screenMargin)
                
                // Display panel
                ZStack {
                    // Panel background
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
                    
                    // Display text
                    Text(calorieAmount.isEmpty ? "0" : calorieAmount)
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundColor(Constants.Colors.amber)
                        .shadow(color: Constants.Colors.amber.opacity(0.6), radius: 2, x: 0, y: 0)
                        .padding()
                }
                .frame(height: 100)
                .padding(.horizontal, Constants.Layout.screenMargin)
                
                // Large keypad
                VStack(spacing: Constants.Layout.componentSpacing) {
                    HStack(spacing: Constants.Layout.componentSpacing) {
                        keypadButton("1")
                        keypadButton("2")
                        keypadButton("3")
                    }
                    
                    HStack(spacing: Constants.Layout.componentSpacing) {
                        keypadButton("4")
                        keypadButton("5")
                        keypadButton("6")
                    }
                    
                    HStack(spacing: Constants.Layout.componentSpacing) {
                        keypadButton("7")
                        keypadButton("8")
                        keypadButton("9")
                    }
                    
                    HStack(spacing: Constants.Layout.componentSpacing) {
                        keypadButton("C", color: Constants.Colors.alertRed)
                        keypadButton("0")
                        keypadButton("⌫", color: Constants.Colors.blue)
                    }
                }
                .padding(.horizontal, Constants.Layout.screenMargin)
                
                Spacer()
                
                // Add button - large and prominent at bottom
                Button {
                    if let calories = Int(calorieAmount), calories > 0 {
                        HapticManager.shared.notification(type: .success)
                        calorieModel.addCalories(calories)
                        calorieModel.saveData()
                        dismiss()
                    }
                } label: {
                    Text("ADD \(calorieAmount.isEmpty ? "0" : calorieAmount) CALORIES")
                        .font(Constants.Fonts.primaryLabel)
                        .foregroundColor(Constants.Colors.primaryText)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                .fill(Constants.Gradients.metallicSurface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                        .stroke(Constants.Colors.blue, lineWidth: Constants.Layout.borderWidth)
                                )
                                .shadow(
                                    color: Constants.Shadows.buttonShadow.color,
                                    radius: Constants.Shadows.buttonShadow.radius,
                                    x: Constants.Shadows.buttonShadow.x,
                                    y: Constants.Shadows.buttonShadow.y
                                )
                        )
                }
                .buttonStyle(SkeuomorphicButtonStyle())
                .disabled(calorieAmount.isEmpty || Int(calorieAmount) == 0)
                .opacity(calorieAmount.isEmpty || Int(calorieAmount) == 0 ? 0.5 : 1.0)
                .padding(.horizontal, Constants.Layout.screenMargin)
                .padding(.bottom, Constants.Layout.screenMargin * 2)
            }
        }
        // Apply custom transition
        .background(HostingControllerConfigurator(transitionManager: transitionManager))
    }
    
    private func keypadButton(_ value: String, color: Color = Constants.Colors.primaryText) -> some View {
        let isPressed = Binding(
            get: { keypadButtonStates[value] ?? false },
            set: { keypadButtonStates[value] = $0 }
        )
        
        return Button {
            handleKeypadInput(value)
        } label: {
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .aspectRatio(1.0, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                        .fill(Constants.Gradients.metallicSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.4),
                                            Color.white.opacity(0.2),
                                            Color.black.opacity(0.2),
                                            Color.black.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: Constants.Layout.borderWidth / 2
                                )
                        )
                        .shadow(
                            color: Constants.Shadows.buttonShadow.color,
                            radius: Constants.Shadows.buttonShadow.radius,
                            x: Constants.Shadows.buttonShadow.x,
                            y: Constants.Shadows.buttonShadow.y
                        )
                )
        }
        .buttonPressAnimation(isPressed: isPressed.wrappedValue)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed.wrappedValue = pressing
        }, perform: {})
    }
    
    private func handleKeypadInput(_ value: String) {
        // Haptic feedback
        HapticManager.shared.impact(style: .light)
        
        switch value {
        case "C":
            calorieAmount = ""
        case "⌫":
            if !calorieAmount.isEmpty {
                calorieAmount.removeLast()
            }
        default:
            // Limit to 5 digits
            if calorieAmount.count < 5 {
                calorieAmount += value
            }
        }
    }
}

#Preview {
    AddCaloriesView(calorieModel: CalorieModel())
} 