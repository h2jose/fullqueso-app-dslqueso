import 'package:flutter/material.dart';

class ShowErrorContainer extends StatelessWidget {
  final String? errorMessage;
  const ShowErrorContainer({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: errorMessage != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: errorMessage != null
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              margin: const EdgeInsets.only(bottom: 8.0),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                border: Border.all(color: Colors.red.shade300),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                errorMessage!,
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}