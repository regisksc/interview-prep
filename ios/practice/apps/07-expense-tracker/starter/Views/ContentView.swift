import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie")
                }

            AddExpenseView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }

            ExpenseListView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
}
