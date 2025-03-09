//
//  SettingsView.swift
//  HalCal
//
//  Created by Claude on 3/9/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var calorieModel: CalorieModel
    @ObservedObject var hydrationModel: HydrationModel
    
    @State private var calorieGoal: String
    @State private var waterGoal: String
    
    // For confirmation dialogs
    @State private var showingCalorieResetConfirmation = false
    @State private var showingWaterResetConfirmation = false
    
    init(calorieModel: CalorieModel, hydrationModel: HydrationModel) {
        self.calorieModel = calorieModel
        self.hydrationModel = hydrationModel
        
        // Initialize text fields with current values
        _calorieGoal = State(initialValue: "\(calorieModel.calorieTarget)")
        _waterGoal = State(initialValue: String(format: "%.1f", hydrationModel.dailyGoal))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    List {
                        Section(header: Text("Goals")) {
                            // Calorie Goal
                            HStack {
                                Text("Calorie Goal")
                                    .foregroundColor(Constants.Colors.primaryText)
                                
                                Spacer()
                                
                                TextField("Calories", text: $calorieGoal)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(Constants.Colors.calorieOrange)
                                    .onChange(of: calorieGoal) { _, newValue in
                                        if let newGoal = Int(newValue) {
                                            calorieModel.calorieTarget = newGoal
                                            calorieModel.saveData()
                                        }
                                    }
                            }
                            
                            // Water Goal
                            HStack {
                                Text("Water Goal (L)")
                                    .foregroundColor(Constants.Colors.primaryText)
                                
                                Spacer()
                                
                                TextField("Liters", text: $waterGoal)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(Constants.Colors.turquoise)
                                    .onChange(of: waterGoal) { _, newValue in
                                        if let newGoal = Double(newValue) {
                                            hydrationModel.setDailyGoal(goal: newGoal)
                                        }
                                    }
                            }
                        }
                        .listRowBackground(Constants.Colors.surfaceLight)
                        
                        Section(header: Text("Reset Options")) {
                            // Reset Calories
                            Button(action: {
                                showingCalorieResetConfirmation = true
                            }) {
                                HStack {
                                    Text("Reset Today's Calories")
                                        .foregroundColor(Constants.Colors.primaryText)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(Constants.Colors.calorieOrange)
                                }
                            }
                            .confirmationDialog(
                                "Reset Calories?",
                                isPresented: $showingCalorieResetConfirmation,
                                titleVisibility: .visible
                            ) {
                                Button("Reset", role: .destructive) {
                                    resetCalories()
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text("This will reset all calories and macros tracked for today. This action cannot be undone.")
                            }
                            
                            // Reset Water
                            Button(action: {
                                showingWaterResetConfirmation = true
                            }) {
                                HStack {
                                    Text("Reset Today's Water")
                                        .foregroundColor(Constants.Colors.primaryText)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(Constants.Colors.turquoise)
                                }
                            }
                            .confirmationDialog(
                                "Reset Water?",
                                isPresented: $showingWaterResetConfirmation,
                                titleVisibility: .visible
                            ) {
                                Button("Reset", role: .destructive) {
                                    resetWater()
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text("This will reset all water intake tracked for today. This action cannot be undone.")
                            }
                        }
                        .listRowBackground(Constants.Colors.surfaceLight)
                    }
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func resetCalories() {
        calorieModel.resetData()
        
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func resetWater() {
        hydrationModel.resetForDay()
        
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    SettingsView(calorieModel: CalorieModel(), hydrationModel: HydrationModel())
} 