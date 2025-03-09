//
//  AddCaloriesView.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI
import UIKit

enum MealType: String, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var id: String { self.rawValue }
}

enum InputMode: String, CaseIterable, Identifiable {
    case calories = "Calories"
    case protein = "Protein"
    case carbs = "Carbs"
    case fat = "Fat"
    
    var id: String { self.rawValue }
    
    var shortLabel: String {
        switch self {
        case .calories: return "Cal"
        case .protein: return "P"
        case .carbs: return "C"
        case .fat: return "F"
        }
    }
    
    var unit: String {
        return self == .calories ? "" : "g"
    }
    
    var color: Color {
        switch self {
        case .calories: return Constants.Colors.calorieOrange
        case .protein, .carbs, .fat: return Constants.Colors.turquoise
        }
    }
}

struct AddCaloriesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var calorieModel: CalorieModel
    @State private var calorieAmount: String = ""
    @State private var proteinAmount: String = ""
    @State private var carbsAmount: String = ""
    @State private var fatAmount: String = ""
    @State private var keypadButtonStates: [String: Bool] = [:]
    @State private var selectedMealType: MealType = .breakfast
    @State private var showMacros: Bool = true
    @State private var currentInputMode: InputMode = .calories
    
    // Mock data for already logged meals - replace with actual data later
    private let loggedMeals: Set<MealType> = [.breakfast, .lunch]
    
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
            VStack(spacing: Constants.Layout.componentSpacing) {
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
                
                // Meal type selector
                mealTypeSelector()
                    .padding(.horizontal, Constants.Layout.screenMargin)
                
                // Macro mode selector
                macroTabSelector()
                    .padding(.horizontal, Constants.Layout.screenMargin)
                    .padding(.top, 8)
                
                // Display panel
                displayPanel()
                    .padding(.horizontal, Constants.Layout.screenMargin)
                
                Spacer(minLength: 30) // Push keypad down
                
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
                        calorieModel.addCalories(calories) // This should be updated to include meal type and macros
                        calorieModel.saveData()
                        dismiss()
                    }
                } label: {
                    Text(addButtonText)
                        .font(Constants.Fonts.primaryLabel)
                        .foregroundColor(Constants.Colors.primaryText)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                .fill(Constants.Gradients.metallicSurface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                        .stroke(currentInputMode.color, lineWidth: Constants.Layout.borderWidth)
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
                .disabled(isButtonDisabled)
                .opacity(isButtonDisabled ? 0.5 : 1.0)
                .padding(.horizontal, Constants.Layout.screenMargin)
                .padding(.bottom, Constants.Layout.screenMargin * 2)
            }
        }
        // Apply custom transition
        .background(HostingControllerConfigurator(transitionManager: transitionManager))
    }
    
    // Meal type selector component
    private func mealTypeSelector() -> some View {
        HStack(spacing: 4) {
            ForEach(MealType.allCases) { mealType in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMealType = mealType
                    }
                    HapticManager.shared.impact(style: .light)
                }) {
                    VStack(spacing: 4) {
                        // Indicator for logged meals
                        if loggedMeals.contains(mealType) {
                            Circle()
                                .fill(Constants.Colors.calorieOrange)
                                .frame(width: 8, height: 8)
                        } else {
                            Spacer()
                                .frame(height: 8)
                        }
                        
                        Text(mealType.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedMealType == mealType ? .white : Color.gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(selectedMealType == mealType ? Constants.Colors.calorieOrange : Constants.Colors.surfaceLight)
                    .cornerRadius(Constants.Layout.cornerRadius)
                }
            }
        }
        .frame(height: 46)
    }
    
    // Macro tab selector
    private func macroTabSelector() -> some View {
        HStack(spacing: 4) {
            ForEach(InputMode.allCases) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentInputMode = mode
                    }
                    HapticManager.shared.impact(style: .light)
                }) {
                    HStack(spacing: 4) {
                        Text(mode.shortLabel)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(currentInputMode == mode ? .white : Color.gray)
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(currentInputMode == mode ? mode.color : Constants.Colors.surfaceLight)
                    .cornerRadius(Constants.Layout.cornerRadius)
                }
            }
        }
        .frame(height: 40)
    }
    
    // Display panel
    private func displayPanel() -> some View {
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
            
            // Display text based on current input mode
            HStack(alignment: .center) {
                Spacer()
                
                let value = valueForMode(currentInputMode)
                Text(value.isEmpty ? "0" : value)
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(currentInputMode.color)
                    .shadow(color: currentInputMode.color.opacity(0.6), radius: 2, x: 0, y: 0)
                
                if currentInputMode != .calories {
                    Text(currentInputMode.unit)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(currentInputMode.color.opacity(0.8))
                        .offset(y: 8)
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(height: 100)
    }
    
    // Helper to get current value based on input mode
    private func valueForMode(_ mode: InputMode) -> String {
        switch mode {
        case .calories: return calorieAmount
        case .protein: return proteinAmount
        case .carbs: return carbsAmount
        case .fat: return fatAmount
        }
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
                        .fill(Constants.Colors.surfaceLight)
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
            clearCurrentInput()
        case "⌫":
            removeLastDigitFromCurrentInput()
        default:
            addDigitToCurrentInput(value)
        }
    }
    
    private func clearCurrentInput() {
        switch currentInputMode {
        case .calories:
            calorieAmount = ""
        case .protein:
            proteinAmount = ""
        case .carbs:
            carbsAmount = ""
        case .fat:
            fatAmount = ""
        }
    }
    
    private func removeLastDigitFromCurrentInput() {
        switch currentInputMode {
        case .calories:
            if !calorieAmount.isEmpty {
                calorieAmount.removeLast()
            }
        case .protein:
            if !proteinAmount.isEmpty {
                proteinAmount.removeLast()
            }
        case .carbs:
            if !carbsAmount.isEmpty {
                carbsAmount.removeLast()
            }
        case .fat:
            if !fatAmount.isEmpty {
                fatAmount.removeLast()
            }
        }
    }
    
    private func addDigitToCurrentInput(_ digit: String) {
        let maxDigits = 3 // Limit to 3 digits for macros, 5 for calories
        
        switch currentInputMode {
        case .calories:
            if calorieAmount.count < 5 {
                calorieAmount += digit
            }
        case .protein:
            if proteinAmount.count < maxDigits {
                proteinAmount += digit
            }
        case .carbs:
            if carbsAmount.count < maxDigits {
                carbsAmount += digit
            }
        case .fat:
            if fatAmount.count < maxDigits {
                fatAmount += digit
            }
        }
    }
    
    // Computed properties
    private var addButtonText: String {
        switch currentInputMode {
        case .calories:
            return "ADD \(calorieAmount.isEmpty ? "0" : calorieAmount) CALORIES TO \(selectedMealType.rawValue.uppercased())"
        case .protein:
            return "ADD \(proteinAmount.isEmpty ? "0" : proteinAmount)g PROTEIN TO \(selectedMealType.rawValue.uppercased())"
        case .carbs:
            return "ADD \(carbsAmount.isEmpty ? "0" : carbsAmount)g CARBS TO \(selectedMealType.rawValue.uppercased())"
        case .fat:
            return "ADD \(fatAmount.isEmpty ? "0" : fatAmount)g FAT TO \(selectedMealType.rawValue.uppercased())"
        }
    }
    
    private var isButtonDisabled: Bool {
        switch currentInputMode {
        case .calories:
            return calorieAmount.isEmpty || Int(calorieAmount) == 0
        case .protein:
            return proteinAmount.isEmpty || Int(proteinAmount) == 0
        case .carbs:
            return carbsAmount.isEmpty || Int(carbsAmount) == 0
        case .fat:
            return fatAmount.isEmpty || Int(fatAmount) == 0
        }
    }
}

#Preview {
    AddCaloriesView(calorieModel: CalorieModel())
} 