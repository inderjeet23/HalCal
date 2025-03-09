//
//  ActivityPanel.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

struct ActivityPanel: View {
    @ObservedObject var activityModel: ActivityModel
    
    private var stepsPercentage: Double {
        min(Double(activityModel.steps) / Double(activityModel.dailyStepGoal), 1.0)
    }
    
    private var standHoursPercentage: Double {
        min(Double(activityModel.standHours) / Double(activityModel.dailyStandGoal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Panel header
            HStack {
                Text("ACTIVITY MONITOR")
                    .font(Constants.Fonts.monospacedSmall)
                    .foregroundColor(Constants.Colors.primaryText)
                    .tracking(1)
                
                Spacer()
                
                // Status indicator
                Circle()
                    .fill(Constants.Colors.blue)
                    .frame(width: 6, height: 6)
                    .shadow(color: Constants.Colors.blue.opacity(0.7), radius: 3, x: 0, y: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Constants.Gradients.metallicSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
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
                    .overlay(
                        // Corner rivets
                        ZStack {
                            // Top left
                            Circle()
                                .fill(Constants.Gradients.metallicButton)
                                .frame(width: 5, height: 5)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                                )
                                .offset(x: -70, y: -12)
                            
                            // Top right
                            Circle()
                                .fill(Constants.Gradients.metallicButton)
                                .frame(width: 5, height: 5)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                                )
                                .offset(x: 70, y: -12)
                        }
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            )
            
            // Steps counter
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("STEPS")
                        .font(Constants.Fonts.monospacedSmall)
                        .foregroundColor(Constants.Colors.primaryText)
                    
                    Spacer()
                    
                    Text("\(activityModel.steps)")
                        .font(Constants.Fonts.monospacedDigital)
                        .foregroundColor(Constants.Colors.blue)
                }
                
                // Progress bar
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Constants.Colors.blue)
                        .frame(width: max(CGFloat(stepsPercentage) * 150, 0), height: 8)
                }
                
                // Goal text
                Text("GOAL: \(activityModel.dailyStepGoal)")
                    .font(Constants.Fonts.monospacedLabel)
                    .foregroundColor(Constants.Colors.secondaryText)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Constants.Colors.surfaceLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Constants.Gradients.metallicRim, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            )
            
            // Active hours
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("ACTIVE HOURS")
                        .font(Constants.Fonts.monospacedSmall)
                        .foregroundColor(Constants.Colors.primaryText)
                    
                    Spacer()
                    
                    Text("\(activityModel.standHours)")
                        .font(Constants.Fonts.monospacedDigital)
                        .foregroundColor(Constants.Colors.amber)
                }
                
                // Hour indicators
                HStack(spacing: 4) {
                    ForEach(0..<12) { hour in
                        hourIndicator(hour: hour + 1, isActive: activityModel.standHours > hour)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Constants.Colors.surfaceLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Constants.Gradients.metallicRim, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            )
            
            // Daily log
            VStack(alignment: .leading, spacing: 8) {
                Text("DAILY LOG")
                    .font(Constants.Fonts.monospacedSmall)
                    .foregroundColor(Constants.Colors.primaryText)
                
                HStack(spacing: 15) {
                    // Breakfast
                    VStack(spacing: 4) {
                        Text("B")
                            .font(Constants.Fonts.monospacedLabel)
                            .foregroundColor(Constants.Colors.primaryText)
                        
                        Circle()
                            .fill(activityModel.mealLog["breakfast"] ?? false ? Constants.Colors.blue : Color.black.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                    .onTapGesture {
                        // NOTE: Meal logging now uses the CalorieModel instead of ActivityModel.mealLog
                    }
                    
                    // Lunch
                    VStack(spacing: 4) {
                        Text("L")
                            .font(Constants.Fonts.monospacedLabel)
                            .foregroundColor(Constants.Colors.primaryText)
                        
                        Circle()
                            .fill(activityModel.mealLog["lunch"] ?? false ? Constants.Colors.blue : Color.black.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                    .onTapGesture {
                        // NOTE: Meal logging now uses the CalorieModel instead of ActivityModel.mealLog
                    }
                    
                    // Dinner
                    VStack(spacing: 4) {
                        Text("D")
                            .font(Constants.Fonts.monospacedLabel)
                            .foregroundColor(Constants.Colors.primaryText)
                        
                        Circle()
                            .fill(activityModel.mealLog["dinner"] ?? false ? Constants.Colors.blue : Color.black.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                    .onTapGesture {
                        // NOTE: Meal logging now uses the CalorieModel instead of ActivityModel.mealLog
                    }
                    
                    // Snacks
                    VStack(spacing: 4) {
                        Text("S")
                            .font(Constants.Fonts.monospacedLabel)
                            .foregroundColor(Constants.Colors.primaryText)
                        
                        Circle()
                            .fill(activityModel.mealLog["snacks"] ?? false ? Constants.Colors.blue : Color.black.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                    .onTapGesture {
                        // NOTE: Meal logging now uses the CalorieModel instead of ActivityModel.mealLog
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Constants.Colors.surfaceLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Constants.Gradients.metallicRim, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            )
            
            // Date and time
            HStack {
                // Date
                Text(formattedDate())
                    .font(Constants.Fonts.monospacedLabel)
                    .foregroundColor(Constants.Colors.secondaryText)
                
                Spacer()
                
                // Sync status
                HStack(spacing: 4) {
                    Circle()
                        .fill(Constants.Colors.blue)
                        .frame(width: 6, height: 6)
                    
                    Text("SYNCED")
                        .font(Constants.Fonts.monospacedLabel)
                        .foregroundColor(Constants.Colors.secondaryText)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Constants.Gradients.metallicSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
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
                    .overlay(
                        // Corner rivets
                        ZStack {
                            // Bottom left
                            Circle()
                                .fill(Constants.Gradients.metallicButton)
                                .frame(width: 5, height: 5)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                                )
                                .offset(x: -70, y: 12)
                            
                            // Bottom right
                            Circle()
                                .fill(Constants.Gradients.metallicButton)
                                .frame(width: 5, height: 5)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                                )
                                .offset(x: 70, y: 12)
                        }
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            )
        }
        .frame(width: 170)
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: Date())
    }
    
    private func hourIndicator(hour: Int, isActive: Bool) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isActive ? Constants.Colors.amber : Color.black.opacity(0.3))
            .frame(height: 16)
    }
}

#Preview("Activity Panel") {
    ZStack {
        Constants.Colors.creamBackground
            .ignoresSafeArea()
        
        ActivityPanel(activityModel: ActivityModel())
            .padding()
    }
} 