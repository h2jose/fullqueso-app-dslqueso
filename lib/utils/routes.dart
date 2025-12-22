import 'package:flutter/material.dart';
import 'package:ubiiqueso/pages/pages.dart';

Map<String, Widget Function(BuildContext context)> routes = {
  '/': (context) => const HomePage(),
  '/dashboard': (context) => const DashboardPage(),
  '/lastorders': (context) => const LastOrdersPage(),
  '/signout': (context) => const SignoutPage(),
};