import SwiftUI
import Foundation

struct Constants {
    // Colors
    struct Colors {
        static let background = Color("Background")
        static let calorieOrange = Color("CalorieOrange")
        static let turquoise = Color("Turquoise")
        static let surfaceLight = Color("SurfaceLight")
        static let surfaceMid = Color("SurfaceMid")
        static let primaryText = Color("PrimaryText")
        static let secondaryText = Color("SecondaryText")
        static let progressBackground = Color("ProgressBackground")
        static let alertRed = Color.red.opacity(0.8)
        static let blue = Color.blue.opacity(0.8)
        static let cardBackground = Color.black.opacity(0.2)
    }
    
    // Layout constants
    struct Layout {
        static let screenMargin: CGFloat = 20
        static let componentSpacing: CGFloat = 16
        static let elementSpacing: CGFloat = 8
        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
    }
    
    // Fonts
    struct Fonts {
        static let sectionHeader = Font.system(size: 20, weight: .bold)
        static let primaryLabel = Font.system(size: 18, weight: .semibold)
        static let secondaryLabel = Font.system(size: 16, weight: .medium)
        static let tertiaryLabel = Font.system(size: 14, weight: .regular)
        static let inputLabel = Font.system(size: 16, weight: .medium)
    }
    
    // Gradients
    struct Gradients {
        static let metallicSurface = LinearGradient(
            gradient: Gradient(colors: [
                Color.gray.opacity(0.2),
                Color.gray.opacity(0.1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let metallicRim = LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.4),
                Color.gray.opacity(0.2),
                Color.black.opacity(0.2)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let metallicButton = LinearGradient(
            gradient: Gradient(colors: [
                Color.gray.opacity(0.3),
                Color.gray.opacity(0.1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // Shadows
    struct Shadows {
        static let buttonShadow = (color: Color.black.opacity(0.15), radius: 3.0, x: 0.0, y: 1.0)
        static let insetShadow = (color: Color.black.opacity(0.1), radius: 2.0, x: 0.0, y: 1.0)
        static let cardShadow = (color: Color.black.opacity(0.2), radius: 4.0, x: 0.0, y: 2.0)
    }
} 