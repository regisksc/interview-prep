import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var comments: [Comment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comments"
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
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

        loadComments()
    }

    private func loadComments() {
        activityIndicator.startAnimating()
        tableView.isHidden = true

        Task {
            do {
                let fetched: [Comment] = try await APIClient.shared.fetch(
                    from: "https://jsonplaceholder.typicode.com/comments?postId=1"
                )
                self.comments = fetched
                self.tableView.reloadData()
                self.tableView.isHidden = false
            } catch {
                let alert = UIAlertController(
                    title: "Error", message: error.localizedDescription, preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                    self.loadComments()
                })
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
            self.activityIndicator.stopAnimating()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let comment = comments[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = comment.email
        config.textProperties.font = .systemFont(ofSize: 14, weight: .semibold)
        config.secondaryText = comment.body
        config.secondaryTextProperties.numberOfLines = 3
        config.secondaryTextProperties.font = .systemFont(ofSize: 13)
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let comment = comments[indexPath.row]
        let alert = UIAlertController(title: comment.name, message: comment.body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Algorithm

    func topEmailDomains(_ comments: [Comment], count: Int) -> [(domain: String, count: Int)] {
        return []
    }
}
