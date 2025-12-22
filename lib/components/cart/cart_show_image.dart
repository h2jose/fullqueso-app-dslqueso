import 'package:flutter/material.dart';

class CartShowImage extends StatelessWidget {
  final String image;
  const CartShowImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        image,
        width: 26,
        height: 26,
        fit: BoxFit.cover,
        headers: const {'Access-Control-Allow-Origin': '*'},
        loadingBuilder: (context, child, progress) {
        return progress == null
          ? child
          : const CircularProgressIndicator();
        },
        errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.error),
      ),
    );
  }
}