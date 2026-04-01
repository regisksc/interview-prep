import SwiftUI

struct TodayView: View {
    private let habits = Habit.samples

    var body: some View {
        NavigationStack {
            List(habits) { habit in
                Label(habit.name, systemImage: habit.icon)
                    .foregroundStyle(habit.color)
            }
            .navigationTitle("Today")
        }
    }
}

#Preview {
    TodayView()
}
