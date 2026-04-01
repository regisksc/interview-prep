import SwiftUI

struct FeedView: View {
    private let posts = Post.samples

    var body: some View {
        NavigationStack {
            List(posts) { post in
                Text(post.caption)
            }
            .navigationTitle("Feed")
        }
    }
}

#Preview {
    FeedView()
}
