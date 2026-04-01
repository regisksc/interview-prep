# Step 7: Infinite Scroll Pagination

**Difficulty:** ★★★ Advanced

---

## Goal

The feed loads the first 20 posts on appear. When the user scrolls near the bottom, the next 20 load automatically using DummyJSON's `skip` and `limit` parameters. A spinner shows at the bottom during fetch.

## The API

```
Page 1: GET https://dummyjson.com/posts?limit=20&skip=0   → posts 1-20
Page 2: GET https://dummyjson.com/posts?limit=20&skip=20  → posts 21-40
Page 3: GET https://dummyjson.com/posts?limit=20&skip=40  → posts 41-60
...until skip >= total (251 posts)
```

The response includes `"total": 251` — use this to know when you've loaded everything.

## When you're done

- [ ] First 20 posts load on appear
- [ ] Scrolling near the last item triggers the next page
- [ ] A `ProgressView` shows at the bottom while fetching
- [ ] Duplicate fetches are prevented (guard on `isLoadingMore`)
- [ ] When all 251 posts are loaded, no further requests fire
- [ ] Scroll position is preserved when new items append

---

## Micro-steps

### 7.1 — Update the repository protocol for pagination

Open `Repositories/PostRepository.swift`. Add a paginated fetch method:

```swift
import Foundation

protocol PostRepository {
    func fetchPosts() async throws -> [Post]
    func fetchPosts(limit: Int, skip: Int) async throws -> PostResponse
    func searchPosts(query: String) async throws -> [Post]
}
```

**Note:** The new method returns `PostResponse` (not just `[Post]`) because we need the `total` field to know when pagination is exhausted.

**🔨 Build checkpoint:** Cmd+B — you'll get errors because `RemotePostRepository` doesn't implement the new method yet. Fix in next step.

---

### 7.2 — Implement paginated fetch in RemotePostRepository

Open `Repositories/RemotePostRepository.swift`. Add the new method:

```swift
final class RemotePostRepository: PostRepository {
    private let baseURL = "https://dummyjson.com"

    func fetchPosts() async throws -> [Post] {
        let response = try await fetchPosts(limit: 20, skip: 0)
        return response.posts
    }

    func fetchPosts(limit: Int, skip: Int) async throws -> PostResponse {
        guard let url = URL(string: "\(baseURL)/posts?limit=\(limit)&skip=\(skip)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(PostResponse.self, from: data)
    }

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

        return try JSONDecoder().decode(PostResponse.self, from: data).posts
    }
}
```

**🔨 Build checkpoint:** Cmd+B — should compile.

---

### 7.3 — Add pagination state to FeedViewModel

Open `ViewModels/FeedViewModel.swift`. Replace the class with this version that adds pagination:

```swift
import Foundation
import Combine

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

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var state: ViewState = .loading
    @Published var query = ""
    @Published var isLoadingMore = false

    private let repository: PostRepository
    private var cancellables = Set<AnyCancellable>()

    private let pageSize = 20
    private var currentSkip = 0
    private var totalPosts = 0
    private var allPosts: [Post] = []

    var hasMorePages: Bool {
        currentSkip < totalPosts
    }

    init(repository: PostRepository) {
        self.repository = repository
        setupSearchPipeline()
    }

    // MARK: - Initial load

    func loadPosts() async {
        state = .loading
        currentSkip = 0
        allPosts = []

        do {
            let response = try await repository.fetchPosts(limit: pageSize, skip: 0)
            allPosts = response.posts
            totalPosts = response.total
            currentSkip = pageSize
            state = allPosts.isEmpty ? .empty : .loaded(allPosts)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Load next page

    func loadMoreIfNeeded(currentPost: Post) async {
        guard case .loaded = state,
              !isLoadingMore,
              hasMorePages else { return }

        let thresholdIndex = allPosts.index(allPosts.endIndex, offsetBy: -3, limitedBy: allPosts.startIndex) ?? allPosts.startIndex

        guard let currentIndex = allPosts.firstIndex(where: { $0.id == currentPost.id }),
              currentIndex >= thresholdIndex else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let response = try await repository.fetchPosts(limit: pageSize, skip: currentSkip)
            allPosts.append(contentsOf: response.posts)
            currentSkip += pageSize
            state = .loaded(allPosts)
        } catch {
            print("Failed to load more: \(error)")
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
            let posts = try await repository.searchPosts(query: searchText)
            state = posts.isEmpty ? .empty : .loaded(posts)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

**Key pagination logic:**

| Property | Purpose |
|---|---|
| `currentSkip` | Tracks how many posts we've already loaded (skip parameter for API) |
| `totalPosts` | From the API response — how many posts exist in total (251) |
| `hasMorePages` | `currentSkip < totalPosts` — stops fetching when we've loaded everything |
| `isLoadingMore` | Prevents concurrent page fetches |
| `thresholdIndex` | Triggers loading 3 items before the end (not at the very last item) |

**🔨 Build checkpoint:** Cmd+B — should compile.

---

### 7.4 — Update FeedView for pagination

Open `Views/FeedView.swift`. Replace the `.loaded` case:

```swift
case .loaded(let posts):
    List {
        ForEach(posts) { post in
            NavigationLink(destination: PostDetailView(post: post)) {
                PostRow(post: post)
            }
            .onAppear {
                Task {
                    await viewModel.loadMoreIfNeeded(currentPost: post)
                }
            }
        }

        if viewModel.isLoadingMore {
            HStack {
                Spacer()
                ProgressView("Loading more...")
                Spacer()
            }
            .listRowSeparator(.hidden)
        }
    }
