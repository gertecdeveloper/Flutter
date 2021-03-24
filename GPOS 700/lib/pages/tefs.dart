import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gertec/config_tef/operacaoRetorno.dart';
import 'package:flutter_gertec/serviceTet.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class PageTef extends StatefulWidget {
  @override
  _PageTefState createState() => _PageTefState();
}

class _PageTefState extends State<PageTef> {
  TefService tefService = new TefService();

  /*
  * Pode inicializar a classe do service MsiTef com os valores da venda ao invés de settar. 
  TefService tefService = new TefService(
    valor: "200", quantParcelas: 2, 
    habilitarImpressao: true, ip: "192.168.0.1", tipoPagamento: "Crédito");

  */

  //Mascara que pegar o valor do input e transforma em um tipo Money
  final precoVenda = MoneyMaskedTextController(
      leftSymbol: "R\$ ",
      decimalSeparator: '.',
      thousandSeparator: ',',
      initialValue: 20);

  final ipServidor =
      TextEditingController(text: "192.168.15.8"); //Text edit ip do servidor

  final numParcelas =
      TextEditingController(text: "1"); //Text edit da quantidade de parcelas

  bool habilitarImpressao = false; //armazena se a impressao vai ser realizada

  String tipoPagamentoSelecionado =
      "Crédito"; //armazena o tipo de pagamento escolhido

  String tefSelecionado = "ger7"; //armazena a Tef escolhida

  // Altera o valor da opcao de habilitar impressao (true, false)
  void alterarValorImpressao(bool newValue) => setState(
        () {
          habilitarImpressao = newValue;
        },
      );

  // Setta os valores e os envia para o TefService formatar e encaminhar para o Tef selecionado
  // Recebe como parâmetros uma String que está relacionada a ação que deseja ser invocada e uma String relacionado a tef utilizada (ger7,msitef)
  // As ações possiveis são: "venda, cancelamento, reimpressao, funcoes" (Os valores devem ser escritos exatamente como o demonstrado)
  void realizarFuncao(String acao, String tef) {
    // Settando os valores necessarios pra venda e chamando a funcao responsel pela venda.
    // Retira mascara Money antes de enviar o valor para a função.
    String valorFormatado = precoVenda.text.substring(3);
    valorFormatado = valorFormatado.replaceAll('.', "");
    valorFormatado = valorFormatado.replaceAll(',', "");
    tefService.setValorVenda = valorFormatado;
    tefService.setIpConfig = ipServidor
        .text; // Somente é necessario settar o ip caso esteja utilizando o Tef Msitef
    tefService.setHabilitarImpressao = habilitarImpressao;
    tefService.setQuantParcelas = int.parse(numParcelas.text);
    tefService.setTipoPagamento = tipoPagamentoSelecionado;
    tefService.enviarParametrosTef(tipoAcao: acao, tipoTef: tef).then(
      (resultadoTef) {
        //* Verificando qual o tipo de Tef foi utilizado. Cada Tef possui seu retorno que deve ser associado a uma classe diferente.
        if (tef == "ger7") {
          RetornoGer7 retornoGer7 = resultadoTef;
          // print(retornoGer7.toJson()); - Caso deseje printar o Json de retorno
          if (retornoGer7.getErrcode != "0") {
            dialogoErroGer7(retornoGer7);
          } else {
            dialogoTransacaoAprovadaGer7(retornoGer7);
          }
        } else {
          RetornoMsiTef retornoMsiTef = resultadoTef;
          // print(retornoMsiTef.toJson()); - Caso deseje printar o Json de retorno
          // Verifica se ocorreu algum problema durante a realização da venda ou demais funções.
          if (retornoMsiTef.getCodTrans.toString().isEmpty ||
              retornoMsiTef.getCodTrans == null ||
              retornoMsiTef.textoImpressoEstabelecimento == null) {
            //Caso ocorra um erro durante as ações, um dialogo de erro é chamado
            dialogoErroMsitef(retornoMsiTef);
          } else {
            dialogoTransacaoAprovadaMsitef(retornoMsiTef);
          }
        }
      },
    );
  }

