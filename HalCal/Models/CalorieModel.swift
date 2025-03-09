//
//  CalorieModel.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import Foundation
import Combine

class CalorieModel: ObservableObject {
    @Published var dailyCalorieGoal: Int = 2000
    @Published var consumedCalories: Int = 0
    @Published var calorieDeficit: Int = 0
    
    // Macronutrient tracking
    @Published var consumedProtein: Double = 0.0
    @Published var consumedCarbs: Double = 0.0
    @Published var consumedFat: Double = 0.0
    
    // Macronutrient goals (in grams)
    @Published var proteinGoal: Double = 150.0
    @Published var carbsGoal: Double = 200.0
    @Published var fatGoal: Double = 65.0
    
    var caloriesRemaining: Int {
        max(dailyCalorieGoal - consumedCalories, 0)
    }
    
    init() {
        // Load saved data or use defaults
        loadSavedData()
        
        // Calculate initial deficit
        calculateDeficit()
    }
    
    // Public method to reload data
    func loadData() {
        loadSavedData()
        calculateDeficit()
    }
    
    func addCalories(_ amount: Int) {
        consumedCalories += amount
        calculateDeficit()
    }
    
    func addMacros(protein: Double, carbs: Double, fat: Double) {
        consumedProtein += protein
        consumedCarbs += carbs
        consumedFat += fat
        
        // Calculate calories from macros (4 cal/g protein, 4 cal/g carbs, 9 cal/g fat)
        let caloriesFromMacros = Int(protein * 4 + carbs * 4 + fat * 9)
        consumedCalories += caloriesFromMacros
        calculateDeficit()
    }
    
    func resetDailyCalories() {
        consumedCalories = 0
        consumedProtein = 0
        consumedCarbs = 0
        consumedFat = 0
        calculateDeficit()
    }
    
    func setDailyGoal(_ goal: Int) {
        dailyCalorieGoal = max(goal, 0)
        calculateDeficit()
    }
    
    func setMacroGoals(protein: Double, carbs: Double, fat: Double) {
        proteinGoal = max(protein, 0)
        carbsGoal = max(carbs, 0)
        fatGoal = max(fat, 0)
    }
    
    // Calculate percentage of goal for each macro
    var proteinPercentage: Double {
        return min((consumedProtein / proteinGoal) * 100, 100)
    }
    
    var carbsPercentage: Double {
        return min((consumedCarbs / carbsGoal) * 100, 100)
    }
    
    var fatPercentage: Double {
        return min((consumedFat / fatGoal) * 100, 100)
    }
    
    // Calculate macronutrient distribution (percentages of total calories)
    var proteinCaloriePercentage: Double {
        let totalCalories = Double(consumedCalories)
        if totalCalories == 0 { return 0 }
        return (consumedProtein * 4 / totalCalories) * 100
    }
    
    var carbsCaloriePercentage: Double {
        let totalCalories = Double(consumedCalories)
        if totalCalories == 0 { return 0 }
        return (consumedCarbs * 4 / totalCalories) * 100
    }
    
    var fatCaloriePercentage: Double {
        let totalCalories = Double(consumedCalories)
        if totalCalories == 0 { return 0 }
        return (consumedFat * 9 / totalCalories) * 100
    }
    
    private func calculateDeficit() {
        // Positive deficit means you're under your calorie goal (good)
        // Negative deficit means you're over your calorie goal (bad)
        calorieDeficit = dailyCalorieGoal - consumedCalories
    }
    
    private func loadSavedData() {
        // In a real app, this would load from UserDefaults or a database
        // For now, we'll just use default values
        dailyCalorieGoal = UserDefaults.standard.integer(forKey: "dailyCalorieGoal")
        if dailyCalorieGoal == 0 {
            dailyCalorieGoal = 2000 // Default value
        }
        
        // Load macronutrient data
        proteinGoal = UserDefaults.standard.double(forKey: "proteinGoal")
        if proteinGoal == 0 { proteinGoal = 150.0 }
        
        carbsGoal = UserDefaults.standard.double(forKey: "carbsGoal")
        if carbsGoal == 0 { carbsGoal = 200.0 }
        
        fatGoal = UserDefaults.standard.double(forKey: "fatGoal")
        if fatGoal == 0 { fatGoal = 65.0 }
        
        // Check if we need to reset daily calories (new day)
        let lastResetDate = UserDefaults.standard.object(forKey: "lastResetDate") as? Date
        let calendar = Calendar.current
        if let lastDate = lastResetDate, !calendar.isDateInToday(lastDate) {
            // It's a new day, reset consumed calories
            consumedCalories = 0
            consumedProtein = 0
            consumedCarbs = 0
            consumedFat = 0
        } else {
            // Same day, load saved consumed calories
            consumedCalories = UserDefaults.standard.integer(forKey: "consumedCalories")
            consumedProtein = UserDefaults.standard.double(forKey: "consumedProtein")
            consumedCarbs = UserDefaults.standard.double(forKey: "consumedCarbs")
            consumedFat = UserDefaults.standard.double(forKey: "consumedFat")
        }
        
        // Save current date as last reset date
        UserDefaults.standard.set(Date(), forKey: "lastResetDate")
    }
    
    func saveData() {
        UserDefaults.standard.set(dailyCalorieGoal, forKey: "dailyCalorieGoal")
        UserDefaults.standard.set(consumedCalories, forKey: "consumedCalories")
        
        // Save macronutrient data
        UserDefaults.standard.set(proteinGoal, forKey: "proteinGoal")
        UserDefaults.standard.set(carbsGoal, forKey: "carbsGoal")
        UserDefaults.standard.set(fatGoal, forKey: "fatGoal")
        
        UserDefaults.standard.set(consumedProtein, forKey: "consumedProtein")
        UserDefaults.standard.set(consumedCarbs, forKey: "consumedCarbs")
        UserDefaults.standard.set(consumedFat, forKey: "consumedFat")
    }
} 