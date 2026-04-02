# Challenge 02: Product Catalog

## Description

A product catalog app that fetches items from an API and displays them in a grid. Each product has: title, price, thumbnail, category, rating.

**API:** `https://dummyjson.com/products?limit=30`

### Key Classes

- `main.dart` — everything in one file: networking, models, UI, price formatting.

## Goal

Refactor into clean architecture layers. Introduce a state management approach.

### Tasks

1. **Refactor** — Separate into Model, Repository (abstract + concrete), and Widget layers. Use a ChangeNotifier or any state management for the product list state. Add unit tests for the repository.

2. **Algorithm** — Given a budget (e.g. $100), find the maximum number of unique products the user can buy. Implement the greedy approach (sort by price, pick cheapest first). The `maxProductsInBudget()` function currently returns 0.

3. **Feature** — Add category filter chips at the top. Tapping a chip filters products by that category.

### Discussion

- Why separate the repository from the widget?
- How does ChangeNotifier compare to Riverpod or BLoC?
- How would you handle image caching?
