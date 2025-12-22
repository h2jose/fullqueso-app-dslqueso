import 'package:flutter/material.dart';

class ListTileWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;
  final void Function()? onTap;

  const ListTileWidget({super.key, required this.text, required this.icon, this.onTap, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          size: 32,
          color: color,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: color,
          ),
        ),
      ),
    );
  }
}