import 'package:flutter/material.dart';
import 'package:ubiiqueso/theme/color.dart';

class AppBarDefaultWidget extends StatelessWidget implements PreferredSize {
  final String text;
  final bool isBack;
  const AppBarDefaultWidget({
    super.key,
    this.text = "Fullqueso",
    this.isBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.primary,
      automaticallyImplyLeading: false,
      centerTitle: true,
      leading: isBack
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () =>Navigator.pop(context),
            )
          : null,
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget get child => throw UnimplementedError();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1);
}
