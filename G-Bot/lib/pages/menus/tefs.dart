import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gBot/Configs/config_tef/operacaoRetorno.dart';
import 'package:flutter_gBot/services/serviceTet.dart';
import 'package:flutter_gBot/widgets/widgetsgertec.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';

class PageTef extends StatefulWidget {
  @override
  _PageTefState createState() => _PageTefState();
}

class _PageTefState extends State<PageTef> {
  /*
  * Pode inicializar a classe do service MsiTef com os valores da venda ao invés de settar. 
  TefService tefService = new TefService(
    valor: "200", quantParcelas: 2, 
    habilitarImpressao: true, ip: "192.168.0.1", tipoPagamento: "Crédito");
  */
  TefService tefService = new TefService();

  // Variavel que se comunica com o Canal Java Android
  final platform = const MethodChannel('samples.flutter.dev/flutterGBot');

  // Função responsavel por finalizar impressao - ImpressoraOutput();
  void finalizarImpressao() async {
    await platform.invokeMethod('fimimpressao');
  }

  // Função responsavel por avancar linhas na impressao;
  void avancaLinhas(int quantLinhas) async {
    await platform.invokeMethod(
      'avancaLinha',
      <String, dynamic>{"quantLinhas": quantLinhas},
    );
  }

  bool validaIp(String ipServer) {
    RegExp regExp = new RegExp(
      r"^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$",
      caseSensitive: false,
      multiLine: false,
    );
    if (regExp.allMatches(ipServer).isEmpty) return false;
    return true;
  }

