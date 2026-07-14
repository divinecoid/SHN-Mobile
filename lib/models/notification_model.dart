class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String? type;
  final int? createdBy;
  final DateTime? createdAt;
  bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    this.createdBy,
    this.createdAt,
    this.isRead = false,
    this.readAt,
    this.data,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'],
      createdBy: json['created_by'] != null ? int.tryParse(json['created_by'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      isRead: json['is_read'] == true || json['is_read'] == 1 || json['is_read'].toString() == '1',
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }
}
