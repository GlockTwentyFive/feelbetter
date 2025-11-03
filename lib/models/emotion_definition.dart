class EmotionDefinition {
  const EmotionDefinition({required this.id, required this.name, this.synonyms = const []});

  final String id;
  final String name;
  final List<String> synonyms;

  EmotionDefinition copyWith({String? id, String? name, List<String>? synonyms}) {
    return EmotionDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      synonyms: synonyms ?? this.synonyms,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'synonyms': synonyms,
      };

  factory EmotionDefinition.fromJson(Map<String, dynamic> json) {
    final rawSynonyms = json['synonyms'] as List<dynamic>? ?? const [];
    return EmotionDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      synonyms: rawSynonyms.map((item) => item.toString()).toList(),
    );
  }

  static List<EmotionDefinition> defaults() => const [
        EmotionDefinition(id: 'anger', name: 'Anger', synonyms: ['mad', 'frustrated', 'fired up']),
        EmotionDefinition(id: 'fear', name: 'Fear', synonyms: ['anxious', 'worried', 'on edge']),
        EmotionDefinition(id: 'sadness', name: 'Sadness', synonyms: ['blue', 'down', 'low energy']),
        EmotionDefinition(id: 'disgust', name: 'Disgust', synonyms: ['grossed out', 'turned off', 'repulsed']),
        EmotionDefinition(id: 'anticipation', name: 'Anticipation', synonyms: ['excited', 'eager', 'ready']),
        EmotionDefinition(id: 'joy', name: 'Joy', synonyms: ['happy', 'bright', 'uplifted']),
        EmotionDefinition(id: 'surprise', name: 'Surprise', synonyms: ['shocked', 'taken aback', 'caught off guard']),
        EmotionDefinition(id: 'trust', name: 'Trust', synonyms: ['supported', 'safe with others', 'grounded']),
        EmotionDefinition(id: 'overwhelmed', name: 'Overwhelmed', synonyms: ['stressed', 'flooded', 'too much at once']),
      ];

  static bool listEquals(List<EmotionDefinition> a, List<EmotionDefinition> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final itemA = a[i];
      final itemB = b[i];
      if (itemA.id != itemB.id || itemA.name != itemB.name) {
        return false;
      }
      if (itemA.synonyms.length != itemB.synonyms.length) {
        return false;
      }
      for (var j = 0; j < itemA.synonyms.length; j++) {
        if (itemA.synonyms[j] != itemB.synonyms[j]) {
          return false;
        }
      }
    }
    return true;
  }
}
