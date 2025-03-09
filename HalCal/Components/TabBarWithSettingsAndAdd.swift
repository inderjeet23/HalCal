import SwiftUI

struct TabBarWithSettingsAndAdd: View {
    @Binding var selectedTab: TabItem
    let addAction: () -> Void
    let settingsAction: () -> Void
    
    // Define constants for sizing
    private let tabItemWidth: CGFloat = 60
    private let tabBarHeight: CGFloat = 60
    private let addButtonSize: CGFloat = 60
    
    var body: some View {
        ZStack {
            // Background with rounded top corners
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .frame(height: tabBarHeight + 30) // Extra height for safe area
                .shadow(color: Color.black.opacity(0.1), radius: 3, y: -2)
            
            // Tab Items - evenly spaced
            HStack(spacing: 0) {
                // Calories Tab
                SettingsTabButton(
                    icon: "flame.fill",
                    label: "Calories",
                    isSelected: selectedTab == .calories,
                    color: Constants.Colors.calorieOrange
                ) {
                    withAnimation {
                        selectedTab = .calories
                    }
                }
                .frame(width: tabItemWidth)
                
                // Activity Tab
                SettingsTabButton(
                    icon: "chart.bar.fill",
                    label: "Activity",
                    isSelected: selectedTab == .activity,
                    color: Color.gray // Replace with your actual activity color
                ) {
                    withAnimation {
                        selectedTab = .activity
                    }
                }
                .frame(width: tabItemWidth)
                
                // Spacer for add button
                Spacer()
                    .frame(width: tabItemWidth)
                
                // Hydration Tab
                SettingsTabButton(
                    icon: "drop.fill",
                    label: "Water",
                    isSelected: selectedTab == .hydration,
                    color: Constants.Colors.turquoise
                ) {
                    withAnimation {
                        selectedTab = .hydration
                    }
                }
                .frame(width: tabItemWidth)
                
                // Settings Tab
                SettingsTabButton(
                    icon: "gearshape.fill",
                    label: "Settings",
                    isSelected: selectedTab == .settings,
                    color: Color.gray // Settings color
                ) {
                    settingsAction()
                }
                .frame(width: tabItemWidth)
            }
            .padding(.horizontal, 10)
            .padding(.top, 6)
            .padding(.bottom, 30) // Safe area padding
            
            // Add button - centered
            Button(action: addAction) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: addButtonSize, height: addButtonSize)
                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -addButtonSize/2 - 5) // Position above tab bar
        }
    }
}

// Individual tab button
struct SettingsTabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? color : Color.gray.opacity(0.7))
                
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? color : Color.gray.opacity(0.7))
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            TabBarWithSettingsAndAdd(
                selectedTab: .constant(.calories),
                addAction: {},
                settingsAction: {}
            )
        }
    }
    .preferredColorScheme(.dark)
} 