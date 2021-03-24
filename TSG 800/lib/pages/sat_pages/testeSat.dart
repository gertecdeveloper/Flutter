import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gertec/util/globalValues.dart';
import 'package:flutter_gertec/services/operacaoSat.dart';
import 'package:flutter_gertec/services/retornoSat.dart';
import 'package:flutter_gertec/util/common_code.dart';
import 'package:flutter_gertec/widgets/widgetsgertec.dart';

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
        return AlertDialog(
          title: Text("Alerta"),
          content: Container(
            height: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(texto),
                SizedBox(
                  height: 50,
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
                  WidgetsGertec.dialogoSat("Verifique a entrada!");
                }
              },
            )
          ],
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
      WidgetsGertec.dialogoSat(retornoFormatado,
          context: context, heightDialog: 300);
    } else {
      WidgetsGertec.dialogoSat(
          "Código de Ativação deve ter entre 8 a 32 caracteres!",
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: 30),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Código de Ativação SAT: ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 18,
                      width: 140,
                      child: TextFormField(
                        controller: codigoAtivacao,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              WidgetsGertec.buttonStandard("CONSULTAR SAT",
                  callback: () => testeSat("ConsultarSat")),
              WidgetsGertec.buttonStandard("STATUS OPERACIONAL",
                  callback: () => testeSat("ConsultarStatusOperacional")),
              WidgetsGertec.buttonStandard("TESTE FIM A FIM",
                  callback: () => testeSat("EnviarTesteFim")),
              WidgetsGertec.buttonStandard("ENVIAR DADOS DE VENDA",
                  callback: () => testeSat("EnviarTesteVendas")),
              WidgetsGertec.buttonStandard(
                "CANCELAR VENDA",
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
      ),
    );
  }
}
