//
//  SystemStatusPanel.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

struct SystemStatusPanel: View {
    var isOperational: Bool = true
    
    var body: some View {
        RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
            .fill(Constants.Colors.surfaceLight)
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
            .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
            .overlay(
                HStack {
                    Text("SYSTEM STATUS:")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(Constants.Colors.secondaryText)
                        .tracking(1)
                    
                    Text(isOperational ? "OPERATIONAL" : "MALFUNCTION")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(isOperational ? Constants.Colors.blue : Constants.Colors.alertRed)
                        .tracking(1)
                        .shadow(
                            color: isOperational ? Constants.Colors.blue.opacity(0.5) : Constants.Colors.alertRed.opacity(0.5),
                            radius: 2,
                            x: 0,
                            y: 0
                        )
                    
                    Spacer()
                    
                    // Status indicator lights
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(isOperational ? Constants.Colors.blue : Constants.Colors.alertRed)
                            .frame(width: 8, height: 8)
                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.5))
                            .shadow(
                                color: isOperational ? Constants.Colors.blue.opacity(0.5) : Constants.Colors.alertRed.opacity(0.5),
                                radius: 3,
                                x: 0,
                                y: 0
                            )
                            .padding(.horizontal, 2)
                    }
                }
                .padding(.horizontal, Constants.Layout.screenMargin)
            )
            .frame(height: 40)
    }
}

#Preview {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            SystemStatusPanel(isOperational: true)
            SystemStatusPanel(isOperational: false)
        }
        .padding()
    }
} 