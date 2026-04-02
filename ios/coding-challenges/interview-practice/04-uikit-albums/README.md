# Challenge 04: Album Browser

**API:** `https://jsonplaceholder.typicode.com/albums`
**Time:** 45 minutes
**Framework:** UIKit

## Starting point

A working app that loads 100 albums and displays them in a grouped `UITableView` with sections by user ID. Grouping logic, networking, and UI are all crammed into one view controller.

## Files

| File | What it does |
|------|-------------|
| `Album.swift` | Codable model matching the API |
| `Networking/APIClient.swift` | Generic async fetch helper |
| `ViewController.swift` | Networking + inline grouping + UI (the mess) |

## Tasks

### 1. Refactor to MVVM (20 min)

Extract an `AlbumViewModel` that owns the albums and section grouping. Create an `AlbumServiceProtocol` for networking. The ViewController handles only `UITableViewDataSource` / `UITableViewDelegate`.

### 2. Test the ViewModel (10 min)

Create a `MockAlbumService`. Test that albums are correctly grouped into sections. Test that section count matches the number of unique user IDs.

### 3. Implement the algorithm (15 min)

`mergeOverlappingRanges(_:)` — For each user, collect their album IDs into sorted ranges. If any ranges overlap or are contiguous, merge them. Return one `(userId: Int, range: ClosedRange<Int>)` per user. Currently returns `[]`.

## Discussion topics

- How do you implement sections in `UITableView`?
- `Dictionary(grouping:by:)` — how does it work?
- How would you collapse/expand sections?
