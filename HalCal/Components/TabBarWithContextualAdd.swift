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
    
    var body: some View {
        HStack {
            // Equal spacing for all icons
            Spacer(minLength: 30)
            
            // Calories icon
            Button(action: { 
                withAnimation(.easeInOut) {
                    selectedTab = .calories
                }
            }) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == .calories ? Constants.Colors.calorieOrange : Color.gray.opacity(0.5))
                    .frame(width: 60)
            }
            
            Spacer()
            
            // Hydration icon
            Button(action: { 
                withAnimation(.easeInOut) {
                    selectedTab = .hydration
                }
            }) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == .hydration ? Constants.Colors.turquoise : Color.gray.opacity(0.5))
                    .frame(width: 60)
            }
            
            Spacer(minLength: 30)
        }
        .padding(.top, 16)
        .padding(.bottom, 30) // Extra padding for bottom safe area
        .background(Color.white)
        .overlay(
            // Centered add button
            Button(action: addAction) {
                ZStack {
                    Circle()
                        .fill(Constants.Colors.addButton)
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.black.opacity(0.2),
                               radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -50), // Position button properly above tab bar
            alignment: .top
        )
    }
}

#Preview {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()
        
        TabBarWithContextualAdd(
            selectedTab: .constant(.calories),
            addAction: {}
        )
    }
    .preferredColorScheme(.dark)
} 