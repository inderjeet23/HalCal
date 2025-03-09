//
//  HydrationView.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

struct HydrationView: View {
    @ObservedObject var hydrationModel: HydrationModel
    @State private var selectedDay: Date = Date()
    @State private var showingAddSheet = false
    @State private var showingSubtractSheet = false
    
    var body: some View {
        ZStack {
            // Background
            Constants.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: Constants.Layout.componentSpacing) {
                // Day selector
                DaySelector(selectedDay: $selectedDay)
                
                // Main content
                VStack(spacing: Constants.Layout.componentSpacing) {
                    // Hydration card
                    VStack(spacing: 8) {
                        HStack {
                            Text("WATER")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Constants.Colors.secondaryText)
                            
                            Spacer()
                            
                            Text("GOAL: \(String(format: "%.1f", hydrationModel.dailyGoal))L")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                        
                        // Water visualization
                        WaterWaveView(
                            waterLevel: hydrationModel.currentHydration,
                            goal: hydrationModel.dailyGoal
                        )
                        .frame(height: 180)
                        
                        // Add/Subtract controls
                        HStack(spacing: Constants.Layout.elementSpacing) {
                            // Subtract button
                            Button {
                                showingSubtractSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "minus")
                                    Text("Remove")
                                }
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(Constants.Colors.alertRed)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Constants.Colors.alertRed.opacity(0.2))
                                .cornerRadius(Constants.Layout.cornerRadius)
                            }
                            
                            // Add button
                            Button {
                                showingAddSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add")
                                }
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(Constants.Colors.addButton)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Constants.Colors.addButton.opacity(0.2))
                                .cornerRadius(Constants.Layout.cornerRadius)
                            }
                        }
                    }
                    .padding(Constants.Layout.cardPadding)
                    .background(Constants.Colors.surfaceLight)
                    .cornerRadius(Constants.Layout.cornerRadius)
                    
                    // Stats card
                    VStack(spacing: Constants.Layout.elementSpacing) {
                        HStack {
                            StatItem(
                                title: "DAILY GOAL",
                                value: String(format: "%.1f L", hydrationModel.dailyGoal)
                            )
                            
                            Divider()
                                .background(Constants.Colors.surfaceMid)
                            
                            StatItem(
                                title: "REMAINING",
                                value: String(format: "%.1f L", max(0, hydrationModel.dailyGoal - hydrationModel.currentHydration))
                            )
                        }
                        
                        Divider()
                            .background(Constants.Colors.surfaceMid)
                        
                        StatItem(
                            title: "PROGRESS",
                            value: String(format: "%.0f%%", hydrationModel.percentageOfGoal)
                        )
                    }
                    .padding(Constants.Layout.cardPadding)
                    .background(Constants.Colors.surfaceLight)
                    .cornerRadius(Constants.Layout.cornerRadius)
                }
                .padding(.horizontal, Constants.Layout.screenMargin)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
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
        .sheet(isPresented: $showingSubtractSheet) {
            // Subtract water sheet
            VStack {
                Text("Remove Water")
                    .font(Constants.Fonts.sectionHeader)
                
                // Quick subtract buttons
                HStack(spacing: Constants.Layout.elementSpacing) {
                    ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { amount in
                        Button {
                            hydrationModel.removeWater(amount: amount)
                            showingSubtractSheet = false
                        } label: {
                            Text("\(String(format: "%.2g", amount))L")
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Constants.Colors.alertRed)
                                .cornerRadius(Constants.Layout.cornerRadius)
                        }
                    }
                }
                .padding()
            }
            .presentationDetents([.height(200)])
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Constants.Colors.secondaryText)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Constants.Colors.primaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WaterWaveView: View {
    let waterLevel: Double
    let goal: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Constants.Colors.surfaceMid)
                
                // Water
                WaterWave(progress: CGFloat(min(waterLevel / goal, 1.0)),
                         waveHeight: 5,
                         offset: 0.0)
                    .fill(Constants.Colors.turquoise)
                    .frame(height: geometry.size.height * CGFloat(min(waterLevel / goal, 1.0)))
            }
        }
    }
}

struct WaterWave: Shape {
    var progress: CGFloat
    var waveHeight: CGFloat
    var offset: Double
    
    var animatableData: Double {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midWidth = width / 2
        
        path.move(to: CGPoint(x: 0, y: height))
        
        var x = CGFloat.zero
        let wavelength = width
        
        while x <= width {
            let relativeX = x / wavelength
            let normalizedOffset = Double(relativeX) + offset
            let y = height - waveHeight * CGFloat(sin(2 * .pi * normalizedOffset))
            path.addLine(to: CGPoint(x: x, y: y))
            x += 1
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    HydrationView(hydrationModel: HydrationModel())
} 