package com.example.numi_flutter

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private var pendingAvatarResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AVATAR_PICKER_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickAvatar" -> pickAvatar(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun pickAvatar(result: MethodChannel.Result) {
        if (pendingAvatarResult != null) {
            result.error("picker_active", "An avatar picker is already open.", null)
            return
        }

        try {
            pendingAvatarResult = result
            startActivityForResult(createAvatarPickerIntent(), AVATAR_PICKER_REQUEST_CODE)
        } catch (error: Exception) {
            pendingAvatarResult = null
            result.error("picker_unavailable", error.message, null)
        }
    }

    private fun createAvatarPickerIntent(): Intent {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Intent(MediaStore.ACTION_PICK_IMAGES).apply {
                type = "image/*"
            }
        } else {
            Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI).apply {
                type = "image/*"
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != AVATAR_PICKER_REQUEST_CODE) {
            return
        }

        val result = pendingAvatarResult ?: return
        pendingAvatarResult = null

        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return
        }

        val uri = data?.data
        if (uri == null) {
            result.success(null)
            return
        }

        try {
            result.success(copyAvatarToCache(uri))
        } catch (error: Exception) {
            result.error("avatar_copy_failed", error.message, null)
        }
    }

    private fun copyAvatarToCache(uri: Uri): String {
        val extension = avatarExtension(uri)
        val destination = File(cacheDir, "avatar_${System.currentTimeMillis()}.$extension")

        contentResolver.openInputStream(uri).use { input ->
            requireNotNull(input) { "Unable to open selected avatar." }
            FileOutputStream(destination).use { output ->
                input.copyTo(output)
            }
        }

        return destination.absolutePath
    }

    private fun avatarExtension(uri: Uri): String {
        return when (contentResolver.getType(uri)) {
            "image/png" -> "png"
            "image/webp" -> "webp"
            "image/gif" -> "gif"
            else -> "jpg"
        }
    }

    companion object {
        private const val AVATAR_PICKER_CHANNEL = "numi/avatar_picker"
        private const val AVATAR_PICKER_REQUEST_CODE = 9041
    }
}
