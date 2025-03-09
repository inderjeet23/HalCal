import Foundation
import Combine

enum ActivityLevel: String, CaseIterable, Identifiable {
    case sedentary = "SEDENTARY"
    case moderate = "MODERATE"
    case active = "ACTIVE"
    case veryActive = "VERY ACTIVE"
    
    var id: String { self.rawValue }
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .moderate: return 1.375
        case .active: return 1.55
        case .veryActive: return 1.725
        }
    }
    
    var description: String {
        switch self {
        case .sedentary: return "Little to no exercise"
        case .moderate: return "Light exercise 1-3 days/week"
        case .active: return "Moderate exercise 3-5 days/week"
        case .veryActive: return "Hard exercise 6-7 days/week"
        }
    }
}

enum FitnessGoal: String, CaseIterable, Identifiable {
    case weightLoss = "WEIGHT LOSS"
    case maintenance = "MAINTENANCE"
    case muscleGain = "MUSCLE GAIN"
    
    var id: String { self.rawValue }
    
    var calorieAdjustment: Double {
        switch self {
        case .weightLoss: return 0.8 // 20% deficit
        case .maintenance: return 1.0 // No adjustment
        case .muscleGain: return 1.1 // 10% surplus
        }
    }
    
    var description: String {
        switch self {
        case .weightLoss: return "Calorie deficit for fat loss"
        case .maintenance: return "Maintain current weight"
        case .muscleGain: return "Calorie surplus for muscle growth"
        }
    }
}

enum UnitSystem: String, CaseIterable, Identifiable {
    case metric = "METRIC"
    case imperial = "IMPERIAL"
    
    var id: String { self.rawValue }
}

enum HapticIntensity: String, CaseIterable, Identifiable {
    case light = "LIGHT"
    case medium = "MEDIUM"
    case strong = "STRONG"
    
    var id: String { self.rawValue }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case hal = "HAL"
    case europa = "EUROPA"
    case mars = "MARS"
    
    var id: String { self.rawValue }
    
    var primaryColor: String {
        switch self {
        case .hal: return "#FF9D00" // Amber
        case .europa: return "#00B2FF" // Blue/Teal
        case .mars: return "#FF4500" // Red/Orange
        }
    }
    
    var secondaryColor: String {
        switch self {
        case .hal: return "#4A90E2" // Blue
        case .europa: return "#00FFCC" // Teal
        case .mars: return "#FFA500" // Orange
        }
    }
}

struct MacroRatio {
    var protein: Double // percentage
    var carbs: Double // percentage
    var fat: Double // percentage
    
    static let balanced = MacroRatio(protein: 40, carbs: 30, fat: 30)
    static let highProtein = MacroRatio(protein: 40, carbs: 40, fat: 20)
    static let keto = MacroRatio(protein: 10, carbs: 30, fat: 60)
}

class UserProfileManager: ObservableObject {
    // User profile data
    @Published var height: Double = 175.0 // cm
    @Published var weight: Double = 70.0 // kg
    @Published var activityLevel: ActivityLevel = .moderate
    @Published var fitnessGoal: FitnessGoal = .maintenance
    @Published var useMetricSystem: Bool = true
    
    // App preferences
    @Published var theme: AppTheme = .hal
    @Published var hapticsEnabled: Bool = true
    @Published var hapticIntensity: HapticIntensity = .medium
    
    // Nutrition goals
    @Published var calorieGoal: Int = 2000
    @Published var macroRatio: MacroRatio = .balanced
    @Published var hydrationGoal: Double = 2.5 // L
    
    // Computed properties for unit conversion
    var heightInFeetInches: (feet: Int, inches: Int) {
        get {
            let totalInches = height / 2.54
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            return (feet, inches)
        }
        set {
            let totalInches = Double(newValue.feet * 12 + newValue.inches)
            height = totalInches * 2.54
        }
    }
    
    var weightInPounds: Double {
        get { weight * 2.20462 }
        set { weight = newValue / 2.20462 }
    }
    
    var hydrationGoalInOunces: Double {
        get { hydrationGoal * 33.814 }
        set { hydrationGoal = newValue / 33.814 }
    }
    
    init() {
        loadUserProfile()
    }
    
    // MARK: - BMR Calculation
    
