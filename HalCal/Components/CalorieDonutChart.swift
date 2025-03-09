//
//  CalorieDonutChart.swift
//  HalCal
//
//  Created by Claude on 3/9/25.
//

import SwiftUI

struct CalorieDonutChart: View {
    let totalCalories: Int
    let remainingCalories: Int
    
    // Computed properties
    private var consumedCalories: Int {
        totalCalories - remainingCalories
    }
    
    private var consumedPercentage: Double {
        Double(consumedCalories) / Double(totalCalories)
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .trim(from: 0, to: 1)
                .stroke(
                    Color.white.opacity(0.1),
                    style: StrokeStyle(lineWidth: 28, lineCap: .round)
                )
                .frame(width: 180, height: 180)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: min(CGFloat(consumedPercentage), 1.0))
                .stroke(
                    Constants.Colors.calorieOrange,
                    style: StrokeStyle(lineWidth: 28, lineCap: .round)
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: consumedPercentage)
            
            // Center text
            VStack(spacing: 6) {
                Text("Left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.gray)
                
                Text("\(remainingCalories) kcal")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Plan label
            VStack {
                Spacer()
                
                HStack(spacing: 60) {
                    // Plan calories
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Plan")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.gray)
                        
                        Text("\(totalCalories) kcal")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Consumed calories (if needed)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Consumed")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.gray)
                        
                        Text("\(consumedCalories) kcal")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Constants.Colors.calorieOrange)
                    }
                }
                .offset(y: 120)
            }
        }
    }
}

#Preview {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()
        
        CalorieDonutChart(totalCalories: 1550, remainingCalories: 972)
    }
} 