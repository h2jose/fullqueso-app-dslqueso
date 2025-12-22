package com.fullqueso.dslqueso

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
            val i = Intent(context, MainActivity::class.java)
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(i)
        }
    }
}


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.fullqueso.ubiiqueso/channel"
    private var pendingResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
                if (call.method == "getResponse") {
                    pendingResult = result
                    val transactionType = call.argument<String>("transType") // 'PAYMENT' or 'SETTLEMENT'
                    val amount = call.argument<String>("amount")
                    val logon = call.argument<String>("logon")
                    val ticket = call.argument<String>("ticket")
                    val trans_id = call.argument<String>("trans_id")
                    launchIntent(transactionType, amount, logon, ticket, trans_id)
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    private fun launchIntent(transactionType: String?, amount: String?, logon: String?, ticket: String?, trans_id: String?) {
        val intent = Intent("com.ubiipagos.pos.views.activity.MainActivityView.launchFromOutside")

       // println("Launching intent with transactionType: $transactionType, amount: $amount, logon: $logon, ticket: $ticket, trans_id: $trans_id")

        if (transactionType == "PAYMENT") {
            intent.putExtra("TRANS_TYPE", "PAYMENT")
            intent.putExtra("TRANS_AMOUNT", amount)
            intent.putExtra("LOGON", logon)
            intent.putExtra("ORDER_NUM", ticket)
            intent.putExtra("TRANS_ID", trans_id)
        } else if (transactionType == "SETTLEMENT") {
            intent.putExtra("TRANS_TYPE", "SETTLEMENT");
            intent.putExtra("SETTLE_TYPE", "N");
        }

        try {
            startActivityForResult(intent, 1)  // El código 1 es para el resultado
        } catch (e: Exception) {
            pendingResult?.error("ERROR", "Failed to launch intent", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == 1) {
            pendingResult?.let { result ->
                val responseMap = mutableMapOf<String, Any?>()

                if (data != null) {
                    val extras = data.extras
                    extras?.keySet()?.forEach { key ->
                        responseMap[key] = extras.get(key)
                    }
                    result.success(responseMap)
                } else {
                    result.error("NO_DATA", "No data received", null)
                }
                pendingResult = null
            }
        }
    }
}

