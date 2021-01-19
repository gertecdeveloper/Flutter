/// Classe de retorno, utilizada para atribuir o resultado do M-Sitef para um Json.
class RetornoMsiTef {
  String _cODRESP;
  String _cOMPDADOSCONF;
  String _cODTRANS;
  String _vLTROCO;
  String _rEDEAUT;
  String _bANDEIRA;
  String _nSUSITEF;
  String _nSUHOST;
  String _cODAUTORIZACAO;
  String _tipoPARC;
  String _numPARC;
  String _viaESTABELECIMENTO;
  String _viaCLIENTE;
  RetornoMsiTef.fromJson(Map<String, dynamic> json) {
    _cODRESP = json['CODRESP'];
    _cOMPDADOSCONF = json['COMP_DADOS_CONF'];
    _cODTRANS = json['CODTRANS'];
    _vLTROCO = json['VLTROCO'];
    _rEDEAUT = json['REDE_AUT'];
    _bANDEIRA = json['BANDEIRA'];
    _nSUSITEF = json['NSU_SITEF'];
    _nSUHOST = json['NSU_HOST'];
    _cODAUTORIZACAO = json['COD_AUTORIZACAO'];
    _tipoPARC = json['TIPO_PARC'];
    _numPARC = json['NUM_PARC'];
    _viaCLIENTE = json['VIA_CLIENTE'];
    _viaESTABELECIMENTO = json['VIA_ESTABELECIMENTO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CODRESP'] = this._cODRESP;
    data['COMP_DADOS_CONF'] = this._cOMPDADOSCONF;
    data['CODTRANS'] = this._cODTRANS;
    data['VLTROCO'] = this._vLTROCO;
    data['REDE_AUT'] = this._rEDEAUT;
    data['BANDEIRA'] = this._bANDEIRA;
    data['NSU_SITEF'] = this._nSUSITEF;
    data['NSU_HOST'] = this._nSUHOST;
    data['COD_AUTORIZACAO'] = this._cODAUTORIZACAO;
    data['TIPO_PARC'] = this._tipoPARC;
    data['NUM_PARC'] = this._numPARC;
    data['VIA_ESTABELECIMENTO'] = this._viaESTABELECIMENTO;
    data['VIA_CLIENTE'] = this._viaCLIENTE;
    return data;
  }

  get getNSUHOST => _nSUHOST;
  String get getSitefTipoParcela => _tipoPARC;
  get getNSUSitef => _nSUSITEF;
  get getCodTrans => _cODTRANS;
  get getNameTransCod {
    String retorno = "Valor invalido";
    switch (int.parse(_tipoPARC)) {
      case 0:
        retorno = "A vista";
        break;
      case 1:
        retorno = "Pré-Datado";
        break;
      case 2:
        retorno = "Parcelado Loja";
        break;
      case 3:
        retorno = "Parcelado Adm";
        break;
    }
    return retorno;
  }

  get getvlTroco => _vLTROCO;
  get getParcelas {
    if (_numPARC != null) {
      return _numPARC;
    }
    return "";
  }

  get getCodAutorizacao => _cODAUTORIZACAO ?? "";
  String get textoImpressoEstabelecimento => _viaESTABELECIMENTO ?? "";
  String get textoImpressoCliente => _viaCLIENTE ?? "";
  get getCompDadosConf => _cOMPDADOSCONF ?? "";
  get getCodResp => _cODRESP ?? "";
  get getRedeAut => _rEDEAUT ?? "";
  get getBandeira => _bANDEIRA ?? "";
}
