import '../models/clip_type.dart';

class ClipClassifier {
  static final RegExp _stackTracePattern = RegExp(
    r'(Exception|Error|Traceback|at\s+\S+\.\S+\(|\.dart:\d+:\d+|file:///.+:\d+)',
    caseSensitive: false,
  );
  static final RegExp _ansiPattern = RegExp(
    r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])',
  );
  static final RegExp _isoDatePattern = RegExp(
    r'\b\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}',
  );
  static final RegExp _ipPattern = RegExp(
    r'\b(?:\d{1,3}\.){3}\d{1,3}\b',
  );
  static final RegExp _envPairPattern = RegExp(
    r'^[A-Z][A-Z0-9_]*=\S+',
    multiLine: true,
  );
  static final RegExp _codeKeywordPattern = RegExp(
    r'\b(function|class|import|export|const|let|var|def|async|await|return|package|struct|enum)\b',
  );

  static ClipType classify(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return ClipType.plainText;

    if (_looksLikeJson(trimmed)) {
      return ClipType.jsonPayload;
    }

    if (_stackTracePattern.hasMatch(trimmed)) {
      return ClipType.stackTrace;
    }

    // Prefer env config before terminal heuristics when KEY=VALUE dense.
    final envMatches = _envPairPattern.allMatches(trimmed).length;
    if (envMatches >= 2 ||
        (envMatches == 1 && trimmed.split('\n').length <= 3)) {
      final lines = trimmed
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();
      if (lines.isNotEmpty &&
          lines.where(_envPairPattern.hasMatch).length >= lines.length * 0.6) {
        return ClipType.envConfig;
      }
    }

    if (_ansiPattern.hasMatch(input) ||
        (_isoDatePattern.hasMatch(trimmed) && _ipPattern.hasMatch(trimmed)) ||
        (trimmed.contains(r'$ ') &&
            (trimmed.contains('npm ') ||
                trimmed.contains('git ') ||
                trimmed.contains('flutter ')))) {
      return ClipType.terminalLog;
    }

    if (_codeKeywordPattern.hasMatch(trimmed) &&
        (trimmed.contains('{') ||
            trimmed.contains('(') ||
            trimmed.contains(';'))) {
      return ClipType.sourceCode;
    }

    if (_ansiPattern.hasMatch(input) || _isoDatePattern.hasMatch(trimmed)) {
      return ClipType.terminalLog;
    }

    return ClipType.plainText;
  }

  static bool _looksLikeJson(String text) {
    final t = text.trim();
    if (!((t.startsWith('{') && t.endsWith('}')) ||
        (t.startsWith('[') && t.endsWith(']')))) {
      return false;
    }
    try {
      // Lightweight structural check without full decode dependency.
      var depth = 0;
      var inString = false;
      var escape = false;
      for (var i = 0; i < t.length; i++) {
        final c = t[i];
        if (inString) {
          if (escape) {
            escape = false;
          } else if (c == '\\') {
            escape = true;
          } else if (c == '"') {
            inString = false;
          }
          continue;
        }
        if (c == '"') {
          inString = true;
        } else if (c == '{' || c == '[') {
          depth++;
        } else if (c == '}' || c == ']') {
          depth--;
          if (depth < 0) return false;
        }
      }
      return depth == 0 && !inString;
    } catch (_) {
      return false;
    }
  }
}
