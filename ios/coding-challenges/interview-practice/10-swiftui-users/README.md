# Challenge 10: User Directory (SwiftUI)

**API:** `https://dummyjson.com/users?limit=20`
**Time:** 45 minutes
**Framework:** SwiftUI

## Starting point

A working SwiftUI app that fetches users, displays them in a list with avatar placeholders and email, and supports searching by name. All state, networking, search filtering, and avatar logic live in one `ContentView`.

## Files

| File | What it does |
|------|-------------|
| `DummyUser.swift` | Codable model + response wrapper |
| `ContentView.swift` | State, networking, search, avatar — everything (the mess) |

## Tasks

### 1. Refactor to MVVM (20 min)

Extract a `UserViewModel` with `@Published` state. Create a `UserServiceProtocol` for networking. Move search filtering into the ViewModel. Extract the user row into a `UserRow` subview.

### 2. Test the ViewModel (10 min)

Create a `MockUserService`. Test loading, error state, and that search filtering returns correct results.

### 3. Implement the algorithm (15 min)

`buildInvertedIndex(_:)` — Build an inverted index from user first names. Map each lowercased character to the array of users whose `firstName` contains that character. Currently returns `[:]`.

**Example:** If users are ["Emily", "Emma"], then `'e' -> [Emily, Emma]`, `'m' -> [Emily, Emma]`, `'i' -> [Emily]`, etc.

## Discussion topics

- `.searchable` modifier — how does it work with bindings?
- How would you add infinite scroll / pagination?
- `AsyncImage` vs custom image loading — trade-offs?
