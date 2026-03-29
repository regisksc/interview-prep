// SwiftUI Drill 3: @StateObject vs @ObservedObject
// Time: 15 minutes
//
// Requirements:
// 1. Create a CounterViewModel class with @Published count
// 2. Create OwnerView that creates the ViewModel (@StateObject)
// 3. Create ChildView that receives it (@ObservedObject)
// 4. Both views display and modify the same count

import SwiftUI

// TODO: Create ViewModel class conforming to ObservableObject
class CounterViewModel: ObservableObject {
    // TODO: Add @Published var count: Int
    
    // TODO: Add increment() method
    // TODO: Add decrement() method
}

// TODO: Create OwnerView that owns the ViewModel
struct OwnerView: View {
    // TODO: Use @StateObject to create ViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Owner View")
                .font(.headline)
            
            // TODO: Display count
            
            // TODO: Add increment/decrement buttons
            
            // TODO: Pass viewModel to ChildView
        }
        .padding()
    }
}

// TODO: Create ChildView that borrows the ViewModel
struct ChildView: View {
    // TODO: Use @ObservedObject for ViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Child View")
                .font(.headline)
            
            // TODO: Display count from viewModel
            
            // TODO: Add increment/decrement buttons
        }
        .padding()
    }
}

// Expected behavior:
// - Both views show the same count
// - Modifying in either view updates both
// - Count persists when navigating between views

// Key learning:
// - @StateObject creates and owns the object
// - @ObservedObject borrows without owning
// - Using @ObservedObject with inline init causes state loss

// Bonus:
// - Add a reset button
// - Persist count with @AppStorage in ViewModel
// - Add validation (count can't go below 0)

#Preview {
    OwnerView()
}

// Solution hint:
// @StateObject private var viewModel = CounterViewModel()
// @ObservedObject var viewModel: CounterViewModel
