import SwiftUI

struct MacroBar: View {
    let value: Double
    let total: Double
    let label: String
    
    private var progress: Double {
        min(value / total, 1.0)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Macro label
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Constants.Colors.secondaryText)
                .frame(width: 20, alignment: .leading)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: Constants.Layout.macroBarHeight / 2)
                        .fill(Constants.Colors.progressBackground)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: Constants.Layout.macroBarHeight / 2)
                        .fill(Constants.Colors.turquoise)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: Constants.Layout.macroBarHeight)
            
            // Value
            Text("\(Int(value))g")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Constants.Colors.primaryText)
                .frame(width: 40, alignment: .trailing)
        }
        .frame(height: 20)
    }
}

struct MacroBars: View {
    let protein: Double
    let proteinGoal: Double
    let carbs: Double
    let carbsGoal: Double
    let fat: Double
    let fatGoal: Double
    
    var body: some View {
        VStack(spacing: 4) {
            MacroBar(value: protein, total: proteinGoal, label: "P")
            MacroBar(value: carbs, total: carbsGoal, label: "C")
            MacroBar(value: fat, total: fatGoal, label: "F")
        }
    }
}

#Preview {
    VStack {
        MacroBars(
            protein: 80,
            proteinGoal: 120,
            carbs: 150,
            carbsGoal: 200,
            fat: 40,
            fatGoal: 65
        )
        .padding()
        .background(Constants.Colors.surfaceLight)
        .cornerRadius(Constants.Layout.cornerRadius)
        .padding()
    }
    .background(Constants.Colors.background)
    .preferredColorScheme(.dark)
} 