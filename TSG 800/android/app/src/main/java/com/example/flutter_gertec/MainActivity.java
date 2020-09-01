package com.example.flutter_gertec;

import android.content.Intent;
import android.os.Bundle;
import android.os.PersistableBundle;

import java.io.IOException;
import java.util.List;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;
import java.util.ArrayList;

import br.com.gertec.gedi.exceptions.GediException;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import static android.hardware.Camera.Parameters.FLASH_MODE_ON;

public class MainActivity extends FlutterActivity {
    private GertecPrinter gertecPrinter;
    private MethodChannel.Result _result; // Instanciando uma variavel do tipo Result, para enviar o resultado para o
                                          // flutter
    private String resultado_Leitor; // Instanciando uma variavel que vai armazenar o resultado ao ler o codigo de
                                     // Barras no V1
    private IntentIntegrator qrScan;
    private String tipo; // Armazerna o tipo de codigo de barra que deseja ser lido
    private ArrayList<String> arrayListTipo;
    private static final String[] CHANNEL = { "samples.flutter.dev/gedi" }; // Canal de comunicação do flutter com o
                                                                            // Java
    private ConfigPrint configPrint = new ConfigPrint();
    private SatLib satLib;

    public void onCreate(@Nullable Bundle savedInstanceState, @Nullable PersistableBundle persistentState) {
        super.onCreate(savedInstanceState, persistentState);
        gertecPrinter.setConfigImpressao(configPrint);
    }

    @Override
    protected void onResume() {
        super.onResume();
        gertecPrinter = new GertecPrinter(this.getActivity());
        satLib = new SatLib(this);
    }

