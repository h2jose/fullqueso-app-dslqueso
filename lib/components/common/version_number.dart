import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionNumber extends StatefulWidget {
  final Color color;
  const VersionNumber({
    super.key,
    required this.color,
  });

  @override
  State<VersionNumber> createState() => _VersionNumberState();
}

class _VersionNumberState extends State<VersionNumber> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  void _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;
    // debugPrint("$version");
    setState(() {
      _version = version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "Version $_version",
      textScaler: const TextScaler.linear(0.8),
      textAlign: TextAlign.center,
      style: TextStyle(color: widget.color),
    );
  }
}
