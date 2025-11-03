class EmotionHistoryEntry {
  const EmotionHistoryEntry({required this.emotionId, required this.timestamp});

  final String emotionId;
  final DateTime timestamp;

  EmotionHistoryEntry copyWith({String? emotionId, DateTime? timestamp}) {
    return EmotionHistoryEntry(
      emotionId: emotionId ?? this.emotionId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'emotion_id': emotionId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory EmotionHistoryEntry.fromJson(Map<String, dynamic> json) {
    return EmotionHistoryEntry(
      emotionId: json['emotion_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
