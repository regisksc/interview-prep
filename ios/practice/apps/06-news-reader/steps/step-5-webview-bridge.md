# Step 5: Article Detail with WKWebView

**Difficulty:** ★★★ Advanced

---

## Goal

Tapping a post navigates to a detail screen that renders the post body as formatted HTML inside a `WKWebView` wrapped with `UIViewRepresentable`. Show a loading indicator while the content renders.

## Why WKWebView?

In real apps, article content is often HTML (from a CMS). `WKWebView` renders it natively. Wrapping UIKit views in SwiftUI via `UIViewRepresentable` is a **common interview topic** — it shows you can bridge the two frameworks.

## When you're done

- [ ] `WebView` is a `UIViewRepresentable` struct wrapping `WKWebView`
- [ ] `PostDetailView` receives a `Post` and renders its body as styled HTML
- [ ] A `Coordinator` acts as `WKNavigationDelegate` to track loading state
- [ ] A spinner shows while the HTML renders
- [ ] Navigation from the feed list to the detail works via `NavigationLink`

---

## Micro-steps

### 5.1 — Create the WebView wrapper

Create a new file: `Views/WebView.swift`

```swift
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let htmlContent: String
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let styledHTML = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                body {
                    font-family: -apple-system, system-ui;
                    font-size: 17px;
                    line-height: 1.6;
                    padding: 16px;
                    color: #1a1a1a;
                    background: #ffffff;
                }
                @media (prefers-color-scheme: dark) {
                    body { color: #f0f0f0; background: #1a1a1a; }
                }
            </style>
        </head>
        <body>\(htmlContent)</body>
        </html>
        """
        webView.loadHTMLString(styledHTML, baseURL: nil)
    }

    // MARK: - Coordinator (WKNavigationDelegate)

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}
```

**How `UIViewRepresentable` works (interview answer):**

| Method | Purpose |
|---|---|
| `makeUIView(context:)` | Called ONCE — creates the UIKit view |
| `updateUIView(_:context:)` | Called when SwiftUI state changes — update the UIKit view |
| `makeCoordinator()` | Creates a helper object that can act as a delegate |

**The Coordinator pattern:** `WKWebView` needs a delegate to report loading events. SwiftUI views are structs (value types) and can't be delegates. So we create a `Coordinator` class that the web view talks to, and the Coordinator updates SwiftUI state via `@Binding`.

**🔨 Build checkpoint:** Cmd+B — should compile.

---

### 5.2 — Create the PostDetailView

Create a new file: `Views/PostDetailView.swift`

```swift
import SwiftUI

struct PostDetailView: View {
    let post: Post
    @State private var isWebViewLoading = true

    var body: some View {
        ZStack {
            WebView(htmlContent: post.body, isLoading: $isWebViewLoading)

            if isWebViewLoading {
                ProgressView("Rendering...")
            }
        }
        .navigationTitle(post.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
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
        }
    }
}
```

**🔨 Build checkpoint:** Cmd+B — should compile.

---

### 5.3 — Add navigation from the feed to the detail

Open `Views/FeedView.swift`. In the `.loaded` case, wrap `PostRow` in a `NavigationLink`:

Find this code in the `.loaded` case:

```swift
case .loaded(let posts):
    List(posts) { post in
        PostRow(post: post)
    }
```

Replace it with:

```swift
case .loaded(let posts):
    List(posts) { post in
        NavigationLink(destination: PostDetailView(post: post)) {
            PostRow(post: post)
        }
    }
```

That's the only change — add `NavigationLink` wrapping the row.

**🏃 Run checkpoint:** Run the app. Tap any post → you should navigate to a detail screen showing the post body as styled HTML. The back button returns to the feed.

---

### 5.4 — Test dark mode support

1. On the simulator, go to **Settings → Developer → Dark Appearance** (or toggle in Xcode's Preview)
2. Navigate to a post detail
3. The HTML should have a dark background and light text (thanks to the `@media (prefers-color-scheme: dark)` CSS rule)

**🏃 Run checkpoint:** Verify dark mode works in the web view.

---

## Files created/edited

| File | Action |
|---|---|
| `Views/WebView.swift` | **Create** |
| `Views/PostDetailView.swift` | **Create** |
| `Views/FeedView.swift` | **Edit** — add `NavigationLink` |

---

## Interview talking points

- **`UIViewRepresentable`** is the bridge from UIKit → SwiftUI. The reverse is `UIHostingController` (SwiftUI → UIKit).
- **Coordinator** is needed because UIKit delegates require a reference type (class). SwiftUI views are value types (structs). The Coordinator acts as the middleman.
- **`makeUIView` is called once, `updateUIView` is called on every state change.** Don't recreate the web view in `updateUIView` — that would be expensive. Just update its content.
- **`@Binding`** lets the Coordinator communicate back to SwiftUI. When `isLoading` changes in the Coordinator, SwiftUI re-renders the overlay.

---

## LLM Review

Copy your `WebView.swift`, `PostDetailView.swift`, and updated `FeedView.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

UIViewRepresentable
- WebView conforms to UIViewRepresentable
- makeUIView creates and returns a WKWebView
- updateUIView loads the HTML string (not recreating the view)
- A Coordinator class is defined via makeCoordinator()

NAVIGATION DELEGATE
- The Coordinator conforms to WKNavigationDelegate
- didStartProvisionalNavigation sets isLoading to true
- didFinish sets isLoading to false
- didFail also sets isLoading to false
- The delegate is assigned in makeUIView (not updateUIView)

LOADING INDICATOR
- A ProgressView overlays the WebView while loading
- The indicator disappears when loading completes
- Uses @Binding to communicate between Coordinator and SwiftUI

NAVIGATION
- Tapping a post in FeedView navigates to PostDetailView
- PostDetailView receives the Post
- NavigationLink is used within NavigationStack
- Back navigation works correctly

QUALITY
- No retain cycles between Coordinator and the SwiftUI view
- WKWebView is not recreated on every SwiftUI update
- HTML includes viewport meta tag for proper mobile rendering
- Dark mode is supported via CSS media query
```
