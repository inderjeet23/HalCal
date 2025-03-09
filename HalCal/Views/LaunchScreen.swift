//
//  LaunchScreen.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

struct LaunchScreen: View {
    @State private var showingText = false
    @State private var showingSubtext = false
    @State private var pulsating = false
    
    var body: some View {
        ZStack {
            // Background
            Constants.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: Constants.Layout.componentSpacing) {
                // Metallic logo circle
                Circle()
                    .fill(Constants.Gradients.brushedMetal)
                    .frame(width: Constants.Layout.buttonMinSize * 2.5, height: Constants.Layout.buttonMinSize * 2.5)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.1),
                                        Color.black.opacity(0.2),
                                        Color.black.opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: Constants.Layout.borderWidth
                            )
                    )
                    .overlay(
                        // Center indicator
                        Circle()
                            .fill(Constants.Colors.blue)
                            .frame(width: Constants.Layout.buttonMinSize * 0.8, height: Constants.Layout.buttonMinSize * 0.8)
                            .shadow(color: Constants.Colors.blue.opacity(0.7), radius: pulsating ? 15 : 8, x: 0, y: 0)
                            .scaleEffect(pulsating ? 1.05 : 1.0)
                    )
                    .shadow(
                        color: Color.black.opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulsating)
                    .onAppear {
                        pulsating = true
                    }
                
                if showingText {
                    // App name
                    Text("HAL·CAL")
                        .font(Constants.Fonts.sectionHeader)
                        .foregroundColor(Constants.Colors.primaryText)
                        .tracking(4)
                        .shadow(color: Constants.Colors.blue.opacity(0.6), radius: 2, x: 0, y: 0)
                        .transition(.opacity)
                }
                
                if showingSubtext {
                    // Tagline
                    Text("CALORIE MONITORING SYSTEM")
                        .font(Constants.Fonts.systemMessage)
                        .foregroundColor(Constants.Colors.secondaryText)
                        .tracking(1)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Constants.Layout.screenMargin)
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            // Animate text appearance
            withAnimation(.easeIn.delay(0.5)) {
                showingText = true
            }
            
            withAnimation(.easeIn.delay(1.5)) {
                showingSubtext = true
            }
        }
    }
}

#Preview {
    LaunchScreen()
} 