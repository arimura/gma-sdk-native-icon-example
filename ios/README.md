# iOS Example

Google Mobile Ads SDK と FluctSDK GMA アダプターを利用してネイティブ広告を表示するサンプルアプリです。
ダミー記事の間にネイティブ広告を挟んだ feed 風レイアウトで、広告セルの左側が画像スペースになっています。

## 画像表示のロジック

広告セル左側の画像スペースは以下のロジックで表示します（`NativeAdCell.updateAdImage(with:)`）。

1. main 画像（`NativeAd.images`）があれば main 画像を表示する
2. main 画像がなければ icon 画像（`NativeAd.icon`）を表示する
3. どちらもなければ画像は表示しない（テキストが全幅に広がる）

## 依存関係

Swift Package Manager で以下を導入しています（`project.yml` 参照）。

- [googleads-mobile-ios-mediation-fluct](https://github.com/voyagegroup/googleads-mobile-ios-mediation-fluct)（FluctSDK の GMA アダプター。FluctSDK 本体と Google Mobile Ads SDK に依存）
- [swift-package-manager-google-mobile-ads](https://github.com/googleads/swift-package-manager-google-mobile-ads)（Google Mobile Ads SDK）

App ID / Ad Unit ID は Google が提供しているサンプル用 ID を設定しています。

- App ID: `ca-app-pub-3940256099942544~1458002511`（`Info.plist` の `GADApplicationIdentifier`）
- Native Ad Unit ID: `ca-app-pub-3940256099942544/3986624511`

## ビルド方法

[XcodeGen](https://github.com/yonaskolb/XcodeGen) でプロジェクトファイルを生成します。

```sh
brew install xcodegen
cd ios
xcodegen generate
open GMANativeIconExample.xcodeproj
```

CI では `.github/workflows/ios-build.yml` で iOS Simulator 向けのビルドを行っています。
