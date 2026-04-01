import SwiftUI

struct AddExpenseView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Add Expense",
                systemImage: "plus.circle",
                description: Text("Expense entry form will go here.")
            )
            .navigationTitle("Add Expense")
        }
    }
}

#Preview {
    AddExpenseView()
}
