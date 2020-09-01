import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gertec/config_tef/operacaoRetorno.dart';
import 'package:flutter_gertec/services/serviceTet.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

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
  static const platform = const MethodChannel('samples.flutter.dev/gedi');

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
      child: AlertDialog(
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
      ),
    );
  }

  imprimirTexto(String texto, int size) async {
    try {
      await platform.invokeMethod(
        'imprimir',
        <String, dynamic>{
          "tipoImpressao": "Texto",
          "mensagem": texto,
          "alinhar": "LEFT",
          "size": size,
          "font": "MONOSPACE",
          "options": [true, false, false] // Negrito, Sublinhado e Italico
        },
      );
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  imprimaGer7(String cupomTEF, int size) {
    if (cupomTEF.isNotEmpty) {
      int curPos = 0;
      int lastPos = 0;
      while (curPos >= 0) {
        curPos = cupomTEF.indexOf("\n", curPos);
        if (curPos > 0) {
          try {
            if (curPos != lastPos) {
              imprimirTexto(cupomTEF.substring(lastPos, curPos), size);
            } else {
              imprimirTexto(" ", size);
            }
            curPos++;
            lastPos = curPos;
          } on Exception catch (e) {
            print(e);
          }
        }
      }
    }
  }

  // Função, para realizar impressão da nota, caso o usuario opte
  void impressaoNota(String texto, int size) async {
    String textoEstabelecimento = "";
    String textoCliente = "";
    // Ger 7 não difere a via do cliente e do escabelecimento, por isto neste momento é buscado o Pattern que difere uma nota da outra, ao encontrar a nota é partida por \n
    if (tefSelecionado == "ger7") {
      textoEstabelecimento = texto.substring(0, texto.indexOf("\f"));
      textoCliente = texto.substring(texto.indexOf("\f"), texto.length);
      imprimaGer7(textoEstabelecimento, size);
      avancaLinhas(100);
      imprimaGer7(textoCliente, size);
    } else {
      imprimirTexto(texto, size);
    }
  } // Mascara que pegar o valor do input e transforma em um tipo Money

  final precoVenda = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.', initialValue: 10);

  final ipServidor = TextEditingController(); //Text edit ip do servidor

  final numParcelas = TextEditingController(text: "1"); //Text edit da quantidade de parcelas

  bool habilitarImpressao = true; //armazena se a impressao vai ser realizada

  String tipoPagamentoSelecionado = "Crédito"; //armazena o tipo de pagamento escolhido

  String tefSelecionado = "msitef"; //armazena a Tef escolhida
  String tipoParcelamento = "Adm"; //armazena a Tef escolhida

  // Dialogo de verificação, para saber se o usuario deseja ou não imprimir a nota utilizando a GEDI
  void dialogoImpressao(String textoNota, int size) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Realizar Impressão"),
        content: Container(
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Deseja realizar a impressão pela aplicação ?"),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("Não"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("Sim"),
            onPressed: () {
              impressaoNota(textoNota, size);
              avancaLinhas(150);
              finalizarImpressao();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

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
    String valorFormatado = precoVenda.text;
    valorFormatado = valorFormatado.replaceAll('.', "");
    valorFormatado = valorFormatado.replaceAll(',', "");
    tefService.setValorVenda = valorFormatado;
    tefService.setTipoParcelamento = this.tipoParcelamento;
    tefService.setIpConfig = ipServidor.text.toString(); // Somente é necessario settar o ip caso esteja utilizando o Tef M-sitef

    tefService.setHabilitarImpressao =
        habilitarImpressao; //* Caso seja M-sitef, este parâmetro é passado, mas não surge efeito (linhas comentadas no ServiceTef), pois na versão v3.70 está opção foi removida do Sitef **

    tefService.setQuantParcelas = int.parse(numParcelas.text);
    tefService.setTipoPagamento = tipoPagamentoSelecionado;
    if (precoVenda.numberValue <= 0) {
      dialogo("O valor de venda digitado deve ser maior que 0", "Erro ao executar função");
    } else if (tef == "msitef" && validaIp(ipServidor.text) == false) {
      dialogo("Verifique o IP digitado", "Erro ao executar função");
    } else {
      tefService.enviarParametrosTef(tipoAcao: acao, tipoTef: tef).then(
        (resultadoTef) {
          //* Verificando qual o tipo de Tef foi utilizado. Cada Tef possui seu retorno que deve ser associado a uma classe diferente.
          if (tef == "ger7") {
            RetornoGer7 retornoGer7 = resultadoTef;
            // print(retornoGer7.toJson()); - Caso deseje printar o Json de retorno
            // Verifica se tem algo pra imprimir
            if (retornoGer7.getErrmsg.isEmpty && retornoGer7.getPrint.isNotEmpty) {
              dialogoImpressao(retornoGer7.getPrint, 17);
            }
            if (acao == "funcoes" && retornoGer7.getErrmsg.isNotEmpty) {
              dialogoErroGer7(retornoGer7);
            }
            // Verifica se ocorreu um erro durante venda ou cancelamento
            if (acao == "venda" || acao == "cancelamento") {
              if (retornoGer7.getErrmsg.isNotEmpty) {
                dialogoErroGer7(retornoGer7);
              } else {
                dialogoTransacaoAprovadaGer7(retornoGer7);
              }
            }
          } else {
            RetornoMsiTef retornoMsiTef = resultadoTef;
            // print(retornoMsiTef.toJson()); - Caso deseje printar o Json de retorno
            // Verifica se tem algo pra imprimir
            if (retornoMsiTef.getCodResp == "0") {
              String impressao = "";
              if (retornoMsiTef.textoImpressoCliente.isNotEmpty) {
                impressao += retornoMsiTef.textoImpressoCliente;
              }
              if (retornoMsiTef.textoImpressoEstabelecimento.isNotEmpty) {
                impressao += "\n\n-----------------------------     \n";
                impressao += retornoMsiTef.textoImpressoEstabelecimento;
              }
              if (impressao != "") {
                dialogoImpressao(impressao, 17);
              }
            }
            // Verifica se ocorreu um erro durante venda ou cancelamento
            if (acao == "venda" || acao == "cancelamento") {
              if (retornoMsiTef.getCodTrans.toString() == "" || retornoMsiTef.getCodTrans == null) {
                //Caso ocorra um erro durante as ações, um dialogo de erro é chamado
                dialogoErroMsitef(retornoMsiTef);
              } else {
                dialogoTransacaoAprovadaMsitef(retornoMsiTef);
              }
            }
          }
        },
      );
    }
  }

  // Dialogo que será exibido caso ocorra algum erro durante a chamada na Ger7
  void dialogoTransacaoAprovadaGer7(RetornoGer7 operacaoRetorno) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Ação executada com sucesso"),
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
      ),
    );
  }

  // Dialogo que será exibido caso a ação seja realizada com sucesso durante a chamada na Ger7
  void dialogoErroGer7(RetornoGer7 operacaoRetorno) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Ocorreu um erro durante a realização da ação"),
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
      ),
    );
  }

  // Dialogo que será exibido caso a ação seja realizada com sucesso durante a chamada na MsiTef
  void dialogoTransacaoAprovadaMsitef(RetornoMsiTef operacaoRetorno) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Ação executada com sucesso"),
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
      ),
    );
  }

  // Dialogo que será exibido caso ocorra algum erro durante a chamada na MsiTef
  void dialogoErroMsitef(RetornoMsiTef operacaoRetorno) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Ocorreu um erro durante a realização da ação"),
        content: Container(
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("CODRESP: " + operacaoRetorno.getCodResp),
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
      ),
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 35),
              child: Center(
                child: Text(
                  "Exemplo TEF API - Flutter",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          TextSpan(text: 'IP', style: TextStyle(fontSize: 18, color: Colors.black)),
                          TextSpan(text: '(somente para o M-Sitef)', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: SizedBox(height: 30, width: 160, child: textFormFieldIp),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 10),
            widgetRadios(),
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
                child: textFormFieldNumParcelas,
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
            checkBoxImpressao(),
            button(
              "ENVIAR TRANSAÇÃO",
              () {
                if (tipoPagamentoSelecionado == "Crédito" && (numParcelas.text.isEmpty || int.parse(numParcelas.text) <= 0)) {
                  dialogo("É necessário colocar o número de parcelas desejadas (obs.: Opção de compra por crédito marcada)",
                      "Ocorreu um erro durante a execução");
                } else {
                  realizarFuncao("venda", tefSelecionado);
                }
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
    );
  }

  Widget get textFormFieldIp {
    if (tefSelecionado != "msitef") {
      return TextFormField(
        enabled: false,
        decoration: InputDecoration(hintText: '192.168.0.1'),
        keyboardType: TextInputType.number,
        controller: ipServidor,
        inputFormatters: [
          BlacklistingTextInputFormatter(RegExp("[-, ]")),
        ],
        style: TextStyle(fontSize: 17),
      );
    } else {
      return TextFormField(
        decoration: InputDecoration(hintText: '192.168.0.1'),
        keyboardType: TextInputType.number,
        inputFormatters: [
          BlacklistingTextInputFormatter(RegExp("[-, ]")),
        ],
        controller: ipServidor,
        style: TextStyle(fontSize: 17),
      );
    }
  }

  Widget get textFormFieldNumParcelas {
    if (tipoPagamentoSelecionado == "Debito" || tipoPagamentoSelecionado == "Todos") {
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

  Widget checkBoxImpressao() {
    if (tefSelecionado == "ger7") {
      return Row(
        children: <Widget>[
          Checkbox(value: habilitarImpressao, onChanged: alterarValorImpressao),
          Text(
            "Habilitar impressão",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          )
        ],
      );
    } else {
      habilitarImpressao = false;
      return AbsorbPointer(
        child: Row(
          children: <Widget>[
            Checkbox(
              activeColor: Colors.grey,
              value: habilitarImpressao,
              onChanged: alterarValorImpressao,
            ),
            Text(
              "Habilitar impressão",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            )
          ],
        ),
      );
    }
  }

  Widget widgetRadios() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
                radioCheck("Crédito", tipoPagamentoSelecionado, radioButtonChangePagamento),
                AutoSizeText(
                  'Crédito',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                radioCheck("Debito", tipoPagamentoSelecionado, radioButtonChangePagamento),
                AutoSizeText(
                  'Débito',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                radioCheck("Todos", tipoPagamentoSelecionado, radioButtonChangePagamento),
                AutoSizeText(
                  'Todos (Msitef)\nVoucher (Ger7)',
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
                radioCheck("Loja", tipoParcelamento, radioButtonChangeParcelamento),
                Text(
                  "Parcelado Loja",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                radioCheck("Adm", tipoParcelamento, radioButtonChangeParcelamento),
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
      height: 30,
      child: Radio(value: text, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, groupValue: controll, onChanged: onChange),
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
