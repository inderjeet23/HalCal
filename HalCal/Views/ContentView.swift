//
//  ContentView.swift
//  HalCal
//
//  Created by Inderjeet Mander on 3/2/25.
//

import SwiftUI
import UIKit // Added for haptic feedback

struct ContentView: View {
    @StateObject private var calorieModel = CalorieModel()
    @StateObject private var hydrationModel = HydrationModel()
    @State private var selectedTab: TabItem = .calories
    @State private var showingAddSheet = false
    @State private var cardPosition: CardPosition = .collapsed
    
    // Tab bar height including safe area
    private let tabBarHeight: CGFloat = 90
    
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
                }
                
                // Space for tab bar
                Spacer(minLength: tabBarHeight)
            }
            .ignoresSafeArea(.keyboard)
            
            // Integrated tab and card component
            IntegratedTabCardView(
                selectedTab: $selectedTab,
                cardPosition: $cardPosition,
                addAction: {
                    showingAddSheet = true
                }
            ) {
                // Card content
                VStack(spacing: 16) {
                    // Your meal cards here
                    ForEach(1...3, id: \.self) { i in
                        HStack {
                            Circle()
                                .fill(Constants.Colors.calorieOrange.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("\(i)")
                                        .foregroundColor(Constants.Colors.calorieOrange)
                                )
                            
                            VStack(alignment: .leading) {
                                Text("Meal \(i)")
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                
                                Text("\(300 * i) calories")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
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