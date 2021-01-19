import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gBot/widgets/widgetsgertec.dart';

class LeituraCodigo extends StatefulWidget {
  @override
  LeituraCodigo({Key key, this.title}) : super(key: key);
  final String title;
  _LeituraCodigo createState() => _LeituraCodigo();
}

class _LeituraCodigo extends State<LeituraCodigo> {
  final platform = [const MethodChannel('samples.flutter.dev/led'), const MethodChannel('samples.flutter.dev/barcode')];
  List<String> listResultBarCodeData = new List<String>();
  @override
  void initState() {
    super.initState();
  }

  bool servicoStatus = false;

// Função que chama no canal de comunicação o inicio do serviço de leitura de codigo de barras
  ligarServicoLeitor() async {
    servicoStatus = true;

    while (servicoStatus) {
      var result = await platform[1].invokeMethod(
        'leitorCodigoBarra',
        <String, dynamic>{"acao": "ativar"},
      );
      setState(() {
        listResultBarCodeData.insert(0, result);
      });
    }
  }

  // Função que chama no canal de comunicação o fim do serviço de leitura de codigo de barras
  desligarServicoLeitor() async {
    servicoStatus = false;
    await platform[1].invokeMethod(
      'leitorCodigoBarra',
      <String, dynamic>{"acao": "desativar"},
    );
  }

// Função que chama no canal de comunicação o serviço de ligar ou desligar o led do leitor
  servicoLed(String acao) async {
    await platform[0].invokeMethod(
      'led',
      <String, dynamic>{"acao": acao},
    );
  }

  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;
    return new WillPopScope(
      onWillPop: () {
        desligarServicoLeitor();
        desligarServicoLeitor();
        servicoLed("desativar");
        Navigator.of(context).pop();
      },
      child: new Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Text(
                "Leitura Código de Barras",
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
              ),
              Container(
                child: Row(
                  children: [
                    Container(
                      width: _width / 2,
                      height: _height - 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          WidgetsGertec.buttonStandard("INICIAR SERVIÇO", callback: () => ligarServicoLeitor()),
                          WidgetsGertec.buttonStandard("PARAR SERVIÇO", callback: () => desligarServicoLeitor()),
                          WidgetsGertec.buttonStandard("LIGAR O LED", callback: () => servicoLed("ativar")),
                          WidgetsGertec.buttonStandard("DESLIGAR O LED", callback: () => servicoLed("desativar")),
                        ],
                      ),
                    ),
                    Container(
                      height: _height - 150,
                      width: _width / 2,
                      child: ListView.builder(
                        itemCount: listResultBarCodeData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              listResultBarCodeData[index],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
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
