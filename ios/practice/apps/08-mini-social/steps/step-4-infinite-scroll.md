# Step 4: Infinite Scroll Pagination

**Difficulty:** ★★★ Advanced

---

## Goal

The feed loads the first page on appear. When the user scrolls near the bottom, the next page loads automatically. A loading indicator appears at the bottom during fetch.

## When you're done

- [ ] The first page loads on view appear
- [ ] Scrolling to the last few items triggers the next page fetch
- [ ] A `ProgressView` at the bottom of the list indicates loading
- [ ] Duplicate pages are not fetched (guard against re-triggering)
- [ ] When all pages are exhausted, no further requests fire
- [ ] The list maintains scroll position when new items append

## Files to edit

- **Edit** `Presentation/ViewModels/FeedViewModel.swift`
- **Edit** `Presentation/Views/FeedView.swift`
- **Edit** `Domain/Repositories/PostRepository.swift` (add pagination parameters)

---

## LLM Review

Copy your `FeedViewModel.swift`, `FeedView.swift`, and `PostRepository.swift` protocol plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

PAGINATION LOGIC
- The repository protocol accepts a page number or cursor parameter
- The ViewModel tracks the current page and a hasMorePages flag
- loadNextPage is called when the user nears the bottom of the list
- New items are appended to the existing array (not replaced)

TRIGGER MECHANISM
- The view detects when the last (or near-last) item appears on screen
- Detection uses .onAppear on the last item, or a threshold check in onAppear
- The trigger fires only once per page (not repeatedly)

LOADING STATE
- A ProgressView or spinner appears at the bottom while fetching
- The loading indicator is part of the list (scrolls with content)
- The indicator hides when loading completes or no more pages exist

GUARD RAILS
- Concurrent page fetches are prevented (isLoading guard)
- hasMorePages is set to false when the API returns fewer items than page size
- After reaching the end, no more network requests are made

QUALITY
- Scroll position is preserved when new items append
- No duplicate items in the list (if IDs overlap across pages)
- The first page loads automatically without user interaction
```
