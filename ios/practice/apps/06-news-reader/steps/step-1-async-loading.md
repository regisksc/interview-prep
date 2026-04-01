# Step 1: Async Article Loading (Real API)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Load real posts from `https://dummyjson.com/posts?limit=20` using `async/await`. Display them in a `List` with a loading spinner.

## The API

```
GET https://dummyjson.com/posts?limit=20&skip=0

Response (abbreviated):
{
  "posts": [
    {
      "id": 1,
      "title": "His mother had always taught him",
      "body": "His mother had always taught him not to ever think of himself as better...",
      "tags": ["history", "american", "crime"],
      "reactions": { "likes": 192, "dislikes": 25 },
      "userId": 121
    }
  ],
  "total": 251,
  "skip": 0,
  "limit": 20
}
```

## When you're done

- [ ] A `NetworkService` class fetches posts from the real API
- [ ] `Post` and `PostResponse` are `Codable` structs matching the JSON above
- [ ] `FeedView` shows a `ProgressView` while loading
- [ ] Posts appear in a `List` with title, body preview, and tags
- [ ] The `.task` modifier is used (not `onAppear + Task {}`)

---

## Micro-steps

### 1.1 — Verify the model file exists

Open `Models/Article.swift`. It should already contain:

```swift
import Foundation

struct PostResponse: Codable {
    let posts: [Post]
    let total: Int
    let skip: Int
    let limit: Int
}

struct Reactions: Codable, Equatable {
    let likes: Int
    let dislikes: Int
}

struct Post: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let body: String
    let tags: [String]
    let reactions: Reactions
    let userId: Int
}
```

> **Why Codable?** `JSONDecoder` needs `Codable` conformance to turn raw JSON data into Swift structs. Every property name must match the JSON key exactly (or you need `CodingKeys`). Here, they match.

**🔨 Build checkpoint:** Press Cmd+B. It should compile with zero errors.

---

### 1.2 — Create the NetworkService

Create a new file: `Services/NetworkService.swift`

```swift
import Foundation

final class NetworkService {
    private let baseURL = "https://dummyjson.com"

    func fetchPosts() async throws -> [Post] {
        guard let url = URL(string: "\(baseURL)/posts?limit=20&skip=0") else {
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
}
```

**Line-by-line explanation:**

| Line | What it does |
|---|---|
| `async throws` | This function suspends (doesn't block the UI thread) and can fail |
| `URLSession.shared.data(from:)` | Apple's built-in networking — downloads data from a URL |
| `as? HTTPURLResponse` | Casts the generic response to check the status code |
| `JSONDecoder().decode(...)` | Converts raw JSON bytes into your Swift `PostResponse` struct |
| `.posts` | The API wraps posts in `{ "posts": [...] }` — we unwrap here |

**🔨 Build checkpoint:** Cmd+B — should compile.

---

### 1.3 — Create the FeedViewModel

Create a new file: `ViewModels/FeedViewModel.swift`

```swift
import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false

    private let service = NetworkService()

    func loadPosts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            posts = try await service.fetchPosts()
        } catch {
            print("Failed to load posts: \(error)")
        }
    }
}
```

**Key concepts for your interview:**

- **`@MainActor`** — guarantees all property updates happen on the main thread. SwiftUI requires this because UI updates must be on the main thread.
- **`@Published`** — whenever these properties change, SwiftUI re-renders views that observe them.
- **`defer`** — runs when the function exits, whether it succeeds or fails. Guarantees `isLoading` is reset.

**🔨 Build checkpoint:** Cmd+B — should compile.

---

### 1.4 — Build the FeedView

Edit `Views/FeedView.swift` (or `ContentView.swift` — whichever is your main view):

```swift
import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading posts...")
                } else {
                    List(viewModel.posts) { post in
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
            }
            .navigationTitle("News Reader")
            .task {
                await viewModel.loadPosts()
            }
        }
    }
}
```

**Why `.task` instead of `.onAppear { Task { } }`?**

`.task` automatically cancels the async work when the view disappears. With `.onAppear + Task`, you'd need to manage cancellation yourself. **This is a common interview question.**

**🏃 Run checkpoint:** Press Cmd+R. You should see a spinner, then 20 real posts from DummyJSON with titles, body previews, tags, and like counts.

---

### 1.5 — Wire up the App entry point

Make sure your `NewsReaderApp.swift` (or equivalent `@main` struct) shows `FeedView`:

```swift
import SwiftUI

@main
struct NewsReaderApp: App {
    var body: some Scene {
        WindowGroup {
            FeedView()
        }
    }
}
```

**🏃 Final run checkpoint:** The app launches, shows a loading spinner, then displays 20 posts fetched from the internet.

---

## Files created/edited

| File | Action |
|---|---|
| `Models/Article.swift` | Already exists — verify it matches |
| `Services/NetworkService.swift` | **Create** |
| `ViewModels/FeedViewModel.swift` | **Create** |
| `Views/FeedView.swift` | **Edit** |
| `NewsReaderApp.swift` | **Verify** entry point |

---

## Interview talking points

- **`async/await`** replaced completion handlers in Swift 5.5. It makes async code read like synchronous code.
- **`URLSession.shared.data(from:)`** is the modern async API — no delegates needed for simple requests.
- **`.task`** ties the Task lifecycle to the view. When the view is removed from the hierarchy, the task is cancelled automatically.
- **`@MainActor`** on the ViewModel ensures all `@Published` property mutations happen on the main thread, preventing UI update crashes.

---

## LLM Review

Copy your `Article.swift`, `NetworkService.swift`, `FeedViewModel.swift`, and `FeedView.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

ASYNC PATTERN
- The service method is marked async throws
- Data fetching uses URLSession.shared.data(from:) with await
- The view uses .task { } — NOT .onAppear { Task { } }
- The ViewModel is annotated @MainActor

LOADING STATE
- isLoading is set true before fetch and false after (via defer or finally)
- ProgressView shows during loading
- isLoading is cleared in both success and failure paths

MODEL
- Post conforms to Codable and Identifiable
- PostResponse wraps the array (matches API shape)
- No force-unwrapping of URL or decoded data

VIEW STRUCTURE
- Posts display in a List with title, body, and tags
- The list uses Post's id for identity (via Identifiable)
- NavigationStack wraps the content
```
