# Challenge 03: Comments Feed

**API:** `https://jsonplaceholder.typicode.com/comments?postId=1`
**Time:** 45 minutes
**Framework:** UIKit

## Starting point

A working app that loads comments for a post and displays them in a `UITableView` showing the commenter's email and body text. Everything lives in one view controller.

## Files

| File | What it does |
|------|-------------|
| `Comment.swift` | Codable model matching the API |
| `Networking/APIClient.swift` | Generic async fetch helper |
| `ViewController.swift` | All logic in one place (the mess) |

## Tasks

### 1. Refactor to MVVM (20 min)

Extract a `CommentViewModel` and `CommentServiceProtocol`. The ViewController should only manage the table view and forward user actions to the ViewModel.

### 2. Test the ViewModel (10 min)

Create a `MockCommentService`. Test loading, error handling, and that the comment count matches expectations.

### 3. Implement the algorithm (15 min)

`topEmailDomains(_:count:)` — Extract the domain from each comment's email (the part after `@`), count occurrences, and return the top N domains sorted by frequency descending. Currently returns `[]`.

## Discussion topics

- How would you handle dynamic row heights?
- What's the difference between `UITableView.automaticDimension` and a fixed row height?
- How would you add pagination to load comments for multiple posts?
