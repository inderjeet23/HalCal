import SwiftUI

struct MacroBalancePanel: View {
    @ObservedObject var calorieModel: CalorieModel
    
    // Computed property to determine if macros are in balance
    private var macrosInBalance: Bool {
        // Check if macros are within acceptable ranges
        // For example: protein 30-40%, carbs 40-50%, fat 20-30%
        let proteinPercent = proteinCaloriePercentage
        let carbsPercent = carbsCaloriePercentage
        let fatPercent = fatCaloriePercentage
        
        return (proteinPercent >= 25 && proteinPercent <= 40) &&
               (carbsPercent >= 35 && carbsPercent <= 55) &&
               (fatPercent >= 15 && fatPercent <= 35)
    }
    
    // Calculate percentage of total calories for each macro
    private var proteinCaloriePercentage: Double {
        let totalCalories = Double(calorieModel.consumedCalories)
        if totalCalories == 0 { return 0 }
        return (calorieModel.consumedProtein * 4 / totalCalories) * 100
    }
    
    private var carbsCaloriePercentage: Double {
        let totalCalories = Double(calorieModel.consumedCalories)
        if totalCalories == 0 { return 0 }
        return (calorieModel.consumedCarbs * 4 / totalCalories) * 100
    }
    
    private var fatCaloriePercentage: Double {
        let totalCalories = Double(calorieModel.consumedCalories)
        if totalCalories == 0 { return 0 }
        return (calorieModel.consumedFat * 9 / totalCalories) * 100
    }
    
    var body: some View {
        VStack(spacing: Constants.Layout.elementSpacing / 2) {
            // Header
            HStack {
                Text("MACRO TRACKER")
                    .font(Constants.Fonts.sectionHeader)
                    .foregroundColor(Constants.Colors.primaryText)
                    .tracking(2)
                
                Spacer()
                
                // Balance indicator
                HStack(spacing: 5) {
                    Circle()
                        .fill(macrosInBalance ? Constants.Colors.blue : Constants.Colors.alertRed)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                        )
                        .shadow(
                            color: macrosInBalance ? Constants.Colors.blue.opacity(0.6) : Constants.Colors.alertRed.opacity(0.6),
                            radius: 2,
                            x: 0,
                            y: 0
                        )
                    
                    Text(macrosInBalance ? "BALANCED" : "UNBALANCED")
                        .font(Constants.Fonts.monospacedLabel)
                        .foregroundColor(macrosInBalance ? Constants.Colors.blue : Constants.Colors.alertRed)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.2),
                                            Color.white.opacity(0.05),
                                            Color.black.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                )
            }
            .padding(.horizontal, Constants.Layout.elementSpacing)
            .padding(.top, Constants.Layout.elementSpacing)
            
