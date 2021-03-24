import 'package:flutter/material.dart';

class WidgetsGertec extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // Botão padrão, recebe como parâmetro uma string('texto') e a função que vai ser chamada ao pressionar o botão('voidCallback')
  static Widget buttonStandard(String text, {VoidCallback callback}) {
    return SizedBox(
      width: 240,
      child: RaisedButton(
        child: Text(text),
        onPressed: callback,
      ),
    );
  }

  // Dialogo que ira aparecer após a função Sat ser iniciada e ocorrer algum erro ou tudo ocorrer certo
  static void dialogoSat(String messageText,
      {@required BuildContext context, double heightDialog = 100}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Retorno"),
          content: Container(
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
        );
      },
    );
  }

  static Widget formField(
      TextEditingController textFormField, String textAntesForm,
      {TextInputType textInputType}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            textAntesForm,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 30,
            width: 140,
            child: TextFormField(
              keyboardType: textInputType,
              controller: textFormField,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
