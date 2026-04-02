# Challenge 08: Quote Wall

**API:** `https://dummyjson.com/quotes?limit=30`
**Time:** 45 minutes
**Framework:** SwiftUI

## Starting point

A working SwiftUI app that fetches quotes and displays them in styled cards with author attribution and character count. All state, networking, and card layout live in one `ContentView`.

## Files

| File | What it does |
|------|-------------|
| `Quote.swift` | Codable model + response wrapper |
| `ContentView.swift` | State, networking, card layout — everything (the mess) |

## Tasks

### 1. Refactor to MVVM (20 min)

Extract a `QuoteViewModel` with `@Published` state. Create a `QuoteServiceProtocol` for networking. Extract the quote card into a `QuoteCard` subview.

### 2. Test the ViewModel (10 min)

Create a `MockQuoteService`. Test loading, error handling, and that quotes are populated.

### 3. Implement the algorithm (15 min)

`longestIncreasingSubsequence(_:)` — Given an array of quotes, find the longest increasing subsequence based on quote length (character count). Return the quotes forming that subsequence. Currently returns `[]`.

**Hint:** Classic LIS with O(n²) DP is fine for 30 items.

## Discussion topics

- `LazyVStack` vs `List` — performance and behavior differences?
- How would you add a "copy to clipboard" button?
- How would you persist favorite quotes locally?
