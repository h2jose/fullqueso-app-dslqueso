import 'dart:convert';

class VersionModel {
  final String app;
  final String version;
  final String file;
  final String date;
  final bool active;

  const VersionModel({
    required this.app,
    required this.version,
    required this.file,
    required this.date,
    required this.active,
  });

  static VersionModel fromJson(json) => VersionModel(
    app: json['app'] ?? '',
    version: json['version'] ?? '',
    file: json['file'] ?? '',
    date: json['date'] ?? '',
    active: json['active'] ?? false,
  );

  static VersionModel fromMap(String json) {
    final Map<String, dynamic> map = jsonDecode(json);
    return VersionModel(
      app: map['app'] ?? '',
      version: map['version'] ?? '',
      file: map['file'] ?? '',
      date: map['date'] ?? '',
      active: map['active'] ?? false,
    );
  }
}