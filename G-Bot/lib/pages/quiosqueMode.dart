import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gBot/pages/sensor.dart';
import 'package:flutter_gBot/widgets/widgetsgertec.dart';

class QuiosquePage extends StatefulWidget {
  @override
  _QuiosquePageState createState() => _QuiosquePageState();
}

class _QuiosquePageState extends State<QuiosquePage> {
  final platform = const MethodChannel('samples.flutter.dev/flutterGBot');

  String statusModoKiosk = "Modo Kiosk Desativado";

  activeKioskMode(String acao) async {
    if (acao == "ativar") {
      setState(() {
        statusModoKiosk = "Modo Kiosk Ativado";
      });
      await platform.invokeMethod("kioskMode", {"acao": "ativar"});
    } else {
      setState(() {
        statusModoKiosk = "Modo Kiosk Desativado";
      });
      await platform.invokeMethod("kioskMode", {"acao": "desativar"});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            statusModoKiosk,
            style: TextStyle(fontSize: 30),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              WidgetsGertec.buttonStandard("START KIOSK MODE", callback: () => activeKioskMode("ativar")),
              WidgetsGertec.buttonStandard("STOP KIOSK MODE", callback: () => activeKioskMode("desativar")),
            ],
          )
        ],
      ),
    );
  }
}
