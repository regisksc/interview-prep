// SwiftUI Drill 4: @AppStorage Persistence
// Time: 10 minutes
//
// Requirements:
// 1. Create a settings view that saves username to @AppStorage
// 2. Load the username on app launch
// 3. Add a "Clear" button that resets it to empty

import SwiftUI

struct SettingsView: View {
    // TODO: Add @AppStorage property for username
    // Key: "username", Default: ""
    
    // TODO: Add @AppStorage for theme preference
    // Key: "darkMode", Default: false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .padding(.top)
            
            // TODO: TextField for username with @AppStorage binding
            
            // TODO: Toggle for dark mode
            
            // TODO: Clear button that resets username to ""
            
            Spacer()
            
            // TODO: Display current values for debugging
            Text("Username: \(username)")
            Text("Dark Mode: \(darkMode ? "On" : "Off")")
        }
        .padding()
    }
}

// Expected behavior:
// - Username persists across app launches
// - Dark mode toggle persists
// - Clear button removes username
// - Values update immediately when changed

// Key learning:
// - @AppStorage wraps UserDefaults
// - Only works with property list types
// - Automatically triggers view updates

// Bonus:
// - Add validation (username 3-20 chars)
// - Show character count
// - Add save confirmation alert

#Preview {
    SettingsView()
}

// Solution hint:
// @AppStorage("username") private var username: String = ""
// @AppStorage("darkMode") private var darkMode = false
