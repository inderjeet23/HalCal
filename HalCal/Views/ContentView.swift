//
//  ContentView.swift
//  HalCal
//
//  Created by Inderjeet Mander on 3/2/25.
//

import SwiftUI

enum AppTab {
    case meals, activity, water
}

struct ContentView: View {
    @StateObject private var calorieModel = CalorieModel()
    @StateObject private var hydrationModel = HydrationModel()
    @State private var selectedTab: AppTab = .meals
    @State private var showingAddSheet = false
    @State private var mealTypeForAdd: MealType = .snack
    
    // Track the state before adding new nutrients
    @State private var previousCalorieTotal: Int = 0
    @State private var previousProteinTotal: Double = 0.0
    @State private var previousCarbsTotal: Double = 0.0
    @State private var previousFatTotal: Double = 0.0
    
    // Tab bar height including safe area
    private let tabBarHeight: CGFloat = 80
    
    var body: some View {
        ZStack {
            // Background
            Constants.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Day selector with settings button
                HStack {
                    Button {
                        // Previous day action
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
                        // Next day action
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Progress display
                if selectedTab == .meals || selectedTab == .activity {
                    CalorieDonutChart(
                        totalCalories: calorieModel.calorieTarget,
                        remainingCalories: calorieModel.remainingCalories
                    )
                    .frame(height: 220)
                    .padding(.top, 20)
                } else if selectedTab == .water {
                    // Water progress display
                    // Keep this simple for now
                    Circle()
                        .stroke(Constants.Colors.turquoise, lineWidth: 20)
                        .frame(width: 200, height: 200)
                        .padding(.top, 20)
                        .overlay(
                            Text(String(format: "%.1f L", hydrationModel.currentHydration))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                
                // Tab selector
                HStack(spacing: 0) {
                    Button {
                        selectedTab = .meals
                    } label: {
                        VStack(spacing: 4) {
                            Text("Meals")
                                .font(.system(size: 16, weight: selectedTab == .meals ? .bold : .regular))
                                .foregroundColor(selectedTab == .meals ? .white : .gray)
                            
                            Rectangle()
                                .fill(selectedTab == .meals ? Constants.Colors.calorieAccent : Color.clear)
                                .frame(height: 3)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button {
                        selectedTab = .activity
                    } label: {
                        VStack(spacing: 4) {
                            Text("Activity")
                                .font(.system(size: 16, weight: selectedTab == .activity ? .bold : .regular))
                                .foregroundColor(selectedTab == .activity ? .white : .gray)
                            
                            Rectangle()
                                .fill(selectedTab == .activity ? Constants.Colors.calorieAccent : Color.clear)
                                .frame(height: 3)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button {
                        selectedTab = .water
                    } label: {
                        VStack(spacing: 4) {
                            Text("Water")
                                .font(.system(size: 16, weight: selectedTab == .water ? .bold : .regular))
                                .foregroundColor(selectedTab == .water ? .white : .gray)
                            
                            Rectangle()
                                .fill(selectedTab == .water ? Constants.Colors.calorieAccent : Color.clear)
                                .frame(height: 3)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 10)
                
                // Content based on selected tab
                ScrollView {
                    if selectedTab == .meals {
                        // Meal categories grid (preserve your existing code)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            MealCategoryCard(
                                icon: "☕️",
                                title: "Breakfast",
                                calories: calorieModel.getMealCalories(for: .breakfast),
                                color: Color(red: 0.9, green: 0.9, blue: 1.0)
                            ) {
                                mealTypeForAdd = .breakfast
                                showingAddSheet = true
                            }
                            
                            MealCategoryCard(
                                icon: "🥗",
                                title: "Lunch",
                                calories: calorieModel.getMealCalories(for: .lunch),
                                color: Color(red: 0.9, green: 1.0, blue: 0.9)
                            ) {
                                mealTypeForAdd = .lunch
                                showingAddSheet = true
                            }
                            
                            MealCategoryCard(
                                icon: "🍲",
                                title: "Dinner",
                                calories: calorieModel.getMealCalories(for: .dinner),
                                color: Color(red: 0.9, green: 1.0, blue: 1.0)
                            ) {
                                mealTypeForAdd = .dinner
                                showingAddSheet = true
                            }
                            
                            MealCategoryCard(
                                icon: "🥨",
                                title: "Snack",
                                calories: calorieModel.getMealCalories(for: .snack),
                                color: Color(red: 1.0, green: 0.9, blue: 1.0)
                            ) {
                                mealTypeForAdd = .snack
                                showingAddSheet = true
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Add spacing at bottom for floating button
                        Spacer().frame(height: 80)
                    } else if selectedTab == .activity {
                        // Display the Today's Meals list here
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Today's Meals")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.top, 20)
                            
                            VStack(spacing: 12) {
                                ForEach(getAllMealsSorted()) { meal in
                                    MealItemRow(meal: meal, onDelete: {
                                        deleteMeal(meal)
                                    })
                                    .padding(.horizontal)
                                }
                            }
                            
                            if getAllMealsSorted().isEmpty {
                                Text("No meals logged today")
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            // Add spacing at bottom for floating button
                            Spacer().frame(height: 80)
                        }
                    } else if selectedTab == .water {
                        // Water tracking view
                        VStack(spacing: 20) {
                            // Stats section
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("DAILY GOAL")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(String(format: "%.1f L", hydrationModel.dailyGoal))
                                        .font(.title3)
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("REMAINING")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(String(format: "%.1f L", max(0, hydrationModel.dailyGoal - hydrationModel.currentHydration)))
                                        .font(.title3)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            // Quick add buttons
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Add Water")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                                
                                HStack(spacing: 8) {
                                    ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { amount in
                                        Button {
                                            hydrationModel.addWater(amount: amount)
                                        } label: {
                                            Text("\(String(format: "%.2g", amount))L")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(Constants.Colors.turquoise)
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Remove water button
                            Button {
                                // Show remove water sheet
                            } label: {
                                Text("Remove Water")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                            
                            // Add spacing at bottom for floating button
                            Spacer().frame(height: 80)
                        }
                    }
                }
            }
            
            // Floating action button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Constants.Colors.calorieAccent)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            if selectedTab == .water {
                // Show water add sheet
                addWaterSheet
            } else {
                // Show food add sheet
                AddCaloriesView(calorieModel: calorieModel, initialMealType: mealTypeForAdd)
            }
        }
    }
    
    // MARK: - Helper properties and methods
    
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
    
    // Water add sheet view
    private var addWaterSheet: some View {
        VStack {
            Text("Add Water")
                .font(Constants.Fonts.sectionHeader)
                .padding(.top, 20)
            
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