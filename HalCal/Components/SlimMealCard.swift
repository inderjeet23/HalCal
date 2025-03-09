import SwiftUI

struct SlimMealCard: View {
    let meal: Meal
    let onDelete: () -> Void
    
    // Return pastel color based on meal type
    private var mealTypeColor: Color {
        switch meal.type {
        case .breakfast:
            return Color(red: 0.9, green: 0.9, blue: 1.0) // Light lavender
        case .lunch:
            return Color(red: 0.9, green: 1.0, blue: 0.9) // Light mint
        case .dinner:
            return Color(red: 0.9, green: 1.0, blue: 1.0) // Light cyan
        case .snack:
            return Color(red: 1.0, green: 0.9, blue: 0.9) // Light pink
        }
    }
    
    // Return icon name based on meal type
    private var mealTypeIcon: String {
        switch meal.type {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "sunset.fill"
        case .snack: return "cup.and.saucer.fill"
        }
    }
    
    // Format time for display
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: meal.time)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon with meal type background
            ZStack {
                Circle()
                    .fill(mealTypeColor)
                    .frame(width: 36, height: 36)
                
                Image(systemName: mealTypeIcon)
                    .foregroundColor(Constants.Colors.turquoise)
                    .font(.system(size: 16))
            }
            
            // Meal info
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    // Calorie and time info
                    Text("\(meal.calories) kcal")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Constants.Colors.calorieOrange)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(formattedTime)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                // Only show macros if any exist
                if meal.protein > 0 || meal.carbs > 0 || meal.fat > 0 {
                    HStack(spacing: 8) {
                        if meal.protein > 0 {
                            macroItem(label: "P", value: meal.protein, color: Constants.Colors.turquoise)
                        }
                        
                        if meal.carbs > 0 {
                            macroItem(label: "C", value: meal.carbs, color: Color.purple)
                        }
                        
                        if meal.fat > 0 {
                            macroItem(label: "F", value: meal.fat, color: Color.yellow)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.3))
                    )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
            .fill(Constants.Colors.surfaceLight)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(mealTypeColor.opacity(0.5), lineWidth: 1)
            )
        )
    }
    
    // Helper for displaying macro nutrients
    private func macroItem(label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
            
            Text("\(Int(value))g")
                .font(.system(size: 12))
                .foregroundColor(color.opacity(0.8))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(color.opacity(0.15))
        )
    }
}

#Preview {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()
        
        SlimMealCard(
            meal: Meal(
                name: "Breakfast",
                calories: 450,
                protein: 25,
                carbs: 45,
                fat: 15,
                time: Date(),
                type: .breakfast
            ),
            onDelete: {}
        )
        .padding()
    }
} 