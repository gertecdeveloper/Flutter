//* Classe que possui partes de código comuns em diversas telas
class CommonGertec {
  CommonGertec();
  final int maxLength = 32; // Armazena o tamanho maximo do códig de validação
  final int minLength = 8; // Armazena o tamanho minimo do códig de validação

  // Verifica se o código de validação do Sat inserido pelo usuario é valido
  // ? Está função foi desenvolvida para minimizar a repetição de código
  bool isCodigoValido(String codigo) {
    if (codigo.length >= this.minLength && codigo.length <= this.maxLength) {
      return true;
    }
    return false;
  }

  // Remove a mascara do CNPJ
  String removeMaskCnpj(String cnpjInput) {
    return cnpjInput.toString().replaceAll(".", "").replaceAll("/", "").replaceAll("-", "");
  }
}
