import 'package:flutter/material.dart';

class CheckoutImageProduct extends StatelessWidget {
  final String imagePath;
  const CheckoutImageProduct({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imagePath,
        width: 26,
        height: 26,
        fit: BoxFit.cover,
        headers: const {'Access-Control-Allow-Origin': '*'},
        loadingBuilder: (context, child, progress) {
          return progress == null ? child : const CircularProgressIndicator();
        },
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      ),
    );
  }
}