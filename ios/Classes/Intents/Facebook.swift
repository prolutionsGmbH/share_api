//
//  Facebook.swift
//  share_api
//
//  Created by Albert Richard Sanyoto on 2019-01-11.
//

import FacebookShare

class Facebook: ShareIntent {
    func execute(function: String, arguments: Dictionary<String, String?>, result: @escaping FlutterResult) {
        switch function {
        case "shareToStory": self.shareToStory(arguments: arguments, result: result);
        case "shareLinkToNewsFeed": self.shareLinkToNewsFeed(arguments: arguments, result: result);
        default: result(FlutterMethodNotImplemented);
        }
    }

    func shareLinkToNewsFeed(arguments: Dictionary<String, String?>, result: @escaping FlutterResult) {
        let link:String? = arguments["link"]!
        let hashTag:String? = arguments["hashTag"]!
        if link != nil {
            var content:LinkShareContent = LinkShareContent.init(url: URL.init(string: link!)!)
            if hashTag != nil {
                content.hashtag = Hashtag.init(hashTag!)
            }

            let shareDialog = ShareDialog(content: content)
            shareDialog.mode = .native
            shareDialog.failsOnInvalidData = true

            do {
                try shareDialog.show()
            } catch {
                result(FlutterError(code: "UnableToShareException", message: "Sharing dialog could not be shown. Error: \(error).", details: arguments))
            }
        } else {
            result(FlutterError(code: "IllegalArgumentException", message: "Link cannot be nil.", details: arguments))
        }
    }

    func shareToStory(arguments: Dictionary<String, String?>, result: @escaping FlutterResult) {
        var pasteboardItems: [[String: Any]] = []
        let argsKeys = arguments.keys
        if argsKeys.contains("appId") {
            let appId = arguments["appId"]! ?? ""
            pasteboardItems.append(["com.facebook.sharedSticker.appID": appId])
        }
        
        let backgroundAssetName = arguments["backgroundAssetName"] as? String
        let stickerAssetName = arguments["stickerAssetName"] as? String
        
        if backgroundAssetName == nil && stickerAssetName == nil {
            result(FlutterError(code: "IllegalArgumentException", message: "Background Asset and Sticker Asset cannot be both null", details: arguments))
            return
        }
        
        let temporaryDirectories = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        if temporaryDirectories.isEmpty {
            result(FlutterError(code: "InvalidTemporaryDirectory", message: "Cannot retrieve list of possible temporary directories", details: arguments))
            return
        }
        let temporaryDirectory = temporaryDirectories.first!
        
        if backgroundAssetName != nil {
            let backgroundAssetPath = temporaryDirectory.appendingPathComponent(backgroundAssetName!)
            let backgroundAsset = UIImage(contentsOfFile: backgroundAssetPath.path)
            pasteboardItems.append(["com.facebook.sharedSticker.backgroundImage": backgroundAsset!])
        }
        
        if stickerAssetName != nil {
            let stickerAssetPath = temporaryDirectory.appendingPathComponent(stickerAssetName!)
            let stickerAsset = UIImage(contentsOfFile: stickerAssetPath.path)
            pasteboardItems.append(["com.facebook.sharedSticker.stickerImage": stickerAsset!])
        }
    
        var topBackgroundColor = arguments["topBackgroundColor"] as? String
        var bottomBackgroundColor = arguments["bottomBackgroundColor"] as? String
        if topBackgroundColor == nil {
            topBackgroundColor = bottomBackgroundColor
        }
        else if bottomBackgroundColor == nil {
            bottomBackgroundColor = topBackgroundColor
        }
        
        if topBackgroundColor != nil && bottomBackgroundColor != nil {
            pasteboardItems.append(["com.facebook.sharedSticker.backgroundTopColor": topBackgroundColor!])
            pasteboardItems.append(["com.facebook.sharedSticker.backgroundBottomColor": bottomBackgroundColor!])
        }
        
        if let contentUrl = arguments["contentUrl"] as? String {
            if !contentUrl.isEmpty {
                pasteboardItems.append(["com.facebook.sharedSticker.contentURL": contentUrl])
            }
        }
        
        if #available(iOS 10.0, *) {
            let pasteboardOptions = [
                UIPasteboardOption.expirationDate: Date.init(timeIntervalSinceNow: 60 * 5)
            ]
            UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            UIApplication.shared.open(URL(string: "facebook-stories://share")!, options: [:], completionHandler: { (r) -> Void in
                if r {
                    result(0x00)
                }
                else {
                    result(0x03)
                }
            })
        } else {
            UIPasteboard.general.addItems(pasteboardItems)
            UIApplication.shared.openURL(URL(string: "facebook-stories://share")!)
            result(0x00)
        }
    }
    
    var urlSchemes = [
        "facebook-stories://share"
    ]
}
