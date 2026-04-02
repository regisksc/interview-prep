# Challenge 02: Photo Gallery

**API:** `https://jsonplaceholder.typicode.com/photos?albumId=1`
**Time:** 45 minutes
**Framework:** UIKit

## Starting point

A working app that loads 50 photos and displays thumbnails in a `UICollectionView`. All logic — networking, image caching, cell configuration, layout — lives in one view controller. A custom `PhotoCell` is defined inline.

## Files

| File | What it does |
|------|-------------|
| `Photo.swift` | Codable model matching the API |
| `Networking/APIClient.swift` | Generic async fetch helper |
| `ViewController.swift` | Everything including the cell class (the mess) |

## Tasks

### 1. Refactor to MVVM (20 min)

Extract a `PhotoViewModel` and `PhotoServiceProtocol`. Move image caching into a dedicated `ImageLoader` or keep it in the cell. Extract `PhotoCell` into its own file.

### 2. Test the ViewModel (10 min)

Create a `MockPhotoService`. Test that loading populates the photos array and that error state is set correctly.

### 3. Implement the algorithm (15 min)

`deduplicateByTitle(_:)` — Remove photos with duplicate titles, keeping only the first occurrence of each title. Currently returns the input unchanged.

## Discussion topics

- How would you handle image loading cancellation when cells are reused?
- `NSCache` vs custom caching — trade-offs?
- How would you add pull-to-refresh to a collection view?
