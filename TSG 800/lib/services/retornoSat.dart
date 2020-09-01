class RetornoSat {
  List<String> _retornoPipe; // Armazena o retorno em forma de lista String
  String _operacao; // Armazena a operacao solicitada
  bool retornoDiferente;
  String _retornoPipeCompleto;
  RetornoSat(String operacao, String retornopipe) {
    this._retornoPipeCompleto = retornopipe;
    this._retornoPipe = retornopipe.split("|");
    this._operacao = operacao;
    /** 
      O resultado das operações solicitadas é uma String divida por Pipes, exemplo: “numeroSessao|EEEEE|mensagem|cod|mensagemSEFAZ”
      Mas nem todos os retornos são padrões, existem alguns com posições diferentes de um mesmo valor.
      Para solucionar este obstaculo foi elabarado uma condição que verifica se a operação solicitada é uma das três(que possuem maior discrepância de posições)
      Caso sim, é retornado uma posição diferente do mesmo valor, caso contrario é retornado a posição padrão
    **/
    retornoDiferente = _operacao == 'AssociarSAT' || _operacao == 'EnviarTesteVendas' || _operacao == 'CancelarUltimaVenda';
  }
  // Retorna a String divida por pipe sem formatações
  get getResultadoCompleto => _retornoPipeCompleto;

  // Retorna a Operacao que foi solicitada
  get getOperacao => _operacao;

  // Verifica se tem algum problema no retorno da operacao solicitada
  get getErroSat {
    //* Se o tamanho da lista de informações obtidas do retorno [_retornoPipe] for igual <= 1, provavelmente ocorreu um erro.
    if (_retornoPipe.length <= 1) {
      // Verifica se houve um erro ao se conectar com o Sat
      if (_retornoPipe[0] == 'Failed to find SAT device.') {
        return 'Dispositivo SAT não localizado';
      } else {
        // Caso não seja um erro de comunicação com o SAT retorna o erro que ocorreu
        return _retornoPipe[0];
      }
    }
    //* Verifica se o código de ativação é invalido
    if (getMensagem == "Codigo de ativação inválido" || getMensagem == "Codigo ativação inválido") {
      return getMensagem;
    }
    // Caso não exista nenhum erro
    return "";
  }

  get getNumeroSessao {
    try {
      return _retornoPipe[0];
    } catch (e) {
      return "";
    }
  }

  get getNumeroEEEE {
    try {
      return _retornoPipe[1];
    } catch (e) {
      return "";
    }
  }

  get getMensagem {
    try {
      if (retornoDiferente) return _retornoPipe[3];
      return _retornoPipe[2];
    } catch (e) {
      return "";
    }
  }

  // Dado somente presente na três funções(AssociarSAT, Enviar Teste Venda e Cancelar Ultima Venda)
  get getNumeroCCCC {
    try {
      if (retornoDiferente) return _retornoPipe[2];
      return "";
    } catch (e) {
      return "";
    }
  }

  get getNumeroCod {
    try {
      if (retornoDiferente) return _retornoPipe[4];
      return _retornoPipe[3];
    } catch (e) {
      return "";
    }
  }

  get getMensagemSefaz {
    try {
      if (retornoDiferente) return _retornoPipe[5];
      return _retornoPipe[4];
    } catch (e) {
      return "";
    }
  }

  // Dado exclusivo do retorno da operação Ativar Sat
  get getCodigoCSR {
    try {
      if (_operacao == 'AtivarSAT') return _retornoPipe[5];
      return "";
    } catch (e) {
      return "";
    }
  }

  // Dado exclusivo do retorno da operação Extrair Log
  get getLogBase64 {
    try {
      if (_operacao == 'ExtrairLog') return _retornoPipe[5];
      return "";
    } catch (e) {
      return "";
    }
  }

  // Dado somente presente na três funções(EnviarTesteFim, Enviar Teste Venda e Cancelar Ultima Venda)
  get getArquivoCFeBase64 {
    try {
      if (_operacao == 'EnviarTesteVendas' || _operacao == 'CancelarUltimaVenda') {
        return _retornoPipe[6];
      } else if (_operacao == 'EnviarTesteFim') {
        return _retornoPipe[5];
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  // Dado somente presente na três funções(EnviarTesteFim, Enviar Teste Venda e Cancelar Ultima Venda)
  get getTimeStamp {
    try {
      if (_operacao == 'EnviarTesteVendas' || _operacao == 'CancelarUltimaVenda') {
        return _retornoPipe[7];
      } else if (_operacao == 'EnviarTesteFim') {
        return _retornoPipe[6];
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  // Dado exclusivo do retorno da operação TEnviarTesteFim
  get getNumDocFiscal {
    try {
      if (_operacao == "EnviarTesteFim") return _retornoPipe[7];
      return "";
    } catch (e) {
      return "";
    }
  }

  // Dado somente presente na três funções(EnviarTesteFim, Enviar Teste Venda e Cancelar Ultima Venda)
  get getChaveConsulta {
    try {
      if (_operacao == 'EnviarTesteVendas' || _operacao == 'CancelarUltimaVenda' || _operacao == 'EnviarTesteFim') return _retornoPipe[8];
      return "";
    } catch (e) {
      return "";
    }
  }

  // Dado somente presente nas funções(Enviar Teste Venda e Cancelar Ultima Venda)
  get getValorTotalCFe {
    try {
      if (_operacao == 'EnviarTesteVendas' || _operacao == 'CancelarUltimaVenda')
        return _retornoPipe[9];
      else
        return "";
    } catch (e) {
      return "";
    }
  }

  // Dado somente presente nas funções(Enviar Teste Venda e Cancelar Ultima Venda)
  get getCPFCNPJValue {
    try {
      if (_operacao == 'EnviarTesteVendas' || _operacao == 'CancelarUltimaVenda')
        return _retornoPipe[10];
      else
        return "";
    } catch (e) {
      return "";
    }
  }

  // Dado somente presente nas funções(Enviar Teste Venda e Cancelar Ultima Venda)
  get getAssinaturaQRCODE {
    try {
      if (_operacao == 'EnviarTesteVendas' || _operacao == 'CancelarUltimaVenda')
        return _retornoPipe[11];
      else
        return "";
    } catch (e) {
      return "";
    }
  }

  get getEstadoDeOperacao {
    try {
      if (_retornoPipe[27] == "0")
        return "DESBLOQUEADO";
      else if (_retornoPipe[27] == "1")
        return "BLOQUEADO SEFAZ";
      else if (_retornoPipe[27] == "2")
        return "BLOQUEIO CONTRIBUINTE";
      else if (_retornoPipe[27] == "3")
        return "BLOQUEIO AUTÔNOMO";
      else if (_retornoPipe[27] == "4") return "BLOQUEIO PARA DESATIVAÇÃO";
    } catch (e) {
      return "";
    }
  }

  get getNumeroSerieSat {
    try {
      return _retornoPipe[5] + "\n";
    } catch (e) {
      return "";
    }
  }

  get getTipoLan => _retornoPipe[6] + "\n";
  get getIpSat => _retornoPipe[7] + "\n";
  get getMacSat => _retornoPipe[8] + "\n";
  get getMascara => _retornoPipe[9] + "\n";
  get getGateway => _retornoPipe[10] + "\n";
  get getDns1 => _retornoPipe[11] + "\n";
  get getDns2 => _retornoPipe[12] + "\n";
  get getStatusRede => _retornoPipe[13] + "\n";
  get getNivelBateria => _retornoPipe[14] + "\n";
  get getMemoriaDeTrabalhoTotal => _retornoPipe[15] + "\n";
  get getMemoriaDeTrabalhoUsada => _retornoPipe[16] + "\n";
  get getDataHora =>
      _retornoPipe[17].substring(6, 8) +
      "/" +
      _retornoPipe[17].substring(4, 6) +
      "/" +
      _retornoPipe[17].substring(0, 4) +
      "  " +
      _retornoPipe[17].substring(8, 10) +
      ":" +
      _retornoPipe[17].substring(10, 12) +
      ":" +
      _retornoPipe[17].substring(12, 14) +
      "\n";

  get getVersao => _retornoPipe[18] + "\n";
  get getVersaoLeiaute => _retornoPipe[19] + "\n";
  get getUltimoCfeEmitido => _retornoPipe[20] + "\n";
  get getPrimeiroCfeMemoria => _retornoPipe[21] + "\n";
  get getUltimoCfeMemoria => _retornoPipe[22] + "\n";
  get getUltimaTransmissaoSefazDataHora =>
      _retornoPipe[23].substring(6, 8) +
      "/" +
      _retornoPipe[23].substring(4, 6) +
      "/" +
      _retornoPipe[23].substring(0, 4) +
      " " +
      _retornoPipe[23].substring(8, 10) +
      ":" +
      _retornoPipe[23].substring(10, 12) +
      ":" +
      _retornoPipe[23].substring(12, 14) +
      "\n";

  get getUltimaComunicacaoSefazData =>
      _retornoPipe[24].substring(6, 8) +
      "/" +
      _retornoPipe[24].substring(4, 6) +
      "/" +
      _retornoPipe[24].substring(0, 4) +
      " " +
      _retornoPipe[24].substring(8, 10) +
      ":" +
      _retornoPipe[24].substring(10, 12) +
      ":" +
      _retornoPipe[24].substring(12, 14) +
      "\n";
}
