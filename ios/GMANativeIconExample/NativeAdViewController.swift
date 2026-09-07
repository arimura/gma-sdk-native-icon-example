import GoogleMobileAds
import UIKit

/// Google のサンプル用ネイティブ広告ユニット ID
/// https://developers.google.com/admob/ios/test-ads
private let nativeAdUnitID = "ca-app-pub-3940256099942544/3986624511"

final class NativeAdViewController: UIViewController {
    private var adLoader: AdLoader?
    private var nativeAd: NativeAd?

    private let nativeAdView = NativeAdView()
    private let headlineLabel = UILabel()
    private let advertiserLabel = UILabel()
    private let bodyLabel = UILabel()
    private let adImageView = UIImageView()
    private let callToActionButton = UIButton(type: .system)
    private let attributionLabel = UILabel()
    private let statusLabel = UILabel()
    private let reloadButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GMA Native Ad Example"
        view.backgroundColor = .systemBackground
        setupViews()
        loadAd()
    }

    // MARK: - Ad loading

    @objc private func loadAd() {
        statusLabel.text = "Loading..."
        nativeAdView.isHidden = true

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

    private func render(nativeAd: NativeAd) {
        self.nativeAd = nativeAd

        headlineLabel.text = nativeAd.headline
        advertiserLabel.text = nativeAd.advertiser
        advertiserLabel.isHidden = nativeAd.advertiser == nil
        bodyLabel.text = nativeAd.body
        bodyLabel.isHidden = nativeAd.body == nil
        callToActionButton.setTitle(nativeAd.callToAction, for: .normal)
        callToActionButton.isHidden = nativeAd.callToAction == nil
        // タップは SDK 側で処理するため、ボタン自体の操作は無効にしておく
        callToActionButton.isUserInteractionEnabled = false

        updateAdImage(with: nativeAd)

        nativeAdView.nativeAd = nativeAd
        nativeAdView.isHidden = false
        statusLabel.text = imageSourceDescription(for: nativeAd)
    }

    /// 画像表示のフォールバックロジック:
    /// 1. main 画像 (`images`) があれば main 画像を表示する
    /// 2. main 画像がなければ icon 画像 (`icon`) を表示する
    /// 3. どちらもなければ画像は表示しない
    private func updateAdImage(with nativeAd: NativeAd) {
        if let mainImage = nativeAd.images?.first?.image {
            adImageView.image = mainImage
            adImageView.isHidden = false
        } else if let iconImage = nativeAd.icon?.image {
            adImageView.image = iconImage
            adImageView.isHidden = false
        } else {
            adImageView.image = nil
            adImageView.isHidden = true
        }
    }

    private func imageSourceDescription(for nativeAd: NativeAd) -> String {
        if nativeAd.images?.first?.image != nil {
            return "Displaying: main image"
        } else if nativeAd.icon?.image != nil {
            return "Displaying: icon image"
        } else {
            return "Displaying: no image"
        }
    }

    // MARK: - Layout

    private func setupViews() {
        statusLabel.text = ""
        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center

        reloadButton.setTitle("Reload Ad", for: .normal)
        reloadButton.addTarget(self, action: #selector(loadAd), for: .touchUpInside)

        attributionLabel.text = "Ad"
        attributionLabel.font = .preferredFont(forTextStyle: .caption2)
        attributionLabel.textColor = .white
        attributionLabel.backgroundColor = .systemYellow
        attributionLabel.textAlignment = .center
        attributionLabel.layer.cornerRadius = 3
        attributionLabel.clipsToBounds = true

        headlineLabel.font = .preferredFont(forTextStyle: .headline)
        headlineLabel.numberOfLines = 2

        advertiserLabel.font = .preferredFont(forTextStyle: .subheadline)
        advertiserLabel.textColor = .secondaryLabel

        bodyLabel.font = .preferredFont(forTextStyle: .body)
        bodyLabel.numberOfLines = 3

        adImageView.contentMode = .scaleAspectFit
        adImageView.clipsToBounds = true

        callToActionButton.backgroundColor = .systemBlue
        callToActionButton.setTitleColor(.white, for: .normal)
        callToActionButton.layer.cornerRadius = 8
        callToActionButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

        let adContentStack = UIStackView(arrangedSubviews: [
            attributionLabel,
            headlineLabel,
            advertiserLabel,
            adImageView,
            bodyLabel,
            callToActionButton,
        ])
        adContentStack.axis = .vertical
        adContentStack.spacing = 8
        adContentStack.alignment = .fill
        adContentStack.translatesAutoresizingMaskIntoConstraints = false

        nativeAdView.addSubview(adContentStack)
        nativeAdView.layer.borderColor = UIColor.separator.cgColor
        nativeAdView.layer.borderWidth = 1
        nativeAdView.layer.cornerRadius = 12
        nativeAdView.isHidden = true

        // NativeAdView にアセットビューを登録する
        nativeAdView.headlineView = headlineLabel
        nativeAdView.advertiserView = advertiserLabel
        nativeAdView.bodyView = bodyLabel
        nativeAdView.imageView = adImageView
        nativeAdView.callToActionView = callToActionButton

        let rootStack = UIStackView(arrangedSubviews: [statusLabel, nativeAdView, reloadButton])
        rootStack.axis = .vertical
        rootStack.spacing = 16
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootStack)

        NSLayoutConstraint.activate([
            adContentStack.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 12),
            adContentStack.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            adContentStack.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
            adContentStack.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -12),

            attributionLabel.widthAnchor.constraint(equalToConstant: 32),
            adImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 240),

            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            rootStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            rootStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
}

// MARK: - NativeAdLoaderDelegate

extension NativeAdViewController: NativeAdLoaderDelegate {
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        render(nativeAd: nativeAd)
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        statusLabel.text = "Failed to load ad: \(error.localizedDescription)"
    }
}
