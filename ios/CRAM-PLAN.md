# 10-Hour iOS/Swift Interview Cram Plan

You have 10 hours. This plan covers what interviewers **actually ask** — state management, networking, MVVM, lists, and basic Combine. Everything else is noise right now.

---

## What to skip entirely

| Topic | Why |
|-------|-----|
| Charts / Swift Charts | Rarely asked in interviews |
| SwiftData / Core Data | Complex, low ROI for 10 hours |
| Custom Layout protocol | iOS 16+ niche topic |
| UIKit deep dives | They want SwiftUI fluency |
| Animations / gestures | Nice-to-have, not make-or-break |
| PreferenceKey / GeometryReader | Advanced — mention you know they exist |
| Unit testing setup | Explain the concept verbally; don't build it today |

---

## The schedule

```
Hours 1–3   Mood Tracker (state management — the #1 interview topic)
            ⬇ cheat sheet: property wrappers
Hours 4–5   Contacts (lists + navigation — bread and butter)
            ⬇ cheat sheet: MVVM diagram
Hours 6–8   News Reader (networking + architecture — the technical round)
            ⬇ cheat sheet: URLSession + Combine patterns
Hours 9–10  Review interview questions + verbal practice
```

---

## Hours 1–3: State Management → App 01 (Mood Tracker)

**Why this matters:** Every iOS interview asks about property wrappers. If you can explain @State vs @StateObject vs @ObservedObject with a concrete example you just built, you're ahead of most candidates.

### Hour 1 — @State + @Binding (Steps 1–2)

| Time | Step | What you build |
|------|------|---------------|
| 0:00–0:30 | [Step 1 — Local State](practice/apps/01-mood-tracker/steps/step-1-local-state.md) | Mood buttons that highlight on tap using `@State` |
| 0:30–1:00 | [Step 2 — Extract Binding](practice/apps/01-mood-tracker/steps/step-2-extract-binding.md) | Extract mood picker to a child view using `@Binding` |

**What to internalize:**
- `@State` = local, value-type, owned by this view
- `@Binding` = two-way reference to someone else's `@State`
- The `$` prefix creates a binding from state

### Hour 2 — ViewModel + Persistence (Steps 3–4)

| Time | Step | What you build |
|------|------|---------------|
| 1:00–1:40 | [Step 3 — ViewModel](practice/apps/01-mood-tracker/steps/step-3-viewmodel.md) | `MoodViewModel` with `@StateObject` / `@ObservedObject`; history tab shows logged moods |
| 1:40–2:00 | [Step 4 — Persistence](practice/apps/01-mood-tracker/steps/step-4-persistence.md) | Settings tab persists name + default mood with `@AppStorage` |

**What to internalize:**
- `@StateObject` = you CREATE and OWN the object (use in the parent)
- `@ObservedObject` = you BORROW a reference (use in children)
- `@AppStorage` = UserDefaults with automatic view updates

### Hour 3 — Environment + Derived State (Steps 5–6)

| Time | Step | What you build |
|------|------|---------------|
| 2:00–2:40 | [Step 5 — Environment](practice/apps/01-mood-tracker/steps/step-5-environment.md) | `UserSession` injected app-wide with `.environmentObject()` |
| 2:40–3:00 | [Step 6 — Derived State](practice/apps/01-mood-tracker/steps/step-6-derived-state.md) | Computed stats: streak, most frequent mood, weekly count |

**What to internalize:**
- `@EnvironmentObject` = dependency injection across the whole view tree
- Computed properties keep views fast — never do heavy work in `body`

> **Skip** Step 7 (scene storage / dark mode). It's nice polish but not interview-critical.

---

### Cheat Sheet: Property Wrappers

Memorize this table — you **will** be asked about it.

| Wrapper | One-liner | Owns data? | Type |
|---------|-----------|-----------|------|
| `@State` | Local view state for value types | Yes | Value |
| `@Binding` | Two-way reference to parent's @State | No | Value |
| `@StateObject` | Creates + owns an ObservableObject | Yes | Reference |
| `@ObservedObject` | Borrows an ObservableObject from parent | No | Reference |
| `@EnvironmentObject` | Shared ObservableObject injected into tree | No | Reference |
| `@Environment` | System values (colorScheme, dismiss, etc.) | No | Any |
| `@AppStorage` | UserDefaults with automatic view updates | Yes | Value |
| `@Published` | Triggers objectWillChange on the enclosing ObservableObject | — | Value |

**The golden rule:** Use `@StateObject` where you *create* the object. Use `@ObservedObject` where you *receive* it.

---

## Hours 4–5: Lists + Navigation → App 04 (Contacts)

**Why this matters:** Almost every iOS app is a list that navigates to a detail view. Interviewers expect you to build this fluently.

### Hour 4 — List fundamentals (Steps 1–3)

