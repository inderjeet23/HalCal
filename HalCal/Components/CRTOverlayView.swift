//
//  CRTOverlayView.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

// MARK: - Glass Panel Modifier
struct GlassPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .drawingGroup() // Use Metal rendering for better performance
    }
}

extension View {
    func panelStyle() -> some View {
        self
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

#Preview("Panel Style") {
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
    }
} 