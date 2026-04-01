# Step 6: Unit Tests + UI Test

**Read first:** [README — Module 8 (Testing Strategy)](../../../../README.md#module-8-testing-strategy)

**Difficulty:** ★★★ Advanced

---

## Goal

Write unit tests for the FeedViewModel (load, pagination, optimistic like/rollback) using the mock repository. Add one UI test that launches the app and scrolls the feed.

## When you're done

- [ ] Unit tests use the mock repository from the DI container
- [ ] Test: initial load populates the feed
- [ ] Test: loadNextPage appends items and increments page
- [ ] Test: like succeeds → state remains toggled
- [ ] Test: like fails → state rolls back
- [ ] A UI test launches the app and verifies the feed list is present and scrollable
- [ ] All tests pass

## Files to create

- `Tests/FeedViewModelTests.swift`
- `UITests/FeedUITests.swift`

---

## LLM Review

Copy your `FeedViewModelTests.swift` and `FeedUITests.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

UNIT TEST SETUP
- Tests inject MockPostRepository into the ViewModel
- Each test starts with a fresh ViewModel (setUp creates a new instance)
- The mock is configurable (return data, throw errors, control page counts)

UNIT TEST COVERAGE
- Test: loadFeed success → posts array is populated, state is loaded
- Test: loadNextPage → posts array grows, page increments
- Test: loadNextPage when hasMorePages is false → no fetch, array unchanged
- Test: like success → post's isLiked is true, likeCount incremented
- Test: like failure → post's isLiked reverts, likeCount reverts

ASYNC TESTING
- Test methods are async (or use expectations)
- Assertions run after await completes
- No sleep() or fixed-time delays

UI TEST
- XCUIApplication launches successfully
- The test verifies a list or collection of posts exists
- The test performs a swipe/scroll gesture
- At least one post cell is verified to exist

QUALITY
- Tests are in the correct targets (unit in Tests, UI in UITests)
- No tests depend on network connectivity
- Assertions use XCTAssert variants — not print()
- Tests do not depend on execution order
```
