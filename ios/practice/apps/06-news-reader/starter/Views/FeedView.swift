import SwiftUI

struct FeedView: View {
    private let articles = Article.samples

    var body: some View {
        NavigationStack {
            List(articles) { article in
                Text(article.title)
            }
            .navigationTitle("Feed")
        }
    }
}

#Preview {
    FeedView()
}
