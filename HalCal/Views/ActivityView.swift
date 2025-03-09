//
//  ActivityView.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

// MARK: - Activity View
struct ActivityView: View {
    @ObservedObject var activityModel: ActivityModel
    @State private var showingAddStepsSheet = false
    
    var body: some View {
        ZStack {
            // Background with subtle texture
            backgroundLayer
            
            // Main content
            VStack(spacing: Constants.Layout.componentSpacing) {
                // Header
                ActivityHeaderView()
                
                // Separator
                separatorLine
                
                // Main content
                ScrollView {
                    VStack(spacing: Constants.Layout.componentSpacing) {
                        // Step tracking section
                        StepTrackingView(activityModel: activityModel)
                        
                        // Meal tracking section
                        MealTrackingView(activityModel: activityModel)
                        
                        // Active hours section
                        ActiveHoursView(activityModel: activityModel)
                    }
                    .padding(.horizontal, Constants.Layout.screenMargin)
                }
                
                Spacer()
                
                // Add steps button
                addStepsButton
            }
            .glassOverlay()
        }
        .sheet(isPresented: $showingAddStepsSheet) {
            AddStepsView(activityModel: activityModel)
        }
    }
    
    // MARK: - Background Layer
    private var backgroundLayer: some View {
        Constants.Colors.creamBackground
            .ignoresSafeArea()
            .overlay(
                // Subtle paper texture
                Image("paperTexture")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blendMode(.multiply)
                    .opacity(0.05)
                    .ignoresSafeArea()
            )
    }
    
    // MARK: - Separator Line
    private var separatorLine: some View {
        Rectangle()
            .fill(LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.1)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            ))
            .frame(height: Constants.Layout.borderWidth)
            .padding(.horizontal, Constants.Layout.screenMargin)
    }
    
    // MARK: - Add Steps Button
    private var addStepsButton: some View {
        SkeuomorphicButton(
            icon: "figure.walk",
            size: Constants.Layout.buttonMinSize * 1.8,
            color: Constants.Colors.blue
        ) {
            showingAddStepsSheet = true
        }
        .padding(.bottom, Constants.Layout.screenMargin * 2)
    }
}

// MARK: - Activity Header View
struct ActivityHeaderView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
            .fill(Constants.Gradients.metallicSurface)
            .frame(height: Constants.Layout.buttonMinSize + Constants.Layout.elementSpacing)
            .overlay(
                HStack {
                    Text("ACTIVITY TRACKER")
                        .font(Constants.Fonts.sectionHeader)
                        .foregroundColor(Constants.Colors.darkText)
                        .tracking(2)
                    
                    Spacer()
                    
                    // Date/time display
                    Text(formattedDateTime())
                        .font(Constants.Fonts.systemMessage)
                        .foregroundColor(Constants.Colors.darkText)
                        .padding(.horizontal, Constants.Layout.elementSpacing)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius / 2)
                                .fill(Constants.Colors.creamBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius / 2)
                                        .stroke(Color.black.opacity(0.1), lineWidth: Constants.Layout.borderWidth)
                                )
                        )
                }
                .padding(.horizontal, Constants.Layout.screenMargin)
            )
            .shadow(
                color: Constants.Shadows.panelShadow.color,
                radius: Constants.Shadows.panelShadow.radius,
                x: Constants.Shadows.panelShadow.x,
                y: Constants.Shadows.panelShadow.y
            )
            .padding(.horizontal, Constants.Layout.screenMargin)
            .padding(.top, Constants.Layout.screenMargin)
    }
    
    private func formattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: Date())
    }
}

// MARK: - Step Tracking View
struct StepTrackingView: View {
    @ObservedObject var activityModel: ActivityModel
    
    var body: some View {
        VStack(spacing: Constants.Layout.elementSpacing) {
            // Section header
            HStack {
                Text("STEP TRACKING")
                    .font(Constants.Fonts.primaryLabel)
                    .foregroundColor(Constants.Colors.darkText)
                    .tracking(1)
                
                Spacer()
                
                // Status indicator
                Circle()
                    .fill(Constants.Colors.blue)
                    .frame(width: Constants.Layout.statusLightDiameter, height: Constants.Layout.statusLightDiameter)
                    .shadow(color: Constants.Colors.blue.opacity(0.6), radius: 2, x: 0, y: 0)
            }
            
            // Step counter panel
            VStack(spacing: Constants.Layout.elementSpacing) {
                HStack {
                    Text("STEPS TODAY")
                        .font(Constants.Fonts.primaryLabel)
                        .foregroundColor(Constants.Colors.darkText)
                    
                    Spacer()
                    
                    Text("\(activityModel.steps)")
                        .font(Constants.Fonts.valueDisplay)
                        .foregroundColor(Constants.Colors.darkText)
                }
                
                // Progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius / 2)
                        .fill(Color.black.opacity(0.1))
                        .frame(height: Constants.Layout.progressBarHeight)
                    
                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius / 2)
                        .fill(Constants.Colors.blue)
                        .frame(width: max(CGFloat(activityModel.steps) / CGFloat(activityModel.goalSteps) * UIScreen.main.bounds.width * 0.8, 0), height: Constants.Layout.progressBarHeight)
                }
                
                HStack {
                    Text("GOAL")
                        .font(Constants.Fonts.primaryLabel)
                        .foregroundColor(Constants.Colors.darkText)
                    
                    Spacer()
                    
                    Text("\(activityModel.goalSteps)")
                        .font(Constants.Fonts.valueDisplay)
                        .foregroundColor(Constants.Colors.darkText)
                }
            }
            .padding(Constants.Layout.screenMargin)
            .panelStyle()
            .addCornerRivets()
        }
    }
}

