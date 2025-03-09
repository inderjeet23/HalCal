import SwiftUI

struct MainTabView: View {
    @StateObject private var calorieModel = CalorieModel()
    @StateObject private var hydrationModel = HydrationModel()
    @State private var selectedTab: TabItem = .calories
    @State private var showingAddSheet = false
    
    var body: some View {
        ZStack {
            Constants.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main content area
                ZStack {
                    // Calorie view
                    if selectedTab == .calories {
                        CaloriesView(calorieModel: calorieModel)
                            .transition(.opacity)
                    }
                    
                    // Hydration view
                    if selectedTab == .hydration {
                        HydrationView(hydrationModel: hydrationModel)
                            .transition(.opacity)
                    }
                }
                
                // Custom tab bar with contextual add button
                TabBarWithContextualAdd(
                    selectedTab: $selectedTab,
                    addAction: {
                        showingAddSheet = true
                    }
                )
                .padding(.horizontal, Constants.Layout.screenMargin)
                .padding(.bottom, Constants.Layout.screenMargin)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            if selectedTab == .calories {
                AddCaloriesView(calorieModel: calorieModel)
            } else if selectedTab == .hydration {
                // Add water sheet
                VStack {
                    Text("Add Water")
                        .font(Constants.Fonts.sectionHeader)
                    
                    // Quick add buttons
                    HStack(spacing: Constants.Layout.elementSpacing) {
                        ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { amount in
                            Button {
                                hydrationModel.addWater(amount: amount)
                                showingAddSheet = false
                            } label: {
                                Text("\(String(format: "%.2g", amount))L")
                                    .font(Constants.Fonts.primaryLabel)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Constants.Colors.turquoise)
                                    .cornerRadius(Constants.Layout.cornerRadius)
                            }
                        }
                    }
                    .padding()
                }
                .presentationDetents([.height(200)])
            }
        }
    }
}

#Preview {
    MainTabView()
} 