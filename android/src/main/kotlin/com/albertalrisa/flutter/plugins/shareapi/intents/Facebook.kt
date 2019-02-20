package com.albertalrisa.flutter.plugins.shareapi.intents

import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import com.albertalrisa.flutter.plugins.shareapi.requests.FACEBOOK_SHARE_TO_STORY
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.MethodChannel
import com.facebook.share.model.ShareHashtag
import com.facebook.share.model.ShareLinkContent
import com.facebook.share.widget.ShareDialog
import java.io.File

class Facebook(authority_name: String, registrar: Registrar, activity: Activity): BaseIntent(authority_name, registrar, activity) {

    override val packageName = "com.facebook.katana"

    override fun execute(function: String?, arguments: Map<String, String>, result: MethodChannel.Result) {
        when (function) {
            "shareToStory" -> {
                shareToStory(arguments, result)
            }
            "shareLinkToNewsFeed" -> {
                shareLinkToNewsFeed(arguments, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun shareLinkToNewsFeed(arguments: Map<String, String>, result: MethodChannel.Result) {
        val shareDialog = ShareDialog(activity)

        val link = arguments["link"]
        val hashTag = arguments["hashTag"]
        var shareHashTag: ShareHashtag? = null
        if (hashTag != null) {
            shareHashTag = ShareHashtag.Builder().setHashtag(hashTag).build()
        }
        val linkContent = ShareLinkContent.Builder()
                .setContentUrl(Uri.parse(link))
                .setShareHashtag(shareHashTag)
                .build()

        shareDialog.show(linkContent)
    }

    private fun shareToStory(arguments: Map<String, String>, result: MethodChannel.Result) {
        val appId = arguments["appId"]

        val shareIntent = Intent("com.facebook.stories.ADD_TO_STORY")
        shareIntent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appId)

        shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

        val backgroundAssetName = arguments["backgroundAssetName"]
        val stickerAssetName = arguments["stickerAssetName"]

        if(backgroundAssetName == null && stickerAssetName == null) {
            val exceptionMessage = "Background Asset and Sticker Asset cannot be both null"
            val exception = IllegalArgumentException(exceptionMessage)
            result.error("IllegalArgumentException", exceptionMessage, exception)
            throw exception
        }

        if (backgroundAssetName != null) {
            val backgroundAsset = File(registrar.context().cacheDir, backgroundAssetName)
            val backgroundAssetUri = FileProvider.getUriForFile(registrar.context(), authority_name, backgroundAsset)
            val backgroundMediaType = arguments["backgroundMediaType"]
            shareIntent.setDataAndType(backgroundAssetUri, backgroundMediaType)
        }

        if (stickerAssetName != null) {
            val stickerAsset = File(registrar.context().cacheDir, stickerAssetName)
            val stickerAssetUri = FileProvider.getUriForFile(registrar.context(), authority_name, stickerAsset)
            val stickerMediaType = arguments["stickerMediaType"]
            if(backgroundAssetName == null) {
                shareIntent.type = stickerMediaType
            }
            shareIntent.putExtra("interactive_asset_uri", stickerAssetUri)
            activity.grantUriPermission(packageName, stickerAssetUri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        var topBackgroundColor:String? = arguments["topBackgroundColor"]
        var bottomBackgroundColor:String? = arguments["bottomBackgroundColor"]
        if(topBackgroundColor == null) {
            topBackgroundColor = bottomBackgroundColor
        }
        else if(bottomBackgroundColor == null) {
            bottomBackgroundColor = topBackgroundColor
        }

        if (topBackgroundColor != null && bottomBackgroundColor != null) {
            shareIntent.putExtra("top_background_color", topBackgroundColor)
            shareIntent.putExtra("bottom_background_color", bottomBackgroundColor)
        }

        if (!arguments["contentUrl"].isNullOrEmpty()) {
            shareIntent.putExtra("content_url", arguments["contentUrl"])
        }

        runActivityForResult(shareIntent, FACEBOOK_SHARE_TO_STORY, activity)
    }
}