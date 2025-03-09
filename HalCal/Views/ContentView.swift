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
    @State private var cardPosition: CardPosition = .collapsed
    
    // Sample meals - in a real app, these would come from CalorieModel
    @State private var meals: [Meal] = [
        Meal(name: "Breakfast", calories: 450, time: Date().addingTimeInterval(-60*60*3), type: .breakfast),
        Meal(name: "Protein Shake", calories: 200, time: Date().addingTimeInterval(-60*60*2), type: .snack),
        Meal(name: "Lunch", calories: 650, time: Date().addingTimeInterval(-60*60), type: .lunch)
    ]
    
    // Tab bar height including safe area
    private let tabBarHeight: CGFloat = 100
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background with subtle texture
            Constants.Colors.background
                .ignoresSafeArea()
                .overlay(
                    // Subtle noise texture
                    Image("noiseTexture")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .blendMode(.overlay)
                        .opacity(0.03)
                        .ignoresSafeArea()
                )
            
            // Main content area
            VStack(spacing: 0) {
                // Calories Tab
                if selectedTab == .calories {
                    CaloriesView(calorieModel: calorieModel)
                        .transition(.opacity)
                }
                
                // Hydration Tab
                if selectedTab == .hydration {
                    HydrationView(hydrationModel: hydrationModel)
                        .transition(.opacity)
                }
            }
            .ignoresSafeArea(.keyboard)
            .padding(.bottom, tabBarHeight) // Add padding to make space for tab bar
            
            // Integrated tab and card component with improved layout
            IntegratedTabCardView(
                selectedTab: $selectedTab,
                cardPosition: $cardPosition,
                addAction: {
                    showingAddSheet = true
                }
            ) {
                // Card content
                VStack(spacing: 16) {
                    HStack {
                        Text("Today's Meals")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Total calories display
                        Text("\(meals.reduce(0) { $0 + $1.calories }) kcal")
                            .font(.subheadline)
                            .foregroundColor(Constants.Colors.calorieOrange)
                            .bold()
                    }
                    .padding(.top, 4)
                    
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
                                        .foregroundColor(.black)
                                    
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
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .edgesIgnoringSafeArea(.bottom) // Make sure it extends to bottom edge
        }
        .sheet(isPresented: $showingAddSheet) {
            if selectedTab == .calories {
                AddCaloriesView(calorieModel: calorieModel)
                    .onDisappear {
                        // When sheet is dismissed, add a meal based on entered data
                        if calorieModel.consumedCalories > 0 {
                            addSampleMeal()
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
    
    // Add a sample meal for testing
    private func addSampleMeal() {
        withAnimation {
            // Create a new meal based on the selected meal type
            let newMeal = Meal(
                name: selectedTab == .calories ? "New Meal" : "Water",
                calories: 300,
                time: Date(),
                type: .snack
            )
            
            meals.append(newMeal)
            
            // Show the card if it was collapsed
            if cardPosition == .collapsed {
                cardPosition = .half
            }
        }
    }
}

#Preview {
    ContentView()
}