# Step 4: Repository Pattern (Architecture)

**Difficulty:** ★★★ Advanced — **KEY INTERVIEW TOPIC**

---

## Goal

Refactor the networking code into a **Repository pattern**: a protocol defining _what_ data operations exist, and a concrete class implementing _how_ they work. The ViewModel depends only on the protocol, never on the concrete implementation.

## Why this is critical for interviews

This is **the #1 architecture question** in iOS interviews:

> *"How do you make your networking code testable?"*

Answer: **Protocol-based dependency injection.** The ViewModel takes a protocol, not a concrete class. In tests, you inject a mock. In production, you inject the real network client.

## When you're done

- [ ] `PostRepository` is a **protocol** with `fetchPosts()` and `searchPosts(query:)`
- [ ] `RemotePostRepository` is the concrete class that hits the real API
- [ ] `FeedViewModel` depends on the protocol (via `init` parameter)
- [ ] `FeedView` creates the concrete repo and passes it to the ViewModel
- [ ] The app works exactly as before

---

## Micro-steps

### 4.1 — Create the PostRepository protocol

Create a new file: `Repositories/PostRepository.swift`

```swift
import Foundation

protocol PostRepository {
    func fetchPosts() async throws -> [Post]
    func searchPosts(query: String) async throws -> [Post]
}
```

That's it — just two method signatures. No implementation. This is the **contract**.

**Why a protocol?**

Think of it as a job description. It says "I need someone who can fetch posts and search posts." It doesn't say _how_ — that's up to whoever conforms. This means you can have:
- `RemotePostRepository` — hits the real API
- `MockPostRepository` — returns fake data (for tests)
- `CachedPostRepository` — checks local cache first

**🔨 Build checkpoint:** Cmd+B — should compile.

---

### 4.2 — Create the concrete RemotePostRepository

Create a new file: `Repositories/RemotePostRepository.swift`

```swift
import Foundation

final class RemotePostRepository: PostRepository {
    private let baseURL = "https://dummyjson.com"

    func fetchPosts() async throws -> [Post] {
        guard let url = URL(string: "\(baseURL)/posts?limit=20&skip=0") else {
            throw URLError(.badURL)
        }
        return try await request(url: url)
    }

    func searchPosts(query: String) async throws -> [Post] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/posts/search?q=\(encoded)") else {
            throw URLError(.badURL)
        }
        return try await request(url: url)
    }

    private func request(url: URL) async throws -> [Post] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(PostResponse.self, from: data)
        return decoded.posts
    }
}
```

**What changed from the old `NetworkService`?**

- It conforms to `PostRepository` (the protocol)
- The shared network logic is extracted into a private `request(url:)` method — DRY principle
- Same exact behavior, just better organized

**🔨 Build checkpoint:** Cmd+B — should compile.

---

### 4.3 — Refactor FeedViewModel to accept the protocol

Open `ViewModels/FeedViewModel.swift`. Replace the class:

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

    private let repository: PostRepository
    private var cancellables = Set<AnyCancellable>()

    init(repository: PostRepository) {
        self.repository = repository
        setupSearchPipeline()
    }

    func loadPosts() async {
        state = .loading
        do {
            let posts = try await repository.fetchPosts()
            state = posts.isEmpty ? .empty : .loaded(posts)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

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

**The critical change:** `private let repository: PostRepository` — the type is the **protocol**, not `RemotePostRepository`. The ViewModel has no idea whether it's talking to a real API, a mock, or a cache.

**🔨 Build checkpoint:** Cmd+B — you'll get an error in `FeedView` because the init now requires a repository parameter. Fix it in the next step.

---

### 4.4 — Update FeedView to inject the repository

Open `Views/FeedView.swift`. Change the `@StateObject` line:

```swift
struct FeedView: View {
    @StateObject private var viewModel: FeedViewModel

    init(repository: PostRepository = RemotePostRepository()) {
        _viewModel = StateObject(wrappedValue: FeedViewModel(repository: repository))
    }

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

**Why `= RemotePostRepository()`?** The default parameter means normal app code can just write `FeedView()` without passing anything. But tests (or SwiftUI previews) can inject a mock.

**🏃 Run checkpoint:** Run the app. It should work exactly as before — same API, same UI. The refactoring was invisible to the user.

---

### 4.5 — Delete the old NetworkService

You can now delete `Services/NetworkService.swift` — all its logic lives in `RemotePostRepository`.

---

## Architecture evaluation

Here's how an interviewer would evaluate your code:

| Criterion | What they're checking | Your code |
|---|---|---|
| **Dependency Inversion** | Does the ViewModel depend on an abstraction (protocol), not a concrete class? | ✅ `PostRepository` protocol |
| **Testability** | Can you swap in a mock without changing the ViewModel? | ✅ `init(repository:)` injection |
| **Single Responsibility** | Is networking separate from UI logic? | ✅ Repository handles network, VM handles state |
| **Open/Closed** | Can you add a cached implementation without modifying existing code? | ✅ Create `CachedPostRepository` conforming to same protocol |

---

## Interview takeaway

When asked *"How do you structure networking in your app?"* say:

> "I use a **Repository pattern** with **protocol-based dependency injection**. The ViewModel depends on a protocol — not a concrete network class. This means I can inject a mock for unit tests, a cached version for offline support, or the real API client for production. The concrete implementation handles URLSession, JSON decoding, and error mapping. The ViewModel only knows about the protocol contract."

Follow up with: *"This follows the **Dependency Inversion Principle** — high-level modules (ViewModel) should not depend on low-level modules (URLSession). Both should depend on abstractions (the protocol)."*

---

## Files created/edited

| File | Action |
|---|---|
| `Repositories/PostRepository.swift` | **Create** — protocol |
| `Repositories/RemotePostRepository.swift` | **Create** — concrete implementation |
| `ViewModels/FeedViewModel.swift` | **Edit** — accept protocol via init |
| `Views/FeedView.swift` | **Edit** — inject default repository |
| `Services/NetworkService.swift` | **Delete** — replaced by repository |

---

## LLM Review

Copy your `PostRepository.swift`, `RemotePostRepository.swift`, `FeedViewModel.swift`, and `FeedView.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

PROTOCOL ABSTRACTION
- PostRepository is a protocol (not a concrete class)
- The protocol declares fetchPosts() async throws -> [Post] and searchPosts(query:) async throws -> [Post]
- FeedViewModel stores the repository as the PROTOCOL type, not the concrete type
- FeedViewModel accepts the repository via init injection (not creating it internally)

CONCRETE IMPLEMENTATION
- RemotePostRepository conforms to PostRepository
- It hits the real DummyJSON API
- Shared networking logic is not duplicated between fetch and search

DEPENDENCY INJECTION
- FeedView creates the concrete repo and passes it to the ViewModel
- A default parameter (= RemotePostRepository()) is used for convenience
- No global singletons or service locators

TESTABILITY
- A MockPostRepository could be written that conforms to PostRepository
- The ViewModel can be tested without any network calls
- The protocol is the only coupling point

QUALITY
- The old NetworkService is deleted (or no longer referenced)
- The app works exactly as before the refactoring
- No force-unwrapping or implicitly unwrapped optionals
```
