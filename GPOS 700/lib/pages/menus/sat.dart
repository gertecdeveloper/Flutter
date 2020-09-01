import 'package:flutter/material.dart';
import 'package:flutter_gertec/widgets/widgetsgertec.dart';
import '../sat_pages/associarSat.dart';
import '../sat_pages/ativarSat.dart';
import '../sat_pages/configRede.dart';
import '../sat_pages/ferramentasSat.dart';
import '../sat_pages/testeSat.dart';
import '../sat_pages/alterarCodigo.dart';

class PageSat extends StatefulWidget {
  @override
  _PageSatState createState() => _PageSatState();
}

// Tela de Menu Principal do Sat com suas Funções principais
class _PageSatState extends State<PageSat> {
  //* Função responsavel por fazer a mudança de telas, recebe como parâmetro um Widget(Deve ser uma screen, caso não, resulta em erro)
  void changeScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

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
              SizedBox(height: 30),
              Text(
                "GERSAT - Aplicativo de Ativação",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 30),
              // Se deseja ir para tela de ativação
              WidgetsGertec.buttonStandard(
                "ATIVAÇÃO SAT",
                callback: () => changeScreen(PageAtivarSat()),
              ),
              // Se deseja ir para tela de associar assinatura
              WidgetsGertec.buttonStandard(
                "ASSOCIAR ASSINATURA",
                callback: () => changeScreen(PageAssociarSat()),
              ),
              // Se deseja ir para tela de teste
              WidgetsGertec.buttonStandard(
                "TESTE SAT",
                callback: () => changeScreen(PageTesteSat()),
              ),
              // Se deseja ir para tela de configuração de rede
              WidgetsGertec.buttonStandard(
                "CONFIGURAÇÕES DE REDE",
                callback: () => changeScreen(PageConfigSat()),
              ),
              // Se deseja ir para tela de alteração de código
              WidgetsGertec.buttonStandard(
                "ALTERAR CÓDIGO DE ATIVAÇÃO",
                callback: () => changeScreen(PageCodigoSat()),
              ),
              // Se deseja ir para tela de ferramentas
              WidgetsGertec.buttonStandard(
                "OUTRAS FERRAMENTAS",
                callback: () => changeScreen(PageFerramentaSat()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
