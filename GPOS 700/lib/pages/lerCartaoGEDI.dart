import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageLeituraCartaoGEDI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LeituraCartaoGEDI(title: 'Impressão de Texto'),
    );
  }
}

class LeituraCartaoGEDI extends StatefulWidget {
  @override
  LeituraCartaoGEDI({Key key, this.title}) : super(key: key);
  final String title;
  _LeituraCartaoGEDI createState() => _LeituraCartaoGEDI();
}

class _LeituraCartaoGEDI extends State<LeituraCartaoGEDI> {
  static const platform = const MethodChannel('samples.flutter.dev/gedi');
  final myController = TextEditingController();
  List<String> resultadosNFCGEDI = new List<String>();

  Future<void> _lerCartaoGEDI() async {
    try {
      String id = await platform.invokeMethod('lernfcgedi');
      setState(() {
        resultadosNFCGEDI.add("Código do Cartão (GEDI): " + id);
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
                  child: Text("Ler Cartão Nfc (GEDI)"),
                  onPressed: () {
                    _lerCartaoGEDI();
                  },
                )),
            Container(
                padding: EdgeInsets.only(top: 20), child: Text("ID Cartões")),
            Expanded(
              child: new ListView.builder(
                shrinkWrap: true,
                itemCount: resultadosNFCGEDI.length,
                itemExtent: 50,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: ListTile(
                      dense: true,
                      title: Text(
                        resultadosNFCGEDI[index],
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
