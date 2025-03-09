import SwiftUI

struct MealCard: View {
    let title: String
    let calories: Int
    let goalCalories: Int
    let protein: Double
    let proteinGoal: Double
    let carbs: Double
    let carbsGoal: Double
    let fat: Double
    let fatGoal: Double
    
    private var progress: Double {
        Double(calories) / Double(goalCalories)
    }
    
    var body: some View {
        HStack(spacing: Constants.Layout.elementSpacing) {
            // Progress circle
            ZStack {
                Circle()
                    .stroke(Constants.Colors.progressBackground, lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Constants.Colors.mealIndicator, lineWidth: 3)
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Meal title and calories
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.primaryText)
                    
                    Spacer()
                    
                    Text("\(calories)/\(goalCalories) kcal")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Constants.Colors.secondaryText)
                }
                
                // Macro bars
                MacroBars(
                    protein: protein,
                    proteinGoal: proteinGoal,
                    carbs: carbs,
                    carbsGoal: carbsGoal,
                    fat: fat,
                    fatGoal: fatGoal
                )
            }
        }
        .padding(Constants.Layout.cardPadding)
        .background(Constants.Colors.surfaceLight)
        .cornerRadius(Constants.Layout.cornerRadius)
    }
}

#Preview {
    VStack {
        MealCard(
            title: "Breakfast",
            calories: 320,
            goalCalories: 400,
            protein: 25,
            proteinGoal: 40,
            carbs: 35,
            carbsGoal: 50,
            fat: 12,
            fatGoal: 20
        )
        .padding()
    }
    .background(Constants.Colors.background)
    .preferredColorScheme(.dark)
} 