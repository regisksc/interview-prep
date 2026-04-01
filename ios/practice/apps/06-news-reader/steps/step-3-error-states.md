# Step 3: Loading / Error / Content States

**Difficulty:** ★★☆ Intermediate

---

## Goal

Replace the ad-hoc `isLoading` boolean with a proper state enum. Show distinct UI for loading, loaded content, empty results, and errors. Add a retry button.

## Why this matters for interviews

Interviewers love asking: *"How do you handle loading and error states?"* The answer is **a single enum with associated values** — not a bag of booleans (`isLoading`, `hasError`, `errorMessage`, `isEmpty`...). That approach leads to impossible states like `isLoading = true AND hasError = true`.

## When you're done

- [ ] A `ViewState` enum replaces `isLoading` and `posts` as separate properties
- [ ] The view switches over the state to render loading / content / error / empty
- [ ] Error state shows the error message + a "Retry" button
- [ ] Tapping Retry transitions back to loading and re-fetches
- [ ] No leftover `isLoading` boolean from Step 1

---

## Micro-steps

### 3.1 — Define the ViewState enum

Open `ViewModels/FeedViewModel.swift`. Add this enum at the top of the file (above the class):

```swift
enum ViewState: Equatable {
    case loading
    case loaded([Post])
    case error(String)
    case empty

    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.empty, .empty):
            return true
        case (.loaded(let a), .loaded(let b)):
            return a == b
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}
```

**Why `Equatable`?** SwiftUI uses equality checks to decide when to re-render. If your `@Published` state is `Equatable`, SwiftUI can skip unnecessary redraws.

**Why not generic `ViewState<T>`?** For a beginner exercise, a concrete enum is clearer. In production, you'd make it `ViewState<T>` — mention this to your interviewer.

**🔨 Build checkpoint:** Cmd+B — should compile.

---

### 3.2 — Rewrite FeedViewModel to use ViewState

Replace the entire `FeedViewModel` class with:

```swift
@MainActor
final class FeedViewModel: ObservableObject {
    @Published var state: ViewState = .loading
    @Published var query = ""

    private let service = NetworkService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSearchPipeline()
    }

    // MARK: - Load all posts

    func loadPosts() async {
        state = .loading
        do {
            let posts = try await service.fetchPosts()
            state = posts.isEmpty ? .empty : .loaded(posts)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Search pipeline

    private func setupSearchPipeline() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self else { return }
                Task { @MainActor in
                    await self.performSearch(searchText)
                }
            }
            .store(in: &cancellables)
    }

    private func performSearch(_ searchText: String) async {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            await loadPosts()
            return
        }

        state = .loading
        do {
            let posts = try await service.searchPosts(query: searchText)
            state = posts.isEmpty ? .empty : .loaded(posts)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

**What changed from Step 2:**

- Removed `posts: [Post]` and `isLoading: Bool` — replaced with single `state: ViewState`
- `state = .loaded(posts)` carries the data as an associated value
- `state = .error(error.localizedDescription)` carries the error message
- No more `defer` — the state transitions are explicit

**🔨 Build checkpoint:** Cmd+B — should compile.

---

### 3.3 — Rewrite FeedView to switch on ViewState

Replace the entire `FeedView` struct:

```swift
import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading posts...")

                case .loaded(let posts):
                    List(posts) { post in
                        PostRow(post: post)
                    }

                case .error(let message):
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        Text("Something went wrong")
                            .font(.title3.bold())

                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Retry") {
                            Task {
                                await viewModel.loadPosts()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }

                case .empty:
                    ContentUnavailableView(
                        "No posts found",
                        systemImage: "magnifyingglass",
                        description: Text("Try a different search term")
                    )
                }
            }
            .navigationTitle("News Reader")
            .searchable(text: $viewModel.query, prompt: "Search posts...")
            .task {
                await viewModel.loadPosts()
            }
        }
    }
}
```

**Key changes:**

- The `Group` now uses a `switch` statement over `viewModel.state`
- Each case renders completely different UI
- The error case has a retry button that re-triggers `loadPosts()`

**🏃 Run checkpoint:** Run the app. Should work normally. To test the error state, temporarily change the URL in `NetworkService` to something invalid (e.g., `https://dummyjson.com/BROKEN`), run, and verify you see the error screen with a Retry button.

---

### 3.4 — Test the error → retry flow

1. Change the URL in `NetworkService.fetchPosts()` to `https://dummyjson.com/BROKEN`
2. Run the app → you should see the error screen
3. Tap "Retry" → should show loading, then error again (because URL is still broken)
4. **Restore the correct URL** (`/posts?limit=20&skip=0`)
5. Run again → should work normally

**🏃 Run checkpoint:** Confirm error + retry flow works.

---

## Files edited

| File | Action |
|---|---|
| `ViewModels/FeedViewModel.swift` | **Rewrite** — add `ViewState` enum, refactor VM |
| `Views/FeedView.swift` | **Rewrite** — switch on `ViewState` |

---

## Interview talking points

- **"Impossible state" problem:** With separate booleans (`isLoading`, `hasError`), you can accidentally set both to `true`. An enum makes this impossible — it's loading OR loaded OR error, never a combination.
- **Associated values:** The `.loaded([Post])` case carries data. The `.error(String)` case carries the message. No need for separate storage.
- **`switch` is exhaustive:** The compiler forces you to handle every case. If you add a new case later, every view that switches on it will get a compile error — you can't forget to handle it.

---

## LLM Review

Copy your `FeedViewModel.swift` and `FeedView.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

STATE MODELING
- A single enum represents loading/loaded/error/empty (not multiple booleans)
- The loaded case carries [Post] as an associated value
- The error case carries a String message
- The ViewModel exposes one @Published state property of this enum type
- No leftover isLoading or posts properties from Step 1/2

VIEW RENDERING
- The view uses switch to render each state distinctly
- Loading shows a ProgressView
- Error shows the message and a Retry button
- Loaded shows the post list
- Empty shows a ContentUnavailableView or equivalent

RETRY
- Tapping Retry transitions to .loading and re-fetches
- Retry does not accumulate duplicate Tasks

QUALITY
- ViewState is Equatable (so SwiftUI can diff efficiently)
- The switch is exhaustive (all cases handled)
- Error messages are user-readable (localizedDescription, not raw dump)
```
