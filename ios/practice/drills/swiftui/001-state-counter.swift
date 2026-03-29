// SwiftUI Drill 1: @State Basics
// Time: 10 minutes
//
// Requirements:
// 1. Create a view with a counter displayed as text
// 2. Add a button that increments the counter
// 3. Add a button that decrements the counter
// 4. Counter changes color based on value:
//    - Negative: red
//    - Zero: gray
//    - Positive: green

import SwiftUI

struct CounterView: View {
    // TODO: Add @State property for count
    
    var body: some View {
        VStack(spacing: 20) {
            // TODO: Display counter with dynamic color
            
            HStack(spacing: 40) {
                // TODO: Decrement button
                // TODO: Increment button
            }
        }
        .padding()
    }
}

// Expected behavior:
// - Counter starts at 0 (gray)
// - Tapping + makes it positive (green)
// - Tapping - makes it negative (red)
// - Color changes smoothly with value

// Bonus:
// - Add animation to color change
// - Add haptic feedback on button tap
// - Add reset button when count != 0

#Preview {
    CounterView()
}

// Solution hint:
// @State private var count = 0
// .foregroundColor(count < 0 ? .red : count > 0 ? .green : .gray)
