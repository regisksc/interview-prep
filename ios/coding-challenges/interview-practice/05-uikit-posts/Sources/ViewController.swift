import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Posts"
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        loadPosts()
    }

    private func loadPosts() {
        activityIndicator.startAnimating()
        tableView.isHidden = true

        Task {
            do {
                let fetched: [Post] = try await APIClient.shared.fetch(
                    from: "https://jsonplaceholder.typicode.com/posts"
                )
                self.posts = fetched
                self.tableView.reloadData()
                self.tableView.isHidden = false
            } catch {
                let alert = UIAlertController(
                    title: "Error", message: error.localizedDescription, preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                    self.loadPosts()
                })
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
            self.activityIndicator.stopAnimating()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let post = posts[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = "\(post.title) [\(post.body.count) chars]"
        config.secondaryText = String(post.body.prefix(100)) + "..."
        config.secondaryTextProperties.numberOfLines = 2
        config.secondaryTextProperties.font = .systemFont(ofSize: 13)
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        let alert = UIAlertController(title: post.title, message: post.body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Algorithm

    func wordFrequency(_ posts: [Post], topN: Int) -> [(word: String, count: Int)] {
        return []
    }
}
