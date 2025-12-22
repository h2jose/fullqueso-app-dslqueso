import 'dart:convert';

import 'package:blinking_text/blinking_text.dart';
import 'package:ubiiqueso/models/version.dart';
import 'package:ubiiqueso/theme/color.dart';
import 'package:ubiiqueso/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class UpdateAvailable extends StatefulWidget {
  const UpdateAvailable({super.key});

  @override
  State<UpdateAvailable> createState() => _UpdateAvailableState();
}

class _UpdateAvailableState extends State<UpdateAvailable> {

  bool isUpdateAvailable = false;

  Future<void> launchInBrowser(Uri urlUpdate) async {
    if (!await launchUrl(
      urlUpdate,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $urlUpdate';
    }
  }

  bool isNewVersionAvailable(String currentVersion, String latestVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> latest = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < current.length; i++) {
      if (latest[i] > current[i]) {
        return true;
      } else if (latest[i] < current[i]) {
        return false;
      }
    }
    return false;
  }

  Future<void> checkForUpdates() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      final response =
          await http.get(Uri.parse('$uriBase/version/last/?app=$appName'));
      if (response.statusCode == 200) {
        final versionData = VersionModel.fromJson(json.decode(response.body));
        String latestVersion = versionData.version;

        if (isNewVersionAvailable(currentVersion, latestVersion)) {
            setState(() {
              isUpdateAvailable = true;
            });
        }

        // print("currentVersion: ${currentVersion}");
        // print("latestVersion: ${latestVersion}");

        // if (currentVersion != versionData.version) {
        //   setState(() {
        //     isUpdateAvailable = true;
        //   });
        // }
      } else {
        throw Exception('Error al obtener la versión');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    checkForUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await launchInBrowser(Uri.parse(urlUpdate));
      },
      child: isUpdateAvailable ? Container(
        color: AppColor.accent,
        width: double.infinity,
        padding: const EdgeInsets.all(10.0),
        child: const BlinkText(
          'Actualiza la APP, PRESIONA AQUÍ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ) : Container(),
    );
  }
}