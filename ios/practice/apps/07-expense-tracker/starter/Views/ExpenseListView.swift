import SwiftUI

struct ExpenseListView: View {
    private let expenses = Expense.samples

    var body: some View {
        NavigationStack {
            List(expenses) { expense in
                Label {
                    Text(expense.amount, format: .currency(code: "USD"))
                } icon: {
                    Image(systemName: expense.category.sfSymbol)
                        .foregroundStyle(expense.category.color)
                }
            }
            .navigationTitle("Expenses")
        }
    }
}

#Preview {
    ExpenseListView()
}
