package jp.fluct.example.gmanativeicon

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdLoader
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView

class MainActivity : AppCompatActivity() {

    companion object {
        private const val TAG = "GmaNativeIconExample"
    }

    private var currentNativeAd: NativeAd? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        MobileAds.initialize(this) { initializationStatus ->
            Log.d(TAG, "MobileAds initialized: ${initializationStatus.adapterStatusMap}")
        }

        findViewById<Button>(R.id.load_ad_button).setOnClickListener { loadNativeAd() }
        loadNativeAd()
    }

    override fun onDestroy() {
        currentNativeAd?.destroy()
        currentNativeAd = null
        super.onDestroy()
    }

    private fun loadNativeAd() {
        val adLoader = AdLoader.Builder(this, getString(R.string.native_ad_unit_id))
            .forNativeAd { nativeAd ->
                if (isDestroyed) {
                    nativeAd.destroy()
                    return@forNativeAd
                }
                currentNativeAd?.destroy()
                currentNativeAd = nativeAd
                showNativeAd(nativeAd)
            }
            .withAdListener(object : AdListener() {
                override fun onAdFailedToLoad(error: LoadAdError) {
                    Log.w(TAG, "Failed to load native ad: $error")
                }
            })
            .build()
        adLoader.loadAd(AdRequest.Builder().build())
    }

    private fun showNativeAd(nativeAd: NativeAd) {
        val container = findViewById<FrameLayout>(R.id.ad_container)
        val adView = LayoutInflater.from(this)
            .inflate(R.layout.native_ad_view, container, false) as NativeAdView

        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        bodyView.text = nativeAd.body
        adView.bodyView = bodyView

        val callToActionView = adView.findViewById<TextView>(R.id.ad_call_to_action)
        callToActionView.text = nativeAd.callToAction
        adView.callToActionView = callToActionView

        bindImage(nativeAd, adView)

        adView.setNativeAd(nativeAd)

        container.removeAllViews()
        container.addView(adView)
    }

    /**
     * feed行の左側の画像スペースに表示する画像アセットのフォールバック:
     * 1. main画像があればMediaViewで表示する
     * 2. main画像がなくicon画像があればiconを表示する
     * 3. どちらもなければ画像スペースごと表示しない
     */
    private fun bindImage(nativeAd: NativeAd, adView: NativeAdView) {
        val imageContainer = adView.findViewById<FrameLayout>(R.id.ad_image_container)
        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        val iconView = adView.findViewById<ImageView>(R.id.ad_icon)

        val hasMainImage = nativeAd.images.isNotEmpty()
        val icon = nativeAd.icon

        when {
            hasMainImage -> {
                imageContainer.visibility = View.VISIBLE
                mediaView.visibility = View.VISIBLE
                iconView.visibility = View.GONE
                adView.mediaView = mediaView
            }
            icon != null -> {
                imageContainer.visibility = View.VISIBLE
                mediaView.visibility = View.GONE
                iconView.visibility = View.VISIBLE
                iconView.setImageDrawable(icon.drawable)
                adView.iconView = iconView
            }
            else -> {
                imageContainer.visibility = View.GONE
                mediaView.visibility = View.GONE
                iconView.visibility = View.GONE
            }
        }
    }
}
