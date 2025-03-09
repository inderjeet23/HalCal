import SwiftUI

enum TabItem: String, CaseIterable {
    case calories = "CALORIES"
    case hydration = "HYDRATION"
    // Removed macros tab for now
    
    var icon: String {
        switch self {
        case .calories: return "flame.fill"
        case .hydration: return "drop.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .calories: return Constants.Colors.calorieOrange
        case .hydration: return Constants.Colors.turquoise
        }
    }
}

struct TabBarWithContextualAdd: View {
    @Binding var selectedTab: TabItem
    let addAction: () -> Void
    
    // Define colors
    private let addButtonColor = Color(red: 0.4, green: 0.85, blue: 0.3) // Bright Reddit-like green
    
    var body: some View {
        ZStack {
            // Background - more elegant rounded shape
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .frame(height: 80)
                .shadow(color: Color.black.opacity(0.1), radius: 3, y: -2)
            
            // Tab bar items
            HStack(spacing: 0) {
                // Left tab (Calories)
                Button(action: { 
                    withAnimation(.easeInOut) {
                        selectedTab = .calories
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 22))
                            .foregroundColor(selectedTab == .calories ? Constants.Colors.calorieOrange : Color.gray.opacity(0.5))
                        
                        Text("Calories")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(selectedTab == .calories ? Constants.Colors.calorieOrange : Color.gray.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Spacer for center add button
                Spacer()
                    .frame(width: 80)
                
                // Right tab (Hydration)
                Button(action: { 
                    withAnimation(.easeInOut) {
                        selectedTab = .hydration
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 22))
                            .foregroundColor(selectedTab == .hydration ? Constants.Colors.turquoise : Color.gray.opacity(0.5))
                        
                        Text("Hydration")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(selectedTab == .hydration ? Constants.Colors.turquoise : Color.gray.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 6)
            .padding(.bottom, 20) // Bottom safe area padding
            
            // Centered add button (always in the middle) - Reddit-style
            Button(action: addAction) {
                ZStack {
                    Circle()
                        .fill(addButtonColor)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.black.opacity(0.15),
                               radius: 3, x: 0, y: 1)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -30) // Position button properly above tab bar
        }
        .frame(height: 80) // Skinnier height
    }
}

#Preview {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            TabBarWithContextualAdd(
                selectedTab: .constant(.calories),
                addAction: {}
            )
        }
    }
    .preferredColorScheme(.dark)
} 