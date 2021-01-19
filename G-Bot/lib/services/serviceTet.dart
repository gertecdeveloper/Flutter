import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gBot/Configs/config_tef/operacaoRetorno.dart';

//Recebe um Json obtido através da chamada feito para Tef e a formata para devolver ao Flutter.
Map<String, dynamic> _formatarInfoRecebida(myjson) {
  Map<String, dynamic> mapResultado;
  // myjson = myjson.toString().replaceAll('\\n', "");
  myjson = myjson.toString().replaceAll('\\r', "");
  // myjson = myjson.toString().replaceAll('\\', "");
  myjson = myjson.toString().replaceAll('"{', "{ ");
  myjson = myjson.toString().replaceAll('}"', " }");
  var parsedJson = json.decode(myjson);
  mapResultado = Map<String, dynamic>.from(parsedJson);
  return mapResultado;
}

class TefService {
  TefService({String valor, String tipoPagamento, int quantParcelas, bool habilitarImpressao, String ip}) {
    this._ipConfig = ip;
    this._valorVenda = valor;
    this._tipoPagamento = tipoPagamento;
    this._quantParcelas = quantParcelas;
    this._habilitarImpressao = habilitarImpressao;
  }

  final _platform = const MethodChannel('samples.flutter.dev/flutterGBot');
  String _valorVenda;
  String _tipoPagamento;
  int _quantParcelas;
  bool _habilitarImpressao;
  String _ipConfig;
  String _tipoParcelamento;

//Metodos Get
  String get getIpConfig => _ipConfig;
  String get getValorVenda => _valorVenda;

  //Retorna uma lista onde o Index 1 == TipoPagamento M-Sitef (Caso exista esse tipo de pagamento no Tef)
  List<String> get getTipoPagamento {
    if (_tipoPagamento == "Crédito") {
      return ["1", "3"];
    } else if (_tipoPagamento == "Debito") {
      return ["2", "2"];
    } else if (_tipoPagamento == "Todos") {
      return ["4", "0"];
    } else if (_tipoPagamento == "Carteira Digital") {
      return ['0', '122'];
    } else {
      return ["0", "0"];
    }
  }

  int get getQuantParcelas => _quantParcelas;
  bool get getImpressaoHabilitada => _habilitarImpressao;
  get getTipoParcelamento => this._tipoParcelamento;

//Metodos Set
  set setTipoParcelamento(String tipo) => _tipoParcelamento = tipo;
  set setValorVenda(String valor) => _valorVenda = valor;
  set setTipoPagamento(String tipo) => this._tipoPagamento = tipo;
  set setQuantParcelas(int quantParcelas) => _quantParcelas = quantParcelas;
  set setHabilitarImpressao(bool value) => _habilitarImpressao = value;
  set setIpConfig(String ip) => _ipConfig = ip;

  /// Realiza a formatação para realização de venda MsiTef.
  ///
  /// Retorna um json, que vai ser enviado para a Tef MsiTef.
  Map<String, String> get _formatarPametrosVendaMsiTef {
    Map<String, String> mapMsiTef = Map();
    mapMsiTef["empresaSitef"] = "00000000";
    mapMsiTef["enderecoSitef"] = this.getIpConfig;
    mapMsiTef["operador"] = "0001";
    mapMsiTef["data"] = "20200324";
    mapMsiTef["hora"] = "130358";
    mapMsiTef["numeroCupom"] = new Random().nextInt(9999999).toString();
    mapMsiTef["valor"] = this.getValorVenda;
    mapMsiTef["CNPJ_CPF"] = "03654119000176";
    mapMsiTef["comExterna"] = "0";
    mapMsiTef["modalidade"] = this.getTipoPagamento[1];
    if (this.getTipoPagamento[1] == "3") {
      if (this.getQuantParcelas == 1 || this.getQuantParcelas == 0) {
        mapMsiTef["transacoesHabilitadas"] = "26";
        mapMsiTef["numParcelas"] = null;
      } else if (this.getTipoParcelamento == "Loja") {
        mapMsiTef["transacoesHabilitadas"] = "27";
      } else if (this.getTipoParcelamento == "Adm") {
        mapMsiTef["transacoesHabilitadas"] = "28";
      }
      mapMsiTef["numParcelas"] = this.getQuantParcelas.toString();
    }
    if (this.getTipoPagamento[1] == "2") {
      mapMsiTef["transacoesHabilitadas"] = "16";
      mapMsiTef["numParcelas"] = null;
    }
    if (this.getTipoPagamento[1] == "0") {
      mapMsiTef["restricoes"] = "transacoesHabilitadas=16";
      mapMsiTef["transacoesHabilitadas"] = null;
      mapMsiTef["numParcelas"] = null;
    }
    if (this.getTipoPagamento[1] == "122") {
      mapMsiTef["restricoes"] = null;
      mapMsiTef["transacoesHabilitadas"] = "7;8";
      mapMsiTef["numParcelas"] = null;
    }

    // ** Removida esta opção v3.70 Sitef **

    // if (this.getImpressaoHabilitada) {
    //   mapMsiTef["comprovante"] = "1";
    // } else {
    //   mapMsiTef["comprovante"] = "0";
    // }
    return mapMsiTef;
  }