    public MainActivity() {
        super();
        this.arrayListTipo = new ArrayList<String>();
    }

    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL[0])
                .setMethodCallHandler((call, result) -> {
                    _result = result;
                    Intent intent;
                    switch (call.method) {
                        // Inicia o intent que vai fazer a leitura do Nfc
                        case "lerNfc":
                            try {
                                intent = new Intent(this, NfcLeitura.class);
                                startActivityForResult(intent, 111);
                            } catch (Exception e) {
                                e.printStackTrace();
                                result.notImplemented();
                            }
                            break;
                        // Inicia o intent que vai fazer a gravação no Cartão
                        // A mensagem que vai ser gravada é enviada do flutter
                        case "gravarNfc":
                            String mensagemGravar = call.argument("mensagemGravar");
                            try {
                                intent = new Intent(this, NfcGravacao.class);
                                intent.putExtra("mensagemGravar", mensagemGravar);
                                startActivity(intent);
                            } catch (Exception e) {
                                e.printStackTrace();
                                result.notImplemented();
                            }
                            break;
                        // Inicia o intent que vai fazer a formatação do cartão Nfc
                        case "formatarNfc":
                            try {
                                intent = new Intent(this, NfcFormatar.class);
                                startActivity(intent);
                            } catch (Exception e) {
                                e.printStackTrace();
                                result.notImplemented();
                            }
                            break;
                        // Inicia o intent que vai fazer o teste de leitura e gravação no cartão Nfc
                        case "testeNfc":
                            try {
                                intent = new Intent(this, NfcLerGravar.class);
                                startActivity(intent);
                            } catch (Exception e) {
                                e.printStackTrace();
                                result.notImplemented();
                            }
                            break;
                        case "checarImpressora":
                            try {
                                gertecPrinter.getStatusImpressora();
                                result.success(gertecPrinter.isImpressoraOK());
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                            break;
                        // Inicia a função que vai abrir o leitor de codigo de barra
                        // Do flutter ele vai pegar o "tipo" de codigo que deseja ser lido
                        case "leitorCodigov1":
                            try {
                                tipo = call.argument("tipoLeitura");
                                startCamera();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                            break;
                        // Verifica qual ação do Sat foi solicitada e retorna o codigo de resposta da
                        // Sefaz
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
                        // Inicia o intent que vai fazer a leitura do codigo de barras v2
                        // Ler qualquer tipo de codigo de barra
                        case "leitorCodigoV2":
                            intent = new Intent(this, CodigoBarrasV2.class);
                            startActivity(intent);
                            break;
                        // Esta função vai chamar as classes para realizar as impressões de acordo com
                        // as configurações recebidas do flutter
                        case "fimimpressao":
                            try {
                                gertecPrinter.ImpressoraOutput();
                                result.success("Finalizou impressao");
                            } catch (GediException e) {
                                e.printStackTrace();
                            }
                            break;
                        case "imprimir":
                            configPrint = new ConfigPrint();
                            try {
                                gertecPrinter.getStatusImpressora();
                                if (gertecPrinter.isImpressoraOK()) {
                                    String tipoImpressao = call.argument("tipoImpressao");
                                    String mensagem = call.argument("mensagem");
                                    switch (tipoImpressao) {
                                        case "Texto":
                                            String alinhar = call.argument("alinhar");
                                            int size = call.argument("size");
                                            String fontFamily = call.argument("font");
                                            List<Boolean> options = call.argument("options");
                                            configPrint.setItalico(options.get(1));
                                            configPrint.setSublinhado(options.get(2));
                                            configPrint.setNegrito(options.get(0));
                                            configPrint.setTamanho(size);
                                            configPrint.setFonte(fontFamily);
                                            configPrint.setAlinhamento(alinhar);
                                            gertecPrinter.setConfigImpressao(configPrint);
                                            gertecPrinter.imprimeTexto(mensagem);
                                            break;
                                        case "Imagem":
                                            gertecPrinter.setConfigImpressao(configPrint);
                                            gertecPrinter.imprimeImagem("invoice");
                                            break;
                                        case "CodigoDeBarra":
                                            int height = call.argument("height");
                                            int width = call.argument("width");
                                            String barCode = call.argument("barCode");
                                            configPrint.setAlinhamento("CENTER");
                                            gertecPrinter.setConfigImpressao(configPrint);
                                            gertecPrinter.imprimeBarCodeIMG(mensagem, height, width, barCode);
                                            break;
                                        case "TodasFuncoes":
                                            ImprimeTodasAsFucoes();
                                            break;
                                    }
                                    gertecPrinter.avancaLinha(40);
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                            break;
                    }
                });
    }

    private void startCamera() {
        this.arrayListTipo.add(tipo);
        qrScan = new IntentIntegrator(this);
        qrScan.setPrompt("Digitalizar o código " + tipo);
        qrScan.setBeepEnabled(true);
        qrScan.setBarcodeImageEnabled(true);
        qrScan.setTimeout(30000); // 30 * 1000 => 3 minuto
        qrScan.addExtra("FLASH_MODE_ON", FLASH_MODE_ON);
        qrScan.setDesiredBarcodeFormats(this.arrayListTipo);
        qrScan.initiateScan();
    }

    private void ImprimeTodasAsFucoes(){

        configPrint.setItalico(false);
        configPrint.setNegrito(true);
        configPrint.setTamanho(20);
        configPrint.setFonte("MONOSPACE");
        gertecPrinter.setConfigImpressao(configPrint);
        try {
            gertecPrinter.getStatusImpressora();
            // Imprimindo Imagem
            configPrint.setiWidth(300);
            configPrint.setiHeight(130);
            configPrint.setAlinhamento("CENTER");
            gertecPrinter.setConfigImpressao(configPrint);
            gertecPrinter.imprimeTexto("==[Iniciando Impressao Imagem]==");
            gertecPrinter.imprimeImagem("gertec");
            gertecPrinter.avancaLinha(10);
            gertecPrinter.imprimeTexto("====[Fim Impressão Imagem]====");
            gertecPrinter.avancaLinha(10);
            // Fim Imagem

            // Impressão Centralizada
            configPrint.setAlinhamento("CENTER");
            configPrint.setTamanho(30);
            gertecPrinter.setConfigImpressao(configPrint);
            gertecPrinter.imprimeTexto("CENTRALIZADO");
            gertecPrinter.avancaLinha(10);
            // Fim Impressão Centralizada

            // Impressão Esquerda
            configPrint.setAlinhamento("LEFT");
            configPrint.setTamanho(40);
            gertecPrinter.setConfigImpressao(configPrint);
            gertecPrinter.imprimeTexto("ESQUERDA");
            gertecPrinter.avancaLinha(10);
            // Fim Impressão Esquerda

            // Impressão Direita
            configPrint.setAlinhamento("RIGHT");
            configPrint.setTamanho(20);
            gertecPrinter.setConfigImpressao(configPrint);
            gertecPrinter.imprimeTexto("DIREITA");
            gertecPrinter.avancaLinha(10);
            // Fim Impressão Direita

            // Impressão Negrito
            configPrint.setNegrito(true);
            configPrint.setAlinhamento("LEFT");
            configPrint.setTamanho(20);
            gertecPrinter.setConfigImpressao(configPrint);
            gertecPrinter.imprimeTexto("=======[Escrita Netrigo]=======");
            gertecPrinter.avancaLinha(10);
            // Fim Impressão Negrito

            // Impressão Italico
            configPrint.setNegrito(false);
            configPrint.setItalico(true);
            configPrint.setAlinhamento("LEFT");
            configPrint.setTamanho(20);
            gertecPrinter.setConfigImpressao(configPrint);
            gertecPrinter.imprimeTexto("=======[Escrita Italico]=======");
            gertecPrinter.avancaLinha(10);
            // Fim Impressão Italico

            // Impressão Italico
            configPrint.setNegrito(false);
            configPrint.setItalico(false);
            configPrint.setSublinhado(true);
            configPrint.setAlinhamento("LEFT");
            configPrint.setTamanho(20);
            gertecPrinter.setConfigImpressao(configPrint);
            gertecPrinter.imprimeTexto("======[Escrita Sublinhado]=====");
            gertecPrinter.avancaLinha(10);
            // Fim Impressão Italico

            // Impressão BarCode 128
            configPrint.setNegrito(false);
            configPrint.setItalico(false);
            configPrint.setSublinhado(false);
            configPrint.setAlinhamento("CENTER");
            configPrint.setTamanho(20);
            gertecPrinter.setConfigImpressao(configPrint);
            gertecPrinter.imprimeTexto("====[Codigo Barras CODE 128]====");
            gertecPrinter.imprimeBarCode("12345678901234567890", 120,120,"CODE_128");
            gertecPrinter.avancaLinha(10);
            // Fim Impressão BarCode 128

            // Impressão Normal
            configPrint.setNegrito(false);
            configPrint.setItalico(false);
            configPrint.setSublinhado(true);
            configPrint.setAlinhamento("LEFT");
            configPrint.setTamanho(20);
            gertecPrinter.setConfigImpressao(configPrint);
            gertecPrinter.imprimeTexto("=======[Escrita Normal]=======");
            gertecPrinter.avancaLinha(10);
            // Fim Impressão Normal

            // Impressão Normal
            configPrint.setNegrito(false);
            configPrint.setItalico(false);
            configPrint.setSublinhado(true);
            configPrint.setAlinhamento("LEFT");
            configPrint.setTamanho(20);
            gertecPrinter.setConfigImpressao(configPrint);
            gertecPrinter.imprimeTexto("=========[BlankLine 50]=========");
            gertecPrinter.avancaLinha(50);
            gertecPrinter.imprimeTexto("=======[Fim BlankLine 50]=======");
            gertecPrinter.avancaLinha(10);
            // Fim Impressão Normal

            // Impressão BarCode 13
            configPrint.setNegrito(false);
            configPrint.setItalico(false);
            configPrint.setSublinhado(false);
            configPrint.setAlinhamento("CENTER");
            configPrint.setTamanho(20);
            gertecPrinter.setConfigImpressao(configPrint);
            gertecPrinter.imprimeTexto("=====[Codigo Barras EAN13]=====");
            gertecPrinter.imprimeBarCode("7891234567895", 120,120,"EAN_13");
            gertecPrinter.avancaLinha(10);
            // Fim Impressão BarCode 128

            // Impressão BarCode QrCode
            gertecPrinter.setConfigImpressao(configPrint);
            gertecPrinter.imprimeTexto("===[Codigo QrCode Gertec LIB]==");
            gertecPrinter.avancaLinha(10);
            gertecPrinter.imprimeBarCode("Gertec Developer Partner LIB", 240,240,"QR_CODE");

            configPrint.setNegrito(false);
            configPrint.setItalico(false);
            configPrint.setSublinhado(false);
            configPrint.setAlinhamento("CENTER");
            configPrint.setTamanho(20);
            gertecPrinter.imprimeTexto("===[Codigo QrCode Gertec IMG]==");
            gertecPrinter.imprimeBarCodeIMG("Gertec Developer Partner IMG", 240,240,"QR_CODE");

            gertecPrinter.avancaLinha(40);

        } catch (Exception e) {
            e.printStackTrace();
        }finally {
            try {
                gertecPrinter.ImpressoraOutput();
            } catch (GediException e) {
                e.printStackTrace();
            }
        }
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        // Pega os resultados obtidos dos intent e envia para o flutter
        // ("_result.success")
        if (requestCode == 111) {
            if (resultCode == RESULT_OK && data != null) {
                _result.success(data.getStringExtra("mensagemLeitura"));
            } else {
                _result.notImplemented();
            }
        } else {
            IntentResult intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data);
            if (intentResult != null) {
                // if qrcode has nothing in it
                if (intentResult.getContents() == null) {
                    resultado_Leitor = (this.tipo + ": Não foi possível ler o código.\n");
                } else {
                    // if qr contains data
                    try {
                        resultado_Leitor = this.tipo + ": " + intentResult.getContents() + "\n";
                    } catch (Exception e) {
                        e.printStackTrace();
                        resultado_Leitor = this.tipo + ": Erro " + e.getMessage() + "\n";
                    }
                }
            } else {
                resultado_Leitor = this.tipo + ": Não foi possível fazer a leitura.\n";
            }
            _result.success(resultado_Leitor);
            this.arrayListTipo.clear();
        }
    }
}