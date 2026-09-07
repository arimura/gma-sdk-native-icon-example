import GoogleMobileAds
import UIKit

/// Google のサンプル用ネイティブ広告ユニット ID
/// https://developers.google.com/admob/ios/test-ads
private let nativeAdUnitID = "ca-app-pub-3940256099942544/3986624511"

/// ダミー記事の間にネイティブ広告を挟んで表示する feed 風の画面
final class NativeAdViewController: UIViewController {
    private enum Row {
        case article(FeedItem)
        case ad
    }

    /// 広告を挿入する位置
    private let adRowIndex = 2

    private let articles: [FeedItem] = (1...10).map { index in
        FeedItem(
            title: "Article \(index): Lorem ipsum dolor sit amet",
            subtitle: "Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore."
        )
    }

    private var adLoader: AdLoader?
    private var nativeAd: NativeAd?
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var rows: [Row] {
        var rows = articles.map(Row.article)
        if nativeAd != nil {
            rows.insert(.ad, at: min(adRowIndex, rows.count))
        }
        return rows
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GMA Native Ad Example"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Reload Ad",
            style: .plain,
            target: self,
            action: #selector(loadAd)
        )

        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.reuseIdentifier)
        tableView.register(NativeAdCell.self, forCellReuseIdentifier: NativeAdCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        loadAd()
    }

    // MARK: - Ad loading

    @objc private func loadAd() {
        navigationItem.prompt = "Loading ad..."
        nativeAd = nil
        tableView.reloadData()

        let adLoader = AdLoader(
            adUnitID: nativeAdUnitID,
            rootViewController: self,
            adTypes: [.native],
            options: nil
        )
        adLoader.delegate = self
        adLoader.load(Request())
        self.adLoader = adLoader
    }
}

// MARK: - UITableViewDataSource

extension NativeAdViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case .article(let item):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ArticleCell.reuseIdentifier,
                for: indexPath
            ) as! ArticleCell
            cell.configure(with: item)
            return cell
        case .ad:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: NativeAdCell.reuseIdentifier,
                for: indexPath
            ) as! NativeAdCell
            if let nativeAd {
                cell.configure(with: nativeAd)
            }
            return cell
        }
    }
}

// MARK: - NativeAdLoaderDelegate

extension NativeAdViewController: NativeAdLoaderDelegate {
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        navigationItem.prompt = NativeAdCell.imageSourceDescription(for: nativeAd)
        tableView.reloadData()
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        navigationItem.prompt = "Failed to load ad: \(error.localizedDescription)"
    }
}
