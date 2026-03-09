import 'package:flutter/material.dart';

class LogoPrincipal extends StatelessWidget {
  final double? widthImg;
  final double? heightImg;
  const LogoPrincipal({super.key, this.widthImg, this.heightImg});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthImg,
      height: heightImg,
      child: Image.asset('assets/images/logo-dg-blanco.png'),
    );
  }
}
