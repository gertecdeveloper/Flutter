import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'config_tef/operacaoRetorno.dart';
import 'config_tef/venda.dart';

//Recebe um Json obtido através da chamada feito para Tef e a formata para devolver ao Flutter.
Map<String, dynamic> _formatarInfoRecebida(myjson) {
  Map<String, dynamic> mapResultado;
  myjson = myjson.toString().replaceAll('\\n', "");
  myjson = myjson.toString().replaceAll('\\r', "");
  myjson = myjson.toString().replaceAll('\\', "");
  myjson = myjson.toString().replaceAll('"{', "{ ");
  myjson = myjson.toString().replaceAll('}"', " }");
  var parsedJson = json.decode(myjson);
  mapResultado = Map<String, dynamic>.from(parsedJson);
  return mapResultado;
}

class TefService {
  TefService(
      {String valor,
      String tipoPagamento,
      int quantParcelas,
      bool habilitarImpressao,
      String ip}) {
    this._ipConfig = ip;
    this._valorVenda = valor;
    this._tipoPagamento = tipoPagamento;
    this._quantParcelas = quantParcelas;
    this._habilitarImpressao = habilitarImpressao;
  }

  final _platform = const MethodChannel('samples.flutter.dev/gedi');
  String _valorVenda;
  String _tipoPagamento;
  int _quantParcelas;
  bool _habilitarImpressao;
  String _ipConfig;

  final String _ger7ApiVersion = "1.04";
  final String _ger7SemParcelamento = "0";
  final String _ger7ParcelaDoLoja = "1";
  final String _ger7ParcelaDoAdm = "2";
  final String _ger7DesabilitaImpressao = "0";
  final String _ger7HabilitaImpressao = "1";

//Metodos Get
  String get getIpConfig => _ipConfig;
  String get getValorVenda => _valorVenda;

  //Retorna uma lista onde o Index 0 == TipoPagamento Ger 7 e o 1 == TipoPagamento M-Sitef (Caso exista esse tipo de pagamento no Tef)
  List<String> get getTipoPagamento {
    if (_tipoPagamento == "Crédito") {
      return ["1", "3"];
    } else if (_tipoPagamento == "Debito") {
      return ["2", "2"];
    } else if (_tipoPagamento == "Voucher") {
      return ["4", "4"];
    } else {
      return ["0", "0"];
    }
  }

  int get getQuantParcelas => _quantParcelas;
  bool get getImpressaoHabilitada => _habilitarImpressao;
//Metodos Set
  set setValorVenda(String valor) => _valorVenda = valor;
  set setTipoPagamento(String tipo) => this._tipoPagamento = tipo;
  set setQuantParcelas(int quantParcelas) => _quantParcelas = quantParcelas;
  set setHabilitarImpressao(bool value) => _habilitarImpressao = value;
  set setIpConfig(String ip) => _ipConfig = ip;

  /// Realiza a formatação para reimpressão da nota emitida.
  /// '''
  /// Retorna um json, que vai ser enviado para a Tef Ger 7.
  String get _formatarPametrosReimpressaoGer7 {
    Venda venda = new Venda();
    venda.setType = "18";
    venda.setId = new Random().nextInt(9999999).toString();
    venda.setReceipt = this._ger7HabilitaImpressao;
    venda.setApiversion = this._ger7ApiVersion;
    String json = jsonEncode(venda.toJson());
    return json;
  }

  /// Realiza a formatação para abertura de funções da Tef.
  /// '''
  /// Retorna um json, que vai ser enviado para a Tef Ger 7.
  String get _formatarPametrosFuncaoGer7 {
    Venda venda = new Venda();
    venda.setType = "3";
    venda.setId = new Random().nextInt(9999999).toString();
    venda.setReceipt = this._ger7HabilitaImpressao;
    venda.setApiversion = this._ger7ApiVersion;
    String json = jsonEncode(venda.toJson());
    return json;
  }

  // Realiza a formatação para realização de venda Ger7.
  // '''
  // Retorna um json, que vai ser enviado para a Tef Ger 7.
  String get _formatarPametrosVendaGer7 {
    Venda venda = new Venda();
    venda.setType = "1";
    venda.setId = new Random().nextInt(9999999).toString();
    venda.setAmount = this.getValorVenda.toString();
    venda.setInstallments = this.getQuantParcelas.toString();
    if (venda.getInstallments == "0" || venda.getInstallments == "1") {
      venda.setInstmode = this._ger7SemParcelamento;
    } else if (true) {
      venda.setInstmode = this._ger7ParcelaDoLoja;
    } else {
      venda.setInstmode = this._ger7ParcelaDoAdm;
    }

    venda.setProduct = this.getTipoPagamento[0];

    if (this.getImpressaoHabilitada) {
      venda.setReceipt = this._ger7HabilitaImpressao;
    } else {
      venda.setReceipt = this._ger7DesabilitaImpressao;
    }
    venda.setApiversion = this._ger7ApiVersion;
    String json = jsonEncode(venda.toJson());
    return json;
  }

