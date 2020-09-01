import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'retornoSat.dart';

const platform = const MethodChannel('samples.flutter.dev/gedi');

class OperacaoSat {
  // Funcão que invoca uma operação no Sat. Recebe como parâmetro um Map com os valores que vão ser enviados para o Sat
  static Future<RetornoSat> invocarOperacaoSat({Map<String, dynamic> args}) async {
    try {
      // O resultado da invocação de uma operação é uma String grande contendos todas as informações divida por Pipes "|"
      String retornoPipeCompleto = await platform.invokeMethod(args['funcao'], args);

      // Após a String ser recebida do canal, ela é enviada como parâmetro para a classe [RetornoSat]
      // onde a String é divida e pode ser pego seus valores através de metodos Get e Set.
      RetornoSat retornoSat = new RetornoSat(args['funcao'], retornoPipeCompleto);
      // Esta função já retorna um objeto do tipo [RetornoSat], onde as informações do retorno já podem ser acessadas
      return retornoSat;
    } on Exception catch (_) {
      return null;
    }
  }

  // Função que retorna uma String formatada para ser posta no dialogo Sat, com todas as informações do retorno da operação realizada
  // Em caso de erro retorna o erro
  // *Existem operações que vão ter como resultado informações semelhantes
  static String formataRetornoSat({@required RetornoSat retornoSat}) {
    String retornoFormatado = '';
    // Verifica se existe um erro no retorno
    if (retornoSat.getErroSat != "") {
      // Retorna o erro caso exista
      return "Mensagem: " + retornoSat.getErroSat;
    } else {
      //* Estas informações são padrões a todos os retornos(sempre vão aparecer no Dialogo Sat)
      //* Para mais informações consulte o arquivo retornosSat.txt. É possivel visualizar nele a posição e informação de cada Retorno do Sat.
      if (retornoSat.getNumeroCCCC != "") {
        // Se tiver Código CCCC adiciona ele a string formatada
        retornoFormatado = retornoSat.getNumeroEEEE + "|" + retornoSat.getNumeroCCCC + "-";
      } else {
        // Caso não tenha o código CCCC adicionada somente o EEEE
        retornoFormatado = retornoSat.getNumeroEEEE + "-";
      }

      retornoFormatado += retornoSat.getMensagem;

      retornoFormatado += "\n"; // Pula linha

      // Verifica se adiciona o Código e Mensagem Sefaz na mensagem, caso não estejam vazios
      if (retornoSat.getNumeroCod != "" && retornoSat.getMensagemSefaz != "") {
        retornoFormatado += "Cod/Mens Sefaz: \n" + retornoSat.getNumeroCod + "-" + retornoSat.getMensagemSefaz;
      } else if (retornoSat.getNumeroCod != "") {
        retornoFormatado += "Cod/Mens Sefaz: \n" + retornoSat.getNumeroCod + "-";
      } else if (retornoSat.getMensagemSefaz != "") {
        retornoFormatado += "Cod/Mens Sefaz: \n" + "-" + retornoSat.getMensagemSefaz;
      }

      retornoFormatado += "\n"; // Pula linha

      //* Agora só são inseridas as informações que não são padrões a todos retornos
      //* São atribuidas as informações especificas do retorno da operação
      if (retornoSat.getOperacao == "AtivarSAT") {
        if (retornoSat.getCodigoCSR != "") {
          retornoFormatado += "CSR: " + retornoSat.getCodigoCSR;
        }
      } else if (retornoSat.getOperacao == "ExtrairLog") {
        //! Cuidado com está parte, ela pode exigir muito processamento se estiver em modo Debug
        //! Recomenda-se que utilize somente em modo release e não colocar em um Dialogo, pois o arquivo retornado é grande
        // retornoFormatado += "Arquivo de log em base64: " + retornoSat.getLogBase64;
        print(retornoSat.getLogBase64);
      } else if (retornoSat.getOperacao == "ConsultarStatusOperacional") {
        retornoFormatado += "------- Conteúdo Retorno -------" +
            "\n" +
            "Número de Série do SAT: " +
            retornoSat.getNumeroSerieSat +
            "Tipo de Lan: " +
            retornoSat.getTipoLan +
            "\n" +
            "IP SAT: " +
            retornoSat.getIpSat +
            "\n" +
            "MAC SAT: " +
            retornoSat.getMacSat +
            "\n" +
            "Máscara: " +
            retornoSat.getMascara +
            "\n" +
            "Gateway: " +
            retornoSat.getGateway +
            "\n" +
            "DNS 1: " +
            retornoSat.getDns1 +
            "\n" +
            "DNS 2: " +
            retornoSat.getDns2 +
            "\n" +
            "Status da Rede: " +
            retornoSat.getStatusRede +
            "\n" +
            "Nível da Bateria: " +
            retornoSat.getNivelBateria +
            "\n" +
            "Memória de Trabalho Total: " +
            retornoSat.getMemoriaDeTrabalhoTotal +
            "\n" +
            "Memória de Trabalho Usada: " +
            retornoSat.getMemoriaDeTrabalhoUsada +
            "\n" +
            "Data/Hora: " +
            retornoSat.getDataHora +
            "\n" +
            "Versão: " +
            retornoSat.getVersao +
            "\n" +
            "Versão de Leiaute: " +
            retornoSat.getVersaoLeiaute +
            "\n" +
            "Último CFe-Sat Emitido: " +
            retornoSat.getUltimoCfeEmitido +
            "\n" +
            "Primeiro CFe-Sat Em Memória: " +
            retornoSat.getPrimeiroCfeMemoria +
            "\n" +
            "Último CFe-Sat Em Memória: " +
            retornoSat.getUltimoCfeMemoria +
            "\n" +
            "Última Transmissão de CFe-SAT para SEFAZ: " +
            retornoSat.getUltimaTransmissaoSefazDataHora +
            "\n" +
            "Última Comunicacao com a SEFAZ:" +
            retornoSat.getUltimaComunicacaoSefazData +
            "\n" +
            "Estado de Operação do SAT: " +
            retornoSat.getEstadoDeOperacao;
      } else if (retornoSat.getOperacao == "AssociarSAT") {
        //* Associar SAT somente tem como dado especifico o campo CCCC(fica ao seu criterio adicionar-lo ou não)
      } else if (retornoSat.getOperacao == "EnviarTesteFim") {
        retornoFormatado += "TimeStamp: " +
            retornoSat.getTimeStamp +
            "\nNum Doc Fiscal: " +
            retornoSat.getNumDocFiscal +
            "\nChave de Consulta: " +
            retornoSat.getChaveConsulta +
            "\nArquivo CFE Base 64: " +
            converterBase64EmXml(retornoSat.getArquivoCFeBase64);
      } else if (retornoSat.getOperacao == "EnviarTesteVendas" || retornoSat.getOperacao == "CancelarUltimaVenda") {
        retornoFormatado += "TimeStamp: " +
            retornoSat.getTimeStamp +
            "\nChave de Consulta: " +
            retornoSat.getChaveConsulta +
            "\nValor CFE: " +
            retornoSat.getValorTotalCFe +
            "\nValor CPF CNPJ: " +
            retornoSat.getCPFCNPJValue +
            "\nArquivo CFE Base 64: " +
            converterBase64EmXml(retornoSat.getArquivoCFeBase64) +
            "\nAssinatura QRCODE: " +
            retornoSat.getAssinaturaQRCODE;
      }
    }
    return retornoFormatado;
  }

  // Função que converte o arquivo Base 64 em String
  static String converterBase64EmXml(String base64Sat) {
    return utf8.decode(base64.decode(base64Sat)); // Converte o arquivo Base 64 em String(vai ser usado para visualizar o Xml de resposta)
  }
}