  // Dialogo que será exibido caso ocorra algum erro durante a chamada na Ger7
  void dialogoTransacaoAprovadaGer7(RetornoGer7 operacaoRetorno) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Transação Aprovada"),
          content: Container(
            height: MediaQuery.of(context).size.height - 20,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Text("version: " + operacaoRetorno.getVersion),
                Text("status: " + operacaoRetorno.getStatus),
                Text("config: " + operacaoRetorno.getConfig),
                Text("license: " + operacaoRetorno.getLicens),
                Text("terminal: " + operacaoRetorno.getTerminal),
                Text("merchant: " + operacaoRetorno.getMerchant),
                Text("id: " + operacaoRetorno.getId),
                Text("type: " + operacaoRetorno.getType),
                Text("product: " + operacaoRetorno.getProduct),
                Text("response: " + operacaoRetorno.getResponse),
                Text("authorization: " + operacaoRetorno.getAuthorization),
                Text("amount: " + operacaoRetorno.getAmount),
                Text("installments: " + operacaoRetorno.getInstallments),
                Text("instmode: " + operacaoRetorno.getInstmode),
                Text("stan: " + operacaoRetorno.getStan),
                Text("rrn: " + operacaoRetorno.getRrn),
                Text("time: " + operacaoRetorno.getTime),
                Text("track2: " + operacaoRetorno.getTrack2),
                Text("aid: " + operacaoRetorno.getAid),
                Text("cardholder: " + operacaoRetorno.getCardholder),
                Text("prefname: " + operacaoRetorno.getPrefname),
                Text("errcode: " + operacaoRetorno.getErrcode),
                Text("label: " + operacaoRetorno.getLabel),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  // Dialogo que será exibido caso a ação seja realizada com sucesso durante a chamada na Ger7
  void dialogoErroGer7(RetornoGer7 operacaoRetorno) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Transação Negada"),
          content: Container(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("version: " + operacaoRetorno.getVersion),
                Text("errcode: " + operacaoRetorno.getErrcode),
                Text("errmsg: " + operacaoRetorno.getErrmsg),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  // Dialogo que será exibido caso a ação seja realizada com sucesso durante a chamada na MsiTef
  void dialogoTransacaoAprovadaMsitef(RetornoMsiTef operacaoRetorno) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Transação Aprovada"),
          content: Container(
              height: 250,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Text("CODRESP: " + operacaoRetorno.getCodResp),
                  Text("COMP_DADOS_CONF: " + operacaoRetorno.getCompDadosConf),
                  Text("CODTRANS: " + operacaoRetorno.getCodTrans),
                  Text("CODTRANS (Name): " + operacaoRetorno.getNameTransCod),
                  Text("VLTROCO: " + operacaoRetorno.getvlTroco),
                  Text("REDE_AUT: " + operacaoRetorno.getRedeAut),
                  Text("BANDEIRA: " + operacaoRetorno.getBandeira),
                  Text("NSU_SITEF: " + operacaoRetorno.getNSUSitef),
                  Text("NSU_HOST: " + operacaoRetorno.getNSUHOST),
                  Text("COD_AUTORIZACAO: " + operacaoRetorno.getCodAutorizacao),
                  Text("NUM_PARC: " + operacaoRetorno.getParcelas)
                ],
              )),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  // Dialogo que será exibido caso ocorra algum erro durante a chamada na MsiTef
  void dialogoErroMsitef(RetornoMsiTef operacaoRetorno) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Transação Negada"),
          content: Container(
            height: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("CODRESP: " + operacaoRetorno.getCodResp),
                Text("Verique se o ip está correto !")
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  //Marca o valor do tipo de Tef escolhido
  void radioButtonChangeTef(String value) {
    setState(
      () {
        tefSelecionado = value;
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: 30),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Text(
                  "Exemplo TEF API - Flutter",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600]),
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          "Valor em R\$",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontWeight: FontWeight.bold),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'IP',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black)),
                            TextSpan(
                                text: '(somente para o M-Siterf)',
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: SizedBox(
                          height: 30,
                          width: 160,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: ipServidor,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  "Pagamento a ser utilizado",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: widgetRadios(),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  "Número de Parcelas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: SizedBox(
                  height: 30,
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: numParcelas,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  "Escolha a API",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: <Widget>[
                    radioCheck("ger7", tefSelecionado, radioButtonChangeTef),
                    Text(
                      "Ger7",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 90),
                    radioCheck("msitef", tefSelecionado, radioButtonChangeTef),
                    Text(
                      "M-Sitef",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                      value: habilitarImpressao,
                      onChanged: alterarValorImpressao),
                  Text(
                    "Habilitar impressão",
                    style: TextStyle(fontSize: 15),
                  )
                ],
              ),
              button(
                "ENVIAR TRANSAÇÃO",
                () {
                  realizarFuncao("venda", tefSelecionado);
                },
              ),
              button(
                "CANCELAR TRANSAÇÃO",
                () {
                  realizarFuncao("cancelamento", tefSelecionado);
                },
              ),
              button(
                "FUNÇÕES",
                () {
                  realizarFuncao("funcoes", tefSelecionado);
                },
              ),
              button(
                "REIMPRESSÃO",
                () {
                  realizarFuncao("reimpressao", tefSelecionado);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget widgetRadios() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            radioCheck("Crédito", tipoPagamentoSelecionado,
                radioButtonChangePagamento),
            AutoSizeText(
              'Crédito',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            radioCheck(
                "Debito", tipoPagamentoSelecionado, radioButtonChangePagamento),
            AutoSizeText(
              'Debito',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            radioCheck(
                "Todos", tipoPagamentoSelecionado, radioButtonChangePagamento),
            AutoSizeText(
              'Todos (Msitef) / Voucher (Ger7)',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget radioCheck(String text, String controll, Function onChange) {
    return SizedBox(
      height: 30,
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
