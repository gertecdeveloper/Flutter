import 'package:flutter/material.dart';
import 'package:flutter_gBot/pages/codigodeBarra.dart';
import 'package:flutter_gBot/pages/lerCartaoNfc.dart';
import 'package:flutter_gBot/pages/menus/sat.dart';
import 'package:flutter_gBot/pages/menus/tefs.dart';
import 'package:flutter_gBot/pages/sensor.dart';
import 'package:flutter_gBot/pages/speaker.dart';
import 'package:flutter_gBot/widgets/widgetsgertec.dart';

import 'pages/quiosqueMode.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter G-BOT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter G-BOT'),
    );
  }
}

class Projeto {
  Projeto(this.pathImage, this.text, {Widget widget}) {
    this.screenTap = widget;
  }
  final String pathImage;
  final String text;
  Widget screenTap;
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Projeto> listProjestos = new List<Projeto>();

  @override
  void initState() {
    super.initState();
    String path = "assets/images/";
    // Inicializa os projetos com os seguintes parâmetros: Path da imagem do icone, Texto e tela que representa a função
    listProjestos.add(new Projeto(path + "barcode.png", "Código de Barras", widget: LeituraCodigo()));
    listProjestos.add(new Projeto(path + "nfc.png", "NFC-NDEF", widget: LeituraCartao()));
    listProjestos.add(new Projeto(path + "sensor.png", "Sensor de Presença", widget: SensorPage()));
    listProjestos.add(new Projeto(path + "speaker.png", "FALA G-Bot", widget: SpeakerGBOT()));
    listProjestos.add(new Projeto(path + "kiosk.png", "Modo Quiosque", widget: QuiosquePage()));
    listProjestos.add(new Projeto(path + "tef.png", "TEF", widget: PageTef()));
    listProjestos.add(new Projeto(path + "icon_sat.png", "SAT", widget: PageSat()));
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width - 100;
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/gertec.png',
                width: _width / 2,
              ),
              SizedBox(height: 30),
              Text(
                "Flutter - 1.0.0 - G-BOT",
                style: TextStyle(fontSize: 35, color: Colors.grey),
              )
            ],
          ),
          Container(
            height: _height - 80,
            width: _width / 2,
            child: ListView.separated(
              itemCount: listProjestos.length,
              separatorBuilder: (BuildContext context, int index) => Divider(
                height: 5,
              ),
              itemBuilder: (BuildContext context, int index) {
                return widgetNameIcon(listProjestos[index]);
              },
            ),
          )
        ],
      ),
    );
  }

  // Função que retorna o Widget montado (Image + Texto), quando 'clicado' troca de tela
  Widget widgetNameIcon(Projeto projeto) {
    return GestureDetector(
      onTap: () {
        WidgetsGertec.screenChange(context, projeto.screenTap);
      },
      child: Row(
        children: [
          Image.asset(
            projeto.pathImage,
            height: 50,
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2 - 100,
            child: Text(
              projeto.text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
