//
//  HydrationModel.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import Foundation
import SwiftUI
import Combine

class HydrationModel: ObservableObject {
    // Published properties for UI updates
    @Published var currentHydration: Double = 0.0
    @Published var dailyGoal: Double = 2.0 // Default 2L daily goal
    
    // UserDefaults keys
    private let currentHydrationKey = "currentHydration"
    private let dailyGoalKey = "hydrationDailyGoal"
    private let lastResetDateKey = "lastHydrationResetDate"
    
    // Timer for auto-saving
    private var saveTimer: AnyCancellable?
    
    init() {
        // Load saved data
        loadSavedData()
        
        // Check if we need to reset for a new day
        checkAndResetForNewDay()
        
        // Set up auto-save timer
        saveTimer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.saveData()
            }
    }
    
    deinit {
        saveTimer?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Set the current hydration level directly with animation
    func setHydration(amount: Double) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            currentHydration = max(0, min(amount, dailyGoal))
        }
        saveData()
    }
    
    /// Add water to the current hydration level with animation
    func addWater(amount: Double) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            currentHydration += amount
        }
        saveData()
    }
    
    /// Remove water from the current hydration level with animation
    func removeWater(amount: Double) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            currentHydration = max(0, currentHydration - amount)
        }
        saveData()
    }
    
    /// Set a new daily goal with animation
    func setDailyGoal(goal: Double) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            dailyGoal = max(0.5, goal) // Minimum 0.5L
        }
        saveData()
    }
    
    /// Reset hydration for the day with animation
    func resetForDay() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            currentHydration = 0.0
        }
        saveLastResetDate()
        saveData()
    }
    
    // MARK: - Private Methods
    
    /// Load saved data from UserDefaults
    private func loadSavedData() {
        let defaults = UserDefaults.standard
        currentHydration = defaults.double(forKey: currentHydrationKey)
        
        // Only load daily goal if it exists, otherwise keep default
        if defaults.object(forKey: dailyGoalKey) != nil {
            dailyGoal = defaults.double(forKey: dailyGoalKey)
        }
    }
    
    /// Save data to UserDefaults
    func saveData() {
        UserDefaults.standard.set(currentHydration, forKey: currentHydrationKey)
        UserDefaults.standard.set(dailyGoal, forKey: dailyGoalKey)
    }
    
    /// Save the current date as the last reset date
    private func saveLastResetDate() {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())
        defaults.set(today, forKey: lastResetDateKey)
    }
    
    /// Check if we need to reset for a new day
    private func checkAndResetForNewDay() {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastResetDate = defaults.object(forKey: lastResetDateKey) as? Date {
            // If the last reset date is before today, reset the hydration
            if lastResetDate < today {
                resetForDay()
            }
        } else {
            // If no last reset date, save today
            saveLastResetDate()
        }
    }
    
    /// Get percentage of daily goal achieved
    var percentageOfGoal: Double {
        return min(currentHydration / dailyGoal, 1.0) * 100.0
    }
} 