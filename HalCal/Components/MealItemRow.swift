import SwiftUI

struct MealItemRow: View {
    let meal: Meal
    let onDelete: () -> Void
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack {
            // Circle with meal type icon
            Circle()
                .fill(Constants.Colors.calorieAccent.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: mealTypeIcon(for: meal.type))
                        .foregroundColor(Constants.Colors.calorieAccent)
                )
            
            VStack(alignment: .leading) {
                Text(meal.name)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("\(meal.calories) calories • \(timeFormatter.string(from: meal.time))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Show macros if they exist
                if meal.protein > 0 || meal.carbs > 0 || meal.fat > 0 {
                    Text("P: \(Int(meal.protein))g • C: \(Int(meal.carbs))g • F: \(Int(meal.fat))g")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.turquoise)
                }
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                    .padding(8)
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
    
    // Get icon for meal type
    private func mealTypeIcon(for type: MealType) -> String {
        switch type {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "sunset.fill"
        case .snack: return "cup.and.saucer.fill"
        }
    }
} 