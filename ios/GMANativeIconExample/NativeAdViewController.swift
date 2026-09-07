import GoogleMobileAds
import UIKit

/// feed内の1アイテムを想定したネイティブ広告の表示例
///
/// - 画面横幅いっぱいの横長領域に広告を表示する
/// - 左端の正方形領域に、main画像 (`NativeAd.images`) があればmain画像を `MediaView` で、
///   なければicon (`NativeAd.icon`) を `UIImageView` で表示する。どちらもなければ画像は表示しない
/// - main画像とiconを同一サイズの領域に表示する為、同じlayoutサイズの `MediaView` と
///   `UIImageView` を重ねて配置し、どちらを表示するかは `isHidden` で切り替える
/// - 右側にタイトル (headline) と広告主 (advertiser) を表示する
final class NativeAdViewController: UIViewController {

    /// Google Mobile Ads SDKのサンプル用ネイティブ広告ユニットID
    private static let adUnitID = "ca-app-pub-3940256099942544/3986624511"

    private static let imageContainerSize: CGFloat = 80

    private var adLoader: AdLoader?

    private let loadAdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load Ad", for: .normal)
        return button
    }()

    private let nativeAdView: NativeAdView = {
        let adView = NativeAdView()
        adView.isHidden = true
        adView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        return adView
    }()

    private let mediaView: MediaView = {
        let view = MediaView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()

    private let advertiserLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        loadAdButton.addTarget(self, action: #selector(loadAd), for: .touchUpInside)

        setupNativeAdView()

        loadAdButton.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(loadAdButton)
        view.addSubview(nativeAdView)

        NSLayoutConstraint.activate([
            loadAdButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            loadAdButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nativeAdView.topAnchor.constraint(equalTo: loadAdButton.bottomAnchor, constant: 16),
            nativeAdView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nativeAdView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        loadAd()
    }

    private func setupNativeAdView() {
        // main画像とiconを同一サイズの正方形領域に表示する為、
        // 同じlayoutサイズのMediaViewとUIImageViewを重ねて配置する
        let imageContainer = UIView()

        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        advertiserLabel.translatesAutoresizingMaskIntoConstraints = false

        imageContainer.addSubview(mediaView)
        imageContainer.addSubview(iconImageView)

        nativeAdView.addSubview(imageContainer)
        nativeAdView.addSubview(headlineLabel)
        nativeAdView.addSubview(advertiserLabel)

        nativeAdView.mediaView = mediaView
        nativeAdView.iconView = iconImageView
        nativeAdView.headlineView = headlineLabel
        nativeAdView.advertiserView = advertiserLabel

        NSLayoutConstraint.activate([
            imageContainer.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 8),
            imageContainer.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 8),
            imageContainer.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -8),
            imageContainer.widthAnchor.constraint(equalToConstant: Self.imageContainerSize),
            imageContainer.heightAnchor.constraint(equalToConstant: Self.imageContainerSize),

            mediaView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),

            iconImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),

            headlineLabel.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 8),
            headlineLabel.leadingAnchor.constraint(equalTo: imageContainer.trailingAnchor, constant: 8),
            headlineLabel.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -8),

            advertiserLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
            advertiserLabel.leadingAnchor.constraint(equalTo: imageContainer.trailingAnchor, constant: 8),
            advertiserLabel.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -8),
            advertiserLabel.bottomAnchor.constraint(lessThanOrEqualTo: nativeAdView.bottomAnchor, constant: -8)
        ])
    }

    @objc private func loadAd() {
        let loader = AdLoader(
            adUnitID: Self.adUnitID,
            rootViewController: self,
            adTypes: [.native],
            options: nil
        )
        loader.delegate = self
        adLoader = loader
        loader.load(Request())
    }

}

// MARK: - AdLoaderDelegate

extension NativeAdViewController: AdLoaderDelegate {

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print(#function, error.localizedDescription)

        // 古いロードの失敗コールバックで、直近のロードで表示中の広告を消さないようにガードする
        guard adLoader === self.adLoader else { return }

        nativeAdView.isHidden = true
    }

}

// MARK: - NativeAdLoaderDelegate

extension NativeAdViewController: NativeAdLoaderDelegate {

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        print(#function, "images=\(nativeAd.images?.count ?? 0), icon=\(String(describing: nativeAd.icon))")

        // 古いロードの成功コールバックで、直近のロードで表示中の広告を上書きしないようにガードする
        guard adLoader === self.adLoader else { return }

        headlineLabel.text = nativeAd.headline
        advertiserLabel.text = nativeAd.advertiser

        let mainImages = nativeAd.images ?? []
        let icon = nativeAd.icon
        if !mainImages.isEmpty {
            // main画像があればMediaViewで表示する
            // (iOSのGMA SDKはnativeAd代入ではMediaViewへ描画内容を設定しない為、明示的に渡す)
            mediaView.mediaContent = nativeAd.mediaContent
            mediaView.isHidden = false
            iconImageView.isHidden = true
        } else if let icon {
            // main画像がなければiconを表示する
            iconImageView.image = icon.image
            iconImageView.isHidden = false
            mediaView.isHidden = true
        } else {
            // どちらもない場合は画像領域を空のままにする
            mediaView.isHidden = true
            iconImageView.isHidden = true
        }

        nativeAdView.nativeAd = nativeAd
        nativeAdView.isHidden = false
    }

}
