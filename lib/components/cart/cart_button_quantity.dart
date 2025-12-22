import 'package:flutter/material.dart';

class CartButtonQuantity extends StatelessWidget {
  final void Function()? onTap;
  final Color color;
  final IconData icon;
  const CartButtonQuantity({super.key, this.onTap, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 45.0,
        height: 45.0,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: Colors.white,
          size: 30.0,
        ), //
      ),
    );
  }
}