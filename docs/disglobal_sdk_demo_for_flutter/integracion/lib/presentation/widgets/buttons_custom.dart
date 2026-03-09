import 'package:flutter/material.dart';

class ButtonHomeCustom extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final Color labelColor;
  final double iconSize;
  final double buttonSize;
  final double fontSize;

  const ButtonHomeCustom({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFAA0000),
    this.iconColor = Colors.white,
    this.labelColor = const Color(0xFFAA0000),
    this.iconSize = 50,
    this.buttonSize = 100,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Material(
            color: backgroundColor,
            shape: const CircleBorder(),
            elevation: 4,
            shadowColor: Colors.black26,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: SizedBox(
                height: buttonSize,
                width: buttonSize,
                child: Icon(icon, size: iconSize, color: iconColor),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: labelColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class CustomActionsButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double fontSize;
  final Color textColor;
  final Color backgroundColor;
  final Color disabledColor;
  final double borderRadius;
  final FontWeight fontWeight;
  final double iconSize;
  final bool withIcon;
  final IconData? icon;
  final double? sideBorder;
  final Color? borderColor;

  const CustomActionsButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.withIcon,
    this.icon,
    this.iconSize = 20,
    this.width = 250,
    this.height = 70,
    this.fontSize = 20,
    this.textColor = Colors.white,
    this.backgroundColor = const Color(0xFFAA0000),
    this.disabledColor = Colors.grey,
    this.borderRadius = 12,
    this.fontWeight = FontWeight.bold,
    this.borderColor,
    this.sideBorder,
  });

  @override
  Widget build(BuildContext context) {
    // 👇 Si borderColor == null => toma backgroundColor
    final Color finalBorderColor = onPressed == null
        ? disabledColor
        : (borderColor ?? backgroundColor);

    return SizedBox(
      width: width,
      height: height,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: onPressed == null ? disabledColor : backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: finalBorderColor, width: sideBorder ?? 2),
          ),
        ),
        onPressed: onPressed,
        child: withIcon
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textColor,
                      fontWeight: fontWeight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    icon ?? Icons.arrow_forward_ios,
                    color: textColor,
                    size: iconSize,
                  ),
                ],
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                  fontWeight: fontWeight,
                ),
              ),
      ),
    );
  }
}
