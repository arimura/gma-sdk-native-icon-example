# Android Example

Google Mobile Ads SDKとFluctSDK GMAアダプターを利用してネイティブ広告を表示するサンプルアプリです。

## レイアウト

feed風のレイアウトです。ダミー記事の行の間にネイティブ広告を1行として挿入します。
各行は左が画像スペース、右がテキストの構成です。

## ネイティブ広告の画像表示ロジック

広告行の左側の画像スペースについて、`MainActivity.kt` の `bindImage` で以下のフォールバックを実装しています。

1. main画像（`NativeAd.getImages()`）があればMediaViewで表示する
2. main画像がなくicon画像（`NativeAd.getIcon()`）があればiconを表示する
3. どちらもなければ画像スペースごと表示しない

## 依存関係

- Google Mobile Ads SDK (`com.google.android.gms:play-services-ads`)
- FluctSDK GMAアダプター (`jp.fluct.mediation.gma:gma-mediation`)
  - Mavenリポジトリ: `https://voyagegroup.github.io/FluctSDK-Android/m2/repository`

## 広告ID

Googleが提供しているサンプルIDを設定しています。

- App ID: `ca-app-pub-3940256099942544~3347511713`
- Native Ad Unit ID: `ca-app-pub-3940256099942544/2247696110`

## ビルド

```sh
cd android
./gradlew assembleDebug
```

Android SDKが必要です（`ANDROID_HOME` を設定するか `local.properties` に `sdk.dir` を記載してください）。
