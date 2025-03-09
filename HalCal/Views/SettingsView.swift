//
//  SettingsView.swift
//  HalCal
//
//  Created by Claude on 3/2/25.
//

import SwiftUI

enum SettingsTab: String, CaseIterable {
    case profile = "PROFILE"
    case goals = "GOALS"
    case preferences = "PREFERENCES"
    
    var icon: String {
        switch self {
        case .profile: return "person.fill"
        case .goals: return "target"
        case .preferences: return "gearshape.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .profile: return Constants.Colors.amber
        case .goals: return Constants.Colors.blue
        case .preferences: return Color(red: 0.2, green: 0.8, blue: 0.2)
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileManager = UserProfileManager()
    @ObservedObject var calorieModel: CalorieModel
    @ObservedObject var hydrationModel: HydrationModel
    @State private var dailyGoal: String
    @State private var hydrationGoal: String
    @State private var showingResetConfirmation = false
    @State private var showingHydrationResetConfirmation = false
    @State private var selectedTab: SettingsTab = .profile
    @State private var showingConfirmCover = false
    
    // Profile section states
    @State private var heightFeet = 5
    @State private var heightInches = 10
    @State private var heightCm = 178.0
    @State private var weightLbs = 150.0
    @State private var weightKg = 68.0
    @State private var showingHeightInfo = false
    @State private var showingWeightInfo = false
    @State private var showingActivityInfo = false
    @State private var showingGoalInfo = false
    
    // Goals section states
    @State private var showingCalorieWarning = false
    @State private var proposedCalorieGoal: Int = 2000
    @State private var customMacroRatio = MacroRatio(protein: 40, carbs: 30, fat: 30)
    @State private var showingMacroInfo = false
    
    // Preferences section states
    @State private var showingThemePreview = false
    @State private var isTestingHaptic = false
    
    init(calorieModel: CalorieModel, hydrationModel: HydrationModel) {
        self.calorieModel = calorieModel
        self.hydrationModel = hydrationModel
        _dailyGoal = State(initialValue: "\(calorieModel.dailyCalorieGoal)")
        _hydrationGoal = State(initialValue: String(format: "%.1f", hydrationModel.dailyGoal))
    }
    
    var body: some View {
        ZStack {
            Constants.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: Constants.Layout.componentSpacing) {
                // Header
                Text("Settings")
                    .font(Constants.Fonts.pageTitle)
                    .foregroundColor(Constants.Colors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Constants.Layout.screenMargin)
                
                // Main content
                ScrollView {
                    VStack(spacing: Constants.Layout.componentSpacing) {
                        // Settings panels based on selected tab
                        switch selectedTab {
                        case .profile:
                            ProfileSettingsPanel()
                        case .goals:
                            GoalsSettingsPanel()
                        case .preferences:
                            PreferencesSettingsPanel()
                        }
                    }
                    .padding(.horizontal, Constants.Layout.screenMargin)
                }
                
                // Custom tab bar for settings
                HStack(spacing: 0) {
                    ForEach(SettingsTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: Constants.Layout.tabIconSize))
                                Text(tab.rawValue)
                                    .font(Constants.Fonts.tabLabel)
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(selectedTab == tab ? tab.color : Constants.Colors.secondaryText)
                            .padding(.vertical, Constants.Layout.tabIconMargin)
                            .background(
                                selectedTab == tab ? tab.color.opacity(0.2) : Color.clear
                            )
                            .cornerRadius(Constants.Layout.cornerRadius)
                        }
                    }
                }
                .padding(.horizontal, Constants.Layout.screenMargin)
                .padding(.top, Constants.Layout.elementSpacing)
                .padding(.bottom, Constants.Layout.screenMargin + 20)
                .background(Constants.Colors.surfaceLight)
                .cornerRadius(Constants.Layout.cornerRadius)
            }
        }
        .onAppear {
            initializeFromProfileManager()
        }
    }
    
    private func initializeFromProfileManager() {
        // Initialize height values
        if profileManager.useMetricSystem {
            heightCm = profileManager.height
            let imperial = profileManager.heightInFeetInches
            heightFeet = imperial.feet
            heightInches = imperial.inches
        } else {
            let imperial = profileManager.heightInFeetInches
            heightFeet = imperial.feet
            heightInches = imperial.inches
            heightCm = profileManager.height
        }
        
        // Initialize weight values
        if profileManager.useMetricSystem {
            weightKg = profileManager.weight
            weightLbs = profileManager.weightInPounds
        } else {
            weightLbs = profileManager.weightInPounds
            weightKg = profileManager.weight
        }
        
        // Initialize calorie goal
        proposedCalorieGoal = profileManager.calorieGoal
        
        // Initialize macro ratio
        customMacroRatio = profileManager.macroRatio
    }
    
    // MARK: - Profile Section
    
    private var profileSection: some View {
        ScrollView {
            VStack(spacing: Constants.Layout.componentSpacing) {
                // Height Input
                MetallicPanel {
                    VStack(alignment: .leading, spacing: Constants.Layout.elementSpacing) {
                        HStack {
                            Text("HEIGHT")
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(Constants.Colors.primaryText)
                            
                            Button {
                                showingHeightInfo = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                            .alert("Height Information", isPresented: $showingHeightInfo) {
                                Button("OK", role: .cancel) {}
                            } message: {
                                Text("Your height is used to calculate your BMR (Basal Metabolic Rate) and daily calorie needs.")
                            }
                        }
                        
                        Picker("Units", selection: $profileManager.useMetricSystem) {
                            Text("ft/in").tag(false)
                            Text("cm").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .metallicSegmentedStyle()
                        
                        if profileManager.useMetricSystem {
                            HStack {
                                TextField("Height", value: $heightCm, format: .number)
                                    .keyboardType(.decimalPad)
                                    .metallicTextField()
                                    .onChange(of: heightCm) {
                                        profileManager.height = heightCm
                                        profileManager.saveUserProfile()
                                    }
                                
                                Text("cm")
                                    .font(Constants.Fonts.primaryLabel)
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                        } else {
                            HStack {
                                Picker("Feet", selection: $heightFeet) {
                                    ForEach(1...8, id: \.self) { foot in
                                        Text("\(foot) ft").tag(foot)
                                    }
                                }
                                .metallicPickerStyle()
                                .frame(width: 100)
                                
                                Picker("Inches", selection: $heightInches) {
                                    ForEach(0...11, id: \.self) { inch in
                                        Text("\(inch) in").tag(inch)
                                    }
                                }
                                .metallicPickerStyle()
                                .frame(width: 100)
                            }
                            .onChange(of: heightFeet) {
                                profileManager.heightInFeetInches = (heightFeet, heightInches)
                                profileManager.saveUserProfile()
                            }
                            .onChange(of: heightInches) {
                                profileManager.heightInFeetInches = (heightFeet, heightInches)
                                profileManager.saveUserProfile()
                            }
                        }
                    }
                }
                
                // Weight Input
                MetallicPanel {
                    VStack(alignment: .leading, spacing: Constants.Layout.elementSpacing) {
                        HStack {
                            Text("WEIGHT")
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(Constants.Colors.primaryText)
                            
                            Button {
                                showingWeightInfo = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                            .alert("Weight Information", isPresented: $showingWeightInfo) {
                                Button("OK", role: .cancel) {}
                            } message: {
                                Text("Your weight is used to calculate your BMR and recommended daily water intake.")
                            }
                        }
                        
                        Picker("Units", selection: $profileManager.useMetricSystem) {
                            Text("lb").tag(false)
                            Text("kg").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .metallicSegmentedStyle()
                        
                        if profileManager.useMetricSystem {
                            HStack {
                                TextField("Weight", value: $weightKg, format: .number)
                                    .keyboardType(.decimalPad)
                                    .metallicTextField()
                                    .onChange(of: weightKg) {
                                        profileManager.weight = weightKg
                                        profileManager.saveUserProfile()
                                    }
                                
                                Text("kg")
                                    .font(Constants.Fonts.primaryLabel)
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                        } else {
                            HStack {
                                TextField("Weight", value: $weightLbs, format: .number)
                                    .keyboardType(.decimalPad)
                                    .metallicTextField()
                                    .onChange(of: weightLbs) {
                                        profileManager.weightInPounds = weightLbs
                                        profileManager.saveUserProfile()
                                    }
                                
                                Text("lb")
                                    .font(Constants.Fonts.primaryLabel)
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                        }
                    }
                }
                
                // Activity Level
                MetallicPanel {
                    VStack(alignment: .leading, spacing: Constants.Layout.elementSpacing) {
                        HStack {
                            Text("ACTIVITY LEVEL")
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(Constants.Colors.primaryText)
                            
                            Button {
                                showingActivityInfo = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                            .alert("Activity Level", isPresented: $showingActivityInfo) {
                                Button("OK", role: .cancel) {}
                            } message: {
                                Text("Your activity level helps determine your daily calorie needs.")
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Constants.Layout.elementSpacing) {
                                ForEach(ActivityLevel.allCases) { level in
                                    Button {
                                        withAnimation {
                                            profileManager.activityLevel = level
                                            profileManager.saveUserProfile()
                                        }
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text(level.rawValue)
                                                .font(Constants.Fonts.primaryLabel)
                                            Text(level.description)
                                                .font(Constants.Fonts.systemMessage)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(width: 120)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                                .fill(profileManager.activityLevel == level ?
                                                      Constants.Colors.blue.opacity(0.3) :
                                                        Constants.Colors.surfaceMid)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                                .stroke(profileManager.activityLevel == level ?
                                                       Constants.Colors.blue :
                                                        Constants.Colors.metallicLight,
                                                       lineWidth: Constants.Layout.borderWidth)
                                        )
                                    }
                                    .buttonStyle(SkeuomorphicButtonStyle())
                                }
                            }
                            .padding(.horizontal, Constants.Layout.elementSpacing)
                        }
                    }
                }
                
                // Fitness Goal
                MetallicPanel {
                    VStack(alignment: .leading, spacing: Constants.Layout.elementSpacing) {
                        HStack {
                            Text("FITNESS GOAL")
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(Constants.Colors.primaryText)
                            
                            Button {
                                showingGoalInfo = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                            .alert("Fitness Goal", isPresented: $showingGoalInfo) {
                                Button("OK", role: .cancel) {}
                            } message: {
                                Text("Your fitness goal determines calorie adjustments: deficit for weight loss, surplus for muscle gain.")
                            }
                        }
                        
                        HStack(spacing: Constants.Layout.elementSpacing) {
                            ForEach(FitnessGoal.allCases) { goal in
                                Button {
                                    withAnimation {
                                        profileManager.fitnessGoal = goal
                                        profileManager.saveUserProfile()
                                    }
                                } label: {
                                    Text(goal.rawValue)
                                        .font(Constants.Fonts.primaryLabel)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                                .fill(profileManager.fitnessGoal == goal ?
                                                      Constants.Colors.blue.opacity(0.3) :
                                                        Constants.Colors.surfaceMid)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                                .stroke(profileManager.fitnessGoal == goal ?
                                                       Constants.Colors.blue :
                                                        Constants.Colors.metallicLight,
                                                       lineWidth: Constants.Layout.borderWidth)
                                        )
                                }
                                .buttonStyle(SkeuomorphicButtonStyle())
                            }
                        }
                    }
                }
                
                // BMR Calculator
                MetallicPanel {
                    VStack(alignment: .leading, spacing: Constants.Layout.elementSpacing) {
                        Text("CALCULATE BMR")
                            .font(Constants.Fonts.primaryLabel)
                            .foregroundColor(Constants.Colors.primaryText)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("BASAL METABOLIC RATE")
                                .font(Constants.Fonts.systemMessage)
                                .foregroundColor(Constants.Colors.secondaryText)
                            
                            Text("\(profileManager.calculateBMR()) KCAL")
                                .font(Constants.Fonts.valueDisplay)
                                .foregroundColor(Constants.Colors.amber)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Constants.Colors.surfaceMid)
                        .cornerRadius(Constants.Layout.cornerRadius)
                        
                        Button {
                            proposedCalorieGoal = profileManager.calculateBMR()
                            profileManager.calorieGoal = proposedCalorieGoal
                            profileManager.saveUserProfile()
                            calorieModel.setDailyGoal(proposedCalorieGoal)
                            calorieModel.saveData()
                        } label: {
                            Text("SET AS DAILY GOAL")
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Constants.Colors.blue)
                                .cornerRadius(Constants.Layout.cornerRadius)
                        }
                        .buttonStyle(SkeuomorphicButtonStyle())
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Goals Section
    
    private var goalsSection: some View {
        ScrollView {
            VStack(spacing: Constants.Layout.componentSpacing) {
                // Calorie Goal Adjuster
                MetallicPanel {
                    VStack(alignment: .leading, spacing: Constants.Layout.elementSpacing) {
                        Text("CALORIE GOAL")
                            .font(Constants.Fonts.primaryLabel)
                            .foregroundColor(Constants.Colors.primaryText)
                        
                        // Current BMR display
                        HStack {
                            Text("BMR:")
                                .font(Constants.Fonts.systemMessage)
                                .foregroundColor(Constants.Colors.secondaryText)
                            
                            Text("\(profileManager.calculateBMR()) KCAL")
                                .font(Constants.Fonts.valueDisplay)
                                .foregroundColor(Constants.Colors.amber)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(Constants.Colors.surfaceMid)
                        .cornerRadius(Constants.Layout.cornerRadius / 2)
                        
                        // Goal adjuster
                        HStack {
                            Button {
                                proposedCalorieGoal = max(proposedCalorieGoal - 100, 500)
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .buttonStyle(SkeuomorphicButtonStyle())
                            
                            TextField("Goal", value: $proposedCalorieGoal, format: .number)
                                .keyboardType(.numberPad)
                                .font(Constants.Fonts.valueDisplay)
                                .multilineTextAlignment(.center)
                                .metallicTextField()
                            
                            Button {
                                proposedCalorieGoal = min(proposedCalorieGoal + 100, 10000)
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .buttonStyle(SkeuomorphicButtonStyle())
                        }
                        
                        // Deficit/Surplus display
                        let difference = proposedCalorieGoal - profileManager.calculateBMR()
                        HStack {
                            Text(difference >= 0 ? "SURPLUS:" : "DEFICIT:")
                                .font(Constants.Fonts.systemMessage)
                                .foregroundColor(Constants.Colors.secondaryText)
                            
                            Text("\(abs(difference)) KCAL")
                                .font(Constants.Fonts.valueDisplay)
                                .foregroundColor(difference >= 0 ? Constants.Colors.blue : Constants.Colors.alertRed)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(Constants.Colors.surfaceMid)
                        .cornerRadius(Constants.Layout.cornerRadius / 2)
                        
                        // Apply button
                        Button {
                            let currentGoal = profileManager.calorieGoal
                            let percentChange = abs(Double(proposedCalorieGoal - currentGoal) / Double(currentGoal))
                            
                            if percentChange > 0.2 {
                                showingCalorieWarning = true
                            } else {
                                profileManager.calorieGoal = proposedCalorieGoal
                                profileManager.saveUserProfile()
                                calorieModel.setDailyGoal(proposedCalorieGoal)
                                calorieModel.saveData()
                            }
                        } label: {
                            Text("APPLY CHANGES")
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Constants.Colors.blue)
                                .cornerRadius(Constants.Layout.cornerRadius)
                        }
                        .buttonStyle(SkeuomorphicButtonStyle())
                        .alert("Large Calorie Change", isPresented: $showingCalorieWarning) {
                            Button("Cancel", role: .cancel) {}
                            Button("Confirm", role: .destructive) {
                                profileManager.calorieGoal = proposedCalorieGoal
                                profileManager.saveUserProfile()
                                calorieModel.setDailyGoal(proposedCalorieGoal)
                                calorieModel.saveData()
                            }
                        } message: {
                            Text("This change is more than 20% from your current goal. Are you sure you want to proceed?")
                        }
                    }
                }
                
                // Macro Ratio Presets
                MetallicPanel {
                    VStack(alignment: .leading, spacing: Constants.Layout.elementSpacing) {
                        HStack {
                            Text("MACRO RATIOS")
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(Constants.Colors.primaryText)
                            
                            Button {
                                showingMacroInfo = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                            .alert("Macro Information", isPresented: $showingMacroInfo) {
                                Button("OK", role: .cancel) {}
                            } message: {
                                Text("Macronutrient ratios determine how your calories are distributed between protein, carbs, and fat.")
                            }
                        }
                        
                        // Preset buttons
                        HStack(spacing: Constants.Layout.elementSpacing) {
                            Button {
                                customMacroRatio = .balanced
                                profileManager.macroRatio = customMacroRatio
                                profileManager.saveUserProfile()
                            } label: {
                                Text("BALANCED\n40/30/30")
                                    .font(Constants.Fonts.primaryLabel)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SkeuomorphicButtonStyle())
                            
                            Button {
                                customMacroRatio = .highProtein
                                profileManager.macroRatio = customMacroRatio
                                profileManager.saveUserProfile()
                            } label: {
                                Text("HIGH PROTEIN\n40/40/20")
                                    .font(Constants.Fonts.primaryLabel)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SkeuomorphicButtonStyle())
                            
                            Button {
                                customMacroRatio = .keto
                                profileManager.macroRatio = customMacroRatio
                                profileManager.saveUserProfile()
                            } label: {
                                Text("KETO\n10/30/60")
                                    .font(Constants.Fonts.primaryLabel)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SkeuomorphicButtonStyle())
                        }
                        
                        // Custom ratio sliders
                        VStack(spacing: Constants.Layout.elementSpacing) {
                            MacroSlider(value: Binding(
                                get: { customMacroRatio.protein },
                                set: { newValue in
                                    let remaining = 100 - newValue
                                    let carbsRatio = remaining * (customMacroRatio.carbs / (customMacroRatio.carbs + customMacroRatio.fat))
                                    let fatRatio = remaining * (customMacroRatio.fat / (customMacroRatio.carbs + customMacroRatio.fat))
                                    customMacroRatio = MacroRatio(protein: newValue, carbs: carbsRatio, fat: fatRatio)
                                    profileManager.macroRatio = customMacroRatio
                                    profileManager.saveUserProfile()
                                }
                            ), title: "PROTEIN", color: Constants.Colors.blue)
                            
                            MacroSlider(value: Binding(
                                get: { customMacroRatio.carbs },
                                set: { newValue in
                                    let remaining = 100 - newValue
                                    let proteinRatio = remaining * (customMacroRatio.protein / (customMacroRatio.protein + customMacroRatio.fat))
                                    let fatRatio = remaining * (customMacroRatio.fat / (customMacroRatio.protein + customMacroRatio.fat))
                                    customMacroRatio = MacroRatio(protein: proteinRatio, carbs: newValue, fat: fatRatio)
                                    profileManager.macroRatio = customMacroRatio
                                    profileManager.saveUserProfile()
                                }
                            ), title: "CARBS", color: Constants.Colors.amber)
                            
                            MacroSlider(value: Binding(
                                get: { customMacroRatio.fat },
                                set: { newValue in
                                    let remaining = 100 - newValue
                                    let proteinRatio = remaining * (customMacroRatio.protein / (customMacroRatio.protein + customMacroRatio.carbs))
                                    let carbsRatio = remaining * (customMacroRatio.carbs / (customMacroRatio.protein + customMacroRatio.carbs))
                                    customMacroRatio = MacroRatio(protein: proteinRatio, carbs: carbsRatio, fat: newValue)
                                    profileManager.macroRatio = customMacroRatio
                                    profileManager.saveUserProfile()
                                }
                            ), title: "FAT", color: Color(red: 0.2, green: 0.8, blue: 0.2))
                        }
                        
                        // Macro distribution gauge
                        CircularMacroGauge(protein: customMacroRatio.protein,
                                         carbs: customMacroRatio.carbs,
                                         fat: customMacroRatio.fat)
                            .frame(height: 150)
                            .padding(.top)
                    }
                }
                
                // Hydration Target
                MetallicPanel {
                    VStack(alignment: .leading, spacing: Constants.Layout.elementSpacing) {
                        Text("HYDRATION TARGET")
                            .font(Constants.Fonts.primaryLabel)
                            .foregroundColor(Constants.Colors.primaryText)
                        
                        HStack {
                            // Decrement button
                            Button {
                                if profileManager.useMetricSystem {
                                    profileManager.hydrationGoal = max(profileManager.hydrationGoal - 0.1, 0.5)
                                } else {
                                    profileManager.hydrationGoalInOunces = max(profileManager.hydrationGoalInOunces - 8, 16)
                                }
                                profileManager.saveUserProfile()
                                hydrationModel.setDailyGoal(goal: profileManager.hydrationGoal)
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .buttonStyle(SkeuomorphicButtonStyle())
                            
                            // Current value display
                            VStack(alignment: .center) {
                                if profileManager.useMetricSystem {
                                    Text(String(format: "%.1f L", profileManager.hydrationGoal))
                                        .font(Constants.Fonts.valueDisplay)
                                        .foregroundColor(Constants.Colors.blue)
                                } else {
                                    Text(String(format: "%.0f FL OZ", profileManager.hydrationGoalInOunces))
                                        .font(Constants.Fonts.valueDisplay)
                                        .foregroundColor(Constants.Colors.blue)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Constants.Colors.surfaceMid)
                            .cornerRadius(Constants.Layout.cornerRadius)
                            
                            // Increment button
                            Button {
                                if profileManager.useMetricSystem {
                                    profileManager.hydrationGoal = min(profileManager.hydrationGoal + 0.1, 5.0)
                                } else {
                                    profileManager.hydrationGoalInOunces = min(profileManager.hydrationGoalInOunces + 8, 168)
                                }
                                profileManager.saveUserProfile()
                                hydrationModel.setDailyGoal(goal: profileManager.hydrationGoal)
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .buttonStyle(SkeuomorphicButtonStyle())
                        }
                        
                        // Calculate recommended button
                        Button {
                            let recommended = profileManager.calculateRecommendedHydration()
                            if profileManager.useMetricSystem {
                                profileManager.hydrationGoal = recommended
                            } else {
                                profileManager.hydrationGoalInOunces = recommended
                            }
                            profileManager.saveUserProfile()
                            hydrationModel.setDailyGoal(goal: profileManager.hydrationGoal)
                        } label: {
                            Text("CALCULATE RECOMMENDED")
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Constants.Colors.blue)
                                .cornerRadius(Constants.Layout.cornerRadius)
                        }
                        .buttonStyle(SkeuomorphicButtonStyle())
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Custom Views
    
    private struct MacroSlider: View {
        @Binding var value: Double
        let title: String
        let color: Color
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(Constants.Fonts.primaryLabel)
                        .foregroundColor(Constants.Colors.primaryText)
                    
                    Spacer()
                    
                    Text(String(format: "%.0f%%", value))
                        .font(Constants.Fonts.valueDisplay)
                        .foregroundColor(color)
                }
                
                Slider(value: $value, in: 0...100)
                    .tint(color)
            }
        }
    }
    
    private struct CircularMacroGauge: View {
        let protein: Double
        let carbs: Double
        let fat: Double
        
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Constants.Colors.surfaceMid, lineWidth: 20)
                    
                    // Fat arc
                    Arc(startAngle: .degrees(0),
                        endAngle: .degrees(360 * (fat / 100)))
                        .stroke(Color(red: 0.2, green: 0.8, blue: 0.2), lineWidth: 20)
                    
                    // Carbs arc
                    Arc(startAngle: .degrees(0),
                        endAngle: .degrees(360 * (carbs / 100)))
                        .stroke(Constants.Colors.amber, lineWidth: 20)
                        .padding(25)
                    
                    // Protein arc
                    Arc(startAngle: .degrees(0),
                        endAngle: .degrees(360 * (protein / 100)))
                        .stroke(Constants.Colors.blue, lineWidth: 20)
                        .padding(50)
                    
                    // Labels
                    VStack(spacing: 4) {
                        Text("P: \(Int(protein))%")
                            .foregroundColor(Constants.Colors.blue)
                        Text("C: \(Int(carbs))%")
                            .foregroundColor(Constants.Colors.amber)
                        Text("F: \(Int(fat))%")
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
                    }
                    .font(Constants.Fonts.systemMessage)
                }
            }
        }
    }
    
    private struct Arc: Shape {
        let startAngle: Angle
        let endAngle: Angle
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                       radius: rect.width / 2,
                       startAngle: .degrees(-90) + startAngle,
                       endAngle: .degrees(-90) + endAngle,
                       clockwise: false)
            return path
        }
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        ScrollView {
            VStack(spacing: Constants.Layout.componentSpacing) {
                // Theme Selection
                MetallicPanel {
                    VStack(alignment: .leading, spacing: Constants.Layout.elementSpacing) {
                        Text("THEME")
                            .font(Constants.Fonts.primaryLabel)
                            .foregroundColor(Constants.Colors.primaryText)
                        
                        HStack(spacing: Constants.Layout.elementSpacing) {
                            ForEach(AppTheme.allCases) { theme in
                                Button {
                                    withAnimation {
                                        profileManager.theme = theme
                                        profileManager.saveUserProfile()
                                    }
                                } label: {
                                    VStack(spacing: 8) {
                                        // Theme preview circle
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: theme.primaryColor))
                                                .frame(width: 60, height: 60)
                                                .overlay(
                                                    Circle()
                                                        .strokeBorder(Color(hex: theme.secondaryColor), lineWidth: 3)
                                                )
                                                .shadow(color: Color(hex: theme.primaryColor).opacity(0.5),
                                                        radius: 10, x: 0, y: 0)
                                            
                                            if profileManager.theme == theme {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        
                                        Text(theme.rawValue)
                                            .font(Constants.Fonts.primaryLabel)
                                            .foregroundColor(profileManager.theme == theme ?
                                                           Color(hex: theme.primaryColor) :
                                                            Constants.Colors.primaryText)
                                    }
                                }
                                .buttonStyle(SkeuomorphicButtonStyle())
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                // Units Toggle
                MetallicPanel {
                    VStack(alignment: .leading, spacing: Constants.Layout.elementSpacing) {
                        Text("UNITS")
                            .font(Constants.Fonts.primaryLabel)
                            .foregroundColor(Constants.Colors.primaryText)
                        
                        HStack {
                            ForEach(UnitSystem.allCases) { system in
                                Button {
                                    withAnimation {
                                        profileManager.useMetricSystem = system == .metric
                                        profileManager.saveUserProfile()
                                    }
                                } label: {
                                    HStack {
                                        if (system == .metric && profileManager.useMetricSystem) ||
                                            (system == .imperial && !profileManager.useMetricSystem) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Constants.Colors.blue)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(Constants.Colors.secondaryText)
                                        }
                                        
                                        Text(system.rawValue)
                                            .font(Constants.Fonts.primaryLabel)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                            .fill((system == .metric && profileManager.useMetricSystem) ||
                                                  (system == .imperial && !profileManager.useMetricSystem) ?
                                                  Constants.Colors.blue.opacity(0.2) :
                                                    Constants.Colors.surfaceMid)
                                    )
                                }
                                .buttonStyle(SkeuomorphicButtonStyle())
                            }
                        }
                    }
                }
                
                // Haptic Feedback
                MetallicPanel {
                    VStack(alignment: .leading, spacing: Constants.Layout.elementSpacing) {
                        HStack {
                            Text("HAPTIC FEEDBACK")
                                .font(Constants.Fonts.primaryLabel)
                                .foregroundColor(Constants.Colors.primaryText)
                            
                            Toggle("", isOn: $profileManager.hapticsEnabled)
                                .onChange(of: profileManager.hapticsEnabled) { oldValue, newValue in
                                    if newValue {
                                        HapticManager.shared.impact(style: .medium)
                                    }
                                    profileManager.saveUserProfile()
                                }
                        }
                        
                        if profileManager.hapticsEnabled {
                            VStack(alignment: .leading, spacing: Constants.Layout.elementSpacing) {
                                Text("INTENSITY")
                                    .font(Constants.Fonts.systemMessage)
                                    .foregroundColor(Constants.Colors.secondaryText)
                                
                                Picker("Intensity", selection: $profileManager.hapticIntensity) {
                                    ForEach(HapticIntensity.allCases) { intensity in
                                        Text(intensity.rawValue).tag(intensity)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .metallicSegmentedStyle()
                                .onChange(of: profileManager.hapticIntensity) { oldValue, newValue in
                                    switch newValue {
                                    case .light:
                                        HapticManager.shared.impact(style: .light)
                                    case .medium:
                                        HapticManager.shared.impact(style: .medium)
                                    case .strong:
                                        HapticManager.shared.impact(style: .heavy)
                                    }
                                    profileManager.saveUserProfile()
                                }
                                
                                Button {
                                    isTestingHaptic = true
                                    switch profileManager.hapticIntensity {
                                    case .light:
                                        HapticManager.shared.impact(style: .light)
                                    case .medium:
                                        HapticManager.shared.impact(style: .medium)
                                    case .strong:
                                        HapticManager.shared.impact(style: .heavy)
                                    }
                                    
                                    // Reset the testing state after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isTestingHaptic = false
                                    }
                                } label: {
                                    HStack {
                                        Text("TEST")
                                            .font(Constants.Fonts.primaryLabel)
                                        
                                        Image(systemName: isTestingHaptic ? "waveform" : "waveform.path")
                                            .font(.system(size: 20))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Constants.Colors.blue)
                                    .cornerRadius(Constants.Layout.cornerRadius)
                                }
                                .buttonStyle(SkeuomorphicButtonStyle())
                                .disabled(!profileManager.hapticsEnabled)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - MetallicPanel View
    
    private struct MetallicPanel<Content: View>: View {
        let content: Content
        
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            content
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                        .fill(Constants.Colors.surfaceLight)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                .stroke(Constants.Gradients.metallicRim, lineWidth: Constants.Layout.borderWidth)
                        )
                        .shadow(
                            color: Constants.Shadows.panelShadow.color,
                            radius: Constants.Shadows.panelShadow.radius,
                            x: Constants.Shadows.panelShadow.x,
                            y: Constants.Shadows.panelShadow.y
                        )
                )
        }
    }
}

// Placeholder panel views
struct ProfileSettingsPanel: View {
    var body: some View {
        Text("Profile Settings")
    }
}

struct GoalsSettingsPanel: View {
    var body: some View {
        Text("Goals Settings")
    }
}

struct PreferencesSettingsPanel: View {
    var body: some View {
        Text("Preferences Settings")
    }
}

#Preview {
    SettingsView(
        calorieModel: CalorieModel(),
        hydrationModel: HydrationModel()
    )
} 