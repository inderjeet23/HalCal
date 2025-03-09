//
//  ContentView.swift
//  HalCal
//
//  Created by Inderjeet Mander on 3/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var calorieModel = CalorieModel()
    @StateObject private var hydrationModel = HydrationModel()
    @State private var selectedTab: TabItem = .calories
    @State private var showingAddSheet = false
    
    // Tab bar height including safe area
    private let tabBarHeight: CGFloat = 80
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background with subtle texture
            Constants.Colors.background
                .ignoresSafeArea()
                .overlay(
                    // Subtle noise texture
                    Image("noiseTexture")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .blendMode(.overlay)
                        .opacity(0.03)
                        .ignoresSafeArea()
                )
            
            // Main content area
            VStack(spacing: 0) {
                // Calories Tab
                if selectedTab == .calories {
                    CaloriesView(calorieModel: calorieModel)
                        .transition(.opacity)
                }
                
                // Hydration Tab
                if selectedTab == .hydration {
                    HydrationView(hydrationModel: hydrationModel)
                        .transition(.opacity)
                        .padding(.bottom, tabBarHeight) // Add padding to make space for tab bar
                }
            }
            .ignoresSafeArea(.keyboard)
            
            // Tab bar
            SimplifiedTabBarWithContextualAdd(
                selectedTab: $selectedTab,
                addAction: {
                    showingAddSheet = true
                }
            )
            .background(Color.clear) // No background needed with the new design
            .edgesIgnoringSafeArea(.bottom)
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
        .onDisappear {
            // Save data when view disappears
            calorieModel.saveData()
            hydrationModel.saveData()
        }
    }
}

#Preview {
    ContentView()
}