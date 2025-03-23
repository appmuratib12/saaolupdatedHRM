class NotificationData {
  final int? id;
  final String? title;
  final String? body;
  final String? imageUrl;
  final String? date;

  NotificationData({
    this.id,
    this.title,
    this.body,
    this.imageUrl,
    String? date,
  }) : date = date ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'date': date,
    };
  }

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      id: map['id'] as int?,
      title: map['title'] as String?,
      body: map['body'] as String?,
      imageUrl: map['imageUrl'] as String?,
      date: map['date'] as String?,
    );
  }
}