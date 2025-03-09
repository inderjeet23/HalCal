//
//  HomeView.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var calorieModel = CalorieModel()
    @StateObject private var hydrationModel = HydrationModel()
    @State private var showingAddCaloriesSheet = false
    @State private var showingSettingsSheet = false
    
    var body: some View {
        ZStack {
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
            
            VStack(spacing: 0) {
                // Header panel
                RoundedRectangle(cornerRadius: 10)
                    .fill(Constants.Gradients.metallicSurface)
                    .frame(height: 60)
                    .overlay(
                        HStack {
                            Text("HAL·CAL")
                                .font(Constants.Fonts.monospacedDigital)
                                .foregroundColor(Constants.Colors.primaryText)
                                .tracking(4)
                            
                            Spacer()
                            
                            // Date/time display
                            Text(formattedDateTime())
                                .font(Constants.Fonts.monospacedSmall)
                                .foregroundColor(Constants.Colors.primaryText)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Constants.Colors.surfaceLight)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                            
                            // Settings button
                            Button {
                                showingSettingsSheet = true
                            } label: {
                                Image(systemName: "gearshape")
                                    .font(.title2)
                                    .foregroundColor(Constants.Colors.primaryText)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Constants.Gradients.metallicButton)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [
                                                                Color.white.opacity(0.3),
                                                                Color.white.opacity(0.1),
                                                                Color.black.opacity(0.1),
                                                                Color.black.opacity(0.2)
                                                            ]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 1
                                                    )
                                            )
                                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                                    )
                            }
                        }
                        .padding(.horizontal)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                // Thin separator line
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 1)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // Main content area with calorie display and hydration gauge
                HStack(alignment: .center, spacing: 20) {
                    Spacer()
                    
                    // Main circular display in the center
                    CircularCalorieDisplay(
                        caloriesRemaining: calorieModel.caloriesRemaining,
                        totalCalories: calorieModel.dailyCalorieGoal,
                        calorieDeficit: calorieModel.calorieDeficit
                    )
                    .frame(width: 300, height: 300)
                    
                    Spacer()
                    
                    // Hydration gauge on the right
                    HydrationGauge(hydrationModel: hydrationModel)
                        .padding(.trailing, 20)
                }
                .padding(.vertical, 30)
                
                // Thin separator line
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 1)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
                Spacer()
                
                // Add calories button
                SkeuomorphicButton(
                    icon: "plus",
                    size: 80,
                    color: Constants.Colors.blue
                ) {
                    showingAddCaloriesSheet = true
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showingAddCaloriesSheet) {
            AddCaloriesView(calorieModel: calorieModel)
        }
        .sheet(isPresented: $showingSettingsSheet) {
            SettingsView(calorieModel: calorieModel, hydrationModel: hydrationModel)
        }
        .onDisappear {
            // Save data when view disappears
            calorieModel.saveData()
        }
    }
    
    private func statusLight(color: Color, label: String) -> some View {
        VStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: color.opacity(0.6), radius: 2, x: 0, y: 0)
            
            Text(label)
                .font(Constants.Fonts.monospacedLabel)
                .foregroundColor(Constants.Colors.primaryText)
                .tracking(1)
        }
    }
    
    private func formattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: Date())
    }
}

#Preview {
    HomeView()
} 