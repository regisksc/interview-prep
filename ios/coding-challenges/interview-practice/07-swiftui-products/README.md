# Challenge 07: Product Store

**API:** `https://dummyjson.com/products?limit=30`
**Time:** 45 minutes
**Framework:** SwiftUI

## Starting point

A working SwiftUI app that fetches products and displays them in a two-column grid with thumbnails, prices, and ratings. All state, networking, and formatting live in one `ContentView`.

## Files

| File | What it does |
|------|-------------|
| `Product.swift` | Codable model + response wrapper |
| `ContentView.swift` | State, networking, grid layout — everything (the mess) |

## Tasks

### 1. Refactor to MVVM (20 min)

Extract a `ProductViewModel` with `@Published` state. Create a `ProductServiceProtocol` for networking. Extract the product card into a `ProductCard` subview.

### 2. Test the ViewModel (10 min)

Create a `MockProductService`. Test loading, error handling, and that product count is correct.

### 3. Implement the algorithm (15 min)

`maxProductsWithinBudget(_:budget:)` — Given a budget, find the maximum number of unique products you can buy. Sort by price ascending, greedily pick until the budget is exhausted. Return the selected products. Currently returns `[]`.

## Discussion topics

- `LazyVGrid` vs `List` — when to use which?
- How would you add a cart with item counts?
- How would you handle currency formatting for different locales?
