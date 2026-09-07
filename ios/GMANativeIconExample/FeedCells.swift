import GoogleMobileAds
import UIKit

private let thumbnailSize: CGFloat = 96

// MARK: - ダミー記事セル

struct FeedItem {
    let title: String
    let subtitle: String
}

final class ArticleCell: UITableViewCell {
    static let reuseIdentifier = "ArticleCell"

    private let thumbnailView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        thumbnailView.backgroundColor = .systemGray5
        thumbnailView.layer.cornerRadius = 8

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2

        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let rowStack = UIStackView(arrangedSubviews: [thumbnailView, textStack])
        rowStack.axis = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .top
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowStack)

        NSLayoutConstraint.activate([
            thumbnailView.widthAnchor.constraint(equalToConstant: thumbnailSize),
            thumbnailView.heightAnchor.constraint(equalToConstant: thumbnailSize),

            rowStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            rowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rowStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: FeedItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
    }
}

// MARK: - ネイティブ広告セル（feed 風・左に画像スペース）

final class NativeAdCell: UITableViewCell {
    static let reuseIdentifier = "NativeAdCell"

    private let nativeAdView = NativeAdView()
    private let adImageView = UIImageView()
    private let attributionLabel = UILabel()
    private let headlineLabel = UILabel()
    private let bodyLabel = UILabel()
    private let advertiserLabel = UILabel()
    private let callToActionLabel = UILabel()
    private let sourceLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        adImageView.contentMode = .scaleAspectFill
        adImageView.clipsToBounds = true
        adImageView.layer.cornerRadius = 8

        attributionLabel.text = "Ad"
        attributionLabel.font = .preferredFont(forTextStyle: .caption2)
        attributionLabel.textColor = .white
        attributionLabel.backgroundColor = .systemYellow
        attributionLabel.textAlignment = .center
        attributionLabel.layer.cornerRadius = 3
        attributionLabel.clipsToBounds = true

        headlineLabel.font = .preferredFont(forTextStyle: .headline)
        headlineLabel.numberOfLines = 2

        bodyLabel.font = .preferredFont(forTextStyle: .subheadline)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 2

        advertiserLabel.font = .preferredFont(forTextStyle: .caption1)
        advertiserLabel.textColor = .tertiaryLabel

        callToActionLabel.font = .preferredFont(forTextStyle: .subheadline)
        callToActionLabel.textColor = .white
        callToActionLabel.backgroundColor = .systemBlue
        callToActionLabel.textAlignment = .center
        callToActionLabel.layer.cornerRadius = 6
        callToActionLabel.clipsToBounds = true
        // タップは NativeAdView（SDK）側で処理する
        callToActionLabel.isUserInteractionEnabled = false

        sourceLabel.font = .preferredFont(forTextStyle: .caption2)
        sourceLabel.textColor = .tertiaryLabel

        let badgeRow = UIStackView(arrangedSubviews: [attributionLabel, headlineLabel])
        badgeRow.axis = .horizontal
        badgeRow.spacing = 6
        badgeRow.alignment = .center

        let textStack = UIStackView(arrangedSubviews: [
            badgeRow,
            bodyLabel,
            advertiserLabel,
            callToActionLabel,
            sourceLabel,
        ])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .fill

        // 左に画像スペース、右にテキストの feed 風レイアウト
        let rowStack = UIStackView(arrangedSubviews: [adImageView, textStack])
        rowStack.axis = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .top
        rowStack.translatesAutoresizingMaskIntoConstraints = false

        nativeAdView.addSubview(rowStack)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nativeAdView)

        NSLayoutConstraint.activate([
            adImageView.widthAnchor.constraint(equalToConstant: thumbnailSize),
            adImageView.heightAnchor.constraint(equalToConstant: thumbnailSize),
            attributionLabel.widthAnchor.constraint(equalToConstant: 26),
            callToActionLabel.heightAnchor.constraint(equalToConstant: 32),

            rowStack.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
            rowStack.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            rowStack.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor),

            nativeAdView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nativeAdView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nativeAdView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nativeAdView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])

        // NativeAdView にアセットビューを登録する
        nativeAdView.headlineView = headlineLabel
        nativeAdView.bodyView = bodyLabel
        nativeAdView.advertiserView = advertiserLabel
        nativeAdView.imageView = adImageView
        nativeAdView.callToActionView = callToActionLabel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with nativeAd: NativeAd) {
        headlineLabel.text = nativeAd.headline
        bodyLabel.text = nativeAd.body
        bodyLabel.isHidden = nativeAd.body == nil
        advertiserLabel.text = nativeAd.advertiser
        advertiserLabel.isHidden = nativeAd.advertiser == nil
        callToActionLabel.text = nativeAd.callToAction
        callToActionLabel.isHidden = nativeAd.callToAction == nil

        updateAdImage(with: nativeAd)
        sourceLabel.text = Self.imageSourceDescription(for: nativeAd)

        nativeAdView.nativeAd = nativeAd
    }

    /// 左側の画像スペースのフォールバックロジック:
    /// 1. main 画像 (`images`) があれば main 画像を表示する
    /// 2. main 画像がなければ icon 画像 (`icon`) を表示する
    /// 3. どちらもなければ画像は表示しない（テキストが全幅に広がる）
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

    static func imageSourceDescription(for nativeAd: NativeAd) -> String {
        if nativeAd.images?.first?.image != nil {
            return "Displaying: main image"
        } else if nativeAd.icon?.image != nil {
            return "Displaying: icon image"
        } else {
            return "Displaying: no image"
        }
    }
}
