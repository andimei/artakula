package com.example.artakula

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "artakula/backup"
    private val SAVE_BACKUP_REQUEST = 1001
    private var pendingSave: PendingSave? = null

    data class PendingSave(
        val content: String,
        val result: MethodChannel.Result,
    )

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method == "saveBackup") {
                val fileName = call.argument<String>("fileName")!!
                val content = call.argument<String>("content")!!

                pendingSave = PendingSave(content, result)

                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "application/json"
                    putExtra(Intent.EXTRA_TITLE, fileName)
                }
                startActivityForResult(intent, SAVE_BACKUP_REQUEST)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == SAVE_BACKUP_REQUEST) {
            val pending = pendingSave ?: return
            pendingSave = null

            if (resultCode == Activity.RESULT_OK && data != null) {
                val uri = data.data
                if (uri != null) {
                    try {
                        contentResolver.openOutputStream(uri)?.use { out ->
                            out.write(pending.content.toByteArray(Charsets.UTF_8))
                        }
                        pending.result.success(uri.toString())
                    } catch (e: Exception) {
                        pending.result.error(
                            "WRITE_ERROR",
                            e.message ?: "Unknown error",
                            null,
                        )
                    }
                    return
                }
            }

            pending.result.success(null)
            return
        }

        super.onActivityResult(requestCode, resultCode, data)
    }
}