    func calculateBMR() -> Int {
        // Harris-Benedict Formula
        var bmr: Double
        
        if useMetricSystem {
            // Metric formula
            if true { // Assuming male for now, would need gender in profile
                bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * 30) // Age hardcoded to 30
            } else {
                bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * 30) // Age hardcoded to 30
            }
        } else {
            // Imperial formula
            let weightLbs = weightInPounds
            let heightInches = Double(heightInFeetInches.feet * 12 + heightInFeetInches.inches)
            
            if true { // Assuming male for now
                bmr = 66 + (6.23 * weightLbs) + (12.7 * heightInches) - (6.8 * 30) // Age hardcoded to 30
            } else {
                bmr = 655 + (4.35 * weightLbs) + (4.7 * heightInches) - (4.7 * 30) // Age hardcoded to 30
            }
        }
        
        // Apply activity level multiplier
        let tdee = bmr * activityLevel.multiplier
        
        // Apply fitness goal adjustment
        let adjustedCalories = tdee * fitnessGoal.calorieAdjustment
        
        return Int(adjustedCalories.rounded())
    }
    
    // MARK: - Hydration Calculation
    
    func calculateRecommendedHydration() -> Double {
        // Standard recommendation: 30-35ml per kg of body weight
        let recommendedMl = weight * 33 // Using 33ml per kg as middle ground
        
        if useMetricSystem {
            return recommendedMl / 1000 // Convert to liters
        } else {
            return (recommendedMl / 1000) * 33.814 // Convert to fluid ounces
        }
    }
    
    // MARK: - Macro Calculations
    
    func calculateMacroGrams(forCalories calories: Int) -> (protein: Double, carbs: Double, fat: Double) {
        let proteinCalories = Double(calories) * (macroRatio.protein / 100)
        let carbsCalories = Double(calories) * (macroRatio.carbs / 100)
        let fatCalories = Double(calories) * (macroRatio.fat / 100)
        
        // Convert calories to grams (4 cal/g protein, 4 cal/g carbs, 9 cal/g fat)
        let proteinGrams = proteinCalories / 4
        let carbsGrams = carbsCalories / 4
        let fatGrams = fatCalories / 9
        
        return (proteinGrams, carbsGrams, fatGrams)
    }
    
    // MARK: - Data Persistence
    
    func loadUserProfile() {
        // Load height
        if let savedHeight = UserDefaults.standard.object(forKey: "userHeight") as? Double {
            height = savedHeight
        }
        
        // Load weight
        if let savedWeight = UserDefaults.standard.object(forKey: "userWeight") as? Double {
            weight = savedWeight
        }
        
        // Load activity level
        if let savedActivityLevel = UserDefaults.standard.string(forKey: "activityLevel"),
           let level = ActivityLevel(rawValue: savedActivityLevel) {
            activityLevel = level
        }
        
        // Load fitness goal
        if let savedFitnessGoal = UserDefaults.standard.string(forKey: "fitnessGoal"),
           let goal = FitnessGoal(rawValue: savedFitnessGoal) {
            fitnessGoal = goal
        }
        
        // Load unit system preference
        useMetricSystem = UserDefaults.standard.bool(forKey: "useMetricSystem")
        
        // Load theme
        if let savedTheme = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            self.theme = theme
        }
        
        // Load haptics settings
        hapticsEnabled = UserDefaults.standard.bool(forKey: "hapticsEnabled")
        if let savedIntensity = UserDefaults.standard.string(forKey: "hapticIntensity"),
           let intensity = HapticIntensity(rawValue: savedIntensity) {
            hapticIntensity = intensity
        }
        
        // Load nutrition goals
        if let savedCalorieGoal = UserDefaults.standard.object(forKey: "userCalorieGoal") as? Int {
            calorieGoal = savedCalorieGoal
        }
        
        if let savedHydrationGoal = UserDefaults.standard.object(forKey: "userHydrationGoal") as? Double {
            hydrationGoal = savedHydrationGoal
        }
        
        // Load macro ratio
        let proteinRatio = UserDefaults.standard.double(forKey: "macroRatioProtein")
        let carbsRatio = UserDefaults.standard.double(forKey: "macroRatioCarbs")
        let fatRatio = UserDefaults.standard.double(forKey: "macroRatioFat")
        
        if proteinRatio > 0 && carbsRatio > 0 && fatRatio > 0 {
            macroRatio = MacroRatio(protein: proteinRatio, carbs: carbsRatio, fat: fatRatio)
        }
    }
    
    func saveUserProfile() {
        // Save height and weight
        UserDefaults.standard.set(height, forKey: "userHeight")
        UserDefaults.standard.set(weight, forKey: "userWeight")
        
        // Save activity level and fitness goal
        UserDefaults.standard.set(activityLevel.rawValue, forKey: "activityLevel")
        UserDefaults.standard.set(fitnessGoal.rawValue, forKey: "fitnessGoal")
        
        // Save unit system preference
        UserDefaults.standard.set(useMetricSystem, forKey: "useMetricSystem")
        
        // Save theme
        UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
        
        // Save haptics settings
        UserDefaults.standard.set(hapticsEnabled, forKey: "hapticsEnabled")
        UserDefaults.standard.set(hapticIntensity.rawValue, forKey: "hapticIntensity")
        
        // Save nutrition goals
        UserDefaults.standard.set(calorieGoal, forKey: "userCalorieGoal")
        UserDefaults.standard.set(hydrationGoal, forKey: "userHydrationGoal")
        
        // Save macro ratio
        UserDefaults.standard.set(macroRatio.protein, forKey: "macroRatioProtein")
        UserDefaults.standard.set(macroRatio.carbs, forKey: "macroRatioCarbs")
        UserDefaults.standard.set(macroRatio.fat, forKey: "macroRatioFat")
    }
} 