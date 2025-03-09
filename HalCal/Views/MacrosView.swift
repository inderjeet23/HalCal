import SwiftUI

struct MacrosView: View {
    @ObservedObject var calorieModel: CalorieModel
    @State private var showingAddMacrosSheet = false
    @State private var isRefreshing = false
    
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
        ZStack {
            // Background with subtle texture
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
            
            VStack(spacing: Constants.Layout.componentSpacing) {
                // Header panel
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Constants.Gradients.metallicSurface)
                    .frame(height: Constants.Layout.buttonMinSize + Constants.Layout.elementSpacing)
                    .overlay(
                        HStack {
                            Text("MACRONUTRIENTS")
                                .font(Constants.Fonts.sectionHeader)
                                .foregroundColor(Constants.Colors.primaryText)
                                .tracking(2)
                            
                            Spacer()
                            
                            // Date/time display
                            Text(formattedDateTime())
                                .font(Constants.Fonts.systemMessage)
                                .foregroundColor(Constants.Colors.primaryText)
                                .padding(.horizontal, Constants.Layout.elementSpacing)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius / 2)
                                        .fill(Constants.Colors.surfaceLight)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius / 2)
                                                .stroke(Color.white.opacity(0.1), lineWidth: Constants.Layout.borderWidth)
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
                
                // Thin separator line
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
                    .padding(.horizontal, Constants.Layout.screenMargin)
                
                // Main content - using ScrollView for pull-to-refresh
                ScrollView {
                    VStack(spacing: Constants.Layout.componentSpacing) {
                        // Macronutrient distribution panel - reduced size
                        VStack(spacing: Constants.Layout.elementSpacing / 2) {
                            Text("MACRONUTRIENT DISTRIBUTION")
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(Constants.Colors.primaryText)
                                .padding(.top, Constants.Layout.elementSpacing / 2)
                            
                            // Pie chart representation - reduced size
                            ZStack {
                                Circle()
                                    .fill(Constants.Colors.surfaceMid)
                                    .frame(width: 150, height: 150)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.3),
                                                        Color.white.opacity(0.1),
                                                        Color.black.opacity(0.2)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                
                                // Protein segment
                                MacroArcView(
                                    percentage: proteinCaloriePercentage,
                                    startAngle: 0,
                                    color: Constants.Colors.blue
                                )
                                .frame(width: 150, height: 150)
                                
                                // Carbs segment
                                MacroArcView(
                                    percentage: carbsCaloriePercentage,
                                    startAngle: proteinCaloriePercentage * 3.6,
                                    color: Constants.Colors.amber
                                )
                                .frame(width: 150, height: 150)
                                
                                // Fat segment
                                MacroArcView(
                                    percentage: fatCaloriePercentage,
                                    startAngle: (proteinCaloriePercentage + carbsCaloriePercentage) * 3.6,
                                    color: Color(red: 0.2, green: 0.8, blue: 0.2) // Green color for fat
                                )
                                .frame(width: 150, height: 150)
                                
                                // Center hole
                                Circle()
                                    .fill(Constants.Colors.background)
                                    .frame(width: 75, height: 75)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.2),
                                                        Color.white.opacity(0.1),
                                                        Color.black.opacity(0.1)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            }
                            .padding(.vertical, Constants.Layout.elementSpacing / 2)
                            
                            // Legend
                            HStack(spacing: Constants.Layout.elementSpacing * 2) {
                                // Protein
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(Constants.Colors.blue)
                                        .frame(width: 12, height: 12)
                                    
                                    Text("PROTEIN")
                                        .font(Constants.Fonts.monospacedLabel)
                                        .foregroundColor(Constants.Colors.primaryText)
                                }
                                
                                // Carbs
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(Constants.Colors.amber)
                                        .frame(width: 12, height: 12)
                                    
                                    Text("CARBS")
                                        .font(Constants.Fonts.monospacedLabel)
                                        .foregroundColor(Constants.Colors.primaryText)
                                }
                                
                                // Fat
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(Color(red: 0.2, green: 0.8, blue: 0.2)) // Green color for fat
                                        .frame(width: 12, height: 12)
                                    
                                    Text("FAT")
                                        .font(Constants.Fonts.monospacedLabel)
                                        .foregroundColor(Constants.Colors.primaryText)
                                }
                            }
                            .padding(.bottom, Constants.Layout.elementSpacing / 2)
                        }
                        .background(Constants.Colors.surfaceLight)
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
                        .padding(.horizontal, Constants.Layout.screenMargin)
                        
                        // Enhanced Macro Balance Panel with integrated progress
                        MacroBalancePanel(calorieModel: calorieModel)
                            .padding(.horizontal, Constants.Layout.screenMargin)
                    }
                    .padding(.vertical, Constants.Layout.componentSpacing)
                }
                .scrollIndicators(.visible)
                .scrollBounceBehavior(.always)
                .refreshable {
                    await refreshData()
                }
                
                Spacer()
                
                // Add macros button
                SkeuomorphicButton(
                    icon: "plus",
                    size: Constants.Layout.buttonMinSize * 1.8,
                    color: Constants.Colors.blue
                ) {
                    HapticManager.shared.impact(style: .medium)
                    showingAddMacrosSheet = true
                }
                .padding(.bottom, Constants.Layout.screenMargin)
            }
        }
        .fullScreenCover(isPresented: $showingAddMacrosSheet) {
            AddMacrosView(calorieModel: calorieModel)
        }
    }
    
    private func formattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: Date())
    }
    
    private func refreshData() async {
        // Simulate a refresh operation
        isRefreshing = true
        
        // Add haptic feedback for pull-to-refresh
        HapticManager.shared.impact(style: .medium)
        
        // Simulate a network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Refresh the data
        calorieModel.loadData()
        
        // Success feedback when refresh completes
        HapticManager.shared.notification(type: .success)
        
        isRefreshing = false
    }
}

// MARK: - MacroArcView
struct MacroArcView: View {
    var percentage: Double
    var startAngle: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            Path { path in
                // Only draw if there's a percentage to show
                if percentage > 0 {
                    path.move(to: center)
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(startAngle + percentage * 3.6),
                        clockwise: false
                    )
                    path.closeSubpath()
                }
            }
            .fill(color)
            .overlay(
                // Add subtle gradient overlay for depth
                Path { path in
                    if percentage > 0 {
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: .degrees(startAngle),
                            endAngle: .degrees(startAngle + percentage * 3.6),
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                }
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.8),
                            color
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            )
        }
    }
}

#Preview {
    MacrosView(calorieModel: CalorieModel())
} 