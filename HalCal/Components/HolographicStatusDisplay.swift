//
//  HolographicStatusDisplay.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

struct HolographicStatusDisplay: View {
    var text: String
    var isOperational: Bool = true
    @State private var flickerIntensity: Double = 0
    
    var body: some View {
        ZStack {
            // Inset display panel
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .fill(Color(white: 0.1))
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
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 2,
                    x: 0,
                    y: 1
                )
            
            // Text with holographic effect
            HStack {
                Text("SYSTEM STATUS:")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .tracking(1)
                
                Text(text)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(isOperational ? Constants.Colors.blue : Constants.Colors.alertRed)
                    .tracking(1)
                    .shadow(
                        color: isOperational ? 
                               Constants.Colors.blue.opacity(0.8 + flickerIntensity) : 
                               Constants.Colors.alertRed.opacity(0.8 + flickerIntensity),
                        radius: 2 + flickerIntensity * 2,
                        x: 0,
                        y: 0
                    )
            }
            
            // Scan line effect
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.2),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .offset(y: sin(Date().timeIntervalSinceReferenceDate * 2) * 10)
                .mask(RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius).padding(1))
                .opacity(0.7)
            
            // Flicker effect for holographic realism
            Rectangle()
                .fill(Color.white.opacity(flickerIntensity * 0.1))
                .mask(RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius).padding(1))
        }
        .frame(height: 40)
        .onAppear {
            // Random flicker effect
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.1)) {
                    if Int.random(in: 0...20) == 0 {
                        flickerIntensity = Double.random(in: 0.1...0.3)
                    } else {
                        flickerIntensity = 0
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            HolographicStatusDisplay(text: "OPERATIONAL", isOperational: true)
            HolographicStatusDisplay(text: "WARNING", isOperational: false)
        }
        .padding()
    }
} 