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
    @Published var steps: Int {
        didSet {
            saveData()
        }
    }
    
    @Published var activeHours: Int {
        didSet {
            saveData()
        }
    }
    
    @Published var goalSteps: Int {
        didSet {
            saveData()
        }
    }
    
    @Published var mealLog: [String: Bool] = [
        "breakfast": false,
        "lunch": false,
        "dinner": false,
        "snacks": false
    ] {
        didSet {
            saveData()
        }
    }
    
    private let stepsKey = "HalCal.steps"
    private let activeHoursKey = "HalCal.activeHours"
    private let goalStepsKey = "HalCal.goalSteps"
    private let mealLogKey = "HalCal.mealLog"
    
    init() {
        // Load saved data or use defaults
        self.steps = UserDefaults.standard.integer(forKey: stepsKey)
        self.activeHours = UserDefaults.standard.integer(forKey: activeHoursKey)
        self.goalSteps = UserDefaults.standard.integer(forKey: goalStepsKey)
        
        if self.goalSteps == 0 {
            self.goalSteps = 10000 // Default goal
        }
        
        if let savedMealLog = UserDefaults.standard.dictionary(forKey: mealLogKey) as? [String: Bool] {
            self.mealLog = savedMealLog
        }
        
        // Check if it's a new day and reset if needed
        checkAndResetForNewDay()
        
        // Start a timer to periodically update active hours
        startActiveHoursTimer()
    }
    
    func saveData() {
        let defaults = UserDefaults.standard
        defaults.set(steps, forKey: stepsKey)
        defaults.set(activeHours, forKey: activeHoursKey)
        defaults.set(goalSteps, forKey: goalStepsKey)
        
        if let encoded = try? JSONEncoder().encode(mealLog) {
            defaults.set(encoded, forKey: mealLogKey)
        }
    }
    
    private func checkAndResetForNewDay() {
        let lastOpenDateKey = "HalCal.lastOpenDate"
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastOpenDate = UserDefaults.standard.object(forKey: lastOpenDateKey) as? Date {
            let lastOpenDay = Calendar.current.startOfDay(for: lastOpenDate)
            
            if today != lastOpenDay {
                // It's a new day, reset daily values
                steps = 0
                activeHours = 0
                mealLog = [
                    "breakfast": false,
                    "lunch": false,
                    "dinner": false,
                    "snacks": false
                ]
            }
        }
        
        // Save today's date
        UserDefaults.standard.set(today, forKey: lastOpenDateKey)
    }
    
    private var activeHoursTimer: Timer?
    
    private func startActiveHoursTimer() {
        // Check active status every 15 minutes
        activeHoursTimer = Timer.scheduledTimer(withTimeInterval: 15 * 60, repeats: true) { [weak self] _ in
            self?.incrementActiveHoursIfNeeded()
        }
    }
    
    private func incrementActiveHoursIfNeeded() {
        // In a real app, this would check if the user has been active
        // For this demo, we'll just increment randomly to simulate activity
        if activeHours < 12 && Int.random(in: 0...3) == 0 {
            activeHours += 1
        }
    }
    
    func addSteps(_ count: Int) {
        steps += count
    }
    
    func logMeal(_ meal: String) {
        if var currentLog = mealLog[meal.lowercased()] {
            currentLog = true
            mealLog[meal.lowercased()] = currentLog
        }
    }
    
    deinit {
        activeHoursTimer?.invalidate()
    }
} 