// MARK: - Meal Tracking View
struct MealTrackingView: View {
    @ObservedObject var activityModel: ActivityModel
    
    var body: some View {
        VStack(spacing: Constants.Layout.elementSpacing) {
            // Section header
            HStack {
                Text("MEAL TRACKING")
                    .font(Constants.Fonts.primaryLabel)
                    .foregroundColor(Constants.Colors.darkText)
                    .tracking(1)
                
                Spacer()
                
                // Status indicator
                Circle()
                    .fill(Constants.Colors.amber)
                    .frame(width: Constants.Layout.statusLightDiameter, height: Constants.Layout.statusLightDiameter)
                    .shadow(color: Constants.Colors.amber.opacity(0.6), radius: 2, x: 0, y: 0)
            }
            
            // Meal tracking panel
            VStack(spacing: Constants.Layout.elementSpacing) {
                // Breakfast
                mealToggleButton(
                    title: "BREAKFAST",
                    isLogged: activityModel.mealLog["breakfast"] ?? false
                ) {
                    activityModel.mealLog["breakfast"] = !(activityModel.mealLog["breakfast"] ?? false)
                }
                
                // Lunch
                mealToggleButton(
                    title: "LUNCH",
                    isLogged: activityModel.mealLog["lunch"] ?? false
                ) {
                    activityModel.mealLog["lunch"] = !(activityModel.mealLog["lunch"] ?? false)
                }
                
                // Dinner
                mealToggleButton(
                    title: "DINNER",
                    isLogged: activityModel.mealLog["dinner"] ?? false
                ) {
                    activityModel.mealLog["dinner"] = !(activityModel.mealLog["dinner"] ?? false)
                }
                
                // Snacks
                mealToggleButton(
                    title: "SNACKS",
                    isLogged: activityModel.mealLog["snacks"] ?? false
                ) {
                    activityModel.mealLog["snacks"] = !(activityModel.mealLog["snacks"] ?? false)
                }
            }
            .padding(Constants.Layout.screenMargin)
            .panelStyle()
            .addCornerRivets()
        }
    }
    
