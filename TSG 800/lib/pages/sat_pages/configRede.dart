import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gertec/util/globalValues.dart';
import 'package:flutter_gertec/services/operacaoSat.dart';
import 'package:flutter_gertec/services/retornoSat.dart';
import 'package:flutter_gertec/util/common_code.dart';
import 'package:flutter_gertec/widgets/widgetsgertec.dart';

class PageConfigSat extends StatefulWidget {
  @override
  _PageConfigSatState createState() => _PageConfigSatState();
}

class _PageConfigSatState extends State<PageConfigSat> {
  // Inicializa o código de ativação com um valor global, para o usuario não precisar ficar digitando
  final codigoAtivacao = TextEditingController(text: GlobalValues.codAtivarSat); // Codigo de ativação

  final ipSat = TextEditingController(); // Ip do Sat para ser ativado
  final mascara = TextEditingController(); // Mascara Rede
  final gateway = TextEditingController(); // gateway Rede
  final dns1 = TextEditingController(); // dns1 Rede
  final dns2 = TextEditingController(); // dns2 Rede
  final proxyIp = TextEditingController(); // proxy Rede
  final porta = TextEditingController(); // porta Rede
  final user = TextEditingController(); // user Rede
  final password = TextEditingController(); // password Rede
  String tipoRede = "Estático"; // Armazena o tipo de rede
  String habilitarDNS = "Sim"; // Armazena opção Dns
  String habilitarProxy = "Não usa proxy"; // Armazena o tipo proxy de rede

  CommonGertec commonGertec = new CommonGertec(); //* Classe que possui partes de código comuns em diversas telas

