import 'package:flutter/material.dart';

import '../pages/sat_pages/associarSat.dart';
import '../pages/sat_pages/ativarSat.dart';
import '../pages/sat_pages/configRede.dart';
import '../pages/sat_pages/ferramentasSat.dart';
import '../pages/sat_pages/testeSat.dart';
import '../pages/sat_pages/alterarCodigo.dart';

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
              SizedBox(
                height: 30,
              ),
              Text(
                "GERSAT - Aplicativo de Ativação",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 30,
              ),
              button(
                "ATIVAÇÃO SAT",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageAtivarSat()),
                  );
                },
              ),
              button(
                "ASSOCIAR ASSINATURA",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageAssociarSat()),
                  );
                },
              ),
              button(
                "TESTE SAT",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageTesteSat()),
                  );
                },
              ),
              button(
                "CONFIGURAÇÕES DE REDE",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageConfigSat()),
                  );
                },
              ),
              button(
                "ALTERAR CÓDIGO DE ATIVAÇÃO",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageCodigoSat()),
                  );
                },
              ),
              button(
                "OUTRAS FERRAMENTAS",
                () {
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

  // Botão padrão, recebe como parâmetro uma string do tipo texto e a função que vai ser chamada ao pressionar o botão
  Widget button(String text, VoidCallback voidCallback) {
    return SizedBox(
      width: 240,
      child: RaisedButton(
        child: Text(text),
        onPressed: voidCallback,
      ),
    );
  }
}