  /// Realiza a formatação para cancelamento da nota emitida.
  /// '''
  /// Retorna um json, que vai ser enviado para a Tef Ger 7.
  String get _formatarPametrosCancelamentoGer7 {
    Venda venda = new Venda();
    venda.setType = "2";
    venda.setId = new Random().nextInt(9999999).toString();
    venda.setApiversion = this._ger7ApiVersion;
    String json = jsonEncode(venda.toJson());
    return json;
  }

  /// Realiza a formatação para realização de venda MsiTef.
  /// '''
  /// Retorna um json, que vai ser enviado para a Tef MsiTef.
  Map<String, String> get _formatarPametrosVendaMsiTef {
    Map<String, String> mapMsiTef = Map();
    String now = new DateTime.now().toString();
    now = now.toString().replaceAll("-", "");
    now = now.toString().replaceAll(":", "");
    now = now.toString().replaceAll(".", "");
    String data = now.substring(0, 8);
    String hora = now.substring(8, 15);
    mapMsiTef["empresaSitef"] = "00000000";
    mapMsiTef["enderecoSitef"] = this.getIpConfig;
    mapMsiTef["operador"] = "0001";
    mapMsiTef["data"] = data;
    mapMsiTef["hora"] = hora;
    mapMsiTef["numeroCupom"] = new Random().nextInt(9999999).toString();
    mapMsiTef["valor"] = this.getValorVenda;
    mapMsiTef["CNPJ_CPF"] = "03654119000176";
    mapMsiTef["comExterna"] = "0";
    mapMsiTef["modalidade"] = this.getTipoPagamento[1];
    if (this.getTipoPagamento[1] == "3") {
      if (this.getQuantParcelas == 1 || this.getQuantParcelas == 0) {
        mapMsiTef["transacoesHabilitadas"] = "26";
      }
      if (true) {
        mapMsiTef["transacoesHabilitadas"] = "27";
      } else {
        mapMsiTef["transacoesHabilitadas"] = "27";
      }
      mapMsiTef["numParcelas"] = this.getQuantParcelas.toString();
    }
    if (this.getTipoPagamento[1] == "2") {
      mapMsiTef["transacoesHabilitadas"] = "16";
    }
    if (this.getTipoPagamento[1] == "0") {
      mapMsiTef["restricoes"] = "transacoesHabilitadas=16";
    }
    mapMsiTef["isDoubleValidation"] = "0";
    mapMsiTef["caminhoCertificadoCA"] = "ca_cert_perm";
    if (this.getImpressaoHabilitada) {
      mapMsiTef["comprovante"] = "1";
    } else {
      mapMsiTef["comprovante"] = "0";
    }
    return mapMsiTef;
  }

  ///Realiza a formatação para realização de cancelamento MsiTef.
  /// '''
  /// Retorna um map <String, String>, que vai ser enviado para a MsiTef.
  Map<String, String> get _formatarPametrosCancelamentoMsiTef {
    Map<String, String> mapMsiTef = Map();
    String now = new DateTime.now().toString();
    now = now.toString().replaceAll("-", "");
    now = now.toString().replaceAll(":", "");
    now = now.toString().replaceAll(".", "");
    String data = now.substring(0, 8);
    String hora = now.substring(8, 15);
    mapMsiTef["empresaSitef"] = "00000000";
    mapMsiTef["enderecoSitef"] = this.getIpConfig;
    mapMsiTef["operador"] = "0001";
    mapMsiTef["data"] = data;
    mapMsiTef["hora"] = hora;
    mapMsiTef["numeroCupom"] = new Random().nextInt(9999999).toString();
    mapMsiTef["valor"] = this.getValorVenda;
    mapMsiTef["CNPJ_CPF"] = "03654119000176";
    mapMsiTef["comExterna"] = "0";
    mapMsiTef["modalidade"] = "200";
    mapMsiTef["isDoubleValidation"] = "0";
    mapMsiTef["caminhoCertificadoCA"] = "ca_cert_perm";
    if (this.getImpressaoHabilitada) {
      mapMsiTef["comprovante"] = "1";
    } else {
      mapMsiTef["comprovante"] = "0";
    }
    return mapMsiTef;
  }

