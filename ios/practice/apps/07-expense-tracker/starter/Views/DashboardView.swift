import SwiftUI

struct DashboardView: View {
    private let expenses = Expense.samples

    private var total: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text(total, format: .currency(code: "USD"))
                    .font(.largeTitle.bold())
                    .padding()
                Spacer()
            }
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardView()
}
