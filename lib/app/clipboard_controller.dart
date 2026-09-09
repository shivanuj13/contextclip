import 'package:flutter/foundation.dart';

import '../bridge/native_bridge.dart';
import '../core/models/clip_type.dart';
import '../core/sanitizer/context_sanitizer.dart';
import '../data/history_store.dart';
import '../data/settings/app_settings.dart';
import '../data/settings/settings_store.dart';

class ClipboardController extends ChangeNotifier {
  ClipboardController({
    required NativeBridge bridge,
    required HistoryStore store,
    required SettingsStore settingsStore,
  })  : _bridge = bridge,
        _store = store,
        _settingsStore = settingsStore;

  final NativeBridge _bridge;
  final HistoryStore _store;
  final SettingsStore _settingsStore;

  List<DecryptedClip> clips = [];
  String searchQuery = '';
  final List<int> selectedOrder = [];
  int highlightedIndex = 0;
  bool paletteVisible = false;
  bool settingsVisible = false;
  bool hasAccessibility = false;
  bool ready = false;

  NativeBridge get bridge => _bridge;
  AppSettings get settings => _settingsStore.settings;
  List<DenyRule> get _denyRules => settings.denyRules;

  Future<void> initialize() async {
    await _settingsStore.load();

    _bridge.onNewClip = _handleNewClip;
    _bridge.onTriggerContextPaste = () {
      _runContextPaste();
    };
    _bridge.onTriggerMarkdownPaste = () {
      _runMarkdownPaste();
    };
    _bridge.onTriggerShowPalette = () {
      showPalette();
    };
    _bridge.onTriggerShowSettings = () {
      showSettings();
    };
    _bridge.attach();

    await _pushHotkeysToNative();

    hasAccessibility = await _bridge.hasAccessibility();
    await refreshClips();
    ready = true;
    notifyListeners();

    if (!hasAccessibility) {
      await _bridge.showWindow();
      return;
    }

    // Keep the armed primer visible until the user dismisses it.
    await _bridge.showWindow();
  }

  Future<void> _pushHotkeysToNative() async {
    await _bridge.setHotkeys(settings.hotkeysNativePayload());
  }

  Future<void> updateSettings(AppSettings next) async {
    await _settingsStore.save(next);
    await _pushHotkeysToNative();
    notifyListeners();
  }

  Future<void> resetSettings() async {
    await _settingsStore.reset();
    await _pushHotkeysToNative();
    notifyListeners();
  }

  Future<void> refreshAccessibility() async {
    hasAccessibility = await _bridge.hasAccessibility();
    notifyListeners();
  }

  Future<void> requestAccessibility() async {
    await _bridge.requestAccessibility();
    await refreshAccessibility();
    if (hasAccessibility) {
      await hidePalette();
    }
  }

  Future<void> refreshClips() async {
    clips = await _store.getRecent(query: searchQuery);
    if (highlightedIndex >= clips.length) {
      highlightedIndex = clips.isEmpty ? 0 : clips.length - 1;
    }
    notifyListeners();
  }

  Future<void> setSearch(String query) async {
    searchQuery = query;
    highlightedIndex = 0;
    await refreshClips();
  }

  Future<void> _handleNewClip(String content) async {
    await _store.ingest(content, customRules: _denyRules);
    if (paletteVisible) {
      await refreshClips();
    } else {
      clips = await _store.getRecent(query: searchQuery);
    }
  }

  Future<void> showPalette() async {
    settingsVisible = false;
    await refreshClips();
    paletteVisible = true;
    selectedOrder.clear();
    highlightedIndex = 0;
    notifyListeners();
    await _bridge.showWindow();
  }

  Future<void> showSettings() async {
    paletteVisible = false;
    settingsVisible = true;
    selectedOrder.clear();
    notifyListeners();
    await _bridge.showWindow();
  }

  Future<void> hidePalette() async {
    paletteVisible = false;
    settingsVisible = false;
    selectedOrder.clear();
    notifyListeners();
    await _bridge.hideWindow();
  }

  void setHighlightedIndex(int index) {
    if (clips.isEmpty) return;
    highlightedIndex = index.clamp(0, clips.length - 1);
    notifyListeners();
  }

