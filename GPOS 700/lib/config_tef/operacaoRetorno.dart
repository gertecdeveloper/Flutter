///Classe de retorno, utilizada para atribuir o resultado do Tef para um Json.
class RetornoGer7 {
  String _version;
  String _status;
  String _config;
  String _license;
  String _terminal;
  String _merchant;
  String _id;
  String _type;
  String _product;
  String _response;
  String _authorization;
  String _amount;
  String _installments;
  String _instmode;
  String _stan;
  String _rrn;
  String _time;
  String _print;
  String _track2;
  String _aid;
  String _cardholder;
  String _prefname;
  String _errcode;
  String _errmsg;
  String _label;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version'] = this.getVersion;
    data['status'] = this.getStatus;
    data['config'] = this.getConfig;
    data['license'] = this.getLicens;
    data['terminal'] = this.getTerminal;
    data['merchant'] = this.getMerchant;
    data['id'] = this.getId;
    data['type'] = this.getType;
    data['product'] = this.getProduct;
    data['response'] = this.getResponse;
    data['authorizationType'] = this.getAuthorization;
    data['amount'] = this.getAmount;
    data['installments'] = this.getInstallments;
    data['instmode'] = this.getInstmode;
    data['stan'] = this.getStan;
    data['rrn'] = this.getRrn;
    data['time'] = this.getTime;
    data['print'] = this.getPrint;
    data['track2'] = this.getTrack2;
    data['aid'] = this.getAid;
    data['cardholder'] = this.getCardholder;
    data['prefname'] = this.getPrefname;
    data['errcode'] = this.getErrcode;
    data['errmsg'] = this.getErrmsg;
    data['label'] = this.getLabel;
    return data;
  }

  RetornoGer7.fromJson(Map<String, dynamic> json) {
    _version = json['version'];
    _status = json['status'];
    _config = json['config'];
    _license = json['license'];
    _terminal = json['terminal'];
    _merchant = json['merchant'];
    _id = json['id'];
    _type = json['type'];
    _product = json['product'];
    _response = json['response'];
    _authorization = json['authorizationType'];
    _amount = json['amount'];
    _installments = json['installments'];
    _instmode = json['instmode'];
    _stan = json['stan'];
    _rrn = json['rrn'];
    _time = json['time'];
    _print = json['print'];
    _track2 = json['track2'];
    _aid = json['aid'];
    _cardholder = json['cardholder'];
    _prefname = json['prefname'];
    _errcode = json['errcode'];
    _errmsg = json['errmsg'];
    _label = json['label'];
  }

  String get getVersion {
    return _version ?? "";
  }

  set setVersion(String version) {
    this._version = version;
  }

  String get getStatus {
    return _status ?? "";
  }

  set setStatus(String status) {
    this._status = status;
  }

  String get getConfig {
    return _config ?? "";
  }

  set setConfig(String config) {
    this._config = config;
  }

  String get getLicens {
    return _license ?? "";
  }

  set setLicense(String license) {
    this._license = license;
  }

  String get getTerminal {
    return _terminal ?? "";
  }

  set setTerminal(String terminal) {
    this._terminal = terminal;
  }

  String get getMerchant {
    return _merchant ?? "";
  }

  set setMerchant(String merchant) {
    this._merchant = merchant;
  }

  String get getId {
    return _id ?? "";
  }

  set setId(String id) {
    this._id = id;
  }

  String get getType {
    return _type ?? "";
  }

  set setType(String type) {
    this._type = type;
  }

  String get getProduct {
    return _product ?? "";
  }

  set setProduct(String product) {
    this._product = product;
  }

  String get getResponse {
    return _response ?? "";
  }

  set setResponse(String response) {
    this._response = response;
  }

  String get getAuthorization {
    return _authorization ?? "";
  }

  set setAuthorization(String authorization) {
    this._authorization = authorization;
  }

  String get getAmount {
    return _amount ?? "";
  }

  set setAmount(String amount) {
    this._amount = amount;
  }

  String get getInstallments {
    return _installments ?? "";
  }

  set setInstallments(String installments) {
    this._installments = installments;
  }

  String get getInstmode {
    return _instmode ?? "";
  }

  set setInstmode(String instmode) {
    this._instmode = instmode;
  }

  String get getStan {
    return _stan ?? "";
  }

  set setStan(String stan) {
    this._stan = stan;
  }

  String get getRrn {
    return _rrn ?? "";
  }

  set setRrn(String rrn) {
    this._rrn = rrn;
  }

  String get getTime {
    return _time ?? "";
  }

  set setTime(String time) {
    this._time = time;
  }

  String get getPrint {
    return _print ?? "";
  }

  set setPrint(String print) {
    this._print = print;
  }

  String get getTrack2 {
    return _track2 ?? "";
  }

  set setTrack2(String track2) {
    this._track2 = track2;
  }

  String get getAid {
    return _aid ?? "";
  }

  set setAid(String aid) {
    this._aid = aid;
  }

  String get getCardholder {
    return _cardholder ?? "";
  }

  set setCardholder(String cardholder) {
    this._cardholder = cardholder;
  }

  String get getPrefname {
    return _prefname ?? "";
  }

  set setPrefname(String prefname) {
    this._prefname = prefname;
  }

  String get getErrcode {
    return _errcode ?? "";
  }

  set setErrcode(String errcode) {
    this._errcode = errcode;
  }

  String get getErrmsg {
    return _errmsg ?? "";
  }

  set setErrmsg(String errmsg) {
    this._errmsg = errmsg;
  }

  String get getLabel {
    return _label ?? "";
  }

  set setLabel(String label) {
    this._label = label;
  }
}

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
  get textoImpressoEstabelecimento => _viaESTABELECIMENTO ?? "";
  get textoImpressoCliente => _viaCLIENTE ?? "";
  get getCompDadosConf => _cOMPDADOSCONF ?? "";
  get getCodResp => _cODRESP ?? "";
  get getRedeAut => _rEDEAUT ?? "";
  get getBandeira => _bANDEIRA ?? "";
}
