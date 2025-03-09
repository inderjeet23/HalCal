//
//  ActivityModel.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import Foundation
import SwiftUI
import Combine

class ActivityModel: ObservableObject {
    // Published properties to track activity metrics
    @Published var steps: Int = 0
    @Published var exerciseMinutes: Int = 0
    @Published var activeCalories: Int = 0
    @Published var standHours: Int = 0
    
    // Activity goal settings
    @Published var dailyStepGoal: Int = 10000
    @Published var dailyExerciseGoal: Int = 30
    @Published var dailyActiveCalorieGoal: Int = 500
    @Published var dailyStandGoal: Int = 12
    
    // Initialize with default values
    init() {
        // In a real app, we would load saved data here
        loadData()
    }
    
    // Record a new activity
    func addActivity(steps: Int = 0, exerciseMinutes: Int = 0, activeCalories: Int = 0, standHours: Int = 0) {
        self.steps += steps
        self.exerciseMinutes += exerciseMinutes
        self.activeCalories += activeCalories
        self.standHours += min(standHours, 24 - self.standHours) // Can't exceed 24 hours
        
        saveData()
    }
    
    // Reset activity data for a new day
    func resetForDay() {
        steps = 0
        exerciseMinutes = 0
        activeCalories = 0
        standHours = 0
        
        saveData()
    }
    
    // Calculate progress percentages
    var stepProgress: Double {
        return min(Double(steps) / Double(dailyStepGoal), 1.0)
    }
    
    var exerciseProgress: Double {
        return min(Double(exerciseMinutes) / Double(dailyExerciseGoal), 1.0)
    }
    
    var calorieProgress: Double {
        return min(Double(activeCalories) / Double(dailyActiveCalorieGoal), 1.0)
    }
    
    var standProgress: Double {
        return min(Double(standHours) / Double(dailyStandGoal), 1.0)
    }
    
    // Persistence methods (simple UserDefaults implementation)
    private func saveData() {
        let defaults = UserDefaults.standard
        defaults.set(steps, forKey: "activity_steps")
        defaults.set(exerciseMinutes, forKey: "activity_exerciseMinutes")
        defaults.set(activeCalories, forKey: "activity_activeCalories")
        defaults.set(standHours, forKey: "activity_standHours")
        
        // Save goals too
        defaults.set(dailyStepGoal, forKey: "activity_dailyStepGoal")
        defaults.set(dailyExerciseGoal, forKey: "activity_dailyExerciseGoal")
        defaults.set(dailyActiveCalorieGoal, forKey: "activity_dailyActiveCalorieGoal")
        defaults.set(dailyStandGoal, forKey: "activity_dailyStandGoal")
    }
    
    private func loadData() {
        let defaults = UserDefaults.standard
        steps = defaults.integer(forKey: "activity_steps")
        exerciseMinutes = defaults.integer(forKey: "activity_exerciseMinutes")
        activeCalories = defaults.integer(forKey: "activity_activeCalories")
        standHours = defaults.integer(forKey: "activity_standHours")
        
        // Load goals if they exist
        if defaults.object(forKey: "activity_dailyStepGoal") != nil {
            dailyStepGoal = defaults.integer(forKey: "activity_dailyStepGoal")
        }
        if defaults.object(forKey: "activity_dailyExerciseGoal") != nil {
            dailyExerciseGoal = defaults.integer(forKey: "activity_dailyExerciseGoal")
        }
        if defaults.object(forKey: "activity_dailyActiveCalorieGoal") != nil {
            dailyActiveCalorieGoal = defaults.integer(forKey: "activity_dailyActiveCalorieGoal")
        }
        if defaults.object(forKey: "activity_dailyStandGoal") != nil {
            dailyStandGoal = defaults.integer(forKey: "activity_dailyStandGoal")
        }
    }
} 