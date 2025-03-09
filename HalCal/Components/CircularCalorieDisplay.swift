//
//  CircularCalorieDisplay.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

struct CircularCalorieDisplay: View {
    var caloriesRemaining: Int
    var totalCalories: Int
    var calorieDeficit: Int
    
    @State private var animatedProgress: CGFloat = 0
    
    private var progress: CGFloat {
        let consumed = totalCalories - caloriesRemaining
        return min(CGFloat(consumed) / CGFloat(totalCalories), 1.0)
    }
    
    var body: some View {
        ZStack {
            // Outer metallic bezel - simplified but still dimensional
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Constants.Colors.metallicLight,
                        Constants.Colors.metallicDark
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.black.opacity(0.2),
                                    Color.black.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 2)
            
            // Inner display face - dark but not black
            Circle()
                .fill(Constants.Colors.surfaceMid)
                .padding(12)
                .overlay(
                    // Fine tick marks for gauge effect (simplified)
                    ForEach(0..<12) { index in
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 1, height: 6)
                            .offset(y: -120)
                            .rotationEffect(.degrees(Double(index) * 30))
                    }
                )
                
            // Progress indicator with clean arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Constants.Colors.blue,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(20)
                .animation(.easeOut(duration: 1.0), value: animatedProgress)
            
            // Clean, modern calorie display text
            VStack(spacing: 15) {
                Text("CALORIES REMAINING")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .tracking(2)
                
                Text("\(caloriesRemaining)")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(Constants.Colors.amber)
                    .shadow(color: Constants.Colors.amber.opacity(0.6), radius: 3, x: 0, y: 0)
                
                Text("DEFICIT: \(calorieDeficit)")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(Constants.Colors.blue)
                    .shadow(color: Constants.Colors.blue.opacity(0.3), radius: 1, x: 0, y: 0)
            }
            
            // Position indicator
            Circle()
                .fill(Constants.Colors.alertRed)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                )
                .shadow(color: Constants.Colors.alertRed.opacity(0.7), radius: 4, x: 0, y: 0)
                .offset(y: -128)
                .rotationEffect(.degrees(-90 + 360 * Double(totalCalories - caloriesRemaining) / Double(totalCalories)))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Preview
#Preview("Calorie Display") {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()
        
        CircularCalorieDisplay(
            caloriesRemaining: 1200,
            totalCalories: 2000,
            calorieDeficit: 300
        )
        .frame(width: 300, height: 300)
    }
} 