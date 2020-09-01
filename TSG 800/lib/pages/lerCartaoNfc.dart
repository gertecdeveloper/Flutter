import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageLeituraCartao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LeituraCartao(title: 'Impressão de Texto'),
    );
  }
}

class LeituraCartao extends StatefulWidget {
  @override
  LeituraCartao({Key key, this.title}) : super(key: key);
  final String title;
  _LeituraCartao createState() => _LeituraCartao();
}

class _LeituraCartao extends State<LeituraCartao> {
  static const platform = const MethodChannel('samples.flutter.dev/gedi');
  final myController = TextEditingController();

  void erroImpresao() {
    showDialog(
      context: context,
      builder: (BuildContext c) {
        return AlertDialog(
          title: Text("Escreva uma mensagem para ser gravada !"),
        );
      },
    );
  }

  Future<void> _lerCartao() async {
    try {
      await platform.invokeMethod('lerNfc');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> _gravarCartao(String message) async {
    if (message.isEmpty) {
      erroImpresao();
    } else {
      try {
        await platform.invokeMethod('gravarNfc', <String, dynamic>{"mensagemGravar": message});
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
  }

  Future<void> _formatarCartao() async {
    try {
      await platform.invokeMethod('formatarNfc');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> _testeCartao() async {
    try {
      await platform.invokeMethod('testeNfc');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              autofocus: false,
              decoration: const InputDecoration(
                counterStyle: TextStyle(color: Colors.lightBlue),
                hintText: 'Mensagem para gravar no cartão',
              ),
              controller: myController,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width - 30,
              child: RaisedButton(
                onPressed: () => _gravarCartao(myController.text),
                child: Text(
                  "GRAVAR NO CARTÃO",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width - 30,
              child: RaisedButton(
                onPressed: () => _lerCartao(),
                child: Text(
                  "LER CARTÃO",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width - 30,
              child: RaisedButton(
                onPressed: () => _formatarCartao(),
                child: Text(
                  "FORMATAR CARTÃO",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width - 30,
              child: RaisedButton(
                onPressed: () => _testeCartao(),
                child: Text(
                  "TESTE LEITURA/GRAVAÇÃO",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
