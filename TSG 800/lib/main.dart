import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'menus/sat.dart';
import 'pages/CodigoDeBarraV1.dart';
import 'pages/imprimir.dart';
import 'pages/lerCartaoNfc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('samples.flutter.dev/gedi');
  Future<void> _leitorCodigoDeBarrasV2() async {
    try {
      await platform.invokeMethod('leitorCodigoV2');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  var newTaskCtrl = TextEditingController();
  var listaNomeFuncoes = [
    {"name": "Código de Barras", "img": "assets/barcode.png"},
    {"name": "Código de Barras V2", "img": "assets/qr_code.png"},
    {"name": "Impressão", "img": "assets/print.png"},
    {"name": "NFC Leitura/Gravação", "img": "assets/nfc2.png"},
    {"name": "SAT", "img": "assets/iconSat.png"},
  ];
  void trocarTela(int id) {
    switch (id) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageCodigoDeBarraV1()),
        );
        break;
      case 1:
        _leitorCodigoDeBarrasV2();
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageImprimir()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageLeituraCartao()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageSat()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = MediaQuery.of(context).size.width;
    double defaultScreenHeight = MediaQuery.of(context).size.height;
    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);

    return new Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 60),
            child: Column(
              children: <Widget>[
                new Image.asset('assets/gertec.png'),
                Text(
                  "Flutter Project v1.0.0",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(30.0), color: Colors.black87),
                ),
              ],
            ),
          ),
          Expanded(
            child: new ListView.builder(
              shrinkWrap: true,
              itemCount: listaNomeFuncoes.length,
              itemExtent: 80,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black12)),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Image(
                      image: AssetImage(listaNomeFuncoes[index]["img"]),
                    ),
                    onTap: () {
                      trocarTela(index);
                    },
                    title: Center(
                      child: Text(
                        listaNomeFuncoes[index]["name"],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(20.0), color: Colors.black54),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