| Time | Step | What you build |
|------|------|---------------|
| 3:00–3:20 | [Step 1 — List Basics](practice/apps/04-contacts/steps/step-1-list-basics.md) | Replace VStack with `List` + `ForEach` |
| 3:20–3:45 | [Step 2 — Custom Rows](practice/apps/04-contacts/steps/step-2-custom-rows.md) | Initials circle, name, subtitle in each row |
| 3:45–4:00 | [Step 3 — Swipe Delete](practice/apps/04-contacts/steps/step-3-swipe-delete.md) | `.onDelete` + `EditButton` |

**What to internalize:**
- `List` + `ForEach` with `Identifiable` models
- Custom row views as extracted subviews
- `.onDelete(perform:)` + `EditButton()`

### Hour 5 — Navigation + Search (Steps 4, 6)

| Time | Step | What you build |
|------|------|---------------|
| 4:00–4:30 | [Step 4 — Navigation](practice/apps/04-contacts/steps/step-4-navigation.md) | `NavigationStack` + `NavigationLink` → detail view |
| 4:30–5:00 | [Step 6 — Searchable](practice/apps/04-contacts/steps/step-6-searchable.md) | `.searchable` modifier filters contacts in real time |

**What to internalize:**
- `NavigationStack` (iOS 16+) replaces the old `NavigationView`
- `.navigationDestination(for:)` for type-safe programmatic navigation
- `.searchable(text:)` for built-in search bar

> **Skip** Step 5 (sections) and Step 7 (sheets/alerts) if short on time. Do Step 6 (searchable) — it shows up in interviews constantly.

---

### Cheat Sheet: MVVM Architecture

```
┌──────────┐      ┌─────────────┐      ┌──────────────┐
│   View   │─────▶│  ViewModel  │─────▶│  Repository  │
│ (SwiftUI)│◀─────│(@Published) │◀─────│ (URLSession) │
└──────────┘      └─────────────┘      └──────────────┘
     UI              Business             Data Access
   @StateObject      @MainActor           async throws
   .task { }         @Published           Codable models
```

**In the interview, say:**
- "The View observes the ViewModel via @StateObject. The ViewModel exposes @Published properties that the View binds to. The ViewModel calls a Repository for data access — this separation makes everything testable."

---

## Hours 6–8: Networking + Architecture → App 06 (News Reader)

**Why this matters:** The technical round will likely involve fetching JSON from an API, handling errors, and maybe a debounced search. This block covers all three.

### API endpoint you'll use

```
GET https://dummyjson.com/posts
GET https://dummyjson.com/posts/search?q=love
```

Response shape:
```json
{
  "posts": [
    {
      "id": 1,
      "title": "His mother had always taught him",
      "body": "His mother had always taught him not to ...",
      "tags": ["history", "american", "crime"],
      "reactions": { "likes": 192, "dislikes": 25 },
      "userId": 9
    }
  ],
  "total": 194,
  "skip": 0,
  "limit": 30
}
```

Backup endpoint: `https://jsonplaceholder.typicode.com/posts` (simpler shape, no search).

### Hour 6 — Async loading (Step 1)

| Time | Step | What you build |
|------|------|---------------|
| 5:00–6:00 | [Step 1 — Async Loading](practice/apps/06-news-reader/steps/step-1-async-loading.md) | `ArticleRepository` with `URLSession` + `async/await`; feed loads on appear |

**What to internalize — the URLSession async pattern:**

```swift
@MainActor
class FeedViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false

    func loadArticles() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let url = URL(string: "https://dummyjson.com/posts")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PostResponse.self, from: data)
            articles = response.posts
        } catch {
            print(error)
        }
    }
}

// In the view:
.task {
    await viewModel.loadArticles()
}
```

### Hour 7 — Combine debounced search (Step 2)

| Time | Step | What you build |
|------|------|---------------|
| 6:00–7:00 | [Step 2 — Combine Search](practice/apps/06-news-reader/steps/step-2-combine-search.md) | Search bar wired to Combine pipeline: debounce → removeDuplicates → network call |

**What to internalize — the debounce search pattern:**

```swift
class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [Article] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { $0.count >= 2 }
            .flatMap { query in
                self.search(query)
                    .replaceError(with: [])
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$results)
    }
}
```

**If they ask "why Combine here instead of async/await?"** — Combine's `debounce` and `removeDuplicates` operators handle the reactive stream of keystrokes naturally. async/await is great for one-shot requests but doesn't have built-in debounce.

### Hour 8 — Error state enum (Step 3)

| Time | Step | What you build |
|------|------|---------------|
| 7:00–8:00 | [Step 3 — Error States](practice/apps/06-news-reader/steps/step-3-error-states.md) | `LoadingState<T>` enum replaces booleans; retry button on errors |

**What to internalize — the state enum pattern:**

```swift
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
}

// In ViewModel
@Published var state: LoadingState<[Article]> = .idle

// In View body
switch viewModel.state {
case .idle:        EmptyView()
case .loading:     ProgressView()
case .loaded(let articles): ArticleList(articles: articles)
case .error(let error):     ErrorView(error: error, retry: { ... })
}
```

**Why interviewers love this:** It shows you think about state modeling, not just happy-path coding.

