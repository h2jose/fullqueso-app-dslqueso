import 'package:disglobal_sdk_demo_for_flutter/infrastructure/utils/amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomTextFieldBox extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String> onValue;
  final String hintText;

  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  final Color textColor;
  final double fontSize;
  final TextAlign textAlign;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  final IconData? suffixIcon;
  final VoidCallback? onIconPressed;

  final double width;
  final double height;
  final EdgeInsets contentPadding;
  final double sizedIcon;

  const CustomTextFieldBox({
    super.key,
    required this.onValue,
    this.controller,
    this.hintText = 'Ingrese un valor',
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.borderRadius = 10,
    this.textColor = const Color(0xFFAA0000),
    this.fontSize = 20,
    this.textAlign = TextAlign.center,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.suffixIcon,
    this.onIconPressed,
    this.width = 300,
    this.height = 80,
    this.sizedIcon = 32,
    this.contentPadding = const EdgeInsets.symmetric(
      vertical: 25,
      horizontal: 16,
    ),
  });

  @override
  State<CustomTextFieldBox> createState() => CustomTextFieldBoxState();
}

class CustomTextFieldBoxState extends State<CustomTextFieldBox> {
  late TextEditingController textController;
  late FocusNode focusNode;

  void reset() {
    textController.clear();
  }

  @override
  void initState() {
    super.initState();
    textController = widget.controller ?? TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outline = OutlineInputBorder(
      borderSide: BorderSide(
        color: widget.borderColor,
        width: widget.borderWidth,
      ),
      borderRadius: BorderRadius.circular(widget.borderRadius),
    );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextFormField(
        controller: textController,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey, fontSize: widget.fontSize),
          enabledBorder: outline,
          focusedBorder: outline,
          filled: true,
          fillColor: widget.backgroundColor, // NUEVO
          suffixIcon: widget.suffixIcon != null
              ? IconButton(
                  icon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      widget.suffixIcon,
                      color: widget.borderColor,
                      size: widget.sizedIcon,
                    ),
                  ),
                  onPressed: () {
                    final value = textController.text.trim();
                    final isValidLength =
                        value.length >= 7 && value.length <= 9;

                    if (!isValidLength) {
                      print('⚠️ Longitud inválida: $value');
                      return;
                    }

                    focusNode.unfocus();
                    textController.clear();
                    widget.onValue(value);
                    widget.onIconPressed?.call();
                  },
                )
              : null,
          contentPadding: widget.contentPadding,
        ),
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w500,
          color: widget.textColor,
        ),
        cursorColor: widget.textColor,
        textAlign: widget.textAlign,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        onFieldSubmitted: (value) {
          focusNode.unfocus();
          widget.onValue(value);
        },
        onTapOutside: (_) => focusNode.unfocus(),
      ),
    );
  }
}

class CustomAmountField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String> onValue;
  final String hintText;

  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  final Color textColor;
  final double fontSize;

  final double width;
  final double height;
  final EdgeInsets contentPadding;

  const CustomAmountField({
    super.key,
    required this.onValue,
    this.controller,
    this.hintText = "0,00",
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.borderRadius = 10,
    this.textColor = const Color(0xFFAA0000),
    this.fontSize = 26,
    this.width = 300,
    this.height = 80,
    this.contentPadding = const EdgeInsets.symmetric(
      vertical: 20,
      horizontal: 16,
    ),
  });

  @override
  State<CustomAmountField> createState() => _CustomAmountFieldState();
}

class _CustomAmountFieldState extends State<CustomAmountField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();

    // Valor inicial por defecto "0,00"
    if (controller.text.isEmpty) {
      controller.text = NumberFormat.currency(
        locale: 'es_VE',
        symbol: '',
        decimalDigits: 2,
      ).format(0).trim();
    }
  }

  double _parseAmount(String formatted) {
    final cleaned = formatted.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.00;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: widget.fontSize,
          color: widget.textColor,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: widget.fontSize, color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.borderColor,
              width: widget.borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.borderColor,
              width: widget.borderWidth,
            ),
          ),
          filled: true,
          fillColor: widget.backgroundColor,
          contentPadding: widget.contentPadding,
        ),
        inputFormatters: [AmountFormatter()],
        onChanged: (value) {
          final parsed = _parseAmount(value);
          final fixed = parsed.toStringAsFixed(2);
          widget.onValue(fixed);
        },
      ),
    );
  }
}
