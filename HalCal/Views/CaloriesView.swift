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
            
            Spacer()
        }
        .background(Constants.Colors.background)
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

// MARK: - Pull-up Card Components
struct PullUpCardView: View {
    @ObservedObject var calorieModel: CalorieModel
    @State private var offset: CGFloat = 0
    @State private var previousOffset: CGFloat = 0
    @State private var currentPosition: CardPosition = .collapsed
    
    // Define snap points
    private let collapsedPosition: CGFloat = 0
    private let halfPosition: CGFloat = 200
    private let expandedPosition: CGFloat = 450
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Card content only shown when pulled up
                if offset > 0 {
                    VStack(spacing: 0) {
                        // Card handle
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 4)
                            .cornerRadius(2)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                        
                        // Meal content
                        VStack(spacing: 16) {
                            EnhancedMealCard(
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
                            
                            EnhancedMealCard(
                                title: "Lunch",
                                calories: 600,
                                goalCalories: 600,
                                protein: 45,
                                proteinGoal: 60,
                                carbs: 75,
                                carbsGoal: 100,
                                fat: 20,
                                fatGoal: 30
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .frame(width: geometry.size.width)
            .background(
                Color.white
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.1), radius: 4, y: -2)
            )
            .offset(y: geometry.size.height - offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Follow finger precisely during drag
                        let dragAmount = value.translation.height
                        let newOffset = previousOffset - dragAmount
                        
                        // Add resistance when pulling beyond boundaries
                        if newOffset < collapsedPosition {
                            offset = newOffset * 0.3 // Resistance when pulling down too far
                        } else if newOffset > expandedPosition {
                            let extraPull = newOffset - expandedPosition
                            offset = expandedPosition + (extraPull * 0.2) // Resistance when pulling up too far
                        } else {
                            offset = newOffset
                        }
                    }
                    .onEnded { value in
                        // Previous position before gesture ended
                        previousOffset = offset
                        
                        // Calculate velocity of movement
                        let predictedEndPosition = value.predictedEndTranslation.height
                        let velocity = predictedEndPosition - value.translation.height
                        
                        // Determine which position to snap to based on position and velocity
                        var targetPosition: CardPosition
                        
                        // If velocity is significant, prioritize direction
                        if abs(velocity) > 300 {
                            targetPosition = velocity < 0 ? .expanded : .collapsed
                        } else {
                            // Otherwise snap to nearest position
                            if offset < halfPosition / 2 {
                                targetPosition = .collapsed
                            } else if offset < (halfPosition + expandedPosition) / 2 {
                                targetPosition = .half
                            } else {
                                targetPosition = .expanded
                            }
                        }
                        
                        // Get target position value
                        let targetOffset: CGFloat
                        switch targetPosition {
                        case .collapsed:
                            targetOffset = collapsedPosition
                        case .half:
                            targetOffset = halfPosition
                        case .expanded:
                            targetOffset = expandedPosition
                        }
                        
                        // Animate to target position with spring and velocity
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                            offset = targetOffset
                            currentPosition = targetPosition
                        }
                        
                        // Store the new position
                        previousOffset = targetOffset
                        
                        // Generate haptic feedback when snapping
                        UIImpactFeedbackGenerator.generateFeedback(style: .medium)
                    }
            )
            .onAppear {
                // Initialize with collapsed state
                offset = collapsedPosition
                previousOffset = collapsedPosition
            }
            .onChange(of: currentPosition) { oldValue, newValue in
                if oldValue != newValue {
                    // Optional: Add more specific haptic feedback based on position change
                }
            }
        }
    }
}

struct EnhancedMealCard: View {
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
        HStack {
            // Progress circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Constants.Colors.calorieOrange, lineWidth: 3)
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 40, height: 40)
            
            // Meal info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text("\(calories)/\(goalCalories) kcal")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            // Macro bars
            VStack(spacing: 4) {
                MacroMiniBar(label: "P", progress: protein / proteinGoal)
                MacroMiniBar(label: "F", progress: fat / fatGoal)
                MacroMiniBar(label: "C", progress: carbs / carbsGoal)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct MacroMiniBar: View {
    let label: String
    let progress: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            // Macro progress bar
            GeometryReader { geo in
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Capsule()
                            .fill(Constants.Colors.turquoise)
                            .frame(width: geo.size.width * min(progress, 1.0))
                        , alignment: .leading
                    )
            }
            .frame(height: 8)
        }
        .frame(width: 80)
    }
}

struct ActionButton: View {
    let icon: String
    var color: Color = .gray
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
        }
    }
}

#Preview {
    CaloriesView(calorieModel: CalorieModel())
} 