package com.example.flutter_gBot;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.KeyEvent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.example.flutter_gBot.Kiosk.KioskMode;
import com.example.flutter_gBot.services.LedUtil;
import com.example.flutter_gBot.services.ServiceResultReceiver;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Map;

import CodigoBarras.LeituraCodigoActivity;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static com.example.flutter_gBot.services.ReadCodeService.SHOW_RESULT;

public class MainActivity extends FlutterActivity implements ServiceResultReceiver.Receiver {
    private ServiceResultReceiver mServiceResultReceiver;

    LeituraCodigoActivity leituraCodigoActivity;
    Intent intentSitef = new Intent("br.com.softwareexpress.sitef.msitef.ACTIVITY_CLISITEF"); // Instanciando o Intent
    // do M-Sitef -- É
    // importante que o
    // programa "Sitef Demo"
    // esteja em execução.

    KioskMode kioskMode;
    public static MethodChannel.Result _result; // Instanciando uma variavel do tipo Result, para enviar o resultado para o flutter

    public static MethodChannel.Result _resultBarCode; // Instanciando uma variavel do tipo Result, para enviar o resultado para o flutter

    // Barras no V1
    private ArrayList<String> arrayListTipo;
    private static final String[] CHANNEL = {"samples.flutter.dev/flutterGBot", "samples.flutter.dev/barcode", "samples.flutter.dev/led"}; // Canal de comunicação do flutter com o
    // Java

    private SatLib satLib;

