import Foundation

// Meal data structure - moved to its own file so it can be referenced by multiple files
struct Meal: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let time: Date
    let type: MealType
} 