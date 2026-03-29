// SwiftUI Drill 2: @Binding Practice
// Time: 15 minutes
//
// Requirements:
// 1. Create a ParentView with @State for a text value
// 2. Create a ChildView with @Binding to the text
// 3. Child has a TextField that modifies the binding
// 4. Parent displays the text in real-time below the child

import SwiftUI

// TODO: Create ChildView with @Binding var text: String
struct ChildView: View {
    // TODO: Add @Binding property
    
    var body: some View {
        VStack {
            Text("Enter your name:")
                .font(.headline)
            
            // TODO: Add TextField bound to the binding
        }
        .padding()
    }
}

// TODO: Create ParentView with @State private var name: String
struct ParentView: View {
    // TODO: Add @State property
    
    var body: some View {
        VStack(spacing: 20) {
            // TODO: Add ChildView, passing binding with $name
            
            // TODO: Display "Hello, [name]!" below
        }
        .padding()
    }
}

// Expected behavior:
// - Typing in ChildView's TextField updates ParentView's display
// - Parent owns the state, Child modifies it
// - Changes reflect immediately in both views

// Bonus:
// - Add character count display
// - Disable TextField if name is longer than 20 characters
// - Add clear button in ParentView

#Preview {
    ParentView()
}

// Solution hint:
// ChildView: @Binding var text: String
// ParentView: @State private var name = ""
// Pass binding: ChildView(text: $name)
