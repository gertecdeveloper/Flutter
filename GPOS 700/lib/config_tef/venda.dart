/// Classe utilizada para enviar os dados da venda para o Tef Ger7.
class Venda {
  String _type;
  String _id;
  String _amount;
  String _installments;
  String _instmode;
  String _product;
  String _receipt;
  String _apiversion;

  Map toJson() {
    Map map = new Map();
    map["amount"] = getAmount;
    map["apiversion"] = getApiversion;
    map["id"] = getId;
    map["installments"] = getInstallments;
    map["instmode"] = getInstmode;
    map["product"] = getProduct;
    map["receipt"] = getReceipt;
    map["type"] = getType;
    return map;
  }

  String get getType {
    return _type;
  }

  set setType(String type) {
    this._type = type;
  }

  String get getId {
    return _id;
  }

  set setId(String id) {
    this._id = id;
  }

  String get getAmount {
    return _amount;
  }

  set setAmount(String amount) {
    this._amount = amount;
  }

  String get getInstallments {
    return _installments;
  }

  set setInstallments(String installments) {
    this._installments = installments;
  }

  String get getInstmode {
    return _instmode;
  }

  set setInstmode(String instmode) {
    this._instmode = instmode;
  }

  String get getProduct {
    return _product;
  }

  set setProduct(String product) {
    this._product = product;
  }

  String get getReceipt {
    return _receipt;
  }

  set setReceipt(String receipt) {
    this._receipt = receipt;
  }

  String get getApiversion {
    return _apiversion;
  }

  set setApiversion(String apiversion) {
    this._apiversion = apiversion;
  }
}