            // Divider
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.05),
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.05)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(height: Constants.Layout.borderWidth)
                .padding(.horizontal, Constants.Layout.elementSpacing)
                .padding(.vertical, Constants.Layout.elementSpacing / 2)
            
            // Tabs for Macro Balance and Daily Progress
            HStack {
                Text("MACRO BALANCE")
                    .font(Constants.Fonts.primaryLabel)
                    .foregroundColor(Constants.Colors.primaryText)
                    .padding(.horizontal, Constants.Layout.elementSpacing)
            }
            .padding(.bottom, Constants.Layout.elementSpacing / 2)
            
            // Protein
            macroProgressRow(
                label: "PROTEIN",
                color: Constants.Colors.blue,
                currentAmount: calorieModel.consumedProtein,
                targetAmount: calorieModel.proteinTarget,
                percentOfCalories: proteinCaloriePercentage
            )
            
            // Carbs
            macroProgressRow(
                label: "CARBS",
                color: Constants.Colors.amber,
                currentAmount: calorieModel.consumedCarbs,
                targetAmount: calorieModel.carbTarget,
                percentOfCalories: carbsCaloriePercentage
            )
            
            // Fat - using green color as requested
            macroProgressRow(
                label: "FAT",
                color: Color(red: 0.2, green: 0.8, blue: 0.2), // Green color
                currentAmount: calorieModel.consumedFat,
                targetAmount: calorieModel.fatTarget,
                percentOfCalories: fatCaloriePercentage
            )
            
            // Divider
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.05),
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.05)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(height: Constants.Layout.borderWidth)
                .padding(.horizontal, Constants.Layout.elementSpacing)
                .padding(.vertical, Constants.Layout.elementSpacing / 2)
            
            // Daily Progress Section
            HStack {
                Text("DAILY PROGRESS")
                    .font(Constants.Fonts.primaryLabel)
                    .foregroundColor(Constants.Colors.primaryText)
                    .padding(.horizontal, Constants.Layout.elementSpacing)
            }
            .padding(.bottom, Constants.Layout.elementSpacing / 2)
            
            // Protein daily progress
            dailyProgressRow(
                label: "PROTEIN",
                color: Constants.Colors.blue,
                currentAmount: calorieModel.consumedProtein,
                targetAmount: calorieModel.proteinTarget
            )
            
            // Carbs daily progress
            dailyProgressRow(
                label: "CARBS",
                color: Constants.Colors.amber,
                currentAmount: calorieModel.consumedCarbs,
                targetAmount: calorieModel.carbTarget
            )
            
            // Fat daily progress
            dailyProgressRow(
                label: "FAT",
                color: Color(red: 0.2, green: 0.8, blue: 0.2), // Green color
                currentAmount: calorieModel.consumedFat,
                targetAmount: calorieModel.fatTarget
            )
            
            // Total calories
            HStack {
                Text("TOTAL CALORIES")
                    .font(Constants.Fonts.monospacedLabel)
                    .foregroundColor(Constants.Colors.primaryText)
                
                Spacer()
                
                Text("\(calorieModel.consumedCalories)")
                    .font(Constants.Fonts.monospacedDigital)
                    .foregroundColor(Constants.Colors.primaryText)
            }
            .padding(.horizontal, Constants.Layout.elementSpacing)
            .padding(.bottom, Constants.Layout.elementSpacing)
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.12)) // #1E1E1E
        .cornerRadius(Constants.Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                            Color.black.opacity(0.1),
                            Color.black.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: Constants.Layout.borderWidth
                )
        )
        .shadow(
            color: Constants.Shadows.panelShadow.color,
            radius: Constants.Shadows.panelShadow.radius,
            x: Constants.Shadows.panelShadow.x,
            y: Constants.Shadows.panelShadow.y
        )
    }
    
    private func macroProgressRow(label: String, color: Color, currentAmount: Double, targetAmount: Double, percentOfCalories: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Label and values
            HStack(alignment: .center) {
                // Colored indicator dot
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                    )
                    .shadow(color: color.opacity(0.6), radius: 2, x: 0, y: 0)
                
                // Macro label
                Text(label)
                    .font(Constants.Fonts.monospacedLabel)
                    .foregroundColor(Constants.Colors.primaryText)
                
                Spacer()
                
                // Current amount
                Text("\(Int(currentAmount))g")
                    .font(Constants.Fonts.monospacedDigital)
                    .foregroundColor(color)
                
                // Percentage of goal
                Text("\(Int(min((currentAmount / targetAmount) * 100, 100)))%")
                    .font(Constants.Fonts.monospacedDigital)
                    .foregroundColor(color)
                    .frame(width: 50, alignment: .trailing)
                
                // Percentage of total calories
                Text("\(Int(percentOfCalories))% OF INTAKE")
                    .font(Constants.Fonts.monospacedLabel)
                    .foregroundColor(Constants.Colors.secondaryText)
                    .frame(width: 120, alignment: .trailing)
            }
            
            // Progress bar
            ZStack(alignment: .leading) {
                // Background
                Capsule()
                    .fill(Color.black.opacity(0.3))
                    .frame(height: 8)
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.black.opacity(0.2)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.5
                            )
                    )
                
                // Progress
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.8),
                                color
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(CGFloat(min((currentAmount / targetAmount), 1.0)) * UIScreen.main.bounds.width * 0.8, 0), height: 8)
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.3),
                                        color.opacity(0.1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.5
                            )
                    )
                    // Inner glow effect
                    .shadow(color: color.opacity(0.6), radius: 2, x: 0, y: 0)
            }
        }
        .padding(.horizontal, Constants.Layout.elementSpacing)
    }
    
    private func dailyProgressRow(label: String, color: Color, currentAmount: Double, targetAmount: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(Constants.Fonts.monospacedLabel)
                    .foregroundColor(Constants.Colors.primaryText)
                
                Spacer()
                
                Text("\(Int(currentAmount))g / \(Int(targetAmount))g")
                    .font(Constants.Fonts.monospacedLabel)
                    .foregroundColor(color)
            }
            
            // Progress bar
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.3))
                    .frame(height: 8)
                
                // Progress
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.8),
                                color
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(CGFloat(min((currentAmount / targetAmount), 1.0)) * UIScreen.main.bounds.width * 0.8, 0), height: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.3),
                                        color.opacity(0.1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.5
                            )
                    )
                    // Inner glow effect
                    .shadow(color: color.opacity(0.6), radius: 2, x: 0, y: 0)
            }
        }
        .padding(.horizontal, Constants.Layout.elementSpacing)
    }
}

#Preview {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()
        
        MacroBalancePanel(calorieModel: CalorieModel())
            .padding()
    }
} 