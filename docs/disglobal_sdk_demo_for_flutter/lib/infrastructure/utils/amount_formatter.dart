import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AmountFormatter extends TextInputFormatter {
  final NumberFormat numberFormat = NumberFormat.currency(
    locale: 'es_VE',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Si borra todo → mostramos 0,00
    if (newValue.text.isEmpty) {
      final formatted = numberFormat.format(0).trim();
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // Solo números
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    double value = double.parse(digits) / 100;

    final newText = numberFormat.format(value).trim();

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
