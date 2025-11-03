enum StrategyCategory { immediate, shortTerm, longTerm }

extension StrategyCategoryLabel on StrategyCategory {
  String get storageKey {
    switch (this) {
      case StrategyCategory.immediate:
        return 'immediate';
      case StrategyCategory.shortTerm:
        return 'short_term';
      case StrategyCategory.longTerm:
        return 'long_term';
    }
  }

  String get displayLabel {
    switch (this) {
      case StrategyCategory.immediate:
        return 'Start here (next 2 minutes)';
      case StrategyCategory.shortTerm:
        return 'Next few hours';
      case StrategyCategory.longTerm:
        return 'Keep the change going';
    }
  }
}

class EmotionStrategySet {
  const EmotionStrategySet({
    required this.emotionId,
    required this.displayName,
    required this.scientificSummary,
    this.immediate = const [],
    this.shortTerm = const [],
    this.longTerm = const [],
    this.supportingFriend = const [],
    this.repairingWhenResponsible = const [],
  });

  final String emotionId;
  final String displayName;
  final String scientificSummary;
  final List<StrategyItem> immediate;
  final List<StrategyItem> shortTerm;
  final List<StrategyItem> longTerm;
  final List<StrategyItem> supportingFriend;
  final List<StrategyItem> repairingWhenResponsible;

