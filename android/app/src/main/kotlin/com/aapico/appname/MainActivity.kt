package com.aapico.appname // Replace with your actual package name

import android.os.Bundle
import androidx.appcompat.app.AlertDialog
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Any initialization logic you need
    }

    override fun onBackPressed() {
        // Show a custom message or confirmation dialog on back press
        showExitConfirmationDialog()
    }

    // Function to show an exit confirmation dialog
    private fun showExitConfirmationDialog() {
        AlertDialog.Builder(this)
            .setTitle("Exit App")
            .setMessage("Are you sure you want to exit?")
            .setPositiveButton("Yes") { dialog, _ ->
                dialog.dismiss()
                // Call finish() instead of super.onBackPressed to exit
                finish()
            }
            .setNegativeButton("No") { dialog, _ ->
                dialog.dismiss() // Dismisses the dialog without closing the app
            }
            .create()
            .show()
    }
}
