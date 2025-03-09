import SwiftUI

struct DaySelector: View {
    @Binding var selectedDay: Date
    private let calendar = Calendar.current
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 8) {
            // Current month and year
            Text(monthYearString())
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Constants.Colors.primaryText)
            
            // Day selector
            HStack(spacing: 15) {
                ForEach(0..<7) { index in
                    let date = getDate(for: index)
                    DayIndicator(
                        day: weekdays[index],
                        date: calendar.component(.day, from: date),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDay),
                        isToday: calendar.isDateInToday(date)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDay = date
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Constants.Layout.screenMargin)
        .padding(.vertical, Constants.Layout.elementSpacing)
    }
    
    private func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDay)
    }
    
    private func getDate(for index: Int) -> Date {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let difference = index - (weekday - 1)
        return calendar.date(byAdding: .day, value: difference, to: today) ?? today
    }
}

struct DayIndicator: View {
    let day: String
    let date: Int
    let isSelected: Bool
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Text(day)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Constants.Colors.secondaryText)
            
            ZStack {
                Circle()
                    .fill(isSelected ? Constants.Colors.calorieAccent : Color.clear)
                    .frame(width: Constants.Layout.dayIndicatorSize,
                           height: Constants.Layout.dayIndicatorSize)
                
                Text("\(date)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .black : Constants.Colors.primaryText)
            }
        }
    }
}

#Preview {
    DaySelector(selectedDay: .constant(Date()))
        .preferredColorScheme(.dark)
} 