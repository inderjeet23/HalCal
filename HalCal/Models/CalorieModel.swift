//
//  CalorieModel.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import Foundation
import Combine

class CalorieModel: ObservableObject {
    // Daily targets
    @Published var calorieTarget: Int = 2000
    @Published var proteinTarget: Double = 150
    @Published var carbTarget: Double = 200
    @Published var fatTarget: Double = 70
    
    // Consumed amounts
    @Published var consumedCalories: Int = 0
    @Published var consumedProtein: Double = 0
    @Published var consumedCarbs: Double = 0
    @Published var consumedFat: Double = 0
    
    // Track meals by type
    @Published var meals: [MealType: [Meal]] = [
        .breakfast: [],
        .lunch: [],
        .dinner: [],
        .snack: []
    ]
    
    init() {
        loadData()
    }
    
    // Function to add calories with an optional meal type
    func addCalories(amount: Int, mealType: MealType = .snack) {
        consumedCalories += amount
        
        // Add to meal tracking
        let meal = Meal(
            name: mealNameForType(mealType),
            calories: amount,
            protein: 0,
            carbs: 0,
            fat: 0,
            time: Date(),
            type: mealType
        )
        
        if meals[mealType] != nil {
            meals[mealType]?.append(meal)
        } else {
            meals[mealType] = [meal]
        }
        
        saveData()
    }
    
    // Function to add macros that also adds the calories from those macros
    func addMacros(protein: Double, carbs: Double, fat: Double, mealType: MealType = .snack) {
        // Calculate calories from macros (4 calories per gram of protein/carbs, 9 per gram of fat)
        let caloriesFromProtein = Int(protein * 4)
        let caloriesFromCarbs = Int(carbs * 4)
        let caloriesFromFat = Int(fat * 9)
        let totalCaloriesFromMacros = caloriesFromProtein + caloriesFromCarbs + caloriesFromFat
        
        // Update totals
        consumedProtein += protein
        consumedCarbs += carbs
        consumedFat += fat
        consumedCalories += totalCaloriesFromMacros
        
        // Add to meal tracking
        let meal = Meal(
            name: mealNameForType(mealType),
            calories: totalCaloriesFromMacros,
            protein: protein,
            carbs: carbs,
            fat: fat,
            time: Date(),
            type: mealType
        )
        
        if meals[mealType] != nil {
            meals[mealType]?.append(meal)
        } else {
            meals[mealType] = [meal]
        }
        
        saveData()
    }
    
    // Get meal name based on type
    private func mealNameForType(_ type: MealType) -> String {
        return type.rawValue
    }
    
    // Save data to UserDefaults
    func saveData() {
        let defaults = UserDefaults.standard
        defaults.set(consumedCalories, forKey: "consumedCalories")
        defaults.set(consumedProtein, forKey: "consumedProtein")
        defaults.set(consumedCarbs, forKey: "consumedCarbs")
        defaults.set(consumedFat, forKey: "consumedFat")
        
        // In a real app, we would serialize and save the meals array too
    }
    
    // Load data from UserDefaults
    func loadData() {
        let defaults = UserDefaults.standard
        consumedCalories = defaults.integer(forKey: "consumedCalories")
        consumedProtein = defaults.double(forKey: "consumedProtein")
        consumedCarbs = defaults.double(forKey: "consumedCarbs")
        consumedFat = defaults.double(forKey: "consumedFat")
        
        // Load sample data for testing
        if true {
            // Add a sample meal
            let sampleMeal = Meal(
                name: "Snack",
                calories: 1882,
                protein: 25,
                carbs: 30,
                fat: 8,
                time: Date(),
                type: .snack
            )
            meals[.snack] = [sampleMeal]
        }
    }
    
    // Reset all values (for testing or for daily reset)
    func resetData() {
        consumedCalories = 0
        consumedProtein = 0
        consumedCarbs = 0
        consumedFat = 0
        meals = [.breakfast: [], .lunch: [], .dinner: [], .snack: []]
        saveData()
    }
    
    // Calculate remaining calories
    var remainingCalories: Int {
        return calorieTarget - consumedCalories
    }
    
    // Calculate percentage of calorie goal
    var caloriePercentage: Double {
        return Double(consumedCalories) / Double(calorieTarget)
    }
    
    // Calculate percentage of protein goal
    var proteinPercentage: Double {
        return consumedProtein / proteinTarget
    }
    
    // Calculate percentage of carb goal
    var carbPercentage: Double {
        return consumedCarbs / carbTarget
    }
    
    // Calculate percentage of fat goal
    var fatPercentage: Double {
        return consumedFat / fatTarget
    }
    
    // Get calories for a specific meal type
    func getMealCalories(for type: MealType) -> Int {
        let mealsForType = meals[type] ?? []
        return mealsForType.reduce(0) { $0 + $1.calories }
    }
} 