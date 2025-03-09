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
    @ObservedObject var calorieModel = CalorieModel()
    @State private var showingAddStepsSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Date navigation header
                HStack {
                    Button {
                        // Previous day
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(8)
                    }
                    
                    Spacer()
                    
                    Text("Sunday, Mar 9")
                        .font(Constants.Fonts.primaryLabel)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        // Next day
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .padding(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Activity rings or summary section
                VStack(spacing: 16) {
                    Text("Today's Activity")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Activity metrics grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        activityMetricCard(
                            title: "Steps",
                            value: activityModel.steps,
                            goal: activityModel.dailyStepGoal,
                            unit: "",
                            progress: activityModel.stepProgress,
                            color: .blue
                        )
                        
                        activityMetricCard(
                            title: "Exercise",
                            value: activityModel.exerciseMinutes,
                            goal: activityModel.dailyExerciseGoal,
                            unit: "min",
                            progress: activityModel.exerciseProgress,
                            color: .green
                        )
                        
                        activityMetricCard(
                            title: "Active Calories",
                            value: activityModel.activeCalories,
                            goal: activityModel.dailyActiveCalorieGoal,
                            unit: "cal",
                            progress: activityModel.calorieProgress,
                            color: Constants.Colors.calorieAccent
                        )
                        
                        activityMetricCard(
                            title: "Stand Hours",
                            value: activityModel.standHours,
                            goal: activityModel.dailyStandGoal,
                            unit: "hr",
                            progress: activityModel.standProgress,
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal)
                
                // Meal activity feed using SlimMealCard
                VStack(spacing: 12) {
                    HStack {
                        Text("Today's Meals")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Total calories display
                        Text("\(getAllMealCalories()) kcal")
                            .font(.subheadline)
                            .foregroundColor(Constants.Colors.calorieAccent)
                            .bold()
                    }
                    .padding(.horizontal)
                    
                    // Display empty state if no meals
                    if !hasAnyMeals() {
                        Text("No meals logged today")
                            .foregroundColor(.gray)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                    } else {
                        // Meals list with SlimMealCard
                        ForEach(getAllMealsSorted()) { meal in
                            SlimMealCard(meal: meal) {
                                withAnimation {
                                    deleteMeal(meal)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Add extra padding at bottom for tab bar
                Spacer().frame(height: 100)
            }
        }
        .background(Constants.Colors.background)
        .sheet(isPresented: $showingAddStepsSheet) {
            AddStepsView(activityModel: activityModel)
        }
    }
    
    // MARK: - Activity Metric Card
    private func activityMetricCard(title: String, value: Int, goal: Int, unit: String, progress: Double, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Constants.Colors.surfaceLight)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: progress)
                    
                    VStack(spacing: 0) {
                        Text("\(value)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        if !unit.isEmpty {
                            Text(unit)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(width: 70, height: 70)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color)
            }
            .padding(12)
        }
    }
    
    // MARK: - Helper methods for meal cards
    
    // Get all meals sorted by time (most recent first)
    private func getAllMealsSorted() -> [Meal] {
        let allMeals = MealType.allCases.flatMap { calorieModel.meals[$0] ?? [] }
        return allMeals.sorted(by: { $0.time > $1.time })
    }
    
    // Check if there are any meals
    private func hasAnyMeals() -> Bool {
        let allMeals = getAllMealsSorted()
        return !allMeals.isEmpty
    }
    
    // Get total calories from all meals
    private func getAllMealCalories() -> Int {
        let allMeals = getAllMealsSorted()
        return allMeals.reduce(0) { $0 + $1.calories }
    }
    
    // Delete a meal
    private func deleteMeal(_ meal: Meal) {
        // Remove the meal from the model
        if var meals = calorieModel.meals[meal.type], let index = meals.firstIndex(where: { $0.id == meal.id }) {
            // Subtract the meal's nutrients from the total
            calorieModel.consumedCalories -= meal.calories
            calorieModel.consumedProtein -= meal.protein
            calorieModel.consumedCarbs -= meal.carbs
            calorieModel.consumedFat -= meal.fat
            
            // Remove the meal from the array
            meals.remove(at: index)
            calorieModel.meals[meal.type] = meals
            
            // Save the updated data
            calorieModel.saveData()
        }
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
        .preferredColorScheme(.dark)
} 