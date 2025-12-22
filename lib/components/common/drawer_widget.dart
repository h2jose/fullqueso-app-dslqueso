import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ubiiqueso/components/common/list_tile_widget.dart';
import 'package:ubiiqueso/components/common/version_number.dart';
import 'package:ubiiqueso/pages/home_page.dart';
import 'package:ubiiqueso/pages/signout_page.dart';
import 'package:ubiiqueso/services/shared_service.dart';
import 'package:ubiiqueso/theme/color.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            child: Column(
              children: [
                Image.asset('assets/images/icon4.png', width: 150),
                const Center(child: VersionNumber(color: Colors.white)),
              ],
            )
          ),
          ListTileWidget(text: "Menu", icon: Icons.home, color: Colors.white, onTap: () => Navigator.pop(context),),
          const SizedBox(height: 5,),
          ListTileWidget(
            text: "Ultimas Ordenes",
            icon: Icons.shopping_cart,
            color: Colors.white,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/lastorders');
            },
          ),
          const SizedBox(
            height: 5,
          ),
          // ListTileWidget(
          //   text: "Impresora",
          //   icon: Icons.print,
          //   color: Colors.white,
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.pushNamed(context, '/printer');
          //   },
          // ),

          // ListTileWidget(
          //   text: "Server Local",
          //   icon: Icons.adf_scanner,
          //   color: Colors.white,
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.pushNamed(context, '/localserver');
          //   },
          // ),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child:   ListTileWidget(text: "Cierre POS", icon: Icons.exit_to_app, color: Colors.white, onTap: (){
              Navigator.pop(context);

              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignoutPage()));

               // SharedService.shopId = '';
               //  SharedService.shopCode = '';
               //  SharedService.shopName = '';
               //  SharedService.punto = 'PUNTO 1';
               //  FirebaseAuth.instance.signOut();
               //  Navigator.pushAndRemoveUntil(
               //      context,
               //      MaterialPageRoute(builder: (context) => const HomePage()),
               //      (route) => false);


            },),
          ),

        ],
      ),
    );
  }
}