  factory EmotionStrategySet.fromJson(Map<String, dynamic> json) {
    final strategies = Map<String, dynamic>.from(json['strategies'] as Map);
    final relationship = Map<String, dynamic>.from(json['relationship_support'] as Map? ?? const {});
    List<StrategyItem> parseList(String key) {
      final raw = strategies[key] as List<dynamic>? ?? const [];
      return raw
          .map((item) => StrategyItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    List<StrategyItem> parseRelationship(String key) {
      final raw = relationship[key] as List<dynamic>? ?? const [];
      return raw
          .map((item) => StrategyItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return EmotionStrategySet(
      emotionId: json['emotion_id'] as String,
      displayName: json['display_name'] as String,
      scientificSummary: json['scientific_summary'] as String? ?? '',
      immediate: parseList('immediate'),
      shortTerm: parseList('short_term'),
      longTerm: parseList('long_term'),
      supportingFriend: parseRelationship('friend_support'),
      repairingWhenResponsible: parseRelationship('self_repair'),
    );
  }

  factory EmotionStrategySet.empty(String emotionId, {String? name, String? summary}) {
    return EmotionStrategySet(
      emotionId: emotionId,
      displayName: name ?? emotionId,
      scientificSummary: summary ?? '',
      immediate: const [],
      shortTerm: const [],
      longTerm: const [],
      supportingFriend: const [],
      repairingWhenResponsible: const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'emotion_id': emotionId,
        'display_name': displayName,
        'scientific_summary': scientificSummary,
        'strategies': {
          'immediate': immediate.map((item) => item.toJson()).toList(),
          'short_term': shortTerm.map((item) => item.toJson()).toList(),
          'long_term': longTerm.map((item) => item.toJson()).toList(),
        },
        'relationship_support': {
          'friend_support': supportingFriend.map((item) => item.toJson()).toList(),
          'self_repair': repairingWhenResponsible.map((item) => item.toJson()).toList(),
        },
      };

  EmotionStrategySet copyWith({
    String? displayName,
    String? scientificSummary,
    List<StrategyItem>? immediate,
    List<StrategyItem>? shortTerm,
    List<StrategyItem>? longTerm,
    List<StrategyItem>? supportingFriend,
    List<StrategyItem>? repairingWhenResponsible,
  }) {
    return EmotionStrategySet(
      emotionId: emotionId,
      displayName: displayName ?? this.displayName,
      scientificSummary: scientificSummary ?? this.scientificSummary,
      immediate: immediate ?? this.immediate,
      shortTerm: shortTerm ?? this.shortTerm,
      longTerm: longTerm ?? this.longTerm,
      supportingFriend: supportingFriend ?? this.supportingFriend,
      repairingWhenResponsible: repairingWhenResponsible ?? this.repairingWhenResponsible,
    );
  }

  List<StrategyItem> listFor(StrategyCategory category) {
    switch (category) {
      case StrategyCategory.immediate:
        return immediate;
      case StrategyCategory.shortTerm:
        return shortTerm;
      case StrategyCategory.longTerm:
        return longTerm;
    }
  }

  EmotionStrategySet withSupportingFriend(List<StrategyItem> items) =>
      copyWith(supportingFriend: items);

  EmotionStrategySet withRepairingWhenResponsible(List<StrategyItem> items) =>
      copyWith(repairingWhenResponsible: items);

  EmotionStrategySet withList(StrategyCategory category, List<StrategyItem> items) {
    switch (category) {
      case StrategyCategory.immediate:
        return copyWith(immediate: items);
      case StrategyCategory.shortTerm:
        return copyWith(shortTerm: items);
      case StrategyCategory.longTerm:
        return copyWith(longTerm: items);
    }
  }
}

class StrategyItem {
  const StrategyItem({
    required this.id,
    required this.title,
    required this.instructions,
    this.modality,
    this.durationSeconds,
    this.durationMinutes,
    this.cadence,
    this.evidence,
  });

  factory StrategyItem.fromJson(Map<String, dynamic> json) {
    final instructionsRaw = json['instructions'] as List<dynamic>? ?? const [];
    return StrategyItem(
      id: json['id'] as String,
      title: json['title'] as String,
      modality: json['modality'] as String?,
      instructions: instructionsRaw.map((item) => item.toString()).toList(),
      durationSeconds: json['duration_seconds'] as int?,
      durationMinutes: json['duration_minutes'] as int?,
      cadence: json['cadence'] as String?,
      evidence: json['evidence'] != null
          ? StrategyEvidence.fromJson(Map<String, dynamic>.from(json['evidence'] as Map))
          : null,
    );
  }

  final String id;
  final String title;
  final List<String> instructions;
  final String? modality;
  final int? durationSeconds;
  final int? durationMinutes;
  final String? cadence;
  final StrategyEvidence? evidence;

  StrategyItem copyWith({
    String? id,
    String? title,
    List<String>? instructions,
    String? modality,
    int? durationSeconds,
    int? durationMinutes,
    String? cadence,
    StrategyEvidence? evidence,
  }) {
    return StrategyItem(
      id: id ?? this.id,
      title: title ?? this.title,
      instructions: instructions ?? this.instructions,
      modality: modality ?? this.modality,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      cadence: cadence ?? this.cadence,
      evidence: evidence ?? this.evidence,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'modality': modality,
        'instructions': instructions,
        'duration_seconds': durationSeconds,
        'duration_minutes': durationMinutes,
        'cadence': cadence,
        'evidence': evidence?.toJson(),
      };

  String? get durationLabel {
    if (durationSeconds != null) {
      if (durationSeconds! < 60) {
        return '${durationSeconds!} sec';
      }
      final minutes = durationSeconds! / 60;
      return minutes == minutes.roundToDouble()
          ? '${minutes.toInt()} min'
          : '${minutes.toStringAsFixed(1)} min';
    }
    if (durationMinutes != null) {
      return '${durationMinutes!} min';
    }
    return null;
  }
}

class StrategyEvidence {
  const StrategyEvidence({required this.type, required this.source, required this.summary});

  factory StrategyEvidence.fromJson(Map<String, dynamic> json) {
    return StrategyEvidence(
      type: json['type'] as String,
      source: json['source'] as String,
      summary: json['summary'] as String,
    );
  }

  final String type;
  final String source;
  final String summary;

  Map<String, dynamic> toJson() => {
        'type': type,
        'source': source,
        'summary': summary,
      };
}
