//
//  CaloriesView.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI
import UIKit

struct CaloriesView: View {
    @ObservedObject var calorieModel: CalorieModel
    @State private var showingAddCaloriesSheet = false
    @State private var selectedDay: Date = Date()
    
    private func validateCalories(_ value: Int) -> Int {
        return min(value, calorieModel.dailyCalorieGoal * 3) // Cap at 3x daily goal
    }
    
    var body: some View {
        VStack(spacing: Constants.Layout.componentSpacing) {
            // Day selector
            DaySelector(selectedDay: $selectedDay)
            
            // Main content
            VStack(spacing: Constants.Layout.componentSpacing) {
                // Calorie display - pill-shaped card
                CalorieDisplay(
                    consumed: validateCalories(calorieModel.consumedCalories),
                    goal: calorieModel.dailyCalorieGoal
                )
                
                // Macro summary - pill-shaped elements
                MacrosPillView(
                    protein: (current: Int(calorieModel.consumedProtein), goal: Int(calorieModel.proteinGoal)),
                    carbs: (current: Int(calorieModel.consumedCarbs), goal: Int(calorieModel.carbsGoal)),
                    fat: (current: Int(calorieModel.consumedFat), goal: Int(calorieModel.fatGoal))
                )
            }
            .padding(.horizontal, Constants.Layout.screenMargin)
        }
        .sheet(isPresented: $showingAddCaloriesSheet) {
            AddCaloriesView(calorieModel: calorieModel)
        }
    }
}

// MARK: - Calorie Display Component
struct CalorieDisplay: View {
    let consumed: Int
    let goal: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("KCAL")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            
            HStack(spacing: 0) {
                // Consumed calories (orange pill)
                Text("\(consumed)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Constants.Colors.calorieOrange)
                    .cornerRadius(16, corners: [.topLeft, .bottomLeft])
                
                // Goal calories (dark pill)
                Text("\(goal)")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Constants.Colors.surfaceLight)
                    .cornerRadius(16, corners: [.topRight, .bottomRight])
            }
        }
    }
}

// MARK: - Macro Pill Components
struct MacrosPillView: View {
    let protein: (current: Int, goal: Int)
    let carbs: (current: Int, goal: Int)
    let fat: (current: Int, goal: Int)
    
    var body: some View {
        VStack(spacing: 12) {
            MacroPill(label: "P", current: protein.current, goal: protein.goal, progress: Double(protein.current) / Double(protein.goal))
            
            MacroPill(label: "F", current: fat.current, goal: fat.goal, progress: Double(fat.current) / Double(fat.goal))
            
            MacroPill(label: "C", current: carbs.current, goal: carbs.goal, progress: Double(carbs.current) / Double(carbs.goal))
        }
    }
}

struct MacroPill: View {
    let label: String
    let current: Int
    let goal: Int
    let progress: Double
    
    var body: some View {
        HStack {
            // Label
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 30, alignment: .leading)
            
            // Progress pill
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Constants.Colors.progressBackground)
                    
                    // Filled portion
                    Capsule()
                        .fill(Constants.Colors.turquoise)
                        .frame(width: geo.size.width * min(progress, 1.0))
                }
            }
            .frame(height: 16)
            
            // Current value
            Text("\(current)g")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 50, alignment: .trailing)
            
            // Goal value
            Text("\(goal)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.secondaryText)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

#Preview {
    CaloriesView(calorieModel: CalorieModel())
} 