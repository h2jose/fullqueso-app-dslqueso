import 'package:flutter/material.dart';
import 'package:ubiiqueso/theme/color.dart';

InputDecoration inputFieldDecoration(text) {
  return InputDecoration(
    labelText: text,
    isDense: true,
    labelStyle: const TextStyle(color: Colors.white),
    filled: true,
    fillColor: Colors.grey.shade700,
  );
}

InputDecoration inputFieldNameDecoration(isProcessing) {
  return InputDecoration(
    labelText: isProcessing ? 'Buscando cliente...' : 'Nombre',
    isDense: true,
    labelStyle: const TextStyle(color: Colors.white),
    filled: true,
    fillColor: Colors.grey.shade700,
  );
}

InputDecoration inputDecorationMonto() {
  return InputDecoration(
    labelText: 'Monto',
    isDense: true,
    labelStyle: const TextStyle(color: AppColor.accent),
    filled: true,
    fillColor: Colors.grey.shade900,
  );
}