  // Função para validar os valores digitos pelo usuario e realizar a ativação do SAT
  void configRedeSat() async {
    GlobalValues.codAtivarSat = codigoAtivacao.text; // Salva  o código de ativação para o usuario não precisar ficar digitando em todas as telas
    if (commonGertec.isCodigoValido(codigoAtivacao.text)) {
      //* Chama a função Invocar Operação Sat, que recebe como parâmetro a "operação invocada" e um "Map com as chaves e seus respectivos valores".
      RetornoSat retornoSat = await OperacaoSat.invocarOperacaoSat(
        // Passa como parâmetro um Map de argumentos de valores que deseja enviar
        args: {
          'funcao': "EnviarConfRede",
          'random': Random().nextInt(999999),
          'codigoAtivar': codigoAtivacao.text.toString(),
          'dadosXml': formatarEnvioConfigRede()
        },
      );

      //? Caso deseje visualizar o retorno completo basta chamar [retornoSat.getResultadoCompleto]

      //* Está função [OperacaoSat.formataRetornoSat] recebe como parâmetro a operação realizada e um objeto do tipo RetornoSat
      //* Retorna uma String com os valores obtidos do retorno da Operação já formatados e prontos para serem exibidos na tela
      // Recomenda-se acessar a função e entender como ela funciona
      String retornoFormatado = OperacaoSat.formataRetornoSat(retornoSat: retornoSat);
      WidgetsGertec.dialogoSat(retornoFormatado, context: context);
    } else {
      WidgetsGertec.dialogoSat("Código de Ativação deve ter entre 8 a 32 caracteres!", context: context);
    }
  }

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
              SizedBox(height: 30),
              WidgetsGertec.formField(codigoAtivacao, "Codigo ativação: "),
              SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Text(
                    "Tipo de Rede: ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: tipoRede,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black, fontSize: 15),
                    onChanged: (String newValue) {
                      setState(
                        () {
                          print(newValue);
                          tipoRede = newValue;
                        },
                      );
                    },
                    items: <String>["Estático", "DHCP"].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                ],
              ),
              verificartipoRede(),
              SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Text(
                    "DNS: ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: habilitarDNS,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black, fontSize: 15),
                    onChanged: (String newValue) {
                      setState(
                        () {
                          habilitarDNS = newValue;
                        },
                      );
                    },
                    items: <String>["Sim", "Não"].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                ],
              ),
              verificartipoDns(),
              SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Text(
                    "Proxy: ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: habilitarProxy,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black, fontSize: 15),
                    onChanged: (String newValue) {
                      setState(
                        () {
                          habilitarProxy = newValue;
                        },
                      );
                    },
                    items: <String>["Não usa proxy", "Proxy com configuração", "Proxy transparente"].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                ],
              ),
              verificartipoProxy(),
              SizedBox(height: 20),
              WidgetsGertec.buttonStandard("ENVIAR", callback: () => configRedeSat())
            ],
          ),
        ),
      ),
    );
  }

  Widget verificartipoRede() {
    if (tipoRede == "Estático")
      return Column(
        children: <Widget>[
          WidgetsGertec.formField(ipSat, "IP SAT: "),
          WidgetsGertec.formField(mascara, "Máscara: "),
          WidgetsGertec.formField(gateway, "Getway: "),
        ],
      );
    else {
      return SizedBox(height: 0);
    }
  }

  Widget verificartipoDns() {
    if (habilitarDNS == "Sim")
      return Column(
        children: <Widget>[
          WidgetsGertec.formField(dns1, "DNS 1: "),
          WidgetsGertec.formField(dns2, "DNS 2: "),
        ],
      );
    else {
      return SizedBox(height: 0);
    }
  }

  Widget verificartipoProxy() {
    if (habilitarProxy != "Não usa proxy")
      return Column(
        children: <Widget>[
          WidgetsGertec.formField(proxyIp, "Proxy Ip: "),
          WidgetsGertec.formField(porta, "Porta: "),
          WidgetsGertec.formField(user, "User: "),
          WidgetsGertec.formField(password, "Password: "),
        ],
      );
    else {
      return SizedBox(height: 0);
    }
  }

  // Configuracao os dados a serem enviados para o Sat
  List<String> formatarEnvioConfigRede() {
    List<String> dadosXml = new List<String>(11);
    dadosXml[0] = "";
    dadosXml[1] = "";
    dadosXml[2] = "";
    dadosXml[3] = "";
    dadosXml[4] = "";
    dadosXml[5] = "";
    dadosXml[6] = "";
    dadosXml[7] = "";
    dadosXml[8] = "";
    dadosXml[9] = "";
    dadosXml[10] = "";

    // Monta as tags do XML sobre a parte de REDE
    if (tipoRede == "Estático") {
      dadosXml[0] = "<tipoLan>IPFIX</tipoLan>";
      if (ipSat.text.isNotEmpty) {
        dadosXml[1] = "<lanIP>" + ipSat.text + "</lanIP>";
      }
      if (mascara.text.isNotEmpty) {
        dadosXml[2] = "<lanMask>" + mascara.text + "</lanMask>";
      }
      if (gateway.text.isNotEmpty) {
        dadosXml[3] = "<lanGW>" + gateway.text + "</lanGW>";
      }

      // Monta as tags do XML sobre a parte de DNS
      if (habilitarDNS == "Sim") {
        if (dns1.text.isNotEmpty) {
          dadosXml[4] = "<lanDNS1>" + dns1.text + "</lanDNS1>";
        }
        if (dns2.text.isNotEmpty) {
          dadosXml[5] = "<lanDNS2>" + dns2.text + "</lanDNS2>";
        }
      } else {
        dadosXml[4] = "<lanDNS1>8.8.8.8</lanDNS1>";
        dadosXml[5] = "<lanDNS2>4.4.4.4</lanDNS2>";
      }
    } else {
      dadosXml[0] = "<tipoLan>DHCP</tipoLan>";
      dadosXml[1] = "";
      dadosXml[2] = "";
      dadosXml[3] = "";
      dadosXml[4] = "";
      dadosXml[5] = "";
    }

    // Monta as tags do XML sobre a parte de PROXY
    if (habilitarProxy == "Não usa proxy") {
      dadosXml[6] = "<proxy>0</proxy >";
      dadosXml[7] = "";
      dadosXml[8] = "";
      dadosXml[9] = "";
      dadosXml[10] = "";
    } else if (habilitarProxy == "Proxy com configuração") {
      dadosXml[6] = "<proxy>1</proxy >";
      if (proxyIp.text.isNotEmpty) {
        dadosXml[7] = "<proxy_ip>" + proxyIp.text + "</proxy_ip>";
      }
      if (porta.text.isNotEmpty) {
        dadosXml[8] = "<proxy_porta>" + porta.text + "</proxy_porta>";
      }
      if (user.text.isNotEmpty) {
        dadosXml[9] = "<proxy_user>" + user.text + "</proxy_user>";
      }
      if (password.text.isNotEmpty) {
        dadosXml[10] = "<proxy_senha>" + password.text + "</proxy_senha>";
      }
    } else {
      dadosXml[6] = "<proxy>2</proxy >";
      if (proxyIp.text.isNotEmpty) {
        dadosXml[7] = "<proxy_ip>" + proxyIp.text + "</proxy_ip>";
      }
      if (porta.text.isNotEmpty) {
        dadosXml[8] = "<proxy_porta>" + porta.text + "</proxy_porta>";
      }
      if (user.text.isNotEmpty) {
        dadosXml[9] = "<proxy_user>" + user.text + "</proxy_user>";
      }
      if (password.text.isNotEmpty) {
        dadosXml[10] = "<proxy_senha>" + password.text + "</proxy_senha>";
      }
    }
    return dadosXml;
  }
}
