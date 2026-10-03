package com.pasodelrio.paso_del_rio

import android.content.ActivityNotFoundException
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "paso_del_rio/ticket_share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            if (call.method != "shareTicketImage") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val bytes = call.argument<ByteArray>("bytes")
            val fileName = call.argument<String>("fileName") ?: "pase-paso-del-rio.png"
            val phone = call.argument<String>("phone") ?: ""

            if (bytes == null || bytes.isEmpty()) {
                result.error("EMPTY_IMAGE", "No se pudo preparar la imagen del pase.", null)
                return@setMethodCallHandler
            }

            try {
                shareTicketImage(bytes, fileName, phone)
                result.success("WhatsApp abierto con la imagen lista. Revisa el chat y pulsa enviar.")
            } catch (error: ActivityNotFoundException) {
                result.error("NO_WHATSAPP", "No se encontró WhatsApp instalado en este teléfono.", null)
            } catch (error: Exception) {
                result.error("SHARE_FAILED", error.message ?: "No se pudo abrir WhatsApp con la imagen.", null)
            }
        }
    }

    private fun shareTicketImage(bytes: ByteArray, fileName: String, phone: String) {
        val directory = File(cacheDir, "shared_tickets").apply { mkdirs() }
        val cleanFileName = fileName.ifBlank { "pase-paso-del-rio.png" }
        val imageFile = File(directory, cleanFileName)
        imageFile.writeBytes(bytes)

        val imageUri = FileProvider.getUriForFile(
            this,
            "$packageName.fileprovider",
            imageFile,
        )

        val whatsappPhone = normalizeWhatsAppPhone(phone)
        val jid = if (whatsappPhone.isBlank()) "" else "$whatsappPhone@s.whatsapp.net"

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "image/png"
            setPackage("com.whatsapp")
            putExtra(Intent.EXTRA_STREAM, imageUri)
            if (jid.isNotBlank()) putExtra("jid", jid)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        try {
            startActivity(intent)
        } catch (error: ActivityNotFoundException) {
            val businessIntent = Intent(intent).apply { setPackage("com.whatsapp.w4b") }
            startActivity(businessIntent)
        }
    }

    private fun normalizeWhatsAppPhone(phone: String): String {
        val digits = phone.filter { it.isDigit() }
        return when {
            digits.length == 10 -> "57$digits"
            digits.startsWith("00") -> digits.drop(2)
            else -> digits
        }
    }
}
