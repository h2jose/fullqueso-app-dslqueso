//? TRANSFORMAR AMOUNT DECIMAL EN STRING A ENTERO EN STRING "240.10" → "24010"
String transformarAmountaEntero(String numero) {
  // Elimina todos los puntos y comas del string
  return numero.toString().replaceAll(RegExp(r'[.,]'), '');
}