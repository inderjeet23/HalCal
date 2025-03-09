//
//  CRTOverlayView.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

struct PaperTextureOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Subtle noise texture for dark mode
                Color.black.opacity(0.05)
                    .overlay(
                        Canvas { context, size in
                            // Add subtle noise pattern
                            for _ in 0..<1500 {
                                let x = CGFloat.random(in: 0..<size.width)
                                let y = CGFloat.random(in: 0..<size.height)
                                let opacity = Double.random(in: 0.03...0.08)
                                let size = CGFloat.random(in: 0.5...1.5)
                                
                                context.fill(
                                    Path(ellipseIn: CGRect(x: x, y: y, width: size, height: size)),
                                    with: .color(Color.white.opacity(opacity))
                                )
                            }
                        }
                    )
                
                // More defined scan lines for CRT effect
                VStack(spacing: 4) {
                    ForEach(0..<Int(geometry.size.height/4), id: \.self) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.03))
                            .frame(height: 1)
                        Spacer()
                            .frame(height: 3)
                    }
                }
                
                // Subtle glass reflection effect
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .center
                )
                .blendMode(.overlay)
                
                // Enhanced vignette effect for dark mode
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.25)
                    ]),
                    center: .center,
                    startRadius: geometry.size.width * 0.4,
                    endRadius: geometry.size.width * 0.9
                )
                .blendMode(.multiply)
            }
        }
        .allowsHitTesting(false) // Let touches pass through
    }
}

// MARK: - Glass Panel Modifier
struct GlassPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(PaperTextureOverlayView())
            .drawingGroup() // Use Metal rendering for better performance
    }
}

extension View {
    func panelStyle() -> some View {
        self
            .crtPanelEffect()
            .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius))
            .shadow(
                color: Constants.Shadows.panelShadow.color,
                radius: Constants.Shadows.panelShadow.radius,
                x: Constants.Shadows.panelShadow.x,
                y: Constants.Shadows.panelShadow.y
            )
    }
    
    func crtPanelEffect() -> some View {
        self.modifier(GlassPanelModifier())
    }
}

#Preview("Paper Texture Overlay") {
    ZStack {
        Constants.Colors.background
        
        VStack {
            Text("CALORIE DISPLAY")
                .font(Constants.Fonts.primaryLabel)
                .foregroundColor(Constants.Colors.primaryText)
                .padding()
                .panelStyle()
                .padding(Constants.Layout.screenMargin)
        }
        .glassOverlay()
    }
} 