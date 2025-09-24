package com.example.example

import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "stream_chat_flutter/photo_picker"
    private var imageResult: MethodChannel.Result? = null
    private var videoResult: MethodChannel.Result? = null

    private val imagePickerLauncher = registerForActivityResult(
        ActivityResultContracts.PickVisualMedia()
    ) { uri: Uri? ->
        if (uri != null) {
            imageResult?.success(uri.toString())
        } else {
            imageResult?.success(null)
        }
        imageResult = null
    }

    private val videoPickerLauncher = registerForActivityResult(
        ActivityResultContracts.PickVisualMedia()
    ) { uri: Uri? ->
        if (uri != null) {
            videoResult?.success(uri.toString())
        } else {
            videoResult?.success(null)
        }
        videoResult = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickImage" -> {
                    imageResult = result
                    imagePickerLauncher.launch(ActivityResultContracts.PickVisualMedia.VisualMediaType.IMAGE_ONLY)
                }
                "pickVideo" -> {
                    videoResult = result
                    videoPickerLauncher.launch(ActivityResultContracts.PickVisualMedia.VisualMediaType.VIDEO_ONLY)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}