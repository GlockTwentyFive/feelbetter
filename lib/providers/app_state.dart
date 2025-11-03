import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../models/emotion_definition.dart';
import '../models/emotion_history_entry.dart';
import '../models/strategy_models.dart';

const _journalEntriesKey = 'journalEntries';
const _themeIdKey = 'themeId';
const _emotionsKey = 'emotions';
const _strategiesKey = 'strategies';
const _emotionHistoryKey = 'emotionHistory';
const _streakCountKey = 'streakCount';
const _lastActiveDayKey = 'lastActiveDay';

enum AppView { calmHome, breathe, journal, emotionStrategies, manageEmotions, emotionTrends }

class AppState extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String _themeId = 'calm-light';
  String get themeId => _themeId;

  AppView _view = AppView.calmHome;
  AppView get view => _view;

  String? _currentEmotionId;
  String? get currentEmotionId => _currentEmotionId;

  bool _showPhilosophyModal = false;
  bool get showPhilosophyModal => _showPhilosophyModal;

  List<JournalEntry> _journalEntries = const [];
  List<JournalEntry> get journalEntries => _journalEntries;

  List<EmotionDefinition> _emotions = EmotionDefinition.defaults();
  UnmodifiableListView<EmotionDefinition> get emotions => UnmodifiableListView(_emotions);

  final Map<String, EmotionStrategySet> _strategies = {};
  UnmodifiableMapView<String, EmotionStrategySet> get strategies => UnmodifiableMapView(_strategies);

  final List<EmotionHistoryEntry> _emotionHistory = [];
  UnmodifiableListView<EmotionHistoryEntry> get emotionHistory => UnmodifiableListView(_emotionHistory);

  int _streakCount = 0;
  DateTime? _lastActiveDay;

  Future<void> initialize() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();

    _themeId = prefs.getString(_themeIdKey) ?? 'calm-light';

    try {
      final journalJson = prefs.getString(_journalEntriesKey);
      if (journalJson != null) {
        final decoded = jsonDecode(journalJson) as List<dynamic>;
        _journalEntries = decoded
            .map((item) => JournalEntry.fromJson(
                Map<String, dynamic>.from(item as Map<String, dynamic>)))
            .toList();
      }
    } catch (_) {
      _journalEntries = const [];
    }

    try {
      final emotionsJson = prefs.getString(_emotionsKey);
      if (emotionsJson != null) {
        final decoded = jsonDecode(emotionsJson) as List<dynamic>;
        _emotions = decoded
            .map((item) => EmotionDefinition.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (_) {
      _emotions = EmotionDefinition.defaults();
    }

    try {
      final strategiesJson = prefs.getString(_strategiesKey);
      if (strategiesJson != null) {
        final decoded = jsonDecode(strategiesJson) as Map<String, dynamic>;
        _strategies
          ..clear()
          ..addAll(decoded.map(
            (key, value) => MapEntry(
              key,
              EmotionStrategySet.fromJson(Map<String, dynamic>.from(value as Map)),
            ),
          ));
      } else {
        await _loadDefaultStrategies();
      }
    } catch (_) {
      await _loadDefaultStrategies();
    }

    await _ensureLatestStrategySections();

    await _loadEmotionHistory();
    await _loadUsageData(prefs);

    _isInitialized = true;
    notifyListeners();
  }

  void setTheme(String themeId) {
    if (_themeId == themeId) return;
    _themeId = themeId;
    _persistTheme();
    notifyListeners();
  }

  void showView(AppView view) {
    if (_view == view && view != AppView.emotionStrategies) {
      return;
    }
    _view = view;
    if (view != AppView.emotionStrategies) {
      _currentEmotionId = null;
    }
    notifyListeners();
  }

  void showEmotionStrategies(String emotionId) {
    if (_currentEmotionId == emotionId && _view == AppView.emotionStrategies) {
      return;
    }
    _currentEmotionId = emotionId;
    _view = AppView.emotionStrategies;
    _recordEmotionUsage(emotionId);
    notifyListeners();
  }

  void openPhilosophyModal() {
    if (_showPhilosophyModal) return;
    _showPhilosophyModal = true;
    notifyListeners();
  }

  void closePhilosophyModal() {
    if (!_showPhilosophyModal) return;
    _showPhilosophyModal = false;
    notifyListeners();
  }

  void saveJournalEntry(JournalEntry entry) {
    final index = _journalEntries.indexWhere((item) => item.id == entry.id);
    if (index >= 0) {
      final updated = List<JournalEntry>.from(_journalEntries);
      updated[index] = entry;
      _journalEntries = updated;
    } else {
      _journalEntries = [entry, ..._journalEntries];
    }
    _persistJournalEntries();
    notifyListeners();
  }

  void deleteJournalEntry(String entryId) {
    _journalEntries = _journalEntries.where((entry) => entry.id != entryId).toList();
    _persistJournalEntries();
    notifyListeners();
  }

  int get streak => _streakCount;

  bool isOverlayView(AppView view) => view == AppView.breathe;

  Future<void> _persistTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeIdKey, _themeId);
  }

  Future<void> _persistJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _journalEntriesKey,
      jsonEncode(_journalEntries.map((entry) => entry.toJson()).toList()),
    );
  }

  Future<void> _persistEmotions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _emotionsKey,
      jsonEncode(_emotions.map((emotion) => emotion.toJson()).toList()),
    );
  }

  Future<void> _persistStrategies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _strategiesKey,
      jsonEncode(_strategies.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }

  Future<void> _persistEmotionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _emotionHistoryKey,
      jsonEncode(_emotionHistory.map((entry) => entry.toJson()).toList()),
    );
  }

  Future<void> _loadDefaultStrategies() async {
    _strategies.clear();
    for (final emotion in EmotionDefinition.defaults()) {
      try {
        _strategies[emotion.id] = await _defaultStrategySet(emotion.id, displayName: emotion.name);
      } catch (_) {
        _strategies[emotion.id] = EmotionStrategySet.empty(emotion.id, name: emotion.name);
      }
    }
  }

  Future<EmotionStrategySet> _defaultStrategySet(String emotionId, {String? displayName}) async {
    final path = 'content/strategies/$emotionId.json';
    try {
      final raw = await rootBundle.loadString(path);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return EmotionStrategySet.fromJson(json);
    } catch (_) {
      return EmotionStrategySet.empty(emotionId, name: displayName ?? emotionId);
    }
  }

  Future<void> _ensureLatestStrategySections() async {
    var updated = false;
    for (final emotion in EmotionDefinition.defaults()) {
      final defaults = await _defaultStrategySet(emotion.id, displayName: emotion.name);
      final existing = _strategies[emotion.id];
      if (existing == null) {
        _strategies[emotion.id] = defaults;
        updated = true;
        continue;
      }

      var next = existing;
      if (next.supportingFriend.isEmpty && defaults.supportingFriend.isNotEmpty) {
        next = next.withSupportingFriend(defaults.supportingFriend);
      }
      if (next.repairingWhenResponsible.isEmpty && defaults.repairingWhenResponsible.isNotEmpty) {
        next = next.withRepairingWhenResponsible(defaults.repairingWhenResponsible);
      }

      if (!identical(next, existing)) {
        _strategies[emotion.id] = next;
        updated = true;
      }
    }

    if (updated) {
      await _persistStrategies();
    }
  }

  Future<void> _loadEmotionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final raw = prefs.getString(_emotionHistoryKey);
      if (raw == null) {
        _emotionHistory.clear();
        return;
      }
      final decoded = jsonDecode(raw) as List<dynamic>;
      _emotionHistory
        ..clear()
        ..addAll(decoded.map((item) => EmotionHistoryEntry.fromJson(Map<String, dynamic>.from(item as Map))));
    } catch (_) {
      _emotionHistory.clear();
    }
  }

  void _recordEmotionUsage(String emotionId) {
    _emotionHistory.insert(0, EmotionHistoryEntry(emotionId: emotionId, timestamp: DateTime.now()));
    if (_emotionHistory.length > 500) {
      _emotionHistory.removeRange(500, _emotionHistory.length);
    }
    _persistEmotionHistory();
  }

  EmotionDefinition? emotionById(String id) {
    try {
      return _emotions.firstWhere((emotion) => emotion.id == id);
    } catch (_) {
      return null;
    }
  }

  EmotionStrategySet strategySetFor(String emotionId) {
    final existing = _strategies[emotionId];
    if (existing != null) return existing;
    final emotion = emotionById(emotionId);
    final created = EmotionStrategySet.empty(emotionId, name: emotion?.name, summary: emotion?.synonyms.join(', '));
    _strategies[emotionId] = created;
    return created;
  }

  void addEmotion(EmotionDefinition definition) {
    _emotions = [..._emotions, definition];
    _persistEmotions();
    notifyListeners();
  }

  void updateEmotion(String emotionId, EmotionDefinition updated) {
    final index = _emotions.indexWhere((emotion) => emotion.id == emotionId);
    if (index == -1) return;
    final list = [..._emotions];
    list[index] = updated;
    _emotions = list;
    _persistEmotions();
    notifyListeners();
  }

  void removeEmotion(String emotionId) {
    _emotions = _emotions.where((emotion) => emotion.id != emotionId).toList();
    _strategies.remove(emotionId);
    _persistEmotions();
    _persistStrategies();
    notifyListeners();
  }

  void reorderEmotions(int oldIndex, int newIndex) {
    final list = [..._emotions];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _emotions = list;
    _persistEmotions();
    notifyListeners();
  }

  void upsertStrategySet(EmotionStrategySet set) {
    _strategies[set.emotionId] = set;
    _persistStrategies();
    notifyListeners();
  }

  void addStrategyItem(String emotionId, StrategyCategory category, StrategyItem item) {
    final set = strategySetFor(emotionId);
    final list = [...set.listFor(category), item];
    _strategies[emotionId] = set.withList(category, list);
    _persistStrategies();
    notifyListeners();
  }

  void updateStrategyItem(String emotionId, StrategyCategory category, StrategyItem item) {
    final set = strategySetFor(emotionId);
    final list = [...set.listFor(category)];
    final index = list.indexWhere((existing) => existing.id == item.id);
    if (index == -1) return;
    list[index] = item;
    _strategies[emotionId] = set.withList(category, list);
    _persistStrategies();
    notifyListeners();
  }

  void removeStrategyItem(String emotionId, StrategyCategory category, String strategyId) {
    final set = strategySetFor(emotionId);
    final list = set.listFor(category).where((item) => item.id != strategyId).toList();
    _strategies[emotionId] = set.withList(category, list);
    _persistStrategies();
    notifyListeners();
  }

  void reorderStrategyItems(String emotionId, StrategyCategory category, int oldIndex, int newIndex) {
    final set = strategySetFor(emotionId);
    final list = [...set.listFor(category)];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _strategies[emotionId] = set.withList(category, list);
    _persistStrategies();
    notifyListeners();
  }

  Future<void> _loadUsageData(SharedPreferences prefs) async {
    _streakCount = prefs.getInt(_streakCountKey) ?? 0;
    final storedDay = prefs.getString(_lastActiveDayKey);
    _lastActiveDay = storedDay != null ? DateTime.tryParse(storedDay) : null;

    // Fallback if no persisted data exists
    if (_streakCount <= 0) {
      final uniqueDays = _journalEntries
          .map((entry) => DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day))
          .toSet()
          .toList()
        ..sort();
      if (uniqueDays.isNotEmpty) {
        _streakCount = uniqueDays.length;
        _lastActiveDay = uniqueDays.last;
      }
    }

    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    if (_lastActiveDay == null) {
      _streakCount = _streakCount <= 0 ? 1 : _streakCount;
      _lastActiveDay = todayKey;
    } else {
      final difference = todayKey.difference(_lastActiveDay!).inDays;
      if (difference > 0) {
        if (difference == 1) {
          _streakCount += 1;
        } else {
          _streakCount = (_streakCount - 1).clamp(1, _streakCount);
        }
        _lastActiveDay = todayKey;
      }
    }

    await prefs.setInt(_streakCountKey, _streakCount);
    if (_lastActiveDay != null) {
      await prefs.setString(_lastActiveDayKey, _lastActiveDay!.toIso8601String());
    }
  }

  Map<String, int> emotionUsageCounts({Duration window = const Duration(days: 7)}) {
    final cutoff = DateTime.now().subtract(window);
    final counts = <String, int>{};
    for (final entry in _emotionHistory) {
      if (entry.timestamp.isBefore(cutoff)) continue;
      counts.update(entry.emotionId, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  List<EmotionHistoryEntry> recentEmotionHistory({int limit = 50}) {
    return _emotionHistory.take(limit).toList();
  }

  void clearEmotionHistory() {
    _emotionHistory.clear();
    _persistEmotionHistory();
    notifyListeners();
  }

}