  ///Realiza a formatação para realização de cancelamento MsiTef.
  ///
  /// Retorna um map <String, String>, que vai ser enviado para a MsiTef.
  Map<String, String> get _formatarPametrosCancelamentoMsiTef {
    Map<String, String> mapMsiTef = Map();
    mapMsiTef["empresaSitef"] = "00000000";
    mapMsiTef["enderecoSitef"] = this.getIpConfig;
    mapMsiTef["operador"] = "0001";
    mapMsiTef["data"] = "20200324";
    mapMsiTef["hora"] = "130358";
    mapMsiTef["numeroCupom"] = new Random().nextInt(9999999).toString();
    mapMsiTef["valor"] = this.getValorVenda;
    mapMsiTef["CNPJ_CPF"] = "03654119000176";
    mapMsiTef["comExterna"] = "0";
    if (this._tipoPagamento == "Carteira Digital") {
      mapMsiTef["modalidade"] = "200";
      mapMsiTef["restricoes"] = null;
      mapMsiTef["numParcelas"] = null;
      mapMsiTef["transacoesHabilitadas"] = "8";
    } else {
      mapMsiTef["modalidade"] = "200";
      mapMsiTef["transacoesHabilitadas"] = null;
    }
    mapMsiTef["isDoubleValidation"] = "0";
    mapMsiTef["restricoes"] = null;
    mapMsiTef["caminhoCertificadoCA"] = "ca_cert_perm";
    // ** Removida esta opção v3.70 Sitef **

    // if (this.getImpressaoHabilitada) {
    //   mapMsiTef["comprovante"] = "1";
    // } else {
    //   mapMsiTef["comprovante"] = "0";
    // }
    return mapMsiTef;
  }

  /// Realiza a formatação para realização de configuração de funções MsiTef.
  ///
  /// Retorna um map <String, String>, que vai ser enviado para a Tef M-Sitef
  Map<String, String> get _formatarPametrosFuncoesMsiTef {
    Map<String, String> mapMsiTef = Map();
    mapMsiTef["empresaSitef"] = "00000000";
    mapMsiTef["enderecoSitef"] = this.getIpConfig;
    mapMsiTef["operador"] = "0001";
    mapMsiTef["data"] = "20200324";
    mapMsiTef["hora"] = "130358";
    mapMsiTef["numeroCupom"] = new Random().nextInt(9999999).toString();
    mapMsiTef["valor"] = this.getValorVenda;
    mapMsiTef["CNPJ_CPF"] = "03654119000176";
    mapMsiTef["comExterna"] = "0";
    mapMsiTef["modalidade"] = "110";
    mapMsiTef["isDoubleValidation"] = "0";
    mapMsiTef["restricoes"] = null;
    mapMsiTef["transacoesHabilitadas"] = null;
    mapMsiTef["caminhoCertificadoCA"] = "ca_cert_perm";
    mapMsiTef["restricoes"] = "transacoesHabilitadas=16;26;27";
    // ** Removida esta opção v3.70 Sitef **

    // if (this.getImpressaoHabilitada) {
    //   mapMsiTef["comprovante"] = "1";
    // } else {
    //   mapMsiTef["comprovante"] = "0";
    // }
    return mapMsiTef;
  }

  /// Realiza a formatação para realização de reimpressão MsiTef.
  ///
  /// Retorna um map <String, String>, que vai ser enviado para a Tef
  Map<String, String> get _formatarPametrosReimpressaoMsiTef {
    Map<String, String> mapMsiTef = Map();
    mapMsiTef["empresaSitef"] = "00000000";
    mapMsiTef["enderecoSitef"] = this.getIpConfig;
    mapMsiTef["operador"] = "0001";
    mapMsiTef["data"] = "20200324";
    mapMsiTef["hora"] = "130358";
    mapMsiTef["numeroCupom"] = new Random().nextInt(9999999).toString();
    mapMsiTef["valor"] = this.getValorVenda;
    mapMsiTef["CNPJ_CPF"] = "03654119000176";
    mapMsiTef["comExterna"] = "0";
    mapMsiTef["modalidade"] = "114";
    mapMsiTef["isDoubleValidation"] = "0";
    mapMsiTef["caminhoCertificadoCA"] = "ca_cert_perm";
    // ** Removida esta opção v3.70 **

    // if (this.getImpressaoHabilitada) {
    //   mapMsiTef["comprovante"] = "1";
    // } else {
    //   mapMsiTef["comprovante"] = "0";
    // }
    return mapMsiTef;
  }

  // Realiza as funções da Tef, tem como retorno um objeto dynamic que pode ser atributi a [RetornoMsiTef]
  // Recebe como parâmetros uma String que está relacionada a ação que deseja ser invocada e uma String relacionado a tef utilizada (msitef)
  // As ações possiveis são: venda, cancelamento, reimpressao, funcoes (Os valores devem ser escritos exatamente como o demonstrado)
  Future<dynamic> enviarParametrosTef({@required String tipoAcao, @required String tipoTef}) async {
    var retornoTef;
    var myjson;
    var parametroFormatado;

    switch (tipoAcao) {
      case "venda":
        parametroFormatado = _formatarPametrosVendaMsiTef;
        break;
      case "cancelamento":
        parametroFormatado = _formatarPametrosCancelamentoMsiTef;
        break;
      case "funcoes":
        parametroFormatado = _formatarPametrosFuncoesMsiTef;
        break;
      case "reimpressao":
        parametroFormatado = _formatarPametrosReimpressaoMsiTef;
        break;
    }
    myjson = await _platform.invokeMethod(
      'realizarAcaoMsitef',
      <String, dynamic>{"mapMsiTef": parametroFormatado},
    );
    retornoTef = RetornoMsiTef.fromJson(_formatarInfoRecebida(myjson));
    return retornoTef;
  }
}
