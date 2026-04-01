import SwiftUI

struct TodayTab: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("How are you feeling today?")
                    .font(.title2)

                Spacer()
            }
            .padding()
            .navigationTitle("Today")
        }
    }
}

#Preview {
    TodayTab()
}