  void moveHighlight(int delta) {
    if (clips.isEmpty) return;
    highlightedIndex = (highlightedIndex + delta).clamp(0, clips.length - 1);
    notifyListeners();
  }

  void toggleSelectionAtHighlight() {
    if (clips.isEmpty) return;
    final id = clips[highlightedIndex].id;
    if (selectedOrder.contains(id)) {
      selectedOrder.remove(id);
    } else {
      selectedOrder.add(id);
    }
    notifyListeners();
  }

  int? selectionBadge(int clipId) {
    final idx = selectedOrder.indexOf(clipId);
    return idx < 0 ? null : idx + 1;
  }

  Future<void> pasteHighlighted({required bool sanitized}) async {
    if (clips.isEmpty) return;
    final clip = clips[highlightedIndex];
    final text = sanitized ? clip.sanitizedContent : clip.rawContent;
    final label = sanitized ? 'Sanitized' : 'Raw';
    final saved = sanitized ? clip.tokensSaved : 0;
    await _pasteText(
      text,
      feedbackLabel: label,
      tokensSaved: saved,
      redactionCount: clip.redactionCount,
    );
  }

  Future<void> packAndPasteSelected() async {
    final packed = _packSelectedMarkdown();
    if (packed == null) return;
    await _pasteText(
      packed.text,
      feedbackLabel: 'Packed',
      tokensSaved: packed.tokensSaved,
      redactionCount: packed.redactionCount,
    );
  }

  ({String text, int tokensSaved, int redactionCount})? _packSelectedMarkdown() {
    final items = <DecryptedClip>[];
    if (selectedOrder.isEmpty) {
      if (clips.isEmpty) return null;
      items.add(clips[highlightedIndex]);
    } else {
      final byId = {for (final c in clips) c.id: c};
      for (final id in selectedOrder) {
        final clip = byId[id];
        if (clip != null) items.add(clip);
      }
    }
    if (items.isEmpty) return null;

    final buffer = StringBuffer();
    var totalSanitized = 0;
    var totalOriginal = 0;
    var redactions = 0;
    for (var i = 0; i < items.length; i++) {
      final clip = items[i];
      if (buffer.isNotEmpty) buffer.writeln();
      buffer.write(
        _formatContextItem(
          i + 1,
          clip.clipType,
          clip.sanitizedContent,
          clip.sanitizedTokens,
        ),
      );
      totalSanitized += clip.sanitizedTokens;
      totalOriginal += clip.originalTokens;
      redactions += clip.redactionCount;
    }
    buffer.writeln();
    buffer.write(
      '<!-- ContextClip: ${items.length} items · ~$totalSanitized tokens · $redactions redactions -->',
    );
    return (
      text: buffer.toString(),
      tokensSaved: totalOriginal - totalSanitized,
      redactionCount: redactions,
    );
  }

  String _formatContextItem(
    int index,
    ClipType type,
    String content,
    int tokens,
  ) {
    final lang = type.fenceLanguage;
    return '### Context Item $index (${type.label}) · ~$tokens tokens\n```$lang\n$content\n```';
  }

  Future<void> _runContextPaste() async {
    final raw = await _bridge.getClipboard();
    if (raw.isEmpty) return;
    final out = ContextSanitizer.process(raw, customRules: _denyRules);
    await _pasteText(
      out.content,
      feedbackLabel: 'Sanitized',
      tokensSaved: out.tokensSaved,
      redactionCount: out.redactionsFound.length,
    );
  }

  Future<void> _runMarkdownPaste() async {
    final raw = await _bridge.getClipboard();
    if (raw.isEmpty) return;
    final out = ContextSanitizer.wrapMarkdown(raw, customRules: _denyRules);
    await _pasteText(
      out.content,
      feedbackLabel: 'Fenced',
      tokensSaved: out.tokensSaved,
      redactionCount: out.redactionsFound.length,
    );
  }

  Future<void> _pasteText(
    String text, {
    required String feedbackLabel,
    required int tokensSaved,
    required int redactionCount,
  }) async {
    await _bridge.setClipboard(text);
    paletteVisible = false;
    settingsVisible = false;
    selectedOrder.clear();
    notifyListeners();
    await _bridge.injectPaste();
    await _bridge.showPasteFeedback(
      label: feedbackLabel,
      tokensSaved: tokensSaved,
      redactionCount: redactionCount,
    );
  }
}