```

**How infinite scroll works:**

1. Each `PostRow` has `.onAppear` — when it scrolls into view, it checks if more posts should load
2. `loadMoreIfNeeded` compares the current post's index to the threshold (3 from the end)
3. If we're near the bottom AND there are more pages AND we're not already loading → fetch the next page
4. New posts are **appended** to the existing array → scroll position is preserved
5. When `hasMorePages` is false, no further requests fire

**🏃 Run checkpoint:** Run the app. Scroll down. When you reach the bottom, you should see a "Loading more..." spinner, then 20 more posts appear. Keep scrolling — eventually all 251 posts load and the spinner stops appearing.

---

### 7.5 — Update the MockPostRepository for tests

If you have tests from Step 6, update `MockPostRepository` to include the new method:

```swift
final class MockPostRepository: PostRepository {
    var postsToReturn: [Post] = []
    var searchResultsToReturn: [Post] = []
    var errorToThrow: Error?
    var paginatedResponse: PostResponse?

    var fetchPostsCalled = false
    var searchQuery: String?

    func fetchPosts() async throws -> [Post] {
        fetchPostsCalled = true
        if let error = errorToThrow { throw error }
        return postsToReturn
    }

    func fetchPosts(limit: Int, skip: Int) async throws -> PostResponse {
        fetchPostsCalled = true
        if let error = errorToThrow { throw error }
        return paginatedResponse ?? PostResponse(
            posts: postsToReturn,
            total: postsToReturn.count,
            skip: skip,
            limit: limit
        )
    }

    func searchPosts(query: String) async throws -> [Post] {
        searchQuery = query
        if let error = errorToThrow { throw error }
        return searchResultsToReturn
    }
}
```

**🔨 Build checkpoint:** Cmd+B and Cmd+U — all tests should pass.

---

## Files edited

| File | Action |
|---|---|
| `Repositories/PostRepository.swift` | **Edit** — add paginated method |
| `Repositories/RemotePostRepository.swift` | **Edit** — implement pagination |
| `ViewModels/FeedViewModel.swift` | **Rewrite** — add pagination state and logic |
| `Views/FeedView.swift` | **Edit** — add `.onAppear` trigger and loading footer |
| `Mocks/MockPostRepository.swift` | **Edit** — add paginated method to mock |

---

## Interview talking points

- **Cursor-based vs. offset-based pagination:** DummyJSON uses offset (`skip`/`limit`). In production, cursor-based is preferred because inserting/deleting items doesn't shift page boundaries.
- **Threshold trigger:** Load the next page when the user is 3 items from the bottom, not at the very last item. This makes the experience feel seamless.
- **Guard against concurrent fetches:** `isLoadingMore` prevents triggering the same page multiple times if the user scrolls rapidly.
- **Append, don't replace:** `allPosts.append(contentsOf:)` preserves scroll position. Replacing the array would jump the user back to the top.

---

## LLM Review

Copy your `PostRepository.swift`, `RemotePostRepository.swift`, `FeedViewModel.swift`, and `FeedView.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

PAGINATION LOGIC
- The repository protocol has a paginated method accepting limit and skip
- The ViewModel tracks currentSkip, totalPosts, and hasMorePages
- loadMoreIfNeeded fires when the user nears the bottom (threshold check)
- New items are appended to the existing array (not replaced)

TRIGGER MECHANISM
- Each PostRow has .onAppear that calls loadMoreIfNeeded
- The trigger fires only when near the threshold (not on every row)
- The trigger checks hasMorePages before fetching

LOADING STATE
- A ProgressView appears at the bottom of the list while fetching more
- The indicator is inside the List (scrolls with content)
- The indicator hides when loading completes or no more pages exist

GUARD RAILS
- Concurrent page fetches are prevented (isLoadingMore guard)
- hasMorePages becomes false when all posts are loaded
- After reaching the end, no more network requests fire

QUALITY
- Scroll position is preserved when new items append
- The first page loads automatically on .task
- totalPosts comes from the API response (not hardcoded)
- The mock is updated to support the paginated method
```
