import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gBot/Configs/config_sat/retornoSat.dart';
import 'package:flutter_gBot/services/operacaoSat.dart';
import 'package:flutter_gBot/util/common_code.dart';
import 'package:flutter_gBot/util/globalValues.dart';
import 'package:flutter_gBot/widgets/widgetsgertec.dart';

class PageFerramentaSat extends StatefulWidget {
  @override
  _PageFerramentaSatState createState() => _PageFerramentaSatState();
}

class _PageFerramentaSatState extends State<PageFerramentaSat> {
  // Inicializa o código de ativação com um valor global, para o usuario não precisar ficar digitando
  final codigoAtivacao = TextEditingController(text: GlobalValues.codAtivarSat); // Codigo de ativação do Sat

  CommonGertec commonGertec = new CommonGertec(); //* Classe que possui partes de código comuns em diversas telas

  // Função para validar os valores digitos pelo usuario e realizar a ativação do SAT
  void ferramentasSat(String funcao) async {
    GlobalValues.codAtivarSat = codigoAtivacao.text; // Salva  o código de ativação para o usuario não precisar ficar digitando em todas as telas
    if (funcao == "Versao" || commonGertec.isCodigoValido(codigoAtivacao.text)) {
      //* Chama a função Invocar Operação Sat, que recebe como parâmetro a "operação invocada" e um "Map com as chaves e seus respectivos valores".
      RetornoSat retornoSat = await OperacaoSat.invocarOperacaoSat(
          // Passa como parâmetro um Map de argumentos de valores que deseja enviar
          args: {'funcao': funcao, 'random': Random().nextInt(999999), 'codigoAtivar': codigoAtivacao.text.toString()});

      //? Caso deseje visualizar o retorno completo basta chamar [retornoSat.getResultadoCompleto]

      // O retorno da operação Versão não é tratado, pois retorna somente uma string
      if (funcao == "Versao") {
        WidgetsGertec.dialogo(retornoSat.getResultadoCompleto, context: context);
      } else {
        //* Está função [OperacaoSat.formataRetornoSat] recebe como parâmetro a operação realizada e um objeto do tipo RetornoSat
        //* Retorna uma String com os valores obtidos do retorno da Operação já formatados e prontos para serem exibidos na tela
        // Recomenda-se acessar a função e entender como ela funciona
        String retornoFormatado = OperacaoSat.formataRetornoSat(retornoSat: retornoSat);
        WidgetsGertec.dialogo(retornoFormatado, context: context);
      }
    } else {
      WidgetsGertec.dialogo("Código de Ativação deve ter entre 8 a 32 caracteres!", context: context);
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
              SizedBox(width: 30),
              WidgetsGertec.formField(codigoAtivacao, "Código de Ativação SAT:", iWidht: 400),
              WidgetsGertec.buttonStandard("BLOQUEAR SAT", callback: () => ferramentasSat("BloquearSat")),
              WidgetsGertec.buttonStandard("DESBLOQUEAR SAT", callback: () => ferramentasSat("DesbloquearSat")),
              WidgetsGertec.buttonStandard("EXTRAIR LOG", callback: () => ferramentasSat("ExtrairLog")),
              WidgetsGertec.buttonStandard("ATUALIZAR SOFTWARE", callback: () => ferramentasSat("AtualizarSoftware")),
              WidgetsGertec.buttonStandard("VERIFICAR VERSÃO", callback: () => ferramentasSat("Versao")),
            ],
          ),
        ),
      ),
    );
  }
}
