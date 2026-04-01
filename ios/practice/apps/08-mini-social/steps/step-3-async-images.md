# Step 3: Async Image Loading

**Difficulty:** ★★★ Advanced

---

## Goal

Each post in the feed displays an image loaded asynchronously with `AsyncImage`, including placeholder and error states.

## When you're done

- [ ] Post images use `AsyncImage` (or a custom async loader) with a valid URL
- [ ] A placeholder (shimmer, gray rectangle, or ProgressView) shows while loading
- [ ] A fallback image or icon shows if the load fails
- [ ] Images are sized consistently regardless of the source image dimensions
- [ ] Scrolling does not re-trigger loads for already-visible images

## Files to edit

- **Create** `Presentation/Views/PostImageView.swift`
- **Edit** `Presentation/Views/PostRow.swift` (or equivalent feed row)

## Hints

<details>
<summary>Hint — AsyncImage phases</summary>
<code>AsyncImage(url:) { phase in switch phase { case .empty: ..., case .success(let image): ..., case .failure: ... } }</code> gives you control over all three states. Use <code>.resizable().aspectRatio(contentMode: .fill)</code> with a fixed frame for consistent sizing.
</details>

---

## LLM Review

Copy your `PostImageView.swift` and `PostRow.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

ASYNC IMAGE
- Uses AsyncImage or a custom async image view with URL input
- The placeholder phase shows a loading indicator or skeleton
- The failure phase shows a fallback (icon, color, or retry prompt)
- The success phase displays the image with proper scaling

SIZING
- Images have a fixed or constrained frame (not unbounded)
- aspectRatio is set (fill or fit) to prevent stretching
- clipped() or clipShape is used if using .fill to prevent overflow

REUSABILITY
- PostImageView is a standalone component (not coupled to Post model internals)
- The view accepts a URL (or optional URL) as input
- Nil URL gracefully shows the fallback

QUALITY
- No synchronous image loading on the main thread
- Images in the feed don't cause layout jumps as they load
- The image view does not re-fetch when scrolled off and back on (framework handles this, but verify no forced re-creation)
```
