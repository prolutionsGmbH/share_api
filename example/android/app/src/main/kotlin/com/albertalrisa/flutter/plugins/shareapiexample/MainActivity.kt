package com.albertalrisa.flutter.plugins.shareapiexample

import android.os.Bundle
import android.content.Intent

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import com.facebook.CallbackManager
import com.facebook.FacebookSdk

class MainActivity(): FlutterActivity() {
  lateinit var callbackManager : CallbackManager

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    callbackManager = CallbackManager.Factory.create()
  }


  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent) {
    super.onActivityResult(requestCode, resultCode, data)
    callbackManager.onActivityResult(requestCode, resultCode, data)
  }
}
