# Challenge 05: Post Reader

**API:** `https://jsonplaceholder.typicode.com/posts`
**Time:** 45 minutes
**Framework:** UIKit

## Starting point

A working app that loads 100 posts and displays them in a `UITableView`. Each row shows the title with a character count and a truncated preview of the body. All logic is in one view controller.

## Files

| File | What it does |
|------|-------------|
| `Post.swift` | Codable model matching the API |
| `Networking/APIClient.swift` | Generic async fetch helper |
| `ViewController.swift` | Networking + formatting + UI (the mess) |

## Tasks

### 1. Refactor to MVVM (20 min)

Extract a `PostViewModel` and `PostServiceProtocol`. Move formatting logic (character count, body truncation) out of `cellForRowAt`. The ViewController should only bind data to cells.

### 2. Test the ViewModel (10 min)

Create a `MockPostService`. Test loading, error state, and that the post count is correct.

### 3. Implement the algorithm (15 min)

`wordFrequency(_:topN:)` — Count word frequency across all post bodies. Normalize to lowercase, ignore words shorter than 4 characters. Return the top N words sorted by count descending. Currently returns `[]`.

## Discussion topics

- How would you add a detail screen with the full post body?
- Formatting logic in the cell vs ViewModel — where does it belong?
- How would you add offline caching with `FileManager`?
