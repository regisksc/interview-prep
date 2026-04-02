import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var collectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var photos: [Photo] = []
    private let imageCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photos"
        view.backgroundColor = .systemBackground

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "photo")
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        loadPhotos()
    }

    private func loadPhotos() {
        activityIndicator.startAnimating()
        collectionView.isHidden = true

        Task {
            do {
                let fetched: [Photo] = try await APIClient.shared.fetch(
                    from: "https://jsonplaceholder.typicode.com/photos?albumId=1"
                )
                self.photos = fetched
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
            } catch {
                let alert = UIAlertController(
                    title: "Error", message: error.localizedDescription, preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                    self.loadPhotos()
                })
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
            self.activityIndicator.stopAnimating()
        }
    }

    private func loadImage(from urlString: String, into imageView: UIImageView) {
        if let cached = imageCache.object(forKey: urlString as NSString) {
            imageView.image = cached
            return
        }
        guard let url = URL(string: urlString) else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: urlString as NSString)
                    imageView.image = image
                }
            } catch { }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! PhotoCell
        let photo = photos[indexPath.item]
        cell.titleLabel.text = photo.title
        cell.photoImageView.image = nil
        loadImage(from: photo.thumbnailUrl, into: cell.photoImageView)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 12) / 3
        return CGSize(width: width, height: width + 30)
    }

    // MARK: - Algorithm

    func deduplicateByTitle(_ photos: [Photo]) -> [Photo] {
        return photos
    }
}

class PhotoCell: UICollectionViewCell {
    let photoImageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.backgroundColor = .systemGray6
        contentView.addSubview(photoImageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 10)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .secondaryLabel
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor),
            titleLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
