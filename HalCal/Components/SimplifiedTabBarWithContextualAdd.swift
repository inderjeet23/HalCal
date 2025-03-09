import SwiftUI

struct SimplifiedTabBarWithContextualAdd: View {
    @Binding var selectedTab: TabItem
    let addAction: () -> Void
    
    // Define colors
    private let addButtonColor = Color(red: 0.4, green: 0.85, blue: 0.3) // Bright green
    
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
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == .calories ? Constants.Colors.calorieAccent : Color.gray.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 6)
                }
                
                // Middle tab (Activity)
                Button(action: { 
                    withAnimation(.easeInOut) {
                        selectedTab = .activity
                    }
                }) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == .activity ? Constants.Colors.calorieAccent : Color.gray.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 6)
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
                    Image(systemName: "drop.fill")
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == .hydration ? Constants.Colors.turquoise : Color.gray.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 6)
                }
            }
            .padding(.horizontal, 50)
            .padding(.bottom, 20) // Bottom safe area padding
            
            // Centered add button - floating style
            Button(action: addAction) {
                ZStack {
                    Circle()
                        .fill(addButtonColor)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -30) // Position button properly above tab bar
        }
        .frame(height: 80)
    }
}

#Preview {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            SimplifiedTabBarWithContextualAdd(
                selectedTab: .constant(.calories),
                addAction: {}
            )
        }
    }
    .preferredColorScheme(.dark)
} 