class AppNotification {
  final String id;
  final String type;
  final String title;
  final String? body;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        type: j['type'] as String? ?? 'general',
        title: j['title'] as String,
        body: j['body'] as String?,
        isRead: j['readAt'] != null,
        createdAt: DateTime.parse(j['createdAt'] as String),
        data: j['data'] as Map<String, dynamic>?,
      );

  AppNotification copyWithRead() => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        isRead: true,
        createdAt: createdAt,
        data: data,
      );
}

