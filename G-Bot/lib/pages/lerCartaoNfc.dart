import 'package:flutter/material.dart';
import 'package:flutter_gBot/widgets/widgetsgertec.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

class LeituraCartao extends StatefulWidget {
  @override
  LeituraCartao({Key key, this.title}) : super(key: key);
  final String title;
  _LeituraCartao createState() => _LeituraCartao();
}

class _LeituraCartao extends State<LeituraCartao> {
  bool fezAcao = false; //Verifica se foi feita alguma acao, pois somente mostra a tela de Nfc, caso o usuario tenha feito algo
  String messageScreen = "";
  String infoBottomImage = "";

  @override
  void initState() {
    super.initState();
  }

  final myController = TextEditingController();

  // Funcao que converte o código Hex do Cartão to Int - Little Endian
  // 1 - Inverte o ID
  // 2 - Transforma o ID INVERTIDO em Int 16
  int converteId(String id) {
    List<String> values = new List<String>();
    String msg = "";
    int cont = 0;
    for (int i = 0; i < id.length; i++) {
      cont++;
      msg += id[i];
      if (cont == 2) {
        values.add(msg);
        msg = "";
        cont = 0;
      }
    }
    //---------------------------------------
    String idInvertido = "";
    values = values.reversed.toList();
    for (int i = 0; i < values.length; i++) {
      idInvertido += values[i];
    }

    return int.parse(idInvertido, radix: 16);
  }

  lerNfc() async {
    setState(() {
      fezAcao = true;
      infoBottomImage = "Leitura do Cartão NFC";
      messageScreen = "Aproxime o Cartão";
    });

    NDEFMessage message = await NFC.readNDEF(once: false).first;

    setState(() {
      messageScreen = "Leitura com sucesso\n" + "ID:" + converteId(message.id).toString() + "\nMensagem: " + message.payload;
    });
  }

  escreverNfc() async {
    if (myController.text.isEmpty) {
      WidgetsGertec.dialogo("Por favor digite uma palavra ou frase!", context: context);
    } else {
      setState(() {
        infoBottomImage = "Gravar Cartão";
        fezAcao = true;
        messageScreen = "Aproxime o Cartão";
      });
      NDEFMessage newMessage = NDEFMessage.withRecords([NDEFRecord.type("text/plain", myController.text)]);

      await NFC.writeNDEF(newMessage, once: true).first;

      setState(() {
        messageScreen = "Sucesso ao gravar informação!";
      });
    }
  }

  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;
    return new Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "NFC-NDEF",
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
            ),
            Text(
              "Obs.: Não é possível ler cartões que não sejam Tag NDEF!",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            Row(
              children: [
                Container(
                  width: _width / 2,
                  height: _height - 150,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        child: TextFormField(
                          autofocus: false,
                          decoration: const InputDecoration(
                            counterStyle: TextStyle(color: Colors.lightBlue),
                            hintText: 'Mensagem para gravar no cartão',
                          ),
                          controller: myController,
                        ),
                        width: _width / 2 - 100,
                      ),
                      SizedBox(height: 20),
                      button("GRAVAR NO CARTÃO", _width, callback: () => escreverNfc()),
                      button("LER CARTÃO", _width, callback: () => lerNfc()),
                      button(
                        "FORMATAR CARTÃO",
                        _width,
                        callback: () => WidgetsGertec.dialogo("Essa função não está permitada com esse plugin!", context: context),
                      ),
                      button(
                        "TESTE LEITURA/GRAVAÇÃO",
                        _width,
                        callback: () => WidgetsGertec.dialogo("Essa função não está permitada com esse plugin!", context: context),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: _width / 2,
                  height: _height - 150,
                  child: telaNfc(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Caso o usuario tenha realizado uma acao, retorna a tela do NFC e caso contrario retorna uma espaco vazio.
  Widget telaNfc() {
    if (fezAcao) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            infoBottomImage,
            style: TextStyle(fontSize: 20),
          ),
          Image.asset('assets/images/ic_nfc.png'),
          Text(
            messageScreen,
            style: TextStyle(fontSize: 15),
          )
        ],
      );
    } else {
      return SizedBox();
    }
  }

  Widget button(String text, double _width, {Function callback}) {
    return SizedBox(
      width: _width / 2 - 100,
      child: RaisedButton(
        onPressed: callback,
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
        color: Colors.blue,
      ),
    );
  }
}
