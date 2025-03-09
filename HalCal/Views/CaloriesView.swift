//
//  CaloriesView.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

struct CaloriesView: View {
    @ObservedObject var calorieModel: CalorieModel
    @State private var selectedDay: Date = Date()
    @State private var showingSettings = false
    @State private var showingAddSheet = false
    @State private var mealTypeForAdd: MealType = .snack
    
    // Sample username - in a real app, this would come from UserProfileManager
    private let username = "Inder"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Day selector with settings button
                HStack {
                    Button {
                        subtractDay()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text(dayFormatter.string(from: selectedDay))
                        .font(Constants.Fonts.primaryLabel)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack {
                        Button {
                            addDay()
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                        }
                        
                        // Settings button
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white)
                                .padding(.leading, 8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Personal greeting
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hello,")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.gray.opacity(0.8))
                        
                        Text(username)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Date display
                    Text("\(dayNumber)\n\(dayMonth)")
                        .font(.system(size: 16, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Calorie visualization - donut chart
                CalorieDonutChart(
                    totalCalories: calorieModel.calorieTarget,
                    remainingCalories: calorieModel.remainingCalories
                )
                .frame(height: 220)
                .padding(.vertical, 10)
                
                // Tab selector for this view
                HStack(spacing: 24) {
                    TabButton(title: "Meals", isSelected: true)
                    TabButton(title: "Activity", isSelected: false)
                    TabButton(title: "Water", isSelected: false)
                }
                .padding(.horizontal)
                
                // Meal categories grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    MealCategoryCard(
                        icon: "☕️",
                        title: "Breakfast",
                        calories: calorieModel.getMealCalories(for: .breakfast),
                        color: Color(red: 0.9, green: 0.9, blue: 1.0) // Light blue
                    ) {
                        // Open add sheet with breakfast pre-selected
                        mealTypeForAdd = .breakfast
                        showingAddSheet = true
                    }
                    
                    MealCategoryCard(
                        icon: "🥗",
                        title: "Lunch",
                        calories: calorieModel.getMealCalories(for: .lunch),
                        color: Color(red: 0.9, green: 1.0, blue: 0.9) // Light green
                    ) {
                        // Open add sheet with lunch pre-selected
                        mealTypeForAdd = .lunch
                        showingAddSheet = true
                    }
                    
                    MealCategoryCard(
                        icon: "🍲",
                        title: "Dinner",
                        calories: calorieModel.getMealCalories(for: .dinner),
                        color: Color(red: 0.9, green: 1.0, blue: 1.0) // Light cyan
                    ) {
                        // Open add sheet with dinner pre-selected
                        mealTypeForAdd = .dinner
                        showingAddSheet = true
                    }
                    
                    MealCategoryCard(
                        icon: "🥨",
                        title: "Snack",
                        calories: calorieModel.getMealCalories(for: .snack),
                        color: Color(red: 1.0, green: 0.9, blue: 1.0) // Light purple
                    ) {
                        // Open add sheet with snack pre-selected
                        mealTypeForAdd = .snack
                        showingAddSheet = true
                    }
                }
                .padding(.horizontal)
                
                // Recent meals section
                if hasAnyMeals() {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Meals")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(getAllMealsSorted()) { meal in
                                MealItemRow(meal: meal, onDelete: {
                                    deleteMeal(meal)
                                })
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                }
                
                // Add extra padding at bottom to ensure content isn't hidden by tab bar
                Color.clear.frame(height: 100)
            }
        }
        .background(Constants.Colors.background)
        .sheet(isPresented: $showingSettings) {
            SettingsView(calorieModel: calorieModel, hydrationModel: HydrationModel())
        }
        .sheet(isPresented: $showingAddSheet) {
            // Pass the pre-selected meal type to AddCaloriesView
            AddCaloriesView(calorieModel: calorieModel, initialMealType: mealTypeForAdd)
        }
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: selectedDay)
    }
    
    private var dayMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: selectedDay)
    }
    
    private func addDay() {
        withAnimation {
            selectedDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDay) ?? selectedDay
        }
    }
    
    private func subtractDay() {
        withAnimation {
            selectedDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDay) ?? selectedDay
        }
    }
    
    // Check if there are any meals
    private func hasAnyMeals() -> Bool {
        let allMeals = getAllMealsSorted()
        return !allMeals.isEmpty
    }
    
    // Get all meals sorted by time (most recent first)
    private func getAllMealsSorted() -> [Meal] {
        let allMeals = MealType.allCases.flatMap { calorieModel.meals[$0] ?? [] }
        return allMeals.sorted(by: { $0.time > $1.time })
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

// Tab button for meal/activity/water selector
struct TabButton: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: isSelected ? .bold : .medium))
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.bottom, 8)
            .overlay(
                Rectangle()
                    .frame(height: 3)
                    .foregroundColor(isSelected ? Constants.Colors.calorieAccent : .clear)
                    .offset(y: 4),
                alignment: .bottom
            )
    }
}

// Preview
#Preview {
    CaloriesView(calorieModel: CalorieModel())
} 