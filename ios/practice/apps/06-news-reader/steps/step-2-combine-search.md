# Step 2: Debounced Search with Combine

**Difficulty:** ★★★ Advanced

---

## Goal

Add a search bar that queries `https://dummyjson.com/posts/search?q=<query>` using a Combine pipeline with `debounce` and `removeDuplicates`. Only fires a network request after the user stops typing for 300ms.

## The API

```
GET https://dummyjson.com/posts/search?q=love

Response: same shape as /posts — { "posts": [...], "total": 5, "skip": 0, "limit": 30 }
```

Try it in your browser right now: `https://dummyjson.com/posts/search?q=love` — you'll see results.

## When you're done

- [ ] A search bar captures the user's query
- [ ] The query feeds into a Combine pipeline with debounce (300ms) + removeDuplicates
- [ ] Typing rapidly fires only ONE request (not one per keystroke)
- [ ] Typing the same query twice does NOT re-fetch
- [ ] Empty query reloads the full feed
- [ ] Subscriptions are stored in `Set<AnyCancellable>` and released on deinit

---

## Micro-steps

### 2.1 — Add the search method to NetworkService

Open `Services/NetworkService.swift` and add this method below `fetchPosts()`:

```swift
func searchPosts(query: String) async throws -> [Post] {
    guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "\(baseURL)/posts/search?q=\(encoded)") else {
        throw URLError(.badURL)
    }

    let (data, response) = try await URLSession.shared.data(from: url)

    guard let http = response as? HTTPURLResponse,
          (200...299).contains(http.statusCode) else {
        throw URLError(.badServerResponse)
    }

    let decoded = try JSONDecoder().decode(PostResponse.self, from: data)
    return decoded.posts
}
```

**Why `addingPercentEncoding`?** If the user types "hello world", the space must become `%20` in the URL. Without encoding, the URL would be invalid.

**🔨 Build checkpoint:** Cmd+B — should compile.

---

### 2.2 — Add Combine imports and properties to FeedViewModel

Open `ViewModels/FeedViewModel.swift`. Replace the entire file with:

```swift
import Foundation
import Combine

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var query = ""

    private let service = NetworkService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSearchPipeline()
    }

    // MARK: - Initial load (no search query)

    func loadPosts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            posts = try await service.fetchPosts()
        } catch {
            print("Failed to load posts: \(error)")
        }
    }

    // MARK: - Combine search pipeline

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

        isLoading = true
        defer { isLoading = false }

        do {
            posts = try await service.searchPosts(query: searchText)
        } catch {
            print("Search failed: \(error)")
        }
    }
}
```

**Line-by-line explanation of the pipeline:**

| Line | What it does |
|---|---|
| `$query` | Publishes a new value every time `query` changes (each keystroke) |
| `.debounce(for: .milliseconds(300), ...)` | Waits 300ms of silence before emitting — so rapid typing produces only one event |
| `.removeDuplicates()` | If the user types "abc", deletes "c", then retypes "c" → "abc" is the same, so it's skipped |
| `.sink { }` | Subscribes — runs the closure with each emitted value |
| `[weak self]` | Prevents a retain cycle between the closure and the ViewModel |
| `.store(in: &cancellables)` | Keeps the subscription alive as long as the ViewModel exists |

**🔨 Build checkpoint:** Cmd+B — should compile.

---

### 2.3 — Add the search bar to FeedView

Open `Views/FeedView.swift`. Replace the entire file with:

```swift
import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if viewModel.posts.isEmpty {
                    ContentUnavailableView(
                        "No posts found",
                        systemImage: "magnifyingglass",
                        description: Text("Try a different search term")
                    )
                } else {
                    List(viewModel.posts) { post in
                        PostRow(post: post)
                    }
                }
            }
            .navigationTitle("News Reader")
            .searchable(text: $viewModel.query, prompt: "Search posts...")
            .task {
                if viewModel.posts.isEmpty {
                    await viewModel.loadPosts()
                }
            }
        }
    }
}

// MARK: - Post Row

struct PostRow: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.headline)

            Text(post.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                ForEach(post.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.1))
                        .clipShape(Capsule())
                }

                Spacer()

                Label("\(post.reactions.likes)", systemImage: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
    }
}
```

**Key things to notice:**

- **`.searchable(text: $viewModel.query)`** — binds the search bar directly to the `@Published var query`. Every keystroke updates `query`, which triggers the Combine pipeline.
- **`ContentUnavailableView`** — iOS 17+ built-in view for empty states. Great for interviews.
- **`PostRow`** is extracted as a separate view — clean architecture.

**🏃 Run checkpoint:** Run the app. Type "love" in the search bar. Wait 300ms. You should see filtered results from the real API. Clear the search → full feed returns.

---

### 2.4 — Test the debounce behavior

1. Type "l" — wait — see results for "l"
2. Type "lo" quickly then "ve" quickly → should only fire ONE request for "love" (not 4)
3. Delete all text → full feed reloads

**🏃 Run checkpoint:** Confirm the above behavior in the running app.

---

## Files edited

| File | Action |
|---|---|
| `Services/NetworkService.swift` | **Edit** — add `searchPosts(query:)` |
| `ViewModels/FeedViewModel.swift` | **Rewrite** — add Combine pipeline |
| `Views/FeedView.swift` | **Rewrite** — add `.searchable` and `PostRow` |

---

## Interview talking points

- **Combine** is Apple's reactive framework. `$query` turns a `@Published` property into a `Publisher`.
- **`debounce`** prevents flooding the API with requests on every keystroke — a classic mobile interview question.
- **`removeDuplicates`** avoids redundant network calls when the effective query hasn't changed.
- **`[weak self]`** in `sink` prevents retain cycles. The ViewModel owns `cancellables`, which owns the subscription, which captures `self` — that's a cycle without `weak`.
- **`.searchable`** is the SwiftUI-native search bar — it integrates with `NavigationStack` automatically.

---

## LLM Review

Copy your updated `NetworkService.swift`, `FeedViewModel.swift`, and `FeedView.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

COMBINE PIPELINE
- $query is a @Published property on the ViewModel
- The pipeline includes .debounce (≥ 300ms)
- The pipeline includes .removeDuplicates
- The pipeline calls an async search function (via Task inside sink)
- Empty query reloads the full feed

CANCELLATION
- Subscriptions are stored in Set<AnyCancellable>
- The pipeline is set up once (in init), not on every view update

NETWORK
- searchPosts uses the real API: dummyjson.com/posts/search?q=
- The query string is percent-encoded for URL safety
- The response is decoded as PostResponse (same shape as /posts)

BEHAVIOR
- Typing rapidly fires only one request (debounce works)
- Identical consecutive queries don't re-fetch (removeDuplicates works)
- Empty search shows full feed

QUALITY
- No [unowned self] — uses [weak self] in sink closures
- PostRow is extracted as a separate view
- ContentUnavailableView (or equivalent) shows for empty results
```
