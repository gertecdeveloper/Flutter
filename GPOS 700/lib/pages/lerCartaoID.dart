import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageLeituraCartaoID extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LeituraCartaoID(title: 'Impressão de Texto'),
    );
  }
}

class LeituraCartaoID extends StatefulWidget {
  @override
  LeituraCartaoID({Key key, this.title}) : super(key: key);
  final String title;
  _LeituraCartaoID createState() => _LeituraCartaoID();
}

class _LeituraCartaoID extends State<LeituraCartaoID> {
  static const platform = const MethodChannel('samples.flutter.dev/gedi');
  final myController = TextEditingController();
  List<String> resultadosNFCID = new List<String>();

  Future<void> _lerCartaoID() async {
    try {
      String id = await platform.invokeMethod('lernfcid');
      setState(() {
        resultadosNFCID.add("Código do Cartão (ID): " + id);
      });
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.only(top: 60),
                child: RaisedButton(
                  child: Text("Ler Cartão Nfc (Nativo)"),
                  onPressed: () {
                    _lerCartaoID();
                  },
                )),
            Container(
                padding: EdgeInsets.only(top: 20), child: Text("ID Cartões")),
            Expanded(
              child: new ListView.builder(
                shrinkWrap: true,
                itemCount: resultadosNFCID.length,
                itemExtent: 50,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: ListTile(
                      dense: true,
                      title: Text(
                        resultadosNFCID[index],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                            color: Colors.black54),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
