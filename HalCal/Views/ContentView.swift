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
    @StateObject private var activityModel = ActivityModel()
    
    @State private var selectedTab: TabItem = .calories
    @State private var showingAddSheet = false
    @State private var showingSettingsSheet = false
    @State private var mealTypeForAdd: MealType = .snack
    
    // Track the state before adding new nutrients
    @State private var previousCalorieTotal: Int = 0
    @State private var previousProteinTotal: Double = 0.0
    @State private var previousCarbsTotal: Double = 0.0
    @State private var previousFatTotal: Double = 0.0
    
    // Sample meals - in a real app, these would come from persistent storage
    @State private var meals: [Meal] = []
    
    // Tab bar height including safe area
    private let tabBarHeight: CGFloat = 90
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Constants.Colors.background
                .ignoresSafeArea()
                
            // Content based on selected tab
            VStack(spacing: 0) {
                // Calories Tab
                if selectedTab == .calories {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Date navigation
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
                            .padding(.bottom, 10)
                            
                            // Circle progress
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
                            .padding(.bottom, 10)
                            
                            // Meal cards grid
                            VStack(spacing: 10) {
                                // Two-column grid for meal cards
                                HStack(spacing: 10) {
                                    // Breakfast
                                    mealCard(
                                        mealType: .breakfast,
                                        calories: getMealCalories(for: .breakfast),
                                        backgroundColor: Color(red: 0.9, green: 0.9, blue: 1.0)
                                    )
                                    
                                    // Lunch
                                    mealCard(
                                        mealType: .lunch,
                                        calories: getMealCalories(for: .lunch),
                                        backgroundColor: Color(red: 0.9, green: 1.0, blue: 0.9)
                                    )
                                }
                                
                                HStack(spacing: 10) {
                                    // Dinner
                                    mealCard(
                                        mealType: .dinner,
                                        calories: getMealCalories(for: .dinner),
                                        backgroundColor: Color(red: 0.9, green: 1.0, blue: 1.0)
                                    )
                                    
                                    // Snack
                                    mealCard(
                                        mealType: .snack,
                                        calories: getMealCalories(for: .snack),
                                        backgroundColor: Color(red: 1.0, green: 0.9, blue: 0.9)
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, tabBarHeight + 20) // Extra space at bottom for tab bar
                        }
                    }
                    .padding(.top, 1) // Tiny padding to prevent content shift
                }
                
                // Activity Tab
                else if selectedTab == .activity {
                    ActivityView(activityModel: activityModel)
                        .transition(.opacity)
                        .padding(.bottom, tabBarHeight) // Make space for tab bar
                }
                
                // Hydration Tab
                else if selectedTab == .hydration {
                    HydrationView(hydrationModel: hydrationModel)
                        .transition(.opacity)
                        .padding(.bottom, tabBarHeight) // Make space for tab bar
                }
            }
            
            // Tab bar - positioned at bottom
            TabBarWithSettingsAndAdd(
                selectedTab: $selectedTab,
                addAction: {
                    // Store current nutrition totals before adding
                    storeCurrentNutritionValues()
                    showingAddSheet = true
                },
                settingsAction: {
                    showingSettingsSheet = true
                }
            )
            .edgesIgnoringSafeArea(.bottom)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingAddSheet) {
            if selectedTab == .calories {
                AddCaloriesView(calorieModel: calorieModel, initialMealType: mealTypeForAdd)
                    .onDisappear {
                        // Calculate what was added during this session
                        let caloriesAdded = calorieModel.consumedCalories - previousCalorieTotal
                        let proteinAdded = calorieModel.consumedProtein - previousProteinTotal
                        let carbsAdded = calorieModel.consumedCarbs - previousCarbsTotal 
                        let fatAdded = calorieModel.consumedFat - previousFatTotal
                        
                        // Get the most recently added meal from the CalorieModel
                        let allMeals: [Meal] = [MealType.breakfast, .lunch, .dinner, .snack]
                            .flatMap { calorieModel.meals[$0] ?? [] }
                        
                        if let lastAddedMeal = allMeals.sorted(by: { $0.time > $1.time }).first {
                            // Only add a meal if something was added
                            if caloriesAdded > 0 || proteinAdded > 0 || carbsAdded > 0 || fatAdded > 0 {
                                addMealWithNutrients(
                                    calories: caloriesAdded,
                                    protein: proteinAdded,
                                    carbs: carbsAdded,
                                    fat: fatAdded,
                                    mealType: lastAddedMeal.type
                                )
                            }
                        }
                    }
            } else if selectedTab == .hydration {
                // Add water sheet
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
        .sheet(isPresented: $showingSettingsSheet) {
            SettingsView(calorieModel: calorieModel, hydrationModel: hydrationModel)
        }
        .onDisappear {
            // Save data when view disappears
            calorieModel.saveData()
            hydrationModel.saveData()
        }
    }
    
    // Helper to create a meal card
    private func mealCard(mealType: MealType, calories: Int, backgroundColor: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(backgroundColor.opacity(0.5), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                // Top row with icon and add button
                HStack {
                    // Meal icon
                    Image(systemName: mealTypeIcon(for: mealType))
                        .foregroundColor(.black)
                        .font(.system(size: 14))
                        .frame(width: 30, height: 30)
                    
                    Spacer()
                    
                    // Add button
                    Button {
                        mealTypeForAdd = mealType
                        showingAddSheet = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Constants.Colors.turquoise.opacity(0.3))
                                .frame(width: 30, height: 30)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Constants.Colors.turquoise)
                        }
                    }
                }
                
                Spacer()
                
                // Name and calories
                Text(mealType.rawValue)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("\(calories) kcal")
                    .font(.system(size: 16))
                    .foregroundColor(calories > 0 ? Constants.Colors.calorieAccent : .gray)
            }
            .padding(12)
        }
        .frame(height: 130)
    }
    
    // Get icon for meal type
    private func mealTypeIcon(for type: MealType) -> String {
        switch type {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "sunset.fill"
        case .snack: return "cup.and.saucer.fill"
        }
    }
    
    // Get total calories for a specific meal type
    private func getMealCalories(for mealType: MealType) -> Int {
        let mealsOfType = calorieModel.meals[mealType] ?? []
        return mealsOfType.reduce(0) { $0 + $1.calories }
    }
    
    // Helper function to store current nutrition values
    private func storeCurrentNutritionValues() {
        previousCalorieTotal = calorieModel.consumedCalories
        previousProteinTotal = calorieModel.consumedProtein
        previousCarbsTotal = calorieModel.consumedCarbs
        previousFatTotal = calorieModel.consumedFat
    }
    
    // Delete a meal
    private func deleteMeal(_ meal: Meal) {
        meals.removeAll(where: { $0.id == meal.id })
        
        // Update the model - remove the calories and macros
        calorieModel.consumedCalories -= meal.calories
        calorieModel.consumedProtein -= meal.protein
        calorieModel.consumedCarbs -= meal.carbs
        calorieModel.consumedFat -= meal.fat
        calorieModel.saveData()
    }
    
    // Add a meal with all nutrient data
    private func addMealWithNutrients(calories: Int, protein: Double, carbs: Double, fat: Double, mealType: MealType? = nil) {
        // Determine meal type - use provided or guess based on time
        let type = mealType ?? getMealTypeBasedOnTime()
        
        // Create a meal with the actual nutrients added
        let newMeal = Meal(
            name: type.rawValue, // Use the raw value of the meal type enum as the name
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            time: Date(),
            type: type
        )
        
        meals.append(newMeal)
    }
    
    // Get appropriate meal type based on time of day
    private func getMealTypeBasedOnTime() -> MealType {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 11 {
            return .breakfast
        } else if hour < 15 {
            return .lunch
        } else if hour < 20 {
            return .dinner
        } else {
            return .snack
        }
    }
}

#Preview {
    ContentView()
}