    private func mealToggleButton(title: String, isLogged: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(Constants.Fonts.primaryLabel)
                    .foregroundColor(Constants.Colors.darkText)
                
                Spacer()
                
                // Status indicator
                ZStack {
                    Circle()
                        .fill(isLogged ? Constants.Colors.blue : Color.black.opacity(0.1))
                        .frame(width: Constants.Layout.indicatorSize, height: Constants.Layout.indicatorSize)
                    
                    if isLogged {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Active Hours View
struct ActiveHoursView: View {
    @ObservedObject var activityModel: ActivityModel
    
    var body: some View {
        VStack(spacing: Constants.Layout.elementSpacing) {
            // Section header
            HStack {
                Text("ACTIVE HOURS")
                    .font(Constants.Fonts.primaryLabel)
                    .foregroundColor(Constants.Colors.darkText)
                    .tracking(1)
                
                Spacer()
                
                // Status indicator
                Circle()
                    .fill(Constants.Colors.blue)
                    .frame(width: Constants.Layout.statusLightDiameter, height: Constants.Layout.statusLightDiameter)
                    .shadow(color: Constants.Colors.blue.opacity(0.6), radius: 2, x: 0, y: 0)
            }
            
            // Active hours panel
            HStack(spacing: Constants.Layout.componentSpacing) {
                ForEach(0..<12) { hour in
                    hourIndicator(hour: hour + 1, isActive: activityModel.activeHours > hour)
                }
            }
            .padding(Constants.Layout.screenMargin)
            .panelStyle()
            .addCornerRivets()
        }
    }
    
    private func hourIndicator(hour: Int, isActive: Bool) -> some View {
        VStack(spacing: Constants.Layout.elementSpacing / 2) {
            Circle()
                .fill(isActive ? Constants.Colors.blue : Color.black.opacity(0.1))
                .frame(width: Constants.Layout.indicatorSize, height: Constants.Layout.indicatorSize)
                .shadow(color: isActive ? Constants.Colors.blue.opacity(0.4) : Color.clear, radius: 2, x: 0, y: 0)
            
            Text("\(hour)")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(Constants.Colors.darkText)
        }
    }
}

// MARK: - Add Steps View
struct AddStepsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var activityModel: ActivityModel
    @State private var stepAmount: String = ""
    
    var body: some View {
        ZStack {
            // Background
            Constants.Colors.creamBackground
                .ignoresSafeArea()
            
            // Main panel with bevel
            VStack {
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Constants.Colors.creamBackground)
                    .shadow(
                        color: Constants.Shadows.panelShadow.color,
                        radius: Constants.Shadows.panelShadow.radius,
                        x: Constants.Shadows.panelShadow.x,
                        y: Constants.Shadows.panelShadow.y
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                            .stroke(Constants.Gradients.metallicRim, lineWidth: Constants.Layout.borderWidth)
                    )
                    .overlay(
                        // Content
                        VStack(spacing: Constants.Layout.componentSpacing) {
                            // Header
                            Text("ADD STEPS")
                                .font(Constants.Fonts.sectionHeader)
                                .foregroundColor(Constants.Colors.darkText)
                                .tracking(2)
                                .padding(.top, Constants.Layout.screenMargin)
                            
                            // Display panel
                            ZStack {
                                // Panel background
                                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                    .fill(Color.white)
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
                                Text(stepAmount.isEmpty ? "0" : stepAmount)
                                    .font(Constants.Fonts.valueDisplay)
                                    .foregroundColor(Constants.Colors.blue)
                                    .shadow(color: Constants.Colors.blue.opacity(0.4), radius: 1, x: 0, y: 0)
                                    .padding()
                            }
                            .frame(height: Constants.Layout.buttonMinSize * 1.5)
                            .padding(.horizontal, Constants.Layout.screenMargin)
                            
                            // Custom keypad
                            KeypadView(value: $stepAmount)
                            
                            // Action buttons
                            HStack(spacing: Constants.Layout.elementSpacing) {
                                // Cancel button
                                Button {
                                    dismiss()
                                } label: {
                                    Text("CANCEL")
                                        .font(Constants.Fonts.primaryLabel)
                                        .foregroundColor(Constants.Colors.darkText)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                                .fill(Constants.Gradients.metallicSurface)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                                        .stroke(Constants.Colors.alertRed, lineWidth: Constants.Layout.borderWidth)
                                                )
                                                .shadow(
                                                    color: Constants.Shadows.buttonShadow.color,
                                                    radius: Constants.Shadows.buttonShadow.radius,
                                                    x: Constants.Shadows.buttonShadow.x,
                                                    y: Constants.Shadows.buttonShadow.y
                                                )
                                        )
                                }
                                
                                // Add button
                                Button {
                                    if let steps = Int(stepAmount), steps > 0 {
                                        activityModel.addSteps(steps)
                                        activityModel.saveData()
                                        dismiss()
                                    }
                                } label: {
                                    Text("ADD")
                                        .font(Constants.Fonts.primaryLabel)
                                        .foregroundColor(Constants.Colors.darkText)
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
                                .disabled(stepAmount.isEmpty || Int(stepAmount) == 0)
                                .opacity(stepAmount.isEmpty || Int(stepAmount) == 0 ? 0.5 : 1.0)
                            }
                            .padding(.horizontal, Constants.Layout.screenMargin)
                            .padding(.bottom, Constants.Layout.screenMargin)
                        }
                    )
            }
            .padding(Constants.Layout.screenMargin)
            .glassOverlay()
        }
    }
}

// MARK: - Keypad View
struct KeypadView: View {
    @Binding var value: String
    
    var body: some View {
        VStack(spacing: Constants.Layout.elementSpacing) {
            HStack(spacing: Constants.Layout.elementSpacing) {
                keypadButton("1")
                keypadButton("2")
                keypadButton("3")
            }
            
            HStack(spacing: Constants.Layout.elementSpacing) {
                keypadButton("4")
                keypadButton("5")
                keypadButton("6")
            }
            
            HStack(spacing: Constants.Layout.elementSpacing) {
                keypadButton("7")
                keypadButton("8")
                keypadButton("9")
            }
            
            HStack(spacing: Constants.Layout.elementSpacing) {
                keypadButton("C", color: Constants.Colors.alertRed)
                keypadButton("0")
                keypadButton("⌫", color: Constants.Colors.blue)
            }
        }
        .padding(.horizontal, Constants.Layout.screenMargin)
    }
    
    private func keypadButton(_ buttonValue: String, color: Color = Constants.Colors.darkText) -> some View {
        Button {
            handleKeypadInput(buttonValue)
        } label: {
            Text(buttonValue)
                .font(Constants.Fonts.valueDisplay)
                .foregroundColor(color)
                .frame(width: Constants.Layout.buttonMinSize, height: Constants.Layout.buttonMinSize)
                .background(
                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius / 2)
                        .fill(Constants.Gradients.metallicSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius / 2)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.5),
                                            Color.white.opacity(0.2),
                                            Color.black.opacity(0.1),
                                            Color.black.opacity(0.2)
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
    }
    
    private func handleKeypadInput(_ buttonValue: String) {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        switch buttonValue {
        case "C":
            value = ""
        case "⌫":
            if !value.isEmpty {
                value.removeLast()
            }
        default:
            // Limit to 5 digits
            if value.count < 5 {
                value += buttonValue
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ActivityView(activityModel: ActivityModel())
} 