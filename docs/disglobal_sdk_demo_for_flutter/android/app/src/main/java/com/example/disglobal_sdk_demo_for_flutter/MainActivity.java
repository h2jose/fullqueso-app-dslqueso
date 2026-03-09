package com.example.disglobal_sdk_demo_for_flutter;

import androidx.annotation.NonNull;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.os.Bundle;
import android.os.RemoteException;
import android.util.Log;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import com.google.gson.Gson;

import com.nexgo.oaf.apiv3.APIProxy;
import com.nexgo.oaf.apiv3.DeviceEngine;
import com.nexgo.oaf.apiv3.device.printer.Printer;
import com.nexgo.oaf.apiv3.device.printer.AlignEnum;
import com.nexgo.oaf.apiv3.device.printer.OnPrintListener;

import cn.nexgo.smartconnect.ISmartconnectService;
import cn.nexgo.smartconnect.listener.ITransactionResultListener;
import cn.nexgo.smartconnect.model.TransactionRequestEntity;
import cn.nexgo.smartconnect.model.TransactionResultEntity;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import java.io.InputStream;
import java.io.IOException;
import android.graphics.Typeface;


public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "nexgo_service";

    private ISmartconnectService smartService;
    private DeviceEngine deviceEngine;
    private Printer printer;

    // =====================================================================
    //  CONFIGURACIÓN DEL METHOD CHANNEL
    // =====================================================================
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {

                    switch (call.method) {

                        case "bindService":
                            bindTerminalService(result);
                            break;

                        case "doTransaction":
                            doTransaction(
                                    call.argument("amount"),
                                    call.argument("cardholderId"),
                                    call.argument("waiterNum"),
                                    call.argument("referenceNo"),
                                    call.argument("transType"),
                                    result
                            );
                            break;

                        case "printReceipt":
                            printReceipt(
                                    call.argument("fullName"),
                                    call.argument("ciClient"),
                                    call.argument("amount"),
                                    call.argument("ctaContrato"),
                                    call.argument("referenceNo"),
                                    call.argument("fecha"),
                                    call.argument("hora"),
                                    call.argument("lote"),
                                    call.argument("afiliado"),
                                    call.argument("terminal"),
                                    call.argument("serial"),
                                    call.argument("trace"),
                                    result
                            );
                            break;

                        case "printerTest":
                            String fechaTest = call.argument("fecha");
                            String horaTest = call.argument("hora");
                            printerTest(fechaTest, horaTest, MainActivity.this, result);
                            break;

                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

    // =====================================================================
    //  BIND DEL SERVICIO SMARTCONNECT PARA TRANSACCIONES
    // =====================================================================
    private void bindTerminalService(MethodChannel.Result result) {
        Intent intent = new Intent();
        intent.setComponent(new ComponentName(
                "cn.nexgo.veslc",
                "cn.nexgo.inbas.smartconnect.SmartConnectService"
        ));

        boolean ok = bindService(intent, serviceConnection, BIND_AUTO_CREATE);

        result.success(ok);
    }

    private final ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder binder) {
            smartService = ISmartconnectService.Stub.asInterface(binder);
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            smartService = null;
        }
    };

    // =====================================================================
    //  HACER TRANSACCIÓN
    // =====================================================================
    private void doTransaction(
            String amount,
            String cardholderId,
            String waiterNum,
            String referenceNo,
            int transType,
            MethodChannel.Result result
    ) {

        TransactionRequestEntity req = new TransactionRequestEntity();
        req.setAmount(amount);
        req.setCardHolderId(cardholderId);
        req.setWaiterNumber(waiterNum);
        req.setReferenceNumber(referenceNo);
        req.setTransacitonType(transType);

        try {
            smartService.transactionRequest(req, new ITransactionResultListener.Stub() {
                @Override
                public void onTransactionResult(TransactionResultEntity trx) {
                    Gson gson = new Gson();
                    String json = gson.toJson(trx);

                    if (trx.getResult() == 0) {
                        result.success(json);
                    } else {
                        result.error(json, json, null);
                    }
                }
            });

        } catch (Exception e) {
            result.error("REMOTE_EXCEPTION", e.getMessage(), null);
        }
    }

    // =====================================================================
    //  PRINT RECEIPT COMPLETO (COMPROBANTE REAL)
    // =====================================================================
    private void printReceipt(
        String fullName,
        String ciClient,
        String amount,
        String ctaContrato,
        String referenceNo,
        String fecha,
        String hora,
        String lote,
        String afiliado,
        String terminal,
        String serial,
        String trace,
        MethodChannel.Result result
        ) {

            try {
                initPrinter();

                printer.appendPrnStr("--------------------------------", 24, AlignEnum.CENTER, false);
                printer.appendPrnStr("COMPROBANTE DE PAGO", 24, AlignEnum.CENTER, true);
                printer.appendPrnStr("--------------------------------\n", 24, AlignEnum.CENTER, false);

                printer.appendPrnStr("Cliente: " + fullName, 24, AlignEnum.LEFT, false);
                printer.appendPrnStr("CI: " + ciClient, 24, AlignEnum.LEFT, false);
                printer.appendPrnStr("Monto: " + amount, 24, AlignEnum.LEFT, false);
                printer.appendPrnStr("Contrato: " + ctaContrato, 24, AlignEnum.LEFT, false);
                printer.appendPrnStr("Referencia: " + referenceNo, 24, AlignEnum.LEFT, false);
                printer.appendPrnStr("Fecha: " + fecha + " " + hora, 24, AlignEnum.LEFT, false);
                printer.appendPrnStr("Lote: " + lote, 24, AlignEnum.LEFT, false);
                printer.appendPrnStr("Afiliado: " + afiliado, 24, AlignEnum.LEFT, false);
                printer.appendPrnStr("Terminal: " + terminal, 24, AlignEnum.LEFT, false);
                printer.appendPrnStr("Serial: " + serial, 24, AlignEnum.LEFT, false);
                printer.appendPrnStr("Trace: " + trace + "\n\n", 24, AlignEnum.LEFT, false);

                printer.startPrint(false, new OnPrintListener() {
                    @Override
                    public void onPrintResult(int code) {
                        if (code == 0) {
                            result.success("printed");
                        } else {
                            result.error("PRINT_ERROR", "Código: " + code, null);
                        }
                    }
                });

            } catch (Exception e) {
                result.error("PRINT_EXCEPTION", e.getMessage(), null);
            }
        }


    // =====================================================================
    //  PRINTER TEST
    // =====================================================================
    private void printerTest(String fecha, String hora, Context context, MethodChannel.Result result) {

        initPrinter();

        try {

            // ================================
            //  CARGAR LOGO DESDE ASSETS
            // ================================
            InputStream inputStream = context.getAssets().open("flutter_assets/assets/images/logo-dg-blanco.png");
            Bitmap logo = BitmapFactory.decodeStream(inputStream);
            inputStream.close();

            // ================================
            //  CONFIGURACIÓN PREVIA
            // ================================
            printer.setTypeface(Typeface.DEFAULT);
            printer.setLetterSpacing(6);
            printer.initPrinter();

            // ================================
            //  LOGO CENTRADO
            // ================================
            if (logo != null) {
                printer.appendImage(logo, AlignEnum.CENTER);
            }

            printer.appendPrnStr("\n", 24, AlignEnum.LEFT, false);

            // ================================
            // FECHA + HORA (MISMA LÍNEA)
            // ================================
            String fechaHora = fecha + "           " + hora;
            printer.appendPrnStr(fechaHora, 24, AlignEnum.CENTER, false);
            printer.appendPrnStr("\n\n", 24, AlignEnum.LEFT, false);

            // ================================
            // ITEMS COMO TU EJEMPLO UI
            // ================================
            printer.appendPrnStr("Item 1:                 Valor 1", 24, AlignEnum.LEFT, false);
            printer.appendPrnStr("\n", 24, AlignEnum.LEFT, false);

            printer.appendPrnStr("Item 2:                 Valor 2", 24, AlignEnum.LEFT, false);
            printer.appendPrnStr("\n", 24, AlignEnum.LEFT, false);

            printer.appendPrnStr("Item 3:                 Valor 3", 24, AlignEnum.LEFT, false);
            printer.appendPrnStr("\n\n", 24, AlignEnum.LEFT, false);

            // ================================
            // TOTAL CENTRADO
            // ================================
            printer.appendPrnStr("1000.00 Bs", 28, AlignEnum.CENTER, true);
            printer.appendPrnStr("\n\n", 24, AlignEnum.LEFT, false);

            // ================================
            // MENSAJE FINAL
            // ================================
            printer.appendPrnStr("------ ESTO ES UNA PRUEBA -----", 24, AlignEnum.CENTER, true);
            printer.appendPrnStr("\n\n\n", 24, AlignEnum.LEFT, false);
            printer.appendPrnStr("\n\n", 24, AlignEnum.LEFT, false);

            // ================================
            // IMPRIMIR
            // ================================
            printer.startPrint(false, new OnPrintListener() {

                @Override
                public void onPrintResult(final int retCode) {
                    runOnUiThread(() -> {
                        if (retCode == -1005) {
                            result.error("PRINT_ERROR", "Impresora sin papel", null);
                        } else if (retCode == 0) {
                            result.success("printer_test_ok");
                        } else {
                            result.error("PRINT_ERROR", "Código: " + retCode, null);
                        }
                    });
                }
            });

        } catch (IOException e) {
            e.printStackTrace();
            result.error("ASSET_ERROR", "Error cargando logo: " + e.getMessage(), null);
        }
    }



    // =====================================================================
    //  INIT PRINTER
    // =====================================================================
    private void initPrinter() {
        if (deviceEngine == null) {
            deviceEngine = APIProxy.getDeviceEngine(this);
        }
        printer = deviceEngine.getPrinter();
    }

}
