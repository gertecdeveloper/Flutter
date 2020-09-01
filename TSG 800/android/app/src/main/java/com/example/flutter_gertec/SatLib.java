package com.example.flutter_gertec;

import android.content.Context;
import android.util.Base64;

import com.phi.gertec.sat.satger.SatGerLib;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.List;

public class SatLib {
    public static SatGerLib serialComms;

    private String funcao;
    Context context;
    private File arquivoXml = new File("mnt/sdcard/Gertec/teste_fim_a_fim.xml");
    private File arquivoXmlVendas = new File("mnt/sdcard/Gertec/EnviarDadosVenda.xml");
    private File arquivoXmlCancelamento = new File("mnt/sdcard/Gertec/CancelarVenda.xml");

    public SatLib(Context context) {
        this.context = context;
        serialComms = new SatGerLib(context, dataReceivedListener); // Inicializando
    }

    public String enviarConfRede(int random, List<String> dadosXml, String codigoAtivacao) throws IOException {
        String packageName = "com.example.flutter_gertec";
        String caminhoXML = "data/data/" + packageName + "/configRede.xml";
        File file = new File(caminhoXML);
        // Se o arquivo não existe, então cria
        if (!file.exists()) {
            file.createNewFile();
        }
        // Começa a escrever no arquivo
        FileWriter fw = new FileWriter(file.getAbsoluteFile());
        BufferedWriter bw = new BufferedWriter(fw);
        bw.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        bw.newLine();
        bw.write("<config>");
        bw.newLine();
        bw.write("<tipoInter>ETHE</tipoInter>");
        bw.newLine();
        bw.write(dadosXml.get(0));
        bw.newLine();

        if (!dadosXml.get(1).equals("")) {
            bw.write(dadosXml.get(1));
            bw.newLine();
        }
        if (!dadosXml.get(2).equals("")) {
            bw.write(dadosXml.get(2));
            bw.newLine();
        }
        if (!dadosXml.get(3).equals("")) {
            bw.write(dadosXml.get(3));
            bw.newLine();
        }
        if (!dadosXml.get(4).equals("")) {
            bw.write(dadosXml.get(4));
            bw.newLine();
        }
        if (!dadosXml.get(5).equals("")) {
            bw.write(dadosXml.get(5));
            bw.newLine();
        }

        bw.write(dadosXml.get(6));
        bw.newLine();

        if (!dadosXml.get(7).equals("")) {
            bw.write(dadosXml.get(7));
            bw.newLine();
        }
        if (!dadosXml.get(8).equals("")) {
            bw.write(dadosXml.get(8));
            bw.newLine();
        }
        if (!dadosXml.get(9).equals("")) {
            bw.write(dadosXml.get(9));
            bw.newLine();
        }
        if (!dadosXml.get(10).equals("")) {
            bw.write(dadosXml.get(10));
            bw.newLine();
        }

        bw.write("</config>");
        bw.flush();
        bw.close();
        // Chama o método para enviar a configuração de rede
        try {
            funcao = "EnviarConfRede";
            String configData;
            // Abre o arquivo XML
            BufferedReader br = new BufferedReader(new FileReader(caminhoXML));
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();

            // Lê linha por linha
            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                line = br.readLine();
            }
            configData = sb.toString();
            return retornoDaFuncaoSat(serialComms.ConfigurarInterfaceDeRede(random, codigoAtivacao, configData));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String versao() {
        try {
            funcao = "Versao";
            return retornoDaFuncaoSat(serialComms.VersaoDllGerSAT());
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String atualizarSoftware(String codAtivacao, int random) {
        try {
            funcao = "AtualizarSoftware";
            return retornoDaFuncaoSat(serialComms.AtualizarSAT(random, codAtivacao));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String extrairLog(String codAtivacao, int random) {
        try {
            funcao = "ExtrairLog";
            return retornoDaFuncaoSat(serialComms.ExtrairLogs(random, codAtivacao));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String desbloquearSat(String codAtivacao, int random) {
        try {
            funcao = "DesbloquearSat";
            return retornoDaFuncaoSat(serialComms.DesbloquearSAT(random, codAtivacao));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String bloquearSat(String codAtivacao, int random) {
        try {
            funcao = "BloquearSat";
            return retornoDaFuncaoSat(serialComms.BloquearSAT(random, codAtivacao));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String trocarCodAtivacao(String codAtual, int opt, String codNovo, int random) {
        try {
            // Sempre o codigo de confirmação vai ser igual ao novo, pois já foi validado no
            // flutter
            funcao = "TrocarCodAtivacao";
            return retornoDaFuncaoSat(serialComms.TrocarCodigoDeAtivacao(random, codAtual, opt, codNovo, codNovo));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String consultarNumeroSessao(String codAtivacao, int cNumeroDeSessao, int random) {
        try {
            funcao = "ConsultarNumeroSessao";
            return retornoDaFuncaoSat(serialComms.ConsultarNumeroSessao(random, codAtivacao, cNumeroDeSessao));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String cancelarUltimaVenda(String codAtivacao, String xmlBase64, String chave, int random) {
        try {
            funcao = "CancelarUltimaVenda";
            String vendaData;

            // Cria um arquivo XML
            File file = new File(this.context.getFilesDir().getPath() + "/xmlCancelamento.xml");

            // Escreve no XML os dados que foram enviados do XML decodificado (Flutter)
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(Base64.decode(xmlBase64, Base64.NO_WRAP));
            fos.close();

            BufferedReader br = new BufferedReader(new FileReader(file));
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();

            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                line = br.readLine();
            }
            vendaData = sb.toString();
            vendaData = vendaData.replaceAll("trocarCfe", chave);
            System.out.println(vendaData);
            return retornoDaFuncaoSat(serialComms.CancelarUltimaVenda(random, codAtivacao, chave, vendaData));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String enviarTesteVendas(String codAtivacao, String xmlBase64, int random) {
        try {
            funcao = "EnviarTesteVendas";
            String vendaData;

            // Cria um arquivo XML
            File file = new File(this.context.getFilesDir().getPath() + "/xmlVenda.xml");

            // Escreve no XML os dados que foram enviados do XML decodificado (Flutter)
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(Base64.decode(xmlBase64, Base64.NO_WRAP));
            fos.close();

            // Carrega o XML
            BufferedReader br = new BufferedReader(new FileReader(file));
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();

            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                line = br.readLine();
            }
            vendaData = sb.toString();
            return retornoDaFuncaoSat(serialComms.EnviarDadosVenda(random, codAtivacao, vendaData));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String enviarTesteFim(String codAtivacao, String xmlBase64, int random) {
        try {
            funcao = "EnviarTesteFim";
            String vendaData;

            // Cria um arquivo XML
            File file = new File(this.context.getFilesDir().getPath() + "/xmlVenda.xml");

            // Escreve no XML os dados que foram enviados do XML decodificado (Flutter)
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(Base64.decode(xmlBase64, Base64.NO_WRAP));
            fos.close();

            // Carrega o XML
            BufferedReader br = new BufferedReader(new FileReader(file));
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();

            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                line = br.readLine();
            }
            vendaData = sb.toString();
            return retornoDaFuncaoSat(serialComms.TesteFimAFim(random, codAtivacao, vendaData));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String consultarStatusOperacional(int random, String codAtivacao) {
        try {
            funcao = "ConsultarStatusOperacional";
            return retornoDaFuncaoSat(serialComms.ConsultarStatusOperacional(random, codAtivacao));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String consultarSat(int random) {
        try {
            funcao = "ConsultarSat";
            return retornoDaFuncaoSat(serialComms.ConsultarSAT(random));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String associarSat(String cnpj, String cnpjSW, String codAtivacao, String assinatura, int random) {
        try {
            funcao = "AssociarSAT";
            return retornoDaFuncaoSat(
                    serialComms.AssociarAssinatura(random, codAtivacao, cnpjSW + "" + cnpj, assinatura));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String ativarSat(String codAtivacao, String cnpj, int random) {
        try {
            funcao = "AtivarSAT";
            return retornoDaFuncaoSat(serialComms.AtivarSAT(random, 1, codAtivacao, cnpj, 35));
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public String retornoDaFuncaoSat(String s) {
        // TODO Fazer algo com a String que foi retornada do sat.
        try {
            return s; // Retorna a mensagem com os pipes, para ser tratado no Flutter
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    SatGerLib.OnDataReceived dataReceivedListener = new SatGerLib.OnDataReceived() {
        public void onError(Exception e) {
            System.out.println(e.getMessage());
        }

        @Override
        public void onReceivedDataUpdate(String s) {
            // TODO Fazer algo com a String que foi retornada do sat.
            try {
                // Trata o retorno da função
                String[] respostaSplited;
                respostaSplited = s.split("\\|");
                byte ptext[] = respostaSplited[2].getBytes();
                String value = new String(ptext, "UTF-8");
            } catch (Exception e) {
            }
        }
    };
}