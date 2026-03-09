import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showAppBar; // ← NUEVO
  final bool showActionButton;
  final VoidCallback? onActionPressed;
  final Widget? floatingActionButton;
  final bool showLeading;
  final VoidCallback? onBack;
  final IconData? iconLeanding;
  final double? sizedIconLeanding;
  final Color? colorIconLeanding;
  final IconData? iconAction;
  final double? sizedIconAction;
  final Color? colorIconAction;
  final Color? colorTitle;
  final double sizedTitle;

  const CustomScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showAppBar = true, // ← DEFAULT EN TRUE
    this.showActionButton = false,
    this.onActionPressed,
    this.floatingActionButton,
    this.showLeading = true,
    this.onBack,
    this.sizedIconLeanding,
    this.sizedIconAction,
    this.colorIconLeanding,
    this.iconLeanding,
    this.colorIconAction,
    this.iconAction,
    this.colorTitle = Colors.white,
    this.sizedTitle = 25,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: colors.primary,
              elevation: 0,
              leading: showLeading
                  ? IconButton(
                      icon: Icon(
                        iconLeanding,
                        size: sizedIconLeanding,
                        color: colorIconLeanding,
                      ),
                      onPressed: onBack ?? () => Navigator.of(context).pop(),
                    )
                  : Row(
                      children: [
                        const SizedBox(width: 15),
                        const CircleAvatar(
                          backgroundImage: AssetImage(
                            'assets/images/icon-dg-blanco.png',
                          ),
                          backgroundColor: Color(0x00FD1201),
                        ),
                      ],
                    ),
              centerTitle: true,
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: sizedTitle,
                  color: colorTitle,
                ),
              ),
              actions: [
                if (showActionButton)
                  IconButton(
                    icon: Icon(
                      iconAction,
                      size: sizedIconAction,
                      color: colorIconAction,
                    ),
                    onPressed: onActionPressed,
                  ),
              ],
            )
          : null, // ← NO APPBAR
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo-autopago.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SizedBox.expand(child: body),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
