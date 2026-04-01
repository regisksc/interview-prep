import SwiftUI

struct ContentView: View {
    let contacts = Contact.samples

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(contacts) { contact in
                    Text(contact.fullName)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("Contacts")
        }
    }
}

#Preview {
    ContentView()
}
