import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var albums: [Album] = []
    private var sections: [(userId: Int, albums: [Album])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Albums"
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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

        loadAlbums()
    }

    private func loadAlbums() {
        activityIndicator.startAnimating()
        tableView.isHidden = true

        Task {
            do {
                let fetched: [Album] = try await APIClient.shared.fetch(
                    from: "https://jsonplaceholder.typicode.com/albums"
                )
                self.albums = fetched
                let grouped = Dictionary(grouping: fetched) { $0.userId }
                self.sections = grouped.keys.sorted().map { userId in
                    (userId: userId, albums: grouped[userId]!)
                }
                self.tableView.reloadData()
                self.tableView.isHidden = false
            } catch {
                let alert = UIAlertController(
                    title: "Error", message: error.localizedDescription, preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                    self.loadAlbums()
                })
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
            self.activityIndicator.stopAnimating()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "User \(sections[section].userId)"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let album = sections[indexPath.section].albums[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = album.title
        config.secondaryText = "Album #\(album.id)"
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Algorithm

    func mergeOverlappingRanges(_ albums: [Album]) -> [(userId: Int, range: ClosedRange<Int>)] {
        return []
    }
}
