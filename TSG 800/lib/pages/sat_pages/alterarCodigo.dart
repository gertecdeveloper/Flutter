import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gertec/util/globalValues.dart';
import 'package:flutter_gertec/services/operacaoSat.dart';
import 'package:flutter_gertec/services/retornoSat.dart';
import 'package:flutter_gertec/util/common_code.dart';
import 'package:flutter_gertec/widgets/widgetsgertec.dart';

class PageCodigoSat extends StatefulWidget {
  @override
  _PageCodigoSatState createState() => _PageCodigoSatState();
}

class _PageCodigoSatState extends State<PageCodigoSat> {
  final codigoAtivacaoNovo = TextEditingController(); // Codigo de ativação Novo

  // Inicializa o código de ativação com um valor global, para o usuario não precisar ficar digitando
  final codigoAtivacao = TextEditingController(text: GlobalValues.codAtivarSat); // Codigo de ativação Novo
  final confirmacaoCodigo = TextEditingController(); // Confirmação do codigo
  String tipoCodigo = "Código de ativação"; // Armazena o tipo de codigo

  CommonGertec commonGertec = new CommonGertec(); //* Classe que possui partes de código comuns em diversas telas

  // Função para validar os valores digitos pelo usuario e realizar a ativação do SAT
  void alterarCodigoSat() async {
    GlobalValues.codAtivarSat = codigoAtivacao.text; // Salva  o código de ativação para o usuario não precisar ficar digitando em todas as telas
    // Verifica se as entradas são validas
    if (commonGertec.isCodigoValido(codigoAtivacao.text) && commonGertec.isCodigoValido(codigoAtivacaoNovo.text)) {
      if (codigoAtivacaoNovo.text == confirmacaoCodigo.text) {
        // No Java o Sat reconhece 1 - Como sendo a opção de mudar codigo de ativação
        // 2 como sendo a opção de alterar codigo de emergência
        int op = 0;
        if (tipoCodigo == "Código de ativação")
          op = 1;
        else
          op = 2;

        //* Chama a função Invocar Operação Sat, que recebe como parâmetro a "operação invocada" e um "Map com as chaves e seus respectivos valores".
        RetornoSat retornoSat = await OperacaoSat.invocarOperacaoSat(
          // Passa como parâmetro um Map de argumentos de valores que deseja enviar
          args: {
            'funcao': "TrocarCodAtivacao",
            'random': Random().nextInt(999999), // Cada chamada no Java deve acompanhar diferente
            'codigoAtivar': codigoAtivacao.text.toString(),
            'codigoAtivacaoNovo': codigoAtivacaoNovo.text.toString(),
            'op': op
          },
        );
        //? Caso deseje visualizar o retorno completo basta chamar [retornoSat.getResultadoCompleto]

        //* Está função [OperacaoSat.formataRetornoSat] recebe como parâmetro a operação realizada e um objeto do tipo RetornoSat
        //* Retorna uma String com os valores obtidos do retorno da Operação já formatados e prontos para serem exibidos na tela
        // Recomenda-se acessar a função e entender como ela funciona
        String retornoFormatado = OperacaoSat.formataRetornoSat(retornoSat: retornoSat);
        WidgetsGertec.dialogoSat(retornoFormatado, context: context);
      } else {
        WidgetsGertec.dialogoSat("O Código de Ativação Novo e a Confirmação do Código de Ativação não correspondem!", context: context);
      }
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
              dropDownList(),
              WidgetsGertec.formField(codigoAtivacao, "Atual: "),
              SizedBox(height: 20),
              WidgetsGertec.formField(codigoAtivacaoNovo, "Novo: "),
              SizedBox(height: 20),
              WidgetsGertec.formField(confirmacaoCodigo, "Confirmar: "),
              SizedBox(height: 20),
              SizedBox(
                width: 240,
                child: RaisedButton(
                  child: Text("ALTERAR"),
                  onPressed: () {
                    alterarCodigoSat();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dropDownList() {
    return Row(
      children: <Widget>[
        Text(
          "Tipo de codigo: ",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: tipoCodigo,
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.black, fontSize: 15),
          onChanged: (String newValue) {
            setState(
              () {
                tipoCodigo = newValue;
              },
            );
          },
          items: <String>[
            "Código de ativação",
            "Código de Emergência",
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.toString()),
            );
          }).toList(),
        ),
      ],
    );
  }
}
