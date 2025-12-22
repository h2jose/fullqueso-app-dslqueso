import 'package:flutter/material.dart';
import 'package:ubiiqueso/components/common/common.dart';
import 'package:ubiiqueso/pages/signout_page.dart';
import 'package:ubiiqueso/theme/color.dart';

class AppBarWidget extends StatelessWidget implements PreferredSize {
  bool leading;
  AppBarWidget({
    super.key,
    this.leading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.primary,
      automaticallyImplyLeading: false,
      leading: leading
          ? IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_left_outlined,
                size: 35,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/dashboard');
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.asset('assets/images/avatar.png', height: 30),
                ),
              ),
            ),
      centerTitle: true,
      title: const TitleAppBarWidget(),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const SignoutPage()),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget get child => throw UnimplementedError();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1);
}
