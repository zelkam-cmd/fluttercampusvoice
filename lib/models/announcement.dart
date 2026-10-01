class Announcement {
  final String id;
  final String title;
  final String content;
  final String date;
  final String priority; // 'high', 'normal', 'low'

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.priority = 'normal',
  });

  factory Announcement.fromJson(Map<String, dynamic> json, [String? id]) {
    return Announcement(
      id: id ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'priority': priority,
    };
  }
}
