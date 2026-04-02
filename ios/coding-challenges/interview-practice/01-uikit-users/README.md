# Challenge 01: User Directory

**API:** `https://jsonplaceholder.typicode.com/users`
**Time:** 45 minutes
**Framework:** UIKit

## Starting point

A working app that loads 10 users from a REST API and displays them in a `UITableView`. All logic — networking, UI setup, cell formatting — lives in one view controller.

## Files

| File | What it does |
|------|-------------|
| `User.swift` | Codable model matching the API |
| `Networking/APIClient.swift` | Generic async fetch helper |
| `ViewController.swift` | Everything else (the mess) |

## Tasks

### 1. Refactor to MVVM (20 min)

Extract a `UserViewModel` that owns the user array and loading state. Create a `UserServiceProtocol` and concrete `UserService` for networking. The ViewController should only manage UIKit views and forward actions.

### 2. Test the ViewModel (10 min)

Create a `MockUserService` conforming to your protocol. Test that `loadUsers()` populates the array and that errors are handled.

### 3. Implement the algorithm (15 min)

`groupUsersByCompany(_:)` — Group users by `company.name` and return an array of `(company: String, users: [User])` tuples sorted alphabetically by company name. Currently returns `[]`.

## Discussion topics

- Why use a protocol for the service?
- What does `@MainActor` do and why use it on the ViewModel?
- How would you add a search bar to filter users?
