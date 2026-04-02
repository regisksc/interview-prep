# Challenge 04: Quotes Collection

## Description

A quotes app that fetches quotes and displays them as cards. Each quote has: quote text, author.

**API:** `https://dummyjson.com/quotes?limit=30`

### Key Classes

- `main.dart` — everything in one file.

## Goal

Refactor to clean architecture. Introduce proper theming and widget decomposition.

### Tasks

1. **Refactor** — Extract Model, Repository, and widgets (QuoteCard as a reusable component). Use an abstract repository for testability. Add unit tests.

2. **Algorithm** — Find the longest increasing subsequence of quote lengths (character count). For example, if quotes have lengths [45, 30, 60, 55, 80, 20, 90], the LIS is [30, 55, 80, 90] with length 4. The `longestIncreasingSubsequence()` function currently returns 0.

3. **Feature** — Add a random quote button that picks a random quote and shows it in a dialog with share functionality.

### Discussion

- What's the difference between const and final constructors in widgets?
- How would you implement a favorites feature with local persistence?
- When should you use Keys in Flutter?
