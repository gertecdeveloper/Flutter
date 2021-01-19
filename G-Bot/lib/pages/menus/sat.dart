import 'package:flutter/material.dart';
import 'package:flutter_gBot/pages/sat_pages/ferramentasSat.dart';
import 'package:flutter_gBot/widgets/widgetsgertec.dart';

import '../../pages/sat_pages/associarSat.dart';
import '../../pages/sat_pages/ativarSat.dart';
import '../../pages/sat_pages/configRede.dart';
import '../../pages/sat_pages/ferramentasSat.dart';
import '../../pages/sat_pages/testeSat.dart';
import '../../pages/sat_pages/alterarCodigo.dart';

class PageSat extends StatefulWidget {
  @override
  _PageSatState createState() => _PageSatState();
}

// Tela de Menu Principal do Sat com suas Funções principais
class _PageSatState extends State<PageSat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: 30),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "GERSAT",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 45),
              ),
              WidgetsGertec.buttonStandard(
                "ATIVAÇÃO SAT",
                callback: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageAtivarSat()),
                  );
                },
              ),
              WidgetsGertec.buttonStandard(
                "ASSOCIAR ASSINATURA",
                callback: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageAssociarSat()),
                  );
                },
              ),
              WidgetsGertec.buttonStandard(
                "TESTE SAT",
                callback: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageTesteSat()),
                  );
                },
              ),
              WidgetsGertec.buttonStandard(
                "CONFIGURAÇÕES DE REDE",
                callback: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageConfigSat()),
                  );
                },
              ),
              WidgetsGertec.buttonStandard(
                "ALTERAR CÓDIGO DE ATIVAÇÃO",
                callback: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageCodigoSat()),
                  );
                },
              ),
              WidgetsGertec.buttonStandard(
                "OUTRAS FERRAMENTAS",
                callback: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageFerramentaSat()),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
