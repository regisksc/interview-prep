import SwiftUI

struct HistoryTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                Image("empty-history")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)

                Text("Your mood history will appear here.")
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryTab()
}
