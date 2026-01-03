package com.fullqueso.dslqueso

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Typeface
import android.os.Bundle
import android.os.IBinder
import android.os.RemoteException
import android.util.Log
import com.google.gson.Gson
import com.nexgo.oaf.apiv3.APIProxy
import com.nexgo.oaf.apiv3.DeviceEngine
import com.nexgo.oaf.apiv3.device.printer.AlignEnum
import com.nexgo.oaf.apiv3.device.printer.OnPrintListener
import com.nexgo.oaf.apiv3.device.printer.Printer
import cn.nexgo.smartconnect.ISmartconnectService
import cn.nexgo.smartconnect.listener.ITransactionResultListener
import cn.nexgo.smartconnect.model.TransactionRequestEntity
import cn.nexgo.smartconnect.model.TransactionResultEntity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "nexgo_service"
    }

    private var smartService: ISmartconnectService? = null
    private var deviceEngine: DeviceEngine? = null
    private var printer: Printer? = null

    // =====================================================================
    //  CONFIGURACIÓN DEL METHOD CHANNEL
    // =====================================================================
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "bindService" -> {
                        bindTerminalService(result)
                    }

                    "doTransaction" -> {
                        doTransaction(
                            amount = call.argument<String>("amount"),
                            cardholderId = call.argument<String>("cardholderId"),
                            waiterNum = call.argument<String>("waiterNum"),
                            referenceNo = call.argument<String>("referenceNo"),
                            transType = call.argument<Int>("transType") ?: 1,
                            result = result
                        )
                    }

                    "printReceipt" -> {
                        printReceipt(
                            fullName = call.argument<String>("fullName"),
                            ciClient = call.argument<String>("ciClient"),
                            amount = call.argument<String>("amount"),
                            ctaContrato = call.argument<String>("ctaContrato"),
                            referenceNo = call.argument<String>("referenceNo"),
                            fecha = call.argument<String>("fecha"),
                            hora = call.argument<String>("hora"),
                            lote = call.argument<String>("lote"),
                            afiliado = call.argument<String>("afiliado"),
                            terminal = call.argument<String>("terminal"),
                            serial = call.argument<String>("serial"),
                            trace = call.argument<String>("trace"),
                            result = result
                        )
                    }

                    "printerTest" -> {
                        val fechaTest = call.argument<String>("fecha")
                        val horaTest = call.argument<String>("hora")
                        printerTest(fechaTest, horaTest, this, result)
                    }

                    "printOrdenServicio" -> {
                        printOrdenServicio(
                            ticket = call.argument<String>("ticket"),
                            cedula = call.argument<String>("cedula"),
                            cliente = call.argument<String>("cliente"),
                            fechaHora = call.argument<String>("fechaHora"),
                            operador = call.argument<String>("operador"),
                            result = result
                        )
                    }

                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    // =====================================================================
    //  BIND DEL SERVICIO SMARTCONNECT PARA TRANSACCIONES
    // =====================================================================
    private fun bindTerminalService(result: MethodChannel.Result) {
        Log.d("DSL_DEBUG", "=== BINDING SERVICE ===")
        val intent = Intent().apply {
            component = ComponentName(
                "cn.nexgo.veslc",
                "cn.nexgo.inbas.smartconnect.SmartConnectService"
            )
        }

        val ok = bindService(intent, serviceConnection, BIND_AUTO_CREATE)
        Log.d("DSL_DEBUG", "bindService returned: $ok")
        result.success(ok)
    }

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            Log.d("DSL_DEBUG", "=== SERVICE CONNECTED ===")
            Log.d("DSL_DEBUG", "Component: ${name?.className}")
            smartService = ISmartconnectService.Stub.asInterface(binder)
            Log.d("DSL_DEBUG", "smartService assigned: ${smartService != null}")
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            Log.w("DSL_DEBUG", "=== SERVICE DISCONNECTED ===")
            smartService = null
        }
    }

    // =====================================================================
    //  HACER TRANSACCIÓN
    // =====================================================================
    private fun doTransaction(
        amount: String?,
        cardholderId: String?,
        waiterNum: String?,
        referenceNo: String?,
        transType: Int,
        result: MethodChannel.Result
    ) {
        Log.d("DSL_DEBUG", "=== INICIANDO doTransaction ===")
        Log.d("DSL_DEBUG", "Amount: $amount")
        Log.d("DSL_DEBUG", "CardHolderId: $cardholderId")
        Log.d("DSL_DEBUG", "WaiterNum: $waiterNum")
        Log.d("DSL_DEBUG", "ReferenceNo: $referenceNo")
        Log.d("DSL_DEBUG", "TransType: $transType")

        // VALIDAR QUE EL SERVICIO ESTÉ CONECTADO
        if (smartService == null) {
            Log.e("DSL_ERROR", "smartService is NULL - Service not bound!")
            result.error("SERVICE_NOT_BOUND", "El servicio DSL no está conectado. Reinicie la aplicación.", null)
            return
        }

        Log.d("DSL_DEBUG", "smartService OK - Creating request...")

        val req = TransactionRequestEntity().apply {
            this.amount = amount
            this.cardHolderId = cardholderId
            this.waiterNumber = waiterNum
            this.referenceNumber = referenceNo
            this.transacitonType = transType
        }

        Log.d("DSL_DEBUG", "Request created - Calling transactionRequest...")

        try {
            smartService!!.transactionRequest(req, object : ITransactionResultListener.Stub() {
                override fun onTransactionResult(trx: TransactionResultEntity?) {
                    Log.d("DSL_DEBUG", "=== RESPUESTA RECIBIDA ===")
                    Log.d("DSL_DEBUG", "Result: ${trx?.result}")
                    Log.d("DSL_DEBUG", "Response: ${trx?.responseMessage}")

                    val gson = Gson()
                    val json = gson.toJson(trx)

                    Log.d("DSL_DEBUG", "JSON: $json")

                    if (trx?.result == 0) {
                        result.success(json)
                    } else {
                        result.error("TRANSACTION_FAILED", json, null)
                    }
                }
            })
            Log.d("DSL_DEBUG", "transactionRequest called - waiting for response...")
        } catch (e: Exception) {
            Log.e("DSL_ERROR", "Exception in transactionRequest: ${e.message}")
            e.printStackTrace()
            result.error("REMOTE_EXCEPTION", e.message, null)
        }
    }

    // =====================================================================
    //  PRINT RECEIPT COMPLETO (COMPROBANTE REAL)
    // =====================================================================
    private fun printReceipt(
        fullName: String?,
        ciClient: String?,
        amount: String?,
        ctaContrato: String?,
        referenceNo: String?,
        fecha: String?,
        hora: String?,
        lote: String?,
        afiliado: String?,
        terminal: String?,
        serial: String?,
        trace: String?,
        result: MethodChannel.Result
    ) {
        try {
            initPrinter()

            printer?.apply {
                appendPrnStr("--------------------------------", 24, AlignEnum.CENTER, false)
                appendPrnStr("COMPROBANTE DE PAGO", 24, AlignEnum.CENTER, true)
                appendPrnStr("--------------------------------\n", 24, AlignEnum.CENTER, false)

                appendPrnStr("Cliente: $fullName", 24, AlignEnum.LEFT, false)
                appendPrnStr("CI: $ciClient", 24, AlignEnum.LEFT, false)
                appendPrnStr("Monto: $amount", 24, AlignEnum.LEFT, false)
                // appendPrnStr("Contrato: $ctaContrato", 24, AlignEnum.LEFT, false)?
                appendPrnStr("Referencia: $referenceNo", 24, AlignEnum.LEFT, false)
                appendPrnStr("Fecha: $fecha $hora", 24, AlignEnum.LEFT, false)
                appendPrnStr("Lote: $lote", 24, AlignEnum.LEFT, false)
                // appendPrnStr("Afiliado: $afiliado", 24, AlignEnum.LEFT, false)
                appendPrnStr("Terminal: $terminal", 24, AlignEnum.LEFT, false)
                appendPrnStr("Serial: $serial", 24, AlignEnum.LEFT, false)
                appendPrnStr("Trace: $trace\n\n", 24, AlignEnum.LEFT, false)

                startPrint(false, object : OnPrintListener {
                    override fun onPrintResult(code: Int) {
                        if (code == 0) {
                            result.success("printed")
                        } else {
                            result.error("PRINT_ERROR", "Código: $code", null)
                        }
                    }
                })
            }
        } catch (e: Exception) {
            result.error("PRINT_EXCEPTION", e.message, null)
        }
    }

    // =====================================================================
    //  PRINTER TEST
    // =====================================================================
    private fun printerTest(
        fecha: String?,
        hora: String?,
        context: Context,
        result: MethodChannel.Result
    ) {
        initPrinter()

        try {
            // ================================
            //  CARGAR LOGO DESDE ASSETS
            // ================================
            val inputStream = context.assets.open("flutter_assets/assets/images/logo-dg-blanco.png")
            val logo: Bitmap = BitmapFactory.decodeStream(inputStream)
            inputStream.close()

            // ================================
            //  CONFIGURACIÓN PREVIA
            // ================================
            printer?.apply {
                setTypeface(Typeface.DEFAULT)
                setLetterSpacing(6)
                initPrinter()

                // ================================
                //  LOGO CENTRADO
                // ================================
                appendImage(logo, AlignEnum.CENTER)
                appendPrnStr("\n", 24, AlignEnum.LEFT, false)

                // ================================
                // FECHA + HORA (MISMA LÍNEA)
                // ================================
                val fechaHora = "$fecha           $hora"
                appendPrnStr(fechaHora, 24, AlignEnum.CENTER, false)
                appendPrnStr("\n\n", 24, AlignEnum.LEFT, false)

                // ================================
                // ITEMS COMO TU EJEMPLO UI
                // ================================
                appendPrnStr("Item 1:                 Valor 1", 24, AlignEnum.LEFT, false)
                appendPrnStr("\n", 24, AlignEnum.LEFT, false)

                appendPrnStr("Item 2:                 Valor 2", 24, AlignEnum.LEFT, false)
                appendPrnStr("\n", 24, AlignEnum.LEFT, false)

                appendPrnStr("Item 3:                 Valor 3", 24, AlignEnum.LEFT, false)
                appendPrnStr("\n\n", 24, AlignEnum.LEFT, false)

                // ================================
                // TOTAL CENTRADO
                // ================================
                appendPrnStr("1000.00 Bs", 28, AlignEnum.CENTER, true)
                appendPrnStr("\n\n", 24, AlignEnum.LEFT, false)

                // ================================
                // MENSAJE FINAL
                // ================================
                appendPrnStr("------ ESTO ES UNA PRUEBA -----", 24, AlignEnum.CENTER, true)
                appendPrnStr("\n\n\n", 24, AlignEnum.LEFT, false)
                appendPrnStr("\n\n", 24, AlignEnum.LEFT, false)

                // ================================
                // IMPRIMIR
                // ================================
                startPrint(false, object : OnPrintListener {
                    override fun onPrintResult(retCode: Int) {
                        runOnUiThread {
                            when (retCode) {
                                -1005 -> result.error("PRINT_ERROR", "Impresora sin papel", null)
                                0 -> result.success("printer_test_ok")
                                else -> result.error("PRINT_ERROR", "Código: $retCode", null)
                            }
                        }
                    }
                })
            }
        } catch (e: IOException) {
            e.printStackTrace()
            result.error("ASSET_ERROR", "Error cargando logo: ${e.message}", null)
        }
    }

    // =====================================================================
    //  PRINT ORDEN DE SERVICIO
    // =====================================================================
    private fun printOrdenServicio(
        ticket: String?,
        cedula: String?,
        cliente: String?,
        fechaHora: String?,
        operador: String?,
        result: MethodChannel.Result
    ) {
        try {
            initPrinter()

            printer?.apply {
                appendPrnStr("================================", 24, AlignEnum.CENTER, false)
                appendPrnStr("ORDEN $ticket", 28, AlignEnum.CENTER, true)
                appendPrnStr("================================\n", 24, AlignEnum.CENTER, false)

                appendPrnStr("ORDEN: $ticket", 24, AlignEnum.LEFT, false)
                appendPrnStr("Cedula: $cedula", 24, AlignEnum.LEFT, false)
                appendPrnStr("Cliente: $cliente", 24, AlignEnum.LEFT, false)
                appendPrnStr("Fecha: $fechaHora", 24, AlignEnum.LEFT, false)
                appendPrnStr("Operado por: $operador\n\n\n\n\n", 24, AlignEnum.LEFT, false)

                startPrint(false, object : OnPrintListener {
                    override fun onPrintResult(code: Int) {
                        if (code == 0) {
                            result.success("printed")
                        } else {
                            result.error("PRINT_ERROR", "Código: $code", null)
                        }
                    }
                })
            }
        } catch (e: Exception) {
            result.error("PRINT_EXCEPTION", e.message, null)
        }
    }

    // =====================================================================
    //  INIT PRINTER
    // =====================================================================
    private fun initPrinter() {
        if (deviceEngine == null) {
            deviceEngine = APIProxy.getDeviceEngine(this)
        }
        printer = deviceEngine?.printer
    }
}