> **Skip** Steps 4–7 (WebView bridge, performance, testing, custom environment). They're advanced topics that won't come up in a beginner interview. Mention them verbally if asked about architecture.

---

### Cheat Sheet: URLSession Async Pattern

```swift
// 1. Model
struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
}

struct PostResponse: Codable {
    let posts: [Post]
}

// 2. Repository
struct PostRepository {
    func fetchPosts() async throws -> [Post] {
        let url = URL(string: "https://dummyjson.com/posts")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(PostResponse.self, from: data).posts
    }

    func search(query: String) async throws -> [Post] {
        let url = URL(string: "https://dummyjson.com/posts/search?q=\(query)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(PostResponse.self, from: data).posts
    }
}

// 3. ViewModel
@MainActor
class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let repository = PostRepository()

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            posts = try await repository.fetchPosts()
        } catch {
            self.error = error
        }
    }
}

// 4. View
struct FeedView: View {
    @StateObject private var viewModel = PostViewModel()

    var body: some View {
        List(viewModel.posts) { post in
            Text(post.title)
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .task {
            await viewModel.load()
        }
    }
}
```

---

### Cheat Sheet: Combine Debounce Search

```swift
import Combine

class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [Post] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] query in
                Task { await self?.search(query) }
            }
            .store(in: &cancellables)
    }

    @MainActor
    func search(_ query: String) async {
        do {
            let url = URL(string: "https://dummyjson.com/posts/search?q=\(query)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            results = try JSONDecoder().decode(PostResponse.self, from: data).posts
        } catch {
            results = []
        }
    }
}
```

---

## Hours 9–10: Interview Question Review

### Hour 9 — Rapid-fire review

Open [swiftui-interview-questions.md](lessons/swiftui-interview-questions.md) and go through **Q1–Q15** (beginner + intermediate). For each:

1. Read the question.
2. **Answer out loud** before reading the answer.
3. If you can't answer in 30 seconds, mark it and move on.
4. Circle back to marked questions after one pass.

Priority questions (these come up the most):

| # | Question | Your 1-sentence answer |
|---|----------|----------------------|
| Q3 | Explain @State | Local value-type storage owned by the view; changes trigger re-render |
| Q4 | What is @Binding? | Two-way reference to a parent's @State so child can read and write it |
| Q5 | @StateObject vs @ObservedObject? | StateObject owns the lifecycle (create here); ObservedObject borrows it (received from parent) |
| Q6 | @EnvironmentObject? | Dependency injection — share an ObservableObject across the entire view tree without passing through every level |
| Q11 | .task vs .onAppear? | .task supports async/await and auto-cancels on disappear; .onAppear is synchronous and needs manual Task management |
| Q12 | How do you make API calls? | URLSession.shared.data(from:) with async/await in a @MainActor ViewModel, triggered by .task in the view |
| Q16 | Navigation in SwiftUI? | NavigationStack with NavigationLink and .navigationDestination(for:) for type-safe routing |
| Q27 | Combine + SwiftUI? | @Published properties feed Combine pipelines; debounce + removeDuplicates for search; assign(to:) to update @Published |
| Q31 | Debounce search? | $query → .debounce(300ms) → .removeDuplicates → .flatMap to search publisher → assign to results |

### Hour 10 — Scenario + architecture questions

Go through **Q30–Q33** in the interview questions file. Practice answering these out loud:

1. **"How would you architect a large SwiftUI app?"**
   → MVVM + Repository pattern. Views observe ViewModels via @StateObject. ViewModels call Repositories for data. Dependency injection via protocols makes it testable.

2. **"Implement a search with debounce"**
   → You literally just built this. Walk through the Combine pipeline step by step.

3. **"How do you handle errors in SwiftUI?"**
   → LoadingState enum with idle/loading/loaded/error cases. The view switches over it. Error state shows message + retry button.

4. **"Pull-to-refresh?"**
   → `.refreshable { await viewModel.refresh() }` — one line.

5. **"@MainActor — what is it and why?"**
   → Guarantees code runs on the main thread. Mark your ViewModel with it so @Published updates are always main-thread safe. Compile-time safety instead of runtime crashes.

---

## Last-minute verbal prep

If the interviewer asks something you haven't built, use this framework:

> "I haven't implemented that specific feature, but my approach would be: [1] define the data model, [2] create a ViewModel with @Published properties for the state, [3] build the view that observes the ViewModel via @StateObject, and [4] handle loading/error/success states with an enum."

This shows you have a **systematic approach** even when you don't have the exact answer.

---

## Quick self-test (5 minutes before the interview)

Can you answer these without looking?

- [ ] What's the difference between @State and @StateObject?
- [ ] When would you use @EnvironmentObject?
- [ ] Write the URLSession async/await fetch pattern from memory
- [ ] What does `.task` do that `.onAppear` doesn't?
- [ ] What's the Combine pipeline for debounced search?
- [ ] What's MVVM and why use it?
- [ ] How do you model loading/error/success states?

If you can hit 5/7, you're ready. Good luck.