  /// Realiza a formatação para realização de configuração de funções MsiTef.
  /// '''
  /// Retorna um map <String, String>, que vai ser enviado para a Tef Ger 7.
  Map<String, String> get _formatarPametrosFuncoesMsiTef {
    Map<String, String> mapMsiTef = Map();
    String now = new DateTime.now().toString();
    now = now.toString().replaceAll("-", "");
    now = now.toString().replaceAll(":", "");
    now = now.toString().replaceAll(".", "");
    String data = now.substring(0, 8);
    String hora = now.substring(8, 15);
    mapMsiTef["empresaSitef"] = "00000000";
    mapMsiTef["enderecoSitef"] = this.getIpConfig;
    mapMsiTef["operador"] = "0001";
    mapMsiTef["data"] = data;
    mapMsiTef["hora"] = hora;
    mapMsiTef["numeroCupom"] = new Random().nextInt(9999999).toString();
    mapMsiTef["valor"] = this.getValorVenda;
    mapMsiTef["CNPJ_CPF"] = "03654119000176";
    mapMsiTef["comExterna"] = "0";
    mapMsiTef["modalidade"] = "110";
    mapMsiTef["isDoubleValidation"] = "0";
    mapMsiTef["caminhoCertificadoCA"] = "ca_cert_perm";
    mapMsiTef["restricoes"] = "transacoesHabilitadas=16;26;27";
    if (this.getImpressaoHabilitada) {
      mapMsiTef["comprovante"] = "1";
    } else {
      mapMsiTef["comprovante"] = "0";
    }
    return mapMsiTef;
  }

  /// Realiza a formatação para realização de reimpressão MsiTef.
  /// '''
  /// Retorna um map <String, String>, que vai ser enviado para a Tef Ger
  Map<String, String> get _formatarPametrosReimpressaoMsiTef {
    Map<String, String> mapMsiTef = Map();
    String now = new DateTime.now().toString();
    now = now.toString().replaceAll("-", "");
    now = now.toString().replaceAll(":", "");
    now = now.toString().replaceAll(".", "");
    String data = now.substring(0, 8);
    String hora = now.substring(8, 15);
    mapMsiTef["empresaSitef"] = "00000000";
    mapMsiTef["enderecoSitef"] = this.getIpConfig;
    mapMsiTef["operador"] = "0001";
    mapMsiTef["data"] = data;
    mapMsiTef["hora"] = hora;
    mapMsiTef["numeroCupom"] = new Random().nextInt(9999999).toString();
    mapMsiTef["valor"] = this.getValorVenda;
    mapMsiTef["CNPJ_CPF"] = "03654119000176";
    mapMsiTef["comExterna"] = "0";
    mapMsiTef["modalidade"] = "114";
    mapMsiTef["isDoubleValidation"] = "0";
    mapMsiTef["caminhoCertificadoCA"] = "ca_cert_perm";
    if (this.getImpressaoHabilitada) {
      mapMsiTef["comprovante"] = "1";
    } else {
      mapMsiTef["comprovante"] = "0";
    }
    return mapMsiTef;
  }

  // Realiza as funções da Tef, tem como retorno um objeto dynamic que pode ser atributi a [RetornoMsiTef] ou [RetornoGer7]
  // Recebe como parâmetros uma String que está relacionada a ação que deseja ser invocada e uma String relacionado a tef utilizada (ger7,msitef)
  // As ações possiveis são: venda, cancelamento, reimpressao, funcoes (Os valores devem ser escritos exatamente como o demonstrado)
  Future<dynamic> enviarParametrosTef(
      {@required String tipoAcao, @required String tipoTef}) async {
    var retornoTef;
    var myjson;
    var parametroFormatado;
    // Verificando qual foi a tef selecionada, dependendo da Tef os seus parâmetros são formatados;
    if (tipoTef == "ger7") {
      switch (tipoAcao) {
        case "venda":
          print("venda");
          parametroFormatado = _formatarPametrosVendaGer7;
          break;
        case "cancelamento":
          parametroFormatado = _formatarPametrosCancelamentoGer7;
          break;
        case "funcoes":
          parametroFormatado = _formatarPametrosFuncaoGer7;
          break;
        case "reimpressao":
          parametroFormatado = _formatarPametrosReimpressaoGer7;
          break;
      }
      myjson = await _platform.invokeMethod(
        'realizarAcaoGer7',
        <String, dynamic>{"json": parametroFormatado},
      );
      retornoTef = RetornoGer7.fromJson(_formatarInfoRecebida(myjson));
    } else {
      // Caso não for Ger7, então M-Sitef
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
    }
    return retornoTef;
  }
}
