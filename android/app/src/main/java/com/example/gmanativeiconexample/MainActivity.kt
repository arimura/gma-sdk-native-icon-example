package com.example.gmanativeiconexample

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdLoader
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView

/// feed内の1アイテムを想定したネイティブ広告の表示例
///
/// - 画面横幅いっぱいの横長領域に広告を表示する
/// - 左端の正方形領域に、main画像 (`NativeAd.images`) があればmain画像を `MediaView` で、
///   なければicon (`NativeAd.icon`) を `ImageView` で表示する。どちらもなければ画像は表示しない
/// - 右側にタイトル (headline) と広告主 (advertiser) を表示する
class MainActivity : Activity() {

    companion object {
        private const val TAG = "MainActivity"

        /// Google Mobile Ads SDKのサンプル用ネイティブ広告ユニットID
        private const val AD_UNIT_ID = "ca-app-pub-3940256099942544/2247696110"
    }

    private var adLoader: AdLoader? = null
    private var nativeAd: NativeAd? = null

    private lateinit var nativeAdView: NativeAdView
    private lateinit var mediaView: MediaView
    private lateinit var iconView: ImageView
    private lateinit var headlineView: TextView
    private lateinit var advertiserView: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        nativeAdView = findViewById(R.id.native_ad_view)
        mediaView = findViewById(R.id.media_view)
        iconView = findViewById(R.id.icon_view)
        headlineView = findViewById(R.id.headline_view)
        advertiserView = findViewById(R.id.advertiser_view)

        nativeAdView.mediaView = mediaView
        nativeAdView.iconView = iconView
        nativeAdView.headlineView = headlineView
        nativeAdView.advertiserView = advertiserView

        findViewById<Button>(R.id.load_ad_button).setOnClickListener { loadAd() }

        MobileAds.initialize(this) {
            loadAd()
        }
    }

    override fun onDestroy() {
        nativeAd?.destroy()
        super.onDestroy()
    }

    private fun loadAd() {
        val loader = AdLoader.Builder(this, AD_UNIT_ID)
            .forNativeAd { nativeAd -> onNativeAdLoaded(nativeAd) }
            .withAdListener(object : AdListener() {
                override fun onAdFailedToLoad(error: LoadAdError) {
                    Log.d(TAG, "onAdFailedToLoad: $error")
                    nativeAdView.visibility = View.GONE
                }
            })
            .build()
        adLoader = loader
        loader.loadAd(AdRequest.Builder().build())
    }

    private fun onNativeAdLoaded(nativeAd: NativeAd) {
        Log.d(TAG, "onNativeAdLoaded: images=${nativeAd.images.size}, icon=${nativeAd.icon}")

        // Activity破棄後にロードが完了した場合は表示せずに破棄する
        if (isDestroyed) {
            nativeAd.destroy()
            return
        }

        this.nativeAd?.destroy()
        this.nativeAd = nativeAd

        headlineView.text = nativeAd.headline
        advertiserView.text = nativeAd.advertiser

        val icon = nativeAd.icon
        if (nativeAd.images.isNotEmpty()) {
            // main画像があればMediaViewで表示する
            mediaView.mediaContent = nativeAd.mediaContent
            mediaView.visibility = View.VISIBLE
            iconView.visibility = View.GONE
        } else if (icon != null) {
            // main画像がなければiconを表示する
            iconView.setImageDrawable(icon.drawable)
            iconView.visibility = View.VISIBLE
            mediaView.visibility = View.GONE
        } else {
            // どちらもない場合は画像領域を空のままにする
            mediaView.visibility = View.GONE
            iconView.visibility = View.GONE
        }

        nativeAdView.setNativeAd(nativeAd)
        nativeAdView.visibility = View.VISIBLE
    }
}
