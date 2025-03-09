//
//  CaloriesView.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI
import UIKit

struct CaloriesView: View {
    @ObservedObject var calorieModel: CalorieModel
    @State private var selectedDay: Date = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            // Day selector
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
                
                Button {
                    addDay()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            // Calories remaining display
            VStack(spacing: 8) {
                Text("Calories Remaining")
                    .font(Constants.Fonts.secondaryLabel)
                    .foregroundColor(.gray)
                
                Text("\(calorieModel.remainingCalories)")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(calorieModel.remainingCalories >= 0 ? .white : Constants.Colors.alertRed)
                
                HStack(spacing: 8) {
                    Text("Goal: \(calorieModel.calorieTarget)")
                        .foregroundColor(Constants.Colors.calorieOrange)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text("Food: \(calorieModel.consumedCalories)")
                        .foregroundColor(Constants.Colors.calorieOrange)
                }
                .font(Constants.Fonts.tertiaryLabel)
            }
            .padding(.vertical, 20)
            
            // Macros summary
            VStack(spacing: 16) {
                Text("Macronutrients")
                    .font(Constants.Fonts.secondaryLabel)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Protein
                MacroProgressBar(
                    title: "Protein",
                    consumed: calorieModel.consumedProtein,
                    target: calorieModel.proteinTarget,
                    color: Constants.Colors.turquoise
                )
                
                // Carbs
                MacroProgressBar(
                    title: "Carbs",
                    consumed: calorieModel.consumedCarbs,
                    target: calorieModel.carbTarget,
                    color: Color.purple
                )
                
                // Fat
                MacroProgressBar(
                    title: "Fat",
                    consumed: calorieModel.consumedFat,
                    target: calorieModel.fatTarget,
                    color: Color.yellow
                )
            }
            .padding()
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.Layout.cornerRadius)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Constants.Colors.background)
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }
    
    private func addDay() {
        withAnimation {
            selectedDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDay) ?? selectedDay
            // In a real app, we would load data for this day
        }
    }
    
    private func subtractDay() {
        withAnimation {
            selectedDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDay) ?? selectedDay
            // In a real app, we would load data for this day
        }
    }
}

struct MacroProgressBar: View {
    let title: String
    let consumed: Double
    let target: Double
    let color: Color
    
    private var percentage: Double {
        min(consumed / target, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(Constants.Fonts.tertiaryLabel)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(consumed))g / \(Int(target))g")
                    .font(Constants.Fonts.tertiaryLabel)
                    .foregroundColor(.gray)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 12)
                    
                    // Fill
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 12)
                        .animation(.easeInOut, value: percentage)
                }
            }
            .frame(height: 12)
        }
    }
}

#Preview {
    CaloriesView(calorieModel: CalorieModel())
} 