import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:share_api/composers/facebook_story.dart';
import 'package:share_api/share_api.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, String> isInstalled = {
    "facebook": "unknown",
    "instagram": "unknown",
    "system": "unknown",
  };

  @override
  void initState() {
    super.initState();
    getInstalledPackages();
  }

  Future<void> getInstalledPackages() async {
    try {
      isInstalled["facebook"] =
          await ShareApi.viaFacebook.isPackageInstalled() ? "true" : "false";
    } on PlatformException {
      isInstalled["facebook"] = 'Failed to get facebook status.';
    }
    try {
      isInstalled["instagram"] =
          await ShareApi.viaInstagram.isPackageInstalled() ? "true" : "false";
    } on PlatformException {
      isInstalled["instagram"] = 'Failed to get instagram status.';
    }
    try {
      isInstalled["system"] =
          await ShareApi.viaSystemUI.isPackageInstalled() ? "true" : "false";
    } on PlatformException {
      isInstalled["system"] = 'Failed to get system status.';
    }

    setState(() {});

    if (!mounted) return;
  }

  bool _isLoading = false;

  void shareToInstagramStory() async {
    var image = await rootBundle.load('assets/image.jpg');
    var bytedata = image.buffer.asUint8List();
    var sticker = await rootBundle.load('assets/image.png');
    var stickerdata = sticker.buffer.asUint8List();
    var composer = FacebookStoryComposer(
      backgroundAsset: bytedata,
      backgroundMediaType: 'image/*',
      stickerAsset: stickerdata,
      stickerMediaType: 'image/*',
      topBackgroundColor: Color(0xFFFF0000),
      bottomBackgroundColor: Color(0xFF00FF00),
    );
    ShareApi.viaInstagram.shareToStory(composer).then((response) {
      print('Instagram $response');
    });
  }

  void shareToStory() async {
    var image = await rootBundle.load('assets/image.jpg');
    var bytedata = image.buffer.asUint8List();
    ShareApi.viaFacebook.setAppId("0000000000000000");
    var composer = FacebookStoryComposer(
      backgroundAsset: bytedata,
      backgroundMediaType: 'image/*',
//      stickerAsset: bytedata,
//      stickerMediaType: 'image/*',
//      topBackgroundColor: Color(0xFFFF0000),
//      bottomBackgroundColor: Color(0xFF00FF00),
    );
    ShareApi.viaFacebook.shareToStory(composer).then((response) {
      print('Facebook $response');
    });
  }

  void shareLinkToNewsFeed() async {
    var image = await rootBundle.load('assets/image.jpg');
    ShareApi.viaFacebook.setAppId("000000000000000");
    ShareApi.viaFacebook.shareLinkToNewsFeed(link: "https://www.facebook.com", hashTag: "#facebook").then((response) {
      print('Facebook NewsFeed $response');
    });
  }

  void shareImage() async {
    setState(() {
      _isLoading = true;
    });
    var image = await rootBundle.load('assets/image.jpg');
    var bytes = image.buffer.asUint8List();
    ShareApi.viaSystemUI.shareImage(bytes, imageType: 'image/png');

    setState(() {
      _isLoading = false;
    });
  }

  void shareText() {
    ShareApi.viaSystemUI.shareText("Shared!");
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset('assets/image.jpg'),
              Container(
                alignment: Alignment(0.5, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Column(
                      children:
                          ["facebook", "instagram", "system"].map((handler) {
                        return Text(isInstalled[handler]);
                      }).toList(),
                    ),
                    RawMaterialButton(
                      onPressed: () {
                        shareToInstagramStory();
                      },
                      fillColor: Colors.lightBlue,
                      splashColor: Colors.lightBlueAccent,
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : Text(
                              'Share File To Instagram Story',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    RawMaterialButton(
                      onPressed: () {
                        shareLinkToNewsFeed();
                      },
                      fillColor: Colors.lightBlue,
                      splashColor: Colors.lightBlueAccent,
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : Text(
                              'Share Link To Facebook News Feed',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    RawMaterialButton(
                      onPressed: () {
                        shareToStory();
                      },
                      fillColor: Colors.lightBlue,
                      splashColor: Colors.lightBlueAccent,
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : Text(
                              'Share File To Facebook Story',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    RawMaterialButton(
                      onPressed: shareImage,
                      fillColor: Colors.lightBlue,
                      splashColor: Colors.lightBlueAccent,
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : Text(
                              'Share Image Through API',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    RawMaterialButton(
                      onPressed: shareText,
                      fillColor: Colors.lightBlue,
                      splashColor: Colors.lightBlueAccent,
                      child: Text(
                        'Share Text Through API',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
