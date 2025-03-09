//
//  HydrationGauge.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

struct HydrationGauge: View {
    @ObservedObject var hydrationModel: HydrationModel
    @State private var waveOffset = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            // Use a simpler ZStack structure
            ZStack {
                // Background components
                BackgroundComponents()
                
                // Content components
                ContentComponents(
                    width: geometry.size.width,
                    hydrationModel: hydrationModel,
                    waveOffset: waveOffset
                )
            }
            .onAppear {
                // Simpler animation setup
                startWaveAnimation()
            }
        }
        .frame(height: 80) // Fixed height for horizontal gauge
    }
    
    // Separate method for animation to reduce complexity
    private func startWaveAnimation() {
        // Simple linear animation
        DispatchQueue.main.async {
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                waveOffset = 1.0
            }
        }
    }
}

// Background components grouped together
struct BackgroundComponents: View {
    var body: some View {
        ZStack {
            // Outer housing
            GaugeHousingView()
            
            // Tube inner area
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius - 4)
                .fill(Constants.Colors.background)
                .padding(6)
            
            // Corner rivets
            CornerRivetsView()
        }
    }
}

// Content components grouped together
struct ContentComponents: View {
    var width: CGFloat
    @ObservedObject var hydrationModel: HydrationModel
    var waveOffset: Double
    
    var body: some View {
        ZStack {
            // Measurement markings
            MeasurementMarkingsView(width: width)
            
            // Target line
            TargetLineView(width: width, dailyGoal: hydrationModel.dailyGoal)
            
            // Water content
            WaterContentView(
                width: width,
                currentHydration: hydrationModel.currentHydration,
                waveOffset: waveOffset
            )
            
            // Current hydration label
            HydrationLabelView(
                width: width,
                currentHydration: hydrationModel.currentHydration
            )
        }
    }
}

// MARK: - Subviews

struct GaugeHousingView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Constants.Colors.metallicLight,
                        Constants.Colors.metallicDark
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1),
                                Color.black.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: Color.black.opacity(0.25),
                radius: 2,
                x: 0,
                y: 2
            )
    }
}

struct MeasurementMarkingsView: View {
    var width: CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(0..<5) { i in
                VStack {
                    // Line marking
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 1, height: i % 2 == 0 ? 15 : 10)
                    
                    if i % 2 == 0 {
                        // Label for even markings
                        Text("\(Double(i) * 0.5, specifier: "%.1f")L")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    
                    Spacer()
                }
                .frame(width: width / 4)
                .offset(x: i == 0 ? 5 : 0)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }
}

struct TargetLineView: View {
    var width: CGFloat
    var dailyGoal: Double
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Constants.Colors.blue)
                .frame(width: 1)
            
            Text("TARGET")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(Constants.Colors.blue)
                .padding(.horizontal, 2)
                .background(Constants.Colors.background)
                .rotationEffect(Angle(degrees: 90))
        }
        .offset(x: ((width - 20) * CGFloat(dailyGoal / 2.0) - width/2 + 10))
    }
}

struct WaterContentView: View {
    var width: CGFloat
    var currentHydration: Double
    var waveOffset: Double
    
    // Computed property to calculate the water width
    private var waterWidth: CGFloat {
        max(0, CGFloat(currentHydration / 2.0) * (width - 20))
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Simplified water view with less complex animation
            ZStack {
                // Simple rectangle for the base water
                Rectangle()
                    .fill(Constants.Colors.blue.opacity(0.8))
                    .frame(width: waterWidth, height: 30) // Increased height
                
                // Wave overlay for effect
                WaterWaveShape(progress: CGFloat(currentHydration / 2.0), waveHeight: 5, waveOffset: waveOffset)
                    .fill(Constants.Colors.blue.opacity(0.3))
                    .frame(width: waterWidth, height: 30) // Increased height
            }
            .clipShape(Capsule()) // Changed to Capsule for rounded ends
            .animation(.easeInOut(duration: 0.5), value: currentHydration)
            
            Spacer(minLength: 0)
        }
        .padding(10)
    }
}

struct CornerRivetsView: View {
    var body: some View {
        VStack {
            HStack {
                Circle()
                    .fill(Constants.Colors.metallicMid)
                    .frame(width: 6, height: 6)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.5))
                Spacer()
                Circle()
                    .fill(Constants.Colors.metallicMid)
                    .frame(width: 6, height: 6)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.5))
            }
            
            Spacer()
            
            HStack {
                Circle()
                    .fill(Constants.Colors.metallicMid)
                    .frame(width: 6, height: 6)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.5))
                Spacer()
                Circle()
                    .fill(Constants.Colors.metallicMid)
                    .frame(width: 6, height: 6)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.5))
            }
        }
        .padding(4)
    }
}

struct HydrationLabelView: View {
    var width: CGFloat
    var currentHydration: Double
    
    // Computed property for label position
    private var labelPosition: CGFloat {
        // Simplified calculation with clamping
        let basePosition = CGFloat(currentHydration / 2.0) * (width - 20) - width/2
        return max(-width/2 + 40, min(basePosition, width/2 - 40))
    }
    
    var body: some View {
        // Simplified label with less complex styling
        Text(String(format: "%.1f L", currentHydration))
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .foregroundColor(Constants.Colors.blue)
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Constants.Colors.surfaceLight.opacity(0.7))
            )
            .offset(x: labelPosition)
            // Simple animation instead of spring
            .animation(.easeInOut(duration: 0.5), value: currentHydration)
    }
}

// MARK: - Water Wave Shape
struct WaterWaveShape: Shape {
    var progress: CGFloat
    var waveHeight: CGFloat
    var waveOffset: Double
    
    var animatableData: Double {
        get { waveOffset }
        set { waveOffset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        // Create a simpler path with fewer points
        let path = Path { path in
            // Start at bottom left
            path.move(to: CGPoint(x: 0, y: rect.height))
            
            // Draw to the bottom right
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            
            // Draw to the top right
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            
            // Only add wave if there's enough water
            if progress > 0.05 {
                // Use fewer steps for the wave
                let steps = 8 // Reduced from 10
                let stepSize = rect.width / CGFloat(steps)
                
                // Draw the wave from right to left
                for i in stride(from: steps, through: 0, by: -1) {
                    let x = CGFloat(i) * stepSize
                    let angle = 2 * .pi * (CGFloat(i) / CGFloat(steps)) + CGFloat(waveOffset * .pi)
                    let y = sin(angle) * waveHeight
                    
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            } else {
                // Straight line if minimal water
                path.addLine(to: CGPoint(x: 0, y: 0))
            }
            
            // Close the path
            path.closeSubpath()
        }
        
        return path
    }
}

#Preview {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()
        
        HydrationGauge(hydrationModel: HydrationModel())
            .frame(width: 300)
            .padding()
    }
} 