//
//  ContentView.swift
//  HalCal
//
//  Created by Inderjeet Mander on 3/2/25.
//

import SwiftUI
import UIKit // Added for haptic feedback

// Sample meal data structure
struct Meal: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let time: Date
    let type: MealType
}

struct ContentView: View {
    @StateObject private var calorieModel = CalorieModel()
    @StateObject private var hydrationModel = HydrationModel()
    @State private var selectedTab: TabItem = .calories
    @State private var showingAddSheet = false
    @State private var previousCalorieTotal: Int = 0 // Track previous calorie total
    
    // Sample meals - in a real app, these would come from CalorieModel
    @State private var meals: [Meal] = []
    
    // Tab bar height including safe area
    private let tabBarHeight: CGFloat = 80 // Updated to match the new tab bar height
    
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
                            // Display CaloriesView at the top
                            CaloriesView(calorieModel: calorieModel)
                                .transition(.opacity)
                            
                            // Meal list section
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Today's Meals")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    // Total calories display
                                    Text("\(meals.reduce(0) { $0 + $1.calories }) kcal")
                                        .font(.subheadline)
                                        .foregroundColor(Constants.Colors.calorieOrange)
                                        .bold()
                                }
                                
                                // Dynamic meals from data model
                                if meals.isEmpty {
                                    Text("No meals logged today")
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 20)
                                } else {
                                    ForEach(meals.sorted(by: { $0.time > $1.time })) { meal in
                                        HStack {
                                            // Circle with meal type icon
                                            Circle()
                                                .fill(Constants.Colors.calorieOrange.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Image(systemName: mealTypeIcon(for: meal.type))
                                                        .foregroundColor(Constants.Colors.calorieOrange)
                                                )
                                            
                                            VStack(alignment: .leading) {
                                                Text(meal.name)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white)
                                                
                                                Text("\(meal.calories) calories • \(timeFormatter.string(from: meal.time))")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            // Delete button
                                            Button(action: {
                                                withAnimation {
                                                    deleteMeal(meal)
                                                }
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 16))
                                                    .padding(8)
                                            }
                                        }
                                        .padding(12)
                                        .background(Color.black.opacity(0.2))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
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
            
            // Simple tab bar (no card functionality)
            TabBarWithContextualAdd(
                selectedTab: $selectedTab,
                addAction: {
                    // Store current calorie total before adding
                    previousCalorieTotal = calorieModel.consumedCalories
                    showingAddSheet = true
                }
            )
            .background(Color.clear) // No background needed with the new design
            .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(isPresented: $showingAddSheet) {
            if selectedTab == .calories {
                AddCaloriesView(calorieModel: calorieModel)
                    .onDisappear {
                        // Only add a meal if calories were actually added during this session
                        let caloriesAdded = calorieModel.consumedCalories - previousCalorieTotal
                        if caloriesAdded > 0 {
                            addMeal(calories: caloriesAdded)
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
        .onDisappear {
            // Save data when view disappears
            calorieModel.saveData()
            hydrationModel.saveData()
        }
    }
    
    // Format time for display
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
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
    
    // Delete a meal
    private func deleteMeal(_ meal: Meal) {
        withAnimation {
            meals.removeAll(where: { $0.id == meal.id })
            
            // Update the model
            calorieModel.consumedCalories -= meal.calories
            calorieModel.saveData()
        }
    }
    
    // Add a meal with specific calories
    private func addMeal(calories: Int) {
        withAnimation {
            // Create a meal with the actual calories added
            let newMeal = Meal(
                name: getMealNameBasedOnTime(),
                calories: calories,
                time: Date(),
                type: getMealTypeBasedOnTime()
            )
            
            meals.append(newMeal)
        }
    }
    
    // Get appropriate meal name based on time of day
    private func getMealNameBasedOnTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 11 {
            return "Breakfast"
        } else if hour < 15 {
            return "Lunch"
        } else if hour < 20 {
            return "Dinner"
        } else {
            return "Evening Snack"
        }
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