  // Caso ocorra um erro no momento de tentar executar ação
  dialogo(String msg, String titulo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Container(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(msg),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  final precoVenda = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', initialValue: 10);

  final ipServidor = TextEditingController(); //Text edit ip do servidor

  final numParcelas =
      TextEditingController(text: "1"); //Text edit da quantidade de parcelas

  bool habilitarImpressao = true; //armazena se a impressao vai ser realizada

  String tipoPagamentoSelecionado =
      "Crédito"; //armazena o tipo de pagamento escolhido

  String resultsMsitef = "";

  String tefSelecionado = "msitef"; //armazena a Tef escolhida
  String tipoParcelamento = "Adm"; //armazena a Tef escolhida

  // Altera o valor da opcao de habilitar impressao (true, false)
  void alterarValorImpressao(bool newValue) => setState(
        () {
          habilitarImpressao = newValue;
        },
      );

  // Setta os valores e os envia para o TefService formatar e encaminhar para o Tef selecionado
  // Recebe como parâmetros uma String que está relacionada a ação que deseja ser invocada e uma String relacionado a tef utilizada (msitef)
  // As ações possiveis são: "venda, cancelamento, reimpressao, funcoes" (Os valores devem ser escritos exatamente como o demonstrado)
  void realizarFuncao(String acao, String tef) {
    // Settando os valores necessarios pra venda e chamando a funcao responsel pela venda.
    // Retira mascara Money antes de enviar o valor para a função.
    String valorFormatado = precoVenda.text;
    valorFormatado = valorFormatado.replaceAll('.', "");
    valorFormatado = valorFormatado.replaceAll(',', "");
    tefService.setValorVenda = valorFormatado;
    tefService.setTipoParcelamento = this.tipoParcelamento;
    tefService.setIpConfig = ipServidor.text
        .toString(); // Somente é necessario settar o ip caso esteja utilizando o Tef M-sitef

    tefService.setHabilitarImpressao =
        habilitarImpressao; //* Caso seja M-sitef, este parâmetro é passado, mas não surge efeito (linhas comentadas no ServiceTef), pois na versão v3.70 está opção foi removida do Sitef **

    tefService.setQuantParcelas = int.parse(numParcelas.text);
    tefService.setTipoPagamento = tipoPagamentoSelecionado;
    if (precoVenda.numberValue <= 0) {
      dialogo("O valor de venda digitado deve ser maior que 0",
          "Erro ao executar função");
    } else if (tef == "msitef" && validaIp(ipServidor.text) == false) {
      dialogo("Verifique o IP digitado", "Erro ao executar função");
    } else {
      tefService.enviarParametrosTef(tipoAcao: acao, tipoTef: tef).then(
        (resultadoTef) {
          RetornoMsiTef retornoMsiTef = resultadoTef;
          // print(retornoMsiTef.toJson()); - Caso deseje printar o Json de retorno
          // Verifica se tem algo pra imprimir
          // Verifica se ocorreu um erro durante venda ou cancelamento
          if (acao == "venda" || acao == "cancelamento") {
            if (retornoMsiTef.getCodTrans.toString() == "" ||
                retornoMsiTef.getCodTrans == null) {
              //Caso ocorra um erro durante as ações, um dialogo de erro é chamado
              msgErroMsitef(retornoMsiTef);
            } else {
              msgTransacaoAprovadaMsitef(retornoMsiTef);
            }
          }
          if (acao == "funcoes" || acao == "reimpressao") {
            if (retornoMsiTef.textoImpressoCliente.isNotEmpty ||
                retornoMsiTef.textoImpressoEstabelecimento.isNotEmpty) {
              DateTime now = DateTime.now();
              String formattedDate =
                  DateFormat('EEE MMM d kk:mm:ss yyyy').format(now);
              setState(() {
                resultsMsitef = formattedDate +
                    "\n" +
                    retornoMsiTef.textoImpressoEstabelecimento +
                    "\n\n\n" +
                    retornoMsiTef.textoImpressoCliente +
                    "\n------------------------------\n" +
                    resultsMsitef;
              });
            }
          }
        },
      );
    }
  }

  // Dialogo que será exibido caso a ação seja realizada com sucesso durante a chamada na MsiTef
  void msgTransacaoAprovadaMsitef(RetornoMsiTef operacaoRetorno) {
    DateTime now = DateTime.now();
    String result = "";
    String formattedDate = DateFormat('EEE MMM d kk:mm:ss yyyy').format(now);
    result += formattedDate + "\n";
    result += "Ação executada com sucesso\n";
    result += "CODRESP: " + operacaoRetorno.getCodResp + "\n";
    result += "COMP_DADOS_CONF: " + operacaoRetorno.getCompDadosConf + "\n";
    result += "CODTRANS: " + operacaoRetorno.getCodTrans + "\n";
    result += "CODTRANS (Name): " + operacaoRetorno.getNameTransCod + "\n";
    result += "VLTROCO: " + operacaoRetorno.getvlTroco + "\n";
    result += "REDE_AUT: " + operacaoRetorno.getRedeAut + "\n";
    result += "BANDEIRA: " + operacaoRetorno.getBandeira + "\n";
    result += "NSU_SITEF: " + operacaoRetorno.getNSUSitef + "\n";
    result += "NSU_HOST: " + operacaoRetorno.getNSUHOST + "\n";
    result += "COD_AUTORIZACAO: " + operacaoRetorno.getCodAutorizacao + "\n";
    result += "NUM_PARC: " + operacaoRetorno.getParcelas;
    result += "\n------------------------------\n";

    setState(() {
      resultsMsitef = formattedDate +
          "\n" +
          operacaoRetorno.textoImpressoEstabelecimento +
          "\n\n\n" +
          operacaoRetorno.textoImpressoCliente +
          "\n------------------------------\n" +
          resultsMsitef;
    });

    WidgetsGertec.dialogo(result, context: context);
  }

  // Dialogo que será exibido caso ocorra algum erro durante a chamada na MsiTef
  void msgErroMsitef(RetornoMsiTef operacaoRetorno) {
    DateTime now = DateTime.now();
    String result = "";
    String formattedDate = DateFormat('EEE MMM d kk:mm:ss yyyy').format(now);
    result += formattedDate + "\n";
    result += "Ocorreu um erro durante a realização da ação:\n" +
        "CODRESP: " +
        operacaoRetorno.getCodResp;
    result += "\n------------------------------\n";
    setState(() {
      resultsMsitef = result + resultsMsitef;
    });
  }

  //Marca o valor do tipo de Tef escolhido
  void radioButtonChangeTef(String value) {
    setState(
      () {
        tefSelecionado = value;
      },
    );
  }

  //Marca o valor do tipo de Parcelamento escolhido
  void radioButtonChangeParcelamento(String value) {
    setState(
      () {
        tipoParcelamento = value;
      },
    );
  }

  //Marca o valor do tipo de pagamento escolhido
  void radioButtonChangePagamento(String value) {
    setState(
      () {
        tipoPagamentoSelecionado = value;
      },
    );
  }

  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Container(
          height: _height - 30,
          child: Column(
            children: [
              Text(
                "Exemplo M-Sitef- Flutter",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600]),
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    "Valor em R\$",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: SizedBox(
                                    height: 30,
                                    width: 160,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: precoVenda,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'IP',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: SizedBox(
                                      height: 30,
                                      width: 160,
                                      child: textFormFieldIp),
                                ),
                              ],
                            )
                          ],
                        ),
                        widgetRadios(),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            "Número de Parcelas",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          width: 300,
                          child: textFormFieldNumParcelas,
                        ),
                        WidgetsGertec.buttonStandard(
                          "ENVIAR TRANSAÇÃO",
                          iHeight: 40,
                          paddingTop: 10,
                          callback: () {
                            if (tipoPagamentoSelecionado == "Crédito" &&
                                (numParcelas.text.isEmpty ||
                                    int.parse(numParcelas.text) <= 0)) {
                              dialogo(
                                  "É necessário colocar o número de parcelas desejadas (obs.: Opção de compra por crédito marcada)",
                                  "Ocorreu um erro durante a execução");
                            } else {
                              realizarFuncao("venda", tefSelecionado);
                            }
                          },
                        ),
                        WidgetsGertec.buttonStandard(
                          "CANCELAR TRANSAÇÃO",
                          iHeight: 40,
                          paddingTop: 10,
                          callback: () =>
                              realizarFuncao("cancelamento", tefSelecionado),
                        ),
                        WidgetsGertec.buttonStandard(
                          "FUNÇÕES",
                          iHeight: 40,
                          paddingTop: 10,
                          callback: () =>
                              realizarFuncao("funcoes", tefSelecionado),
                        ),
                        WidgetsGertec.buttonStandard(
                          "REIMPRESSÃO",
                          iHeight: 40,
                          paddingTop: 10,
                          callback: () =>
                              realizarFuncao("reimpressao", tefSelecionado),
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
                        Text(
                          "Retorno TEF",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        WidgetsGertec.boxText(resultsMsitef,
                            width: _width / 2 - 100, height: _height - 150)
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget get textFormFieldIp {
    return TextFormField(
      decoration: InputDecoration(hintText: '192.168.0.1'),
      keyboardType: TextInputType.number,
      controller: ipServidor,
      inputFormatters: [
        BlacklistingTextInputFormatter(RegExp("[-, ]")),
      ],
      style: TextStyle(fontSize: 17),
    );
  }

  Widget get textFormFieldNumParcelas {
    if (tipoPagamentoSelecionado == "Debito" ||
        tipoPagamentoSelecionado == "Todos") {
      this.numParcelas.text = "1";
      return TextFormField(
        enabled: false,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly,
        ],
        keyboardType: TextInputType.numberWithOptions(signed: false),
        controller: numParcelas,
        style: TextStyle(fontSize: 20),
      );
    } else {
      return TextFormField(
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly,
        ],
        keyboardType: TextInputType.numberWithOptions(signed: false),
        controller: numParcelas,
        style: TextStyle(fontSize: 20),
      );
    }
  }

  Widget widgetRadios() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "Pagamento a ser utilizado",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: <Widget>[
                radioCheck("Crédito", tipoPagamentoSelecionado,
                    radioButtonChangePagamento),
                Text(
                  'Crédito',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                radioCheck("Debito", tipoPagamentoSelecionado,
                    radioButtonChangePagamento),
                Text(
                  'Débito',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                radioCheck("Carteira Digital", tipoPagamentoSelecionado,
                    radioButtonChangePagamento),
                Text(
                  'Carteira Digital',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                radioCheck("Todos", tipoPagamentoSelecionado,
                    radioButtonChangePagamento),
                Text(
                  'Todos',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                "Tipo de parcelamento",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                radioCheck(
                    "Loja", tipoParcelamento, radioButtonChangeParcelamento),
                Text(
                  "Parcelado Loja",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                radioCheck(
                    "Adm", tipoParcelamento, radioButtonChangeParcelamento),
                Text(
                  "Parcelado Adm",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget radioCheck(String text, String controll, Function onChange) {
    return SizedBox(
      height: 20,
      child: Radio(
          value: text,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          groupValue: controll,
          onChanged: onChange),
    );
  }

  Widget button(String text, VoidCallback callback) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 30,
        child: RaisedButton(
          onPressed: callback,
          child: Text(
            text,
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }
}
