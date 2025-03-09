//
//  MealCategoryCard.swift
//  HalCal
//
//  Created by Claude on 3/9/25.
//

import SwiftUI

struct MealCategoryCard: View {
    let icon: String
    let title: String
    let calories: Int
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Emoji icon
                    Text(icon)
                        .font(.system(size: 24))
                    
                    Spacer()
                    
                    // Plus button for adding
                    Image(systemName: "plus")
                        .foregroundColor(Constants.Colors.calorieOrange)
                        .font(.system(size: 16, weight: .medium))
                        .padding(6)
                        .background(Constants.Colors.calorieOrange.opacity(0.15))
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Meal title
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black.opacity(0.8))
                    
                    // Calorie count
                    Text("\(calories) kcal")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black.opacity(0.6))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        HStack {
            MealCategoryCard(
                icon: "☕️",
                title: "Breakfast",
                calories: 243,
                color: Color(red: 0.9, green: 0.9, blue: 1.0)
            ) {
                print("Add breakfast")
            }
            
            MealCategoryCard(
                icon: "🥗",
                title: "Lunch",
                calories: 335,
                color: Color(red: 0.9, green: 1.0, blue: 0.9)
            ) {
                print("Add lunch")
            }
        }
        
        HStack {
            MealCategoryCard(
                icon: "🍲",
                title: "Dinner",
                calories: 0,
                color: Color(red: 0.9, green: 1.0, blue: 1.0)
            ) {
                print("Add dinner")
            }
            
            MealCategoryCard(
                icon: "🥨",
                title: "Snack",
                calories: 0,
                color: Color(red: 1.0, green: 0.9, blue: 1.0)
            ) {
                print("Add snack")
            }
        }
    }
    .padding()
    .background(Color.black)
} 