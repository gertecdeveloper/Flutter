import 'package:flutter/material.dart';

class WidgetsGertec extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // Botão padrão, recebe como parâmetro uma string('texto') e a função que vai ser chamada ao pressionar o botão('voidCallback')
  static Widget buttonStandard(String text, {double iWidht = 400, double iHeight = 60, VoidCallback callback, double paddingTop = 20}) {
    return SizedBox(
      width: iWidht,
      height: iHeight,
      child: Padding(
        padding: EdgeInsets.only(top: paddingTop),
        child: RaisedButton(
          child: Text(text, style: TextStyle(color: Colors.black)),
          onPressed: callback,
        ),
      ),
    );
  }

  // Dialogo que ira aparecer após a função Sat ser iniciada e ocorrer algum erro ou tudo ocorrer certo
  static void dialogo(String messageText, {@required BuildContext context, double heightDialog = 100}) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Retorno"),
        content: Container(
          width: 300,
          height: heightDialog,
          child: ListView(
            children: <Widget>[
              Text(messageText),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("Ok"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  static Widget formField(TextEditingController textFormField, String textAntesForm,
      {double textSize = 15, double iWidht = 250, TextInputType textInputType}) {
    return SizedBox(
      width: iWidht,
      child: TextFormField(
        keyboardType: textInputType,
        decoration: InputDecoration(
          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          isDense: true,
          prefixIcon: Text(
            textAntesForm,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        controller: textFormField,
        style: TextStyle(
          fontSize: 15,
        ),
      ),
    );
  }

  static Widget boxText(String message, {double width = 400, double height = 400}) {
    return SizedBox(
      height: height,
      width: width,
      child: Card(
        color: Colors.grey[200],
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }

  //* Função responsavel por fazer a mudança de telas, recebe como parâmetro um Widget(Deve ser uma screen, caso não, resulta em erro)
  static screenChange(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }
}
