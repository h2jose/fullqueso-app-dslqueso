import 'package:ubiiqueso/theme/color.dart';
import 'package:flutter/material.dart';

class FormInput extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final IconData? icon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;

  final String formProperty;
  final Map<String, String> formValues;

  const FormInput({
    Key? key,
    this.hintText,
    this.labelText,
    this.helperText,
    this.icon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    required this.formProperty,
    required this.formValues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        maxLines: maxLines,
        autofocus: false,
        initialValue: '',
        textCapitalization: TextCapitalization.words,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: (value) => formValues[formProperty] = value,
        validator: (value) {
          if (value == null) return "This field is required";

          if (value.trim().isEmpty) {
            return "This field is required";
          } else if (formProperty == 'email') {
            String pattern =
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp regExp = RegExp(pattern);
            return regExp.hasMatch(value) ? null : 'Email not valid';
          } else if (formProperty == 'email2') {
            return formValues['email']?.trim().toLowerCase() !=
                    formValues['email2']?.trim().toLowerCase()
                ? 'Emails not matching'
                : null;
          }

          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          isDense: true,
          labelStyle: const TextStyle(color: AppColor.primary),
          hintStyle: const TextStyle(color: AppColor.primary),
          helperStyle: const TextStyle(color: AppColor.primary),
          enabledBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 0.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          hintText: hintText,
          labelText: labelText,
          helperText: helperText,
          // prefixIcon: Icon( Icons.verified_user_outlined ),
          suffixIcon: suffixIcon == null ? null : Icon(suffixIcon),
          icon: icon == null ? null : Icon(icon),
        ));
  }
}
