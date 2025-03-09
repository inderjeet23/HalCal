import SwiftUI
import UIKit

struct AddMacrosView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var calorieModel: CalorieModel
    
    @State private var proteinAmount: String = ""
    @State private var carbsAmount: String = ""
    @State private var fatAmount: String = ""
    @State private var currentField: MacroField = .protein
    @State private var keypadButtonStates: [String: Bool] = [:]
    
    // Create a custom transition manager
    private let transitionManager = CustomTransitionManager()
    
    enum MacroField {
        case protein, carbs, fat
    }
    
    // Computed property to calculate calories from entered macros
    private var calculatedCalories: Int {
        let protein = Double(proteinAmount) ?? 0
        let carbs = Double(carbsAmount) ?? 0
        let fat = Double(fatAmount) ?? 0
        
        return Int(protein * 4 + carbs * 4 + fat * 9)
    }
    
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
                    
                    Text("ADD MACROS")
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
                
                // Macro input fields - larger and more prominent
                VStack(spacing: Constants.Layout.elementSpacing * 1.5) {
                    // Protein
                    macroInputField(
                        label: "PROTEIN",
                        value: $proteinAmount,
                        color: Constants.Colors.blue,
                        isSelected: currentField == .protein
                    ) {
                        HapticManager.shared.selection()
                        currentField = .protein
                    }
                    
                    // Carbs
                    macroInputField(
                        label: "CARBS",
                        value: $carbsAmount,
                        color: Constants.Colors.amber,
                        isSelected: currentField == .carbs
                    ) {
                        HapticManager.shared.selection()
                        currentField = .carbs
                    }
                    
                    // Fat
                    macroInputField(
                        label: "FAT",
                        value: $fatAmount,
                        color: Color(red: 0.2, green: 0.8, blue: 0.2),
                        isSelected: currentField == .fat
                    ) {
                        HapticManager.shared.selection()
                        currentField = .fat
                    }
                    
                    // Calories display
                    HStack {
                        Text("CALORIES")
                            .font(Constants.Fonts.primaryLabel)
                            .foregroundColor(Constants.Colors.primaryText)
                        
                        Spacer()
                        
                        Text("\(calculatedCalories)")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(Constants.Colors.amber)
                            .shadow(color: Constants.Colors.amber.opacity(0.4), radius: 1, x: 0, y: 0)
                    }
                    .padding(.vertical, Constants.Layout.elementSpacing)
                    .padding(.horizontal, Constants.Layout.elementSpacing * 2)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                            .fill(Constants.Colors.surfaceMid)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                    .stroke(Constants.Gradients.metallicRim, lineWidth: Constants.Layout.borderWidth)
                            )
                    )
                }
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
                    let protein = Double(proteinAmount) ?? 0
                    let carbs = Double(carbsAmount) ?? 0
                    let fat = Double(fatAmount) ?? 0
                    
                    if protein > 0 || carbs > 0 || fat > 0 {
                        HapticManager.shared.notification(type: .success)
                        calorieModel.addMacros(protein: protein, carbs: carbs, fat: fat)
                        calorieModel.saveData()
                        dismiss()
                    }
                } label: {
                    Text("ADD MACROS (\(calculatedCalories) CALORIES)")
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
                .disabled(calculatedCalories == 0)
                .opacity(calculatedCalories == 0 ? 0.5 : 1.0)
                .padding(.horizontal, Constants.Layout.screenMargin)
                .padding(.bottom, Constants.Layout.screenMargin * 2)
            }
        }
        // Apply custom transition
        .background(HostingControllerConfigurator(transitionManager: transitionManager))
    }
    
    private func macroInputField(label: String, value: Binding<String>, color: Color, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(label)
                .font(Constants.Fonts.primaryLabel)
                .foregroundColor(Constants.Colors.primaryText)
                .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            Text("\(value.wrappedValue.isEmpty ? "0" : value.wrappedValue)g")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .padding(.horizontal, Constants.Layout.elementSpacing * 2)
                .padding(.vertical, Constants.Layout.elementSpacing)
                .background(
                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                        .fill(isSelected ? color.opacity(0.1) : Constants.Colors.surfaceMid)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                .stroke(
                                    isSelected ? 
                                    LinearGradient(
                                        gradient: Gradient(colors: [color.opacity(0.8), color]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) : 
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.2),
                                            Color.white.opacity(0.1),
                                            Color.black.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: Constants.Layout.borderWidth
                                )
                        )
                )
                .animation(.easeInOut(duration: MotionManager.shared.stateChangeDuration), value: isSelected)
        }
        .padding(.vertical, Constants.Layout.elementSpacing)
        .padding(.horizontal, Constants.Layout.elementSpacing * 2)
        .background(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .fill(Constants.Colors.surfaceLight)
                .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private func keypadButton(_ value: String, color: Color = Constants.Colors.primaryText) -> some View {
        let isPressed = Binding(
            get: { keypadButtonStates[value] ?? false },
            set: { keypadButtonStates[value] = $0 }
        )
        
        return Button {
            handleKeypadInput(value, for: currentField)
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
    
    private func handleKeypadInput(_ value: String, for field: MacroField) {
        // Haptic feedback
        HapticManager.shared.impact(style: .light)
        
        var currentValue: Binding<String>
        
        switch field {
        case .protein:
            currentValue = $proteinAmount
        case .carbs:
            currentValue = $carbsAmount
        case .fat:
            currentValue = $fatAmount
        }
        
        switch value {
        case "C":
            currentValue.wrappedValue = ""
        case "⌫":
            if !currentValue.wrappedValue.isEmpty {
                currentValue.wrappedValue.removeLast()
            }
        default:
            // Limit to 3 digits
            if currentValue.wrappedValue.count < 3 {
                currentValue.wrappedValue += value
            }
        }
    }
}

#Preview {
    AddMacrosView(calorieModel: CalorieModel())
} 