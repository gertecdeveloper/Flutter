import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gBot/Configs/config_sat/retornoSat.dart';
import 'package:flutter_gBot/util/globalValues.dart';
import 'package:flutter_gBot/services/operacaoSat.dart';
import 'package:flutter_gBot/util/common_code.dart';
import 'package:flutter_gBot/widgets/widgetsgertec.dart';
import 'package:intl/intl.dart';

class PageTesteSat extends StatefulWidget {
  @override
  _PageTesteSatState createState() => _PageTesteSatState();
}

class _PageTesteSatState extends State<PageTesteSat> {
  // Inicializa o código de ativação com um valor global, para o usuario não precisar ficar digitando
  final codigoAtivacao = TextEditingController(
      text: GlobalValues.codAtivarSat); // Codigo de ativação do Sat
  final chaveCancelamento = TextEditingController(
      text: GlobalValues.valorCfe); // Chave de cancelamento
  final chaveSessao =
      TextEditingController(text: "123"); // Chave de sessao para consulta
  String xmlVenda; // Xml de Venda a ser enviado, transformado em Base 64
  String
      xmlCancelamento; // Xml de Cancelamento a ser enviado, transformado em Base 64

  String resultadoSAT = ""; // Armazena a resposta do SAT

  CommonGertec commonGertec =
      new CommonGertec(); //* Classe que possui partes de código comuns em diversas telas

  void initState() {
    super.initState();
    // Transforma os Xml em base 64 e envia para o Java Android transmitir para a Sefaz
    transformarbase64('assets/xmlSat/arq_cancelamento.xml')
        .then((value) => xmlCancelamento = value);
    transformarbase64('assets/xmlSat/arq_venda_008_Simples_Nacional.xml')
        .then((value) => xmlVenda = value);
  }

  //Reponsavel por fazer a conversão de um File Xml das pastas assets, para um codigo na base 64.
  Future<String> transformarbase64(String assetPath) async {
    ByteData bytes = await rootBundle.load(assetPath);
    var buffer = bytes.buffer;
    var m = base64.encode(Uint8List.view(buffer));
    return m;
  }

  // Dialogo para inserir dados
  void dialogoInserirDados(
    String texto,
    TextEditingController textEditingController,
    TextInputType textInputType,
    Function function,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Alerta"),
            content: Container(
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(texto),
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: TextFormField(
                      keyboardType: textInputType,
                      controller: textEditingController,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  if (textEditingController.text.length > 0) {
                    Navigator.pop(context);
                    function();
                  } else {
                    WidgetsGertec.dialogo("Verifique a entrada!",
                        context: context);
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  // Função para validar os valores digitos pelo usuario e realizar a ativação do SAT
  Future<void> testeSat(String funcao) async {
    GlobalValues.codAtivarSat = codigoAtivacao
        .text; // Salva  o código de ativação para o usuario não precisar ficar digitando em todas as telas
    if (funcao == "ConsultarSat" ||
        commonGertec.isCodigoValido(codigoAtivacao.text)) {
      //* Chama a função Invocar Operação Sat, que recebe como parâmetro a "operação invocada" e um "Map com as chaves e seus respectivos valores".
      RetornoSat retornoSat = await OperacaoSat.invocarOperacaoSat(
        // Passa como parâmetro um Map de argumentos de valores que deseja enviar
        args: {
          //* os dados são enviados para o Java, mas nem todos são lidos, por isso não existe problema de alguns parametros estarem Nulos
          'funcao': funcao,
          'random': Random().nextInt(999999),
          'codigoAtivar': codigoAtivacao.text.toString(),
          'chaveCancelamento': chaveCancelamento.text ?? " ",
          'chaveSessao': int.parse(chaveSessao.text) ?? " ",
          'xmlVenda': xmlVenda,
          'xmlCancelamento': xmlCancelamento
        },
      );

      //? Caso deseje visualizar o retorno completo basta chamar [retornoSat.getResultadoCompleto]
      /* 
      * Está verificação(abaixo) tem como objetivo capturar a "Chave de Consulta" retornado na operação EnviarTesteVendas
      * O valor é armazenado em uma variavel global e quando o usuario abre a tela para cancelar venda, o campo (Chave de Cancelamento) já fica preenchido
      */
      if (funcao == 'EnviarTesteVendas') {
        GlobalValues.valorCfe = retornoSat.getChaveConsulta;
        setState(() {
          chaveCancelamento.text = GlobalValues.valorCfe;
        });
      }

      //* Está função [OperacaoSat.formataRetornoSat] recebe como parâmetro a operação realizada e um objeto do tipo RetornoSat
      //* Retorna uma String com os valores obtidos do retorno da Operação já formatados e prontos para serem exibidos na tela
      // Recomenda-se acessar a função e entender como ela funciona
      String retornoFormatado =
          OperacaoSat.formataRetornoSat(retornoSat: retornoSat);
      DateTime now = DateTime.now();
      String result = "";
      String formattedDate = DateFormat('EEE MMM d kk:mm:ss yyyy').format(now);

      setState(() {
        result += formattedDate + "\n";
        result += retornoFormatado;
        result += "\n------------------------------------------\n";
        resultadoSAT = result + resultadoSAT;
      });
    } else {
      WidgetsGertec.dialogo(
          "Código de Ativação deve ter entre 8 a 32 caracteres!",
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: _width / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    WidgetsGertec.formField(
                        codigoAtivacao, "Código de Ativação SAT:",
                        iWidht: 400),
                    WidgetsGertec.buttonStandard("CONSULTAR SAT",
                        iWidht: 400, callback: () => testeSat("ConsultarSat")),
                    WidgetsGertec.buttonStandard("STATUS OPERACIONAL",
                        iWidht: 400,
                        callback: () => testeSat("ConsultarStatusOperacional")),
                    WidgetsGertec.buttonStandard("TESTE FIM A FIM",
                        iWidht: 400,
                        callback: () => testeSat("EnviarTesteFim")),
                    WidgetsGertec.buttonStandard("ENVIAR DADOS DE VENDA",
                        iWidht: 400,
                        callback: () => testeSat("EnviarTesteVendas")),
                    WidgetsGertec.buttonStandard(
                      "CANCELAR VENDA",
                      iWidht: 400,
                      callback: () =>
                          // Aqui vai ser aberto o dialogo para inserção de dados para cancelamento da Venda, ao preencher e clicar em Ok, vai ser cancelado a venda
                          dialogoInserirDados(
                        "Digite a chave de cancelamento",
                        chaveCancelamento,
                        TextInputType.name,
                        () => testeSat("CancelarUltimaVenda"),
                      ),
                    ),
                    WidgetsGertec.buttonStandard(
                      "CONSULTAR SESSÃO",
                      iWidht: 400,
                      callback: () =>
                          // Aqui vai ser aberto o dialogo para inserção de dados para consulta da sessão
                          dialogoInserirDados(
                        "Digite o número da sessão",
                        chaveSessao,
                        TextInputType.number,
                        () => testeSat("ConsultarNumeroSessao"),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: _width / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      "Retorno SAT",
                      style: TextStyle(fontSize: 40),
                    ),
                    WidgetsGertec.boxText(resultadoSAT,
                        width: _width / 2 - 100, height: _height - 100)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
