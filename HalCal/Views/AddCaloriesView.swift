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
    
    // Title text for header
    var headerText: String {
        switch self {
        case .calories: return "ADD CALORIES"
        case .protein: return "ADD PROTEIN"
        case .carbs: return "ADD CARBS"
        case .fat: return "ADD FAT"
        }
    }
}

struct AddCaloriesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var calorieModel: CalorieModel
    
    // Current input state
    @State private var currentInputMode: InputMode = .calories
    @State private var selectedMealType: MealType = .snack
    @State private var currentValue: String = ""
    
    // Track accumulated values for all nutrients in this session
    @State private var caloriesValue: Int = 0
    @State private var proteinValue: Double = 0.0
    @State private var carbsValue: Double = 0.0
    @State private var fatValue: Double = 0.0
    
    // Constants
    private let keypadButtonSize: CGFloat = 70
    private let selectorHeight: CGFloat = 54
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text(currentInputMode.headerText)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Value display
            HStack {
                Spacer()
                Text("\(currentValue.isEmpty ? "0" : currentValue) \(currentInputMode.unit)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(currentInputMode.color)
                    .animation(.easeInOut, value: currentInputMode)
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal, 24)
            }
            
            // Already added values display
            HStack(spacing: 12) {
                if caloriesValue > 0 {
                    ValueBadge(value: "\(caloriesValue)kcal", color: Constants.Colors.calorieOrange)
                }
                if proteinValue > 0 {
                    ValueBadge(value: "\(Int(proteinValue))g P", color: Constants.Colors.turquoise)
                }
                if carbsValue > 0 {
                    ValueBadge(value: "\(Int(carbsValue))g C", color: Color.purple)
                }
                if fatValue > 0 {
                    ValueBadge(value: "\(Int(fatValue))g F", color: Color.yellow)
                }
                
                if caloriesValue == 0 && proteinValue == 0 && carbsValue == 0 && fatValue == 0 {
                    Text("No nutrients added yet")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .frame(height: 30)
            
            // Meal type selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MealType.allCases) { mealType in
                        Button(action: {
                            selectedMealType = mealType
                        }) {
                            Text(mealType.rawValue)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(selectedMealType == mealType ? .white : .gray)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 20)
                                .background(
                                    selectedMealType == mealType ?
                                    currentInputMode.color :
                                    Constants.Colors.cardBackground
                                )
                                .cornerRadius(Constants.Layout.cornerRadius)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .frame(height: selectorHeight)
            
            // Macro input mode selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    MacroButton(
                        title: "Calories",
                        isSelected: currentInputMode == .calories,
                        color: Constants.Colors.calorieOrange
                    ) {
                        // Save current value before switching
                        saveCurrentValue()
                        currentInputMode = .calories
                    }
                    
                    MacroButton(
                        title: "Protein",
                        isSelected: currentInputMode == .protein,
                        color: Constants.Colors.turquoise
                    ) {
                        // Save current value before switching
                        saveCurrentValue()
                        currentInputMode = .protein
                    }
                    
                    MacroButton(
                        title: "Carbs",
                        isSelected: currentInputMode == .carbs,
                        color: Color.purple
                    ) {
                        // Save current value before switching
                        saveCurrentValue()
                        currentInputMode = .carbs
                    }
                    
                    MacroButton(
                        title: "Fat",
                        isSelected: currentInputMode == .fat,
                        color: Color.yellow
                    ) {
                        // Save current value before switching
                        saveCurrentValue()
                        currentInputMode = .fat
                    }
                }
                .padding(.horizontal, 24)
            }
            .frame(height: selectorHeight)
            
            // Numeric keypad
            VStack(spacing: 8) {
                ForEach(0..<3) { row in
                    HStack(spacing: 8) {
                        ForEach(1..<4) { col in
                            let number = row * 3 + col
                            KeypadButton(text: "\(number)") {
                                addDigit(String(number))
                            }
                            .frame(width: keypadButtonSize, height: keypadButtonSize)
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    KeypadButton(text: "0") {
                        addDigit("0")
                    }
                    .frame(width: keypadButtonSize, height: keypadButtonSize)
                    
                    KeypadButton(text: ".") {
                        if !currentValue.contains(".") && currentValue.count > 0 {
                            currentValue += "."
                        }
                    }
                    .frame(width: keypadButtonSize, height: keypadButtonSize)
                    
                    KeypadButton(text: "⌫") {
                        if !currentValue.isEmpty {
                            currentValue.removeLast()
                        }
                    }
                    .frame(width: keypadButtonSize, height: keypadButtonSize)
                }
            }
            .padding(.horizontal, 24)
            
            // Button row
            HStack(spacing: 16) {
                Button(action: {
                    // Cancel without adding
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(Constants.Layout.cornerRadius)
                }
                
                Button(action: {
                    // Save current input before finishing
                    saveCurrentValue()
                    
                    // Add all tracked nutrients to the model
                    var anythingAdded = false
                    
                    if caloriesValue > 0 {
                        calorieModel.addCalories(amount: caloriesValue, mealType: selectedMealType)
                        anythingAdded = true
                    }
                    
                    if proteinValue > 0 || carbsValue > 0 || fatValue > 0 {
                        calorieModel.addMacros(
                            protein: proteinValue,
                            carbs: carbsValue,
                            fat: fatValue,
                            mealType: selectedMealType
                        )
                        anythingAdded = true
                    }
                    
                    if anythingAdded {
                        // Provide haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                    
                    dismiss()
                }) {
                    Text("Add")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            (caloriesValue > 0 || proteinValue > 0 || carbsValue > 0 || fatValue > 0 || !currentValue.isEmpty) ?
                            currentInputMode.color :
                            currentInputMode.color.opacity(0.3)
                        )
                        .cornerRadius(Constants.Layout.cornerRadius)
                }
                .disabled(caloriesValue == 0 && proteinValue == 0 && carbsValue == 0 && fatValue == 0 && currentValue.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Constants.Colors.background)
        .onAppear {
            // Load values from persisted storage in a real app
        }
    }
    
    // Add a digit to the current value
    private func addDigit(_ digit: String) {
        // Limit digits for usability
        if currentValue.count < 6 {
            currentValue += digit
        }
    }
    
    // Save the current value to the appropriate nutrient tracker
    private func saveCurrentValue() {
        guard !currentValue.isEmpty else { return }
        
        switch currentInputMode {
        case .calories:
            if let value = Int(currentValue) {
                caloriesValue += value
            }
        case .protein:
            if let value = Double(currentValue) {
                proteinValue += value
            }
        case .carbs:
            if let value = Double(currentValue) {
                carbsValue += value
            }
        case .fat:
            if let value = Double(currentValue) {
                fatValue += value
            }
        }
        
        // Clear the current value for the next input
        currentValue = ""
    }
}

// Badge to show added values
struct ValueBadge: View {
    let value: String
    let color: Color
    
    var body: some View {
        Text(value)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

// Button for selecting macro input type
struct MacroButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .background(isSelected ? color : Constants.Colors.surfaceLight.opacity(0.3))
                .cornerRadius(Constants.Layout.cornerRadius)
        }
    }
}

// Keypad button component
struct KeypadButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
        }
    }
}

#Preview {
    AddCaloriesView(calorieModel: CalorieModel())
} 