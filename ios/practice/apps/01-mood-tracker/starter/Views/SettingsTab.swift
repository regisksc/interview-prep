import SwiftUI

struct SettingsTab: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Settings will appear here.")
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsTab()
}
