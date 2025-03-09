//
//  ContentView.swift
//  HalCal
//
//  Created by Inderjeet Mander on 3/2/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var calorieModel = CalorieModel()
    @StateObject private var hydrationModel = HydrationModel()
    @State private var selectedTab: TabItem = .calories
    @State private var showingAddSheet = false
    @State private var mealTypeForAdd: MealType = .snack
    
    // Track the state before adding new nutrients
    @State private var previousCalorieTotal: Int = 0
    @State private var previousProteinTotal: Double = 0.0
    @State private var previousCarbsTotal: Double = 0.0
    @State private var previousFatTotal: Double = 0.0
    
    // Sample meals - in a real app, these would come from persistent storage
    @State private var meals: [Meal] = []
    
    // Tab bar height including safe area
    private let tabBarHeight: CGFloat = 80
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background with subtle texture
            Constants.Colors.background
                .ignoresSafeArea()
            
            // Main content area
            VStack(spacing: 0) {
                // Calories Tab
                if selectedTab == .calories {
                    ScrollView {
                        VStack(spacing: Constants.Layout.componentSpacing) {
                            // Date navigation
                            HStack {
                                Button {
                                    // Previous day
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
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
                                }
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
                            
                            // Meal categories grid - ORIGINAL LAYOUT
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
                            
                            // Add extra padding at bottom for floating button
                            Spacer().frame(height: 80)
                        }
                    }
                }
                
                // ACTIVITY Tab (with slim meal cards)
                if selectedTab == .activity {
                    ScrollView {
                        VStack(spacing: Constants.Layout.componentSpacing) {
                            // Date navigation
                            HStack {
                                Button {
                                    // Previous day
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
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
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            // Summary section (Calories)
                            VStack(spacing: 8) {
                                // Main calorie circle
                                ZStack {
                                    // Background track
                                    Circle()
                                        .stroke(
                                            Constants.Colors.surfaceLight,
                                            lineWidth: 18
                                        )
                                        .frame(width: 200, height: 200)
                                    
                                    // Progress
                                    Circle()
                                        .trim(from: 0, to: CGFloat(min(calorieModel.consumedCalories, calorieModel.calorieTarget)) / CGFloat(calorieModel.calorieTarget))
                                        .stroke(
                                            Constants.Colors.turquoise,
                                            style: StrokeStyle(lineWidth: 18, lineCap: .round)
                                        )
                                        .frame(width: 200, height: 200)
                                        .rotationEffect(.degrees(-90))
                                    
                                    // Remaining text
                                    VStack(spacing: 4) {
                                        Text("Left")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                        
                                        Text("\(calorieModel.remainingCalories) kcal")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.top, 16)
                                
                                // Summary stats
                                HStack(spacing: 40) {
                                    // Plan
                                    VStack {
                                        Text("Plan")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        
                                        Text("\(calorieModel.calorieTarget) kcal")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    
                                    // Consumed
                                    VStack {
                                        Text("Consumed")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        
                                        Text("\(calorieModel.consumedCalories) kcal")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Constants.Colors.calorieOrange)
                                    }
                                }
                                .padding(.vertical, 12)
                            }
                            .padding(.bottom, 8)
                            
                            // Divider
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                                .padding(.horizontal)
                            
                            // Meal list section
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Today's Meals")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    // Total calories display
                                    Text("\(getAllMealCalories()) kcal")
                                        .font(.subheadline)
                                        .foregroundColor(Constants.Colors.calorieOrange)
                                        .bold()
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                
                                // Display empty state if no meals
                                if !hasAnyMeals() {
                                    emptyMealCards()
                                } else {
                                    // Dynamic meals from data model
                                    ForEach(getAllMealsSorted()) { meal in
                                        SlimMealCard(meal: meal) {
                                            withAnimation {
                                                deleteMeal(meal)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }
                            .padding(.bottom, tabBarHeight + 20) // Provide space for tab bar
                        }
                    }
                }
                
                // Hydration Tab
                if selectedTab == .hydration {
                    HydrationView(hydrationModel: hydrationModel)
                        .transition(.opacity)
                        .padding(.bottom, tabBarHeight) // Add padding to make space for tab bar
                }
            }
            .ignoresSafeArea(.keyboard)
            
            // Tab bar
            TabBarWithContextualAdd(
                selectedTab: $selectedTab,
                addAction: {
                    // Store current nutrition totals before adding
                    storeCurrentNutritionValues()
                    showingAddSheet = true
                }
            )
            .background(Color.clear)
            .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(isPresented: $showingAddSheet) {
            if selectedTab == .calories {
                AddCaloriesView(calorieModel: calorieModel, initialMealType: mealTypeForAdd)
            } else if selectedTab == .hydration {
                // Add water sheet
                addWaterSheet
            }
        }
        .onDisappear {
            // Save data when view disappears
            calorieModel.saveData()
            hydrationModel.saveData()
        }
    }
    
    // Display empty meal cards for each meal type
    private func emptyMealCards() -> some View {
        VStack(spacing: 8) {
            ForEach(MealType.allCases, id: \.self) { mealType in
                emptyMealCard(for: mealType)
            }
        }
    }
    
    // Create an empty meal card for a specific meal type
    private func emptyMealCard(for mealType: MealType) -> some View {
        // Return pastel color based on meal type
        let mealTypeColor: Color = {
            switch mealType {
            case .breakfast:
                return Color(red: 0.9, green: 0.9, blue: 1.0) // Light lavender
            case .lunch:
                return Color(red: 0.9, green: 1.0, blue: 0.9) // Light mint
            case .dinner:
                return Color(red: 0.9, green: 1.0, blue: 1.0) // Light cyan
            case .snack:
                return Color(red: 1.0, green: 0.9, blue: 0.9) // Light pink
            }
        }()
        
        // Return icon name based on meal type
        let mealTypeIcon: String = {
            switch mealType {
            case .breakfast: return "sunrise.fill"
            case .lunch: return "sun.max.fill" 
            case .dinner: return "sunset.fill"
            case .snack: return "cup.and.saucer.fill"
            }
        }()
        
        return HStack {
            // Icon
            ZStack {
                Circle()
                    .fill(mealTypeColor)
                    .frame(width: 36, height: 36)
                
                Image(systemName: mealTypeIcon)
                    .foregroundColor(Constants.Colors.turquoise)
                    .font(.system(size: 16))
            }
            
            // Meal name
            Text(mealType.rawValue)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Text("0 kcal")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
            
            // Add button
            Button {
                showingAddSheet = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Constants.Colors.turquoise)
                    .font(.system(size: 24))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
            .fill(Constants.Colors.surfaceLight)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(mealTypeColor.opacity(0.3), lineWidth: 1)
            )
        )
        .padding(.horizontal, 16)
    }
    
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
    
    // Helper function to store current nutrition values
    private func storeCurrentNutritionValues() {
        previousCalorieTotal = calorieModel.consumedCalories
        previousProteinTotal = calorieModel.consumedProtein
        previousCarbsTotal = calorieModel.consumedCarbs
        previousFatTotal = calorieModel.consumedFat
    }
    
    // Water add sheet view
    private var addWaterSheet: some View {
        VStack {
            Text("Add Water")
                .font(Constants.Fonts.sectionHeader)
            
            // Quick add buttons
            HStack(spacing: Constants.Layout.elementSpacing) {
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { amount in
                    Button {
                        hydrationModel.addWater(amount: amount)
                        showingAddSheet = false
                    } label: {
                        Text("\(String(format: "%.2g", amount))L")
                            .font(Constants.Fonts.primaryLabel)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Constants.Colors.turquoise)
                            .cornerRadius(Constants.Layout.cornerRadius)
                    }
                }
            }
            .padding()
        }
        .presentationDetents([.height(200)])
    }
}

#Preview {
    ContentView()
}