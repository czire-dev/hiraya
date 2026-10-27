class AppNotification {
  AppNotification({
    required this.id,
    required this.userId,
    required this.message,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final String userId;
  final String message;
  final DateTime createdAt;
  bool read;
}
