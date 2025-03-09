//
//  ActivityView.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

// MARK: - Activity View
struct ActivityView: View {
    @ObservedObject var activityModel: ActivityModel
    @ObservedObject var calorieModel = CalorieModel()
    @State private var showingAddStepsSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Date navigation header
                HStack {
                    Button {
                        // Previous day
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(8)
                    }
                    
                    Spacer()
                    
                    Text("Sunday, Mar 9")
                        .font(Constants.Fonts.primaryLabel)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        // Next day
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .padding(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Activity rings or summary section
                VStack(spacing: 16) {
                    Text("Today's Activity")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Activity metrics grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        activityMetricCard(
                            title: "Steps",
                            value: activityModel.steps,
                            goal: activityModel.dailyStepGoal,
                            unit: "",
                            progress: activityModel.stepProgress,
                            color: .blue
                        )
                        
                        activityMetricCard(
                            title: "Exercise",
                            value: activityModel.exerciseMinutes,
                            goal: activityModel.dailyExerciseGoal,
                            unit: "min",
                            progress: activityModel.exerciseProgress,
                            color: .green
                        )
                        
                        activityMetricCard(
                            title: "Active Calories",
                            value: activityModel.activeCalories,
                            goal: activityModel.dailyActiveCalorieGoal,
                            unit: "cal",
                            progress: activityModel.calorieProgress,
                            color: Constants.Colors.calorieAccent
                        )
                        
                        activityMetricCard(
                            title: "Stand Hours",
                            value: activityModel.standHours,
                            goal: activityModel.dailyStandGoal,
                            unit: "hr",
                            progress: activityModel.standProgress,
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal)
                
                // Meal activity feed using SlimMealCard
                VStack(spacing: 12) {
                    HStack {
                        Text("Today's Meals")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Total calories display
                        Text("\(getAllMealCalories()) kcal")
                            .font(.subheadline)
                            .foregroundColor(Constants.Colors.calorieAccent)
                            .bold()
                    }
                    .padding(.horizontal)
                    
                    // Display empty state if no meals
                    if !hasAnyMeals() {
                        Text("No meals logged today")
                            .foregroundColor(.gray)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                    } else {
                        // Meals list with SlimMealCard
                        ForEach(getAllMealsSorted()) { meal in
                            SlimMealCard(meal: meal) {
                                withAnimation {
                                    deleteMeal(meal)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Add extra padding at bottom for tab bar
                Spacer().frame(height: 100)
            }
        }
        .background(Constants.Colors.background)
        .sheet(isPresented: $showingAddStepsSheet) {
            // A simple sheet to add steps
            VStack(spacing: 16) {
                Text("Add Steps")
                    .font(.headline)
                    .padding()
                
                TextField("Number of steps", text: Binding(
                    get: { "" },
                    set: { if let value = Int($0) { activityModel.addActivity(steps: value) } }
                ))
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
                
                Button("Add") {
                    showingAddStepsSheet = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .presentationDetents([.height(250)])
        }
    }
    
    // MARK: - Activity Metric Card
    private func activityMetricCard(title: String, value: Int, goal: Int, unit: String, progress: Double, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Constants.Colors.surfaceLight)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: progress)
                    
                    VStack(spacing: 0) {
                        Text("\(value)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        if !unit.isEmpty {
                            Text(unit)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(width: 70, height: 70)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color)
            }
            .padding(12)
        }
    }
    
    // MARK: - Helper methods for meal cards
    
    // Get all meals sorted by time (most recent first)
    private func getAllMealsSorted() -> [Meal] {
        let allMeals = MealType.allCases.flatMap { calorieModel.meals[$0] ?? [] }
        return allMeals.sorted(by: { $0.time > $1.time })
    }
    
    // Check if there are any meals
    private func hasAnyMeals() -> Bool {
        let allMeals = getAllMealsSorted()
        return !allMeals.isEmpty
    }
    
    // Get total calories from all meals
    private func getAllMealCalories() -> Int {
        let allMeals = getAllMealsSorted()
        return allMeals.reduce(0) { $0 + $1.calories }
    }
    
    // Delete a meal
    private func deleteMeal(_ meal: Meal) {
        // Remove the meal from the model
        if var meals = calorieModel.meals[meal.type], let index = meals.firstIndex(where: { $0.id == meal.id }) {
            // Subtract the meal's nutrients from the total
            calorieModel.consumedCalories -= meal.calories
            calorieModel.consumedProtein -= meal.protein
            calorieModel.consumedCarbs -= meal.carbs
            calorieModel.consumedFat -= meal.fat
            
            // Remove the meal from the array
            meals.remove(at: index)
            calorieModel.meals[meal.type] = meals
            
            // Save the updated data
            calorieModel.saveData()
        }
    }
}

// MARK: - SlimMealCard 
struct SlimMealCard: View {
    let meal: Meal
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            // Meal icon
            ZStack {
                Circle()
                    .fill(mealTypeColor(for: meal.type).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: mealTypeIcon(for: meal.type))
                    .foregroundColor(mealTypeColor(for: meal.type))
            }
            .padding(.trailing, 8)
            
            // Meal info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                HStack {
                    Text("\(meal.calories) kcal")
                        .font(.system(size: 14))
                        .foregroundColor(Constants.Colors.calorieAccent)
                    
                    Spacer()
                    
                    // Time
                    Text(formattedTime(from: meal.time))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.8))
                    .font(.system(size: 14))
                    .padding(8)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Constants.Colors.surfaceLight)
        )
    }
    
    // Helper function to get color for meal type
    private func mealTypeColor(for type: MealType) -> Color {
        switch type {
        case .breakfast: return .blue
        case .lunch: return .green
        case .dinner: return .orange
        case .snack: return .purple
        }
    }
    
    // Helper function to get icon for meal type
    private func mealTypeIcon(for type: MealType) -> String {
        switch type {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "sunset.fill"
        case .snack: return "cup.and.saucer.fill"
        }
    }
    
    // Helper function to format time
    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    ActivityView(activityModel: ActivityModel())
        .preferredColorScheme(.dark)
} 