    boolean sensorStart = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        leituraCodigoActivity = new LeituraCodigoActivity(this);
    }

    @Override
    protected void onResume() {
        super.onResume();

        satLib = new SatLib(this);
    }

    public MainActivity() {
        super();
        this.arrayListTipo = new ArrayList<String>();
    }

    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        kioskMode = new KioskMode(this);
        mServiceResultReceiver = new ServiceResultReceiver(new Handler());
        mServiceResultReceiver.setReceiver(this);


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL[1])
                .setMethodCallHandler((call, result) -> {
                            _resultBarCode = result;
                            switch (call.method) {
                                // ligar ou desligar o leitor de codigo de barras
                                case "leitorCodigoBarra":
                                    String str = call.argument("acao");
                                    if (call.argument("acao").equals("ativar")) {
                                        leituraCodigoActivity.StartService();
                                    } else if (call.argument("acao").equals("desativar")) {
                                        leituraCodigoActivity.StopService();
                                    }
                                    break;
                            }
                        }
                );

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL[2])
                .setMethodCallHandler((call, result) -> {
                            switch (call.method) {
                                // ligar ou desligar o led do leitor
                                case "led":
                                    if (call.argument("acao").equals("ativar")) {
                                        LedUtil.setRedLed();
                                        result.success("");
                                    } else if (call.argument("acao").equals("desativar")) {
                                        result.success("");
                                        LedUtil.setOffLed();
                                    }
                                    break;
                            }
                        }
                );

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL[0])
                .setMethodCallHandler((call, result) -> {
                            _result = result;
                            Map<String, String> map;
                            Bundle bundle = new Bundle();
                            switch (call.method) {
                                // Inicia ou pausa o modo Kiosk
                                case "kioskMode":
                                    try {
                                        if (call.argument("acao").equals("ativar")) {
                                            kioskMode.startKiosMode();
                                        } else if (call.argument("acao").equals("desativar")) {
                                            kioskMode.stopKioskMode();
                                        }
                                        result.success("");
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                        result.notImplemented();
                                    }
                                    break;
                                // Inicia ou pausa o modo Sensor
                                case "sensorGbot":
                                    if (call.argument("acao").equals("ativar")) {
                                        sensorStart = true;
                                    } else if (call.argument("acao").equals("desativar")) {
                                        sensorStart = false;
                                    }
                                    break;
                                // Inicia o intent que vai enviar o Map recebido do flutter para o M-Sitef e
                                // após isto pegar seu retorno
                                case "realizarAcaoMsitef":
                                    map = call.argument("mapMsiTef");
                                    for (String key : map.keySet()) {
                                        bundle.putString(key, map.get(key));
                                    }
                                    intentSitef.putExtras(bundle);
                                    startActivityForResult(intentSitef, 4321);
                                    break;
                                // "satLib" possui todas funções do Sat
                                case "AtivarSAT":
                                    _result.success(satLib.ativarSat(call.argument("codigoAtivar"), call.argument("cnpj"),
                                            call.argument("random")));
                                    break;
                                case "AssociarSAT":
                                    _result.success(satLib.associarSat(call.argument("cnpj"), call.argument("cnpjSoft"),
                                            call.argument("codigoAtivar"), call.argument("assinatura"),
                                            call.argument("random")));
                                    break;
                                case "ConsultarSat":
                                    _result.success(satLib.consultarSat(call.argument("random")));
                                    break;
                                case "ConsultarStatusOperacional":
                                    String a = call.argument("codigoAtivar");
                                    int b = call.argument("random");
                                    _result.success(satLib.consultarStatusOperacional(call.argument("random"),
                                            call.argument("codigoAtivar")));
                                    break;
                                case "EnviarTesteFim":
                                    _result.success(satLib.enviarTesteFim(call.argument("codigoAtivar"),
                                            call.argument("xmlVenda"), call.argument("random")));
                                    break;
                                case "EnviarTesteVendas":
                                    _result.success(satLib.enviarTesteVendas(call.argument("codigoAtivar"),
                                            call.argument("xmlVenda"), call.argument("random")));
                                    break;
                                case "CancelarUltimaVenda":
                                    _result.success(satLib.cancelarUltimaVenda(call.argument("codigoAtivar"),
                                            call.argument("xmlCancelamento"), call.argument("chaveCancelamento"),
                                            call.argument("random")));
                                    break;
                                case "ConsultarNumeroSessao":
                                    _result.success(satLib.consultarNumeroSessao(call.argument("codigoAtivar"),
                                            call.argument("chaveSessao"), call.argument("random")));
                                    break;
                                case "EnviarConfRede":
                                    try {
                                        _result.success(satLib.enviarConfRede(call.argument("random"),
                                                call.argument("dadosXml"), call.argument("codigoAtivar")));
                                    } catch (IOException e) {
                                        e.printStackTrace();
                                    }
                                    break;
                                case "TrocarCodAtivacao":
                                    _result.success(satLib.trocarCodAtivacao(call.argument("codigoAtivar"), call.argument("op"),
                                            call.argument("codigoAtivacaoNovo"), call.argument("random")));
                                    break;
                                case "BloquearSat":
                                    _result.success(satLib.bloquearSat(call.argument("codigoAtivar"), call.argument("random")));
                                    break;
                                case "DesbloquearSat":
                                    _result.success(
                                            satLib.desbloquearSat(call.argument("codigoAtivar"), call.argument("random")));
                                    break;
                                case "ExtrairLog":
                                    _result.success(satLib.extrairLog(call.argument("codigoAtivar"), call.argument("random")));
                                    break;
                                case "AtualizarSoftware":
                                    _result.success(
                                            satLib.atualizarSoftware(call.argument("codigoAtivar"), call.argument("random")));
                                    break;
                                case "Versao":
                                    _result.success(satLib.versao());
                                    break;
                            }
                        }
                );
    }


    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (sensorStart) {
            switch (event.getKeyCode()) {
                case KeyEvent.KEYCODE_F4:
                    Date dt = new Date();
                    String currentTimeString = String.valueOf(dt.getHours()) + ":" + String.valueOf(dt.getMinutes()) + ":" + String.valueOf(dt.getSeconds());
                    _result.success(currentTimeString + " - Pessoa identificada à frente do equipamento.");
                    break;
            }
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public void onReceiveResult(int resultCode, Bundle resultData) {
        switch (resultCode) {
            case SHOW_RESULT:
                if (resultData != null) {
                    _result.success(resultData.getString("data"));
                } else {
                    _result.notImplemented();
                }
                break;
        }
    }

    // O M-Sitef não retorna um json como resposta, logo é criado um json com a
    // reposta do Sitef.
    public String respSitefToJson(Intent data) throws JSONException {
        JSONObject json = new JSONObject();
        json.put("CODRESP", data.getStringExtra("CODRESP"));
        json.put("COMP_DADOS_CONF", data.getStringExtra("COMP_DADOS_CONF"));
        json.put("CODTRANS", data.getStringExtra("CODTRANS"));
        json.put("VLTROCO", data.getStringExtra("VLTROCO"));
        json.put("REDE_AUT", data.getStringExtra("REDE_AUT"));
        json.put("BANDEIRA", data.getStringExtra("BANDEIRA"));
        json.put("NSU_SITEF", data.getStringExtra("NSU_SITEF"));
        json.put("NSU_HOST", data.getStringExtra("NSU_HOST"));
        json.put("COD_AUTORIZACAO", data.getStringExtra("COD_AUTORIZACAO"));
        json.put("NUM_PARC", data.getStringExtra("NUM_PARC"));
        json.put("TIPO_PARC", data.getStringExtra("TIPO_PARC"));
        // Quando passa esta informação para o flutter os break lines são perdidos logo
        // é necessario para outro dado para representar no caso %%
        json.put("VIA_ESTABELECIMENTO", data.getStringExtra("VIA_ESTABELECIMENTO"));
        json.put("VIA_CLIENTE", data.getStringExtra("VIA_CLIENTE"));
        return json.toString();
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        // Pega os resultados obtidos dos intent e envia para o flutter
        // ("_result.success")
        if (requestCode == 4321) {
            if (resultCode == RESULT_OK || resultCode == RESULT_CANCELED && data != null) {
                try {
                    _result.success(respSitefToJson(data));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                _result.notImplemented();
            }
        }
    }
}
