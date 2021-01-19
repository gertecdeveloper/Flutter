import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gBot/widgets/widgetsgertec.dart';

class SensorPage extends StatefulWidget {
  @override
  _SensorPage createState() => _SensorPage();
}

// Tela de Menu Principal do Sat com suas Funções principais
class _SensorPage extends State<SensorPage> {
  bool ativarSensor = false;

  List<String> listResultadSensor = new List<String>();

  final platform = const MethodChannel('samples.flutter.dev/flutterGBot');

// Função que chama no canal de comunicação a função de iniciar
  iniciarSensor() async {
    ativarSensor = true;

    while (ativarSensor) {
      var result = await platform.invokeMethod(
        'sensorGbot',
        <String, dynamic>{"acao": "ativar"},
      );
      setState(() {
        listResultadSensor.insert(0, result);
      });
    }
  }

// Função que chama no canal de comunicação a função de pausar
  pausarSensor() async {
    ativarSensor = false;
    await platform.invokeMethod(
      'sensorGbot',
      <String, dynamic>{"acao": "desativar"},
    );
  }

  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return new WillPopScope(
      onWillPop: () {
        pausarSensor();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 30),
            height: _height,
            width: _width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Sensor de Presença",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 45),
                ),
                Row(
                  children: [
                    Container(
                      height: _height - 120,
                      width: _width / 2 - 150,
                      child: Column(
                        children: [
                          WidgetsGertec.buttonStandard(
                            "INICIAR SERVIÇO",
                            iWidht: 200,
                            callback: () => iniciarSensor(),
                          ),
                          WidgetsGertec.buttonStandard(
                            "PARAR SERVIÇO",
                            iWidht: 200,
                            callback: () => pausarSensor(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: _height - 120,
                      width: _width / 2 + 150,
                      child: ListView.separated(
                        itemCount: listResultadSensor.length,
                        separatorBuilder: (BuildContext context, int index) => Divider(
                          height: 5,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return Text(
                            listResultadSensor[index],
                            style: TextStyle(fontSize: 20),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
