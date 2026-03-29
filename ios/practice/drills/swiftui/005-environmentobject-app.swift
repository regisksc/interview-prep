// SwiftUI Drill 5: @EnvironmentObject Setup
// Time: 15 minutes
//
// Requirements:
// 1. Create AppState class with @Published isLoggedIn and username
// 2. Inject AppState at App level with .environmentObject()
// 3. Read AppState in deeply nested view with @EnvironmentObject

import SwiftUI

// TODO: Create AppState class conforming to ObservableObject
class AppState: ObservableObject {
    // TODO: @Published var isLoggedIn: Bool
    // TODO: @Published var username: String
}

// TODO: Create App struct
@main
struct MyApp: App {
    // TODO: @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            // TODO: Create ContentView and inject appState with .environmentObject()
        }
    }
}

// TODO: Create ContentView with navigation to ProfileView
struct ContentView: View {
    // TODO: @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // TODO: Display login status
                
                // TODO: If logged in, show username
                // TODO: If logged out, show "Not logged in"
                
                // TODO: Toggle button (login/logout)
                
                // TODO: Navigation link to ProfileView
            }
            .navigationTitle("Home")
        }
    }
}

// TODO: Create ProfileView that also accesses appState
struct ProfileView: View {
    // TODO: @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Profile")
                .font(.largeTitle)
            
            // TODO: Display username from appState
        }
    }
}

// Expected behavior:
// - AppState is created once at app level
// - Both ContentView and ProfileView access same state
// - Login/logout toggles affect all views
// - No need to pass state through intermediate views

// Key learning:
// - @EnvironmentObject for dependency injection
// - Missing injection causes runtime crash
// - Great for app-wide state (user session, theme, etc.)

// Bonus:
// - Add email property to AppState
// - Create login form that updates AppState
// - Add logout confirmation alert

#Preview {
    ContentView()
        .environmentObject(AppState())
}

// Solution hint:
// @main
// struct MyApp: App {
//     @StateObject private var appState = AppState()
//     
//     var body: some Scene {
//         WindowGroup {
//             ContentView()
//                 .environmentObject(appState)
//         }
//     }
// }
