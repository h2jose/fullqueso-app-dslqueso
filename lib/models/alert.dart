class AlertModel {
  final String body;
  final String code;
  final String order;
  final int timestamp;
  final String title;
  final String ticket;

  const AlertModel({
    required this.body,
    required this.code,
    required this.order,
    required this.timestamp,
    required this.title,
    required this.ticket,
  });

  static AlertModel fromJson(json) => AlertModel(
    body: json['body'] ?? '',
    code: json['code'] ?? '',
    order: json['order'] ?? '',
    timestamp: json['timestamp'],
    title: json['title'] ?? '',
    ticket: json['ticket'] ?? '',
  );

}