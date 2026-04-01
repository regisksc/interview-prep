# Step 5: Optimistic Like/Unlike

**Difficulty:** ★★★ Advanced

---

## Goal

When the user taps "Like" on a post, the UI updates immediately (optimistic update). If the server request fails, the UI rolls back to the previous state.

## When you're done

- [ ] Tapping the like button instantly toggles the heart icon and increments/decrements the count
- [ ] A network request fires in the background to persist the like
- [ ] On success, nothing changes (the optimistic state is correct)
- [ ] On failure, the like state and count revert to the pre-tap values
- [ ] The rollback is visible (the heart un-fills and count reverts)
- [ ] Rapid double-tapping does not produce inconsistent state

## Files to edit

- **Edit** `Presentation/ViewModels/FeedViewModel.swift` (or a PostViewModel)
- **Edit** `Presentation/Views/PostRow.swift`
- **Edit** `Domain/Repositories/PostRepository.swift` (add like/unlike method)

---

## LLM Review

Copy your ViewModel with the like logic, `PostRow.swift`, and the repository protocol plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

OPTIMISTIC UPDATE
- The UI state (isLiked, likeCount) is updated BEFORE the network call
- The previous state is captured before mutation for potential rollback
- The network call runs asynchronously after the UI update

ROLLBACK
- On network failure, the UI reverts to the captured previous state
- The revert is applied on the main thread (@MainActor)
- The user sees the rollback (heart un-fills, count changes back)

CONSISTENCY
- Rapid taps are handled (debounce, disable during request, or sequential queue)
- The final state always matches the last successful server state
- No race conditions between multiple like/unlike requests for the same post

VISUAL FEEDBACK
- The like button shows filled/unfilled heart (or equivalent)
- The like count updates alongside the icon
- An animation accompanies the toggle (optional but expected)

QUALITY
- The optimistic update pattern is encapsulated (not scattered across view and VM)
- Error state does not surface an alert for every failed like (silent rollback is acceptable)
- The like/unlike method on the repository protocol is async throws
```
