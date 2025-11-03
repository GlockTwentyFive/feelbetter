class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? timestamp,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
