//
//  Constants.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

struct Constants {
    // MARK: - Colors
    struct Colors {
        // Core colors
        static let background = Color.black // Pure black background
        static let surfaceLight = Color(red: 0.12, green: 0.12, blue: 0.12) // Card background
        static let surfaceMid = Color(red: 0.16, green: 0.16, blue: 0.16) // Secondary surface
        
        // Text colors
        static let primaryText = Color.white
        static let secondaryText = Color.white.opacity(0.7)
        
        // Accent colors
        static let calorieAccent = Color(hex: "3CBBB1") // New teal color
        static let calorieOrange = Color(hex: "3CBBB1") // For backward compatibility
        static let turquoise = Color(hex: "30D5C8") // Turquoise for macros/hydration
        static let addButton = Color(hex: "7ED321") // Green for add buttons
        
        // Progress colors
        static let progressBackground = Color.white.opacity(0.1)
        static let mealIndicator = Color(hex: "FF8500").opacity(0.8)
        
        // Legacy colors (keeping for compatibility)
        static let amber = calorieOrange
        static let blue = turquoise
        static let alertRed = Color(red: 1.0, green: 0.23, blue: 0.19)
        
        // Metallic colors for skeuomorphic elements
        static let metallicLight = Color(white: 0.28)
        static let metallicMid = Color(white: 0.20)
        static let metallicDark = Color(white: 0.15)
        
        // Legacy colors (keeping for backward compatibility)
        static let creamBackground = Color(red: 0.95, green: 0.93, blue: 0.88)
        static let darkText = Color(red: 0.15, green: 0.15, blue: 0.17)
        static let metallic = Color(hex: "D8D8D8")
        static let lightMetallic = Color(hex: "E8E8E8")
        static let darkMetallic = Color(hex: "AAAAAA")
    }
    
    // MARK: - Fonts
    struct Fonts {
        // Primary labels: 14px monospace, all caps
        static let primaryLabel = Font.system(size: 14).monospaced().weight(.medium)
        
        // Value displays: 18px monospace
        static let valueDisplay = Font.system(size: 18).monospaced().weight(.medium)
        
        // Section headers: 18px monospace, all caps
        static let sectionHeader = Font.system(size: 18).monospaced().weight(.bold)
        
        // Page titles: 24px monospace, bold
        static let pageTitle = Font.system(size: 24).monospaced().weight(.bold)
        
        // System messages: 12px monospace
        static let systemMessage = Font.system(size: 12).monospaced().weight(.regular)
        
        // Status readouts: 14px monospace
        static let statusReadout = Font.system(size: 14).monospaced().weight(.medium)
        
        // Tab labels: 12px monospace
        static let tabLabel = Font.system(size: 12).monospaced().weight(.medium)
        
        // Legacy fonts (keeping for backward compatibility)
        static let monospacedDigital = Font.system(.title).monospaced().weight(.medium)
        static let monospacedSmall = Font.system(.caption).monospaced().weight(.regular)
        static let monospacedLarge = Font.system(.largeTitle).monospaced().weight(.bold)
        static let monospacedLabel = Font.system(.caption2).monospaced().weight(.medium)
    }
    
    // MARK: - Layout
    struct Layout {
        // Card styling
        static let cornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 1
        static let cardPadding: CGFloat = 16
        
        // Spacing
        static let screenMargin: CGFloat = 16
        static let componentSpacing: CGFloat = 12 // Reduced from previous value
        static let elementSpacing: CGFloat = 8
        
        // UI Element sizes
        static let buttonMinSize: CGFloat = 44
        static let addButtonSize: CGFloat = 60 // Reduced size
        static let progressBarHeight: CGFloat = 8
        static let macroBarHeight: CGFloat = 6
        static let dayIndicatorSize: CGFloat = 30 // Updated to match mockup
        
        // Wave animation
        static let waveAmplitude: CGFloat = 5
        static let wavePeriod: CGFloat = 2
        
        // UI Element sizes
        static let statusLightDiameter: CGFloat = 6
        static let textFieldHeight: CGFloat = 44
        static let indicatorSize: CGFloat = 12
        
        // Tab bar metrics
        static let tabIconSize: CGFloat = 24
        static let tabIconMargin: CGFloat = 4
        static let tabIndicatorPadding: CGFloat = 4
        
        // Legacy values (keeping for backward compatibility)
        static let shadowRadius: CGFloat = 5
        static let buttonDepth: CGFloat = 4
        static let panelBevel: CGFloat = 2
    }
    
    // MARK: - Animation
    struct Animation {
        static let buttonPress = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.5)
    }
    
    // MARK: - Gradients
    struct Gradients {
        // Enhanced metallic gradients for dark mode
        static let metallicSurface = LinearGradient(
            gradient: Gradient(colors: [
                Colors.metallicLight,
                Colors.metallicMid,
                Colors.metallicDark
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let metallicRim = LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.3),
                Color.white.opacity(0.1),
                Color.black.opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // New brushed metal effect for dark mode
        static let brushedMetal = LinearGradient(
            gradient: Gradient(colors: [
                Colors.metallicLight,
                Colors.metallicMid,
                Colors.metallicDark
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Enhanced button gradient
        static let metallicButton = LinearGradient(
            gradient: Gradient(colors: [
                Colors.metallicLight,
                Colors.metallicMid,
                Colors.metallicDark
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Legacy gradients (keeping for backward compatibility)
        static let textFieldBackground = LinearGradient(
            gradient: Gradient(colors: [
                Constants.Colors.darkMetallic.opacity(0.8),
                Constants.Colors.metallic.opacity(0.95)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let buttonShadow = Shadow(color: Color.black.opacity(0.4), radius: 3, x: 0, y: 3)
        static let panelShadow = Shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        static let insetShadow = Shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
        static let innerGlow = Shadow(color: Color.white.opacity(0.15), radius: 2, x: 0, y: 0)
    }
}

// MARK: - Shadow Struct
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions for Realistic Textures
extension View {
    func brushedMetalEffect() -> some View {
        self.background(
            ZStack {
                // Base metal color for dark mode
                LinearGradient(
                    gradient: Gradient(colors: [
                        Constants.Colors.metallicLight, 
                        Constants.Colors.metallicMid,
                        Constants.Colors.metallicDark
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Brushed metal lines
                ForEach(0..<40) { index in
                    Rectangle()
                        .fill(Color.white.opacity(Double.random(in: 0.03...0.08)))
                        .frame(height: 1)
                        .offset(y: CGFloat(index * 5) - 100)
                        .rotationEffect(.degrees(Double.random(in: -3...3)))
                }
                
                // Subtle spotlight highlight
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.clear
                    ]),
                    center: .init(x: 0.3, y: 0.3),
                    startRadius: 5,
                    endRadius: 150
                )
            }
        )
    }
} 