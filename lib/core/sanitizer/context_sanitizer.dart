import 'dart:convert';

import '../classifier/clip_classifier.dart';
import '../models/clip_type.dart';
import '../tokenizer/token_counter.dart';
import '../../data/settings/app_settings.dart';

class SanitizeOutput {
  final String content;
  final int originalTokens;
  final int sanitizedTokens;
  final int tokensSaved;
  final List<String> redactionsFound;
  final ClipType clipType;

  SanitizeOutput({
    required this.content,
    required this.originalTokens,
    required this.sanitizedTokens,
    required this.redactionsFound,
    required this.clipType,
  }) : tokensSaved = originalTokens - sanitizedTokens;

  bool get hadSecrets => redactionsFound.isNotEmpty;
}

class ContextSanitizer {
  static final RegExp _ansiPattern = RegExp(
    r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])',
  );
  static final RegExp _isoTimestampPattern = RegExp(
    r'\b\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})?\b',
  );
  static final RegExp _excessiveNewlines = RegExp(r'\n{3,}');
  static final RegExp _multiSpaces = RegExp(r'[ \t]{2,}');
  static final RegExp _bearerPattern = RegExp(
    r'Bearer\s+[A-Za-z0-9\-._~+/]+=*',
  );
  static final RegExp _connectionUriPattern = RegExp(
    r'(postgres|postgresql|mysql|mongodb|redis|amqp)://[^\s/:]+:[^\s/@]+@[^\s]+',
    caseSensitive: false,
  );
  static final RegExp _envSecretLinePattern = RegExp(
    r'^([A-Za-z_][A-Za-z0-9_]*(?:SECRET|TOKEN|PASSWORD|API[_-]?KEY|PRIVATE[_-]?KEY)[A-Za-z0-9_]*)\s*=\s*\S+',
    multiLine: true,
    caseSensitive: false,
  );
  // Also match KEY names that *are* exactly those tokens or start with them.
  static final RegExp _envSecretLineLoosePattern = RegExp(
    r'^((?:SECRET|TOKEN|PASSWORD|API[_-]?KEY|PRIVATE[_-]?KEY)[A-Za-z0-9_]*)\s*=\s*\S+',
    multiLine: true,
    caseSensitive: false,
  );

  /// Pattern id → generic placeholder label (vendor-neutral for agents).
  static final Map<String, String> _secretPlaceholders = {
    'ANTHROPIC_KEY': 'api_key',
    'OPENAI_KEY': 'api_key',
    'GITHUB_PAT': 'api_key',
    'AWS_KEY': 'api_key',
    'PRIVATE_KEY': 'private_key',
    'JWT': 'token',
    'SLACK_TOKEN': 'api_key',
    'SLACK_APP': 'api_key',
    'STRIPE_KEY': 'api_key',
    'GOOGLE_API_KEY': 'api_key',
    'HUGGINGFACE_TOKEN': 'api_key',
    'NPM_TOKEN': 'api_key',
  };

  /// More-specific patterns first (LinkedHashMap preserves insertion order).
  static final Map<String, RegExp> _secretPatterns = {
    'ANTHROPIC_KEY': RegExp(r'sk-ant-[a-zA-Z0-9_\-]{32,}'),
    'OPENAI_KEY': RegExp(r'sk-[a-zA-Z0-9]{32,}'),
    'GITHUB_PAT': RegExp(r'(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36}'),
    'AWS_KEY': RegExp(
      r'(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}',
    ),
    'PRIVATE_KEY': RegExp(
      r'-----BEGIN [A-Z ]+PRIVATE KEY-----[\s\S]+?-----END [A-Z ]+PRIVATE KEY-----',
    ),
    'JWT': RegExp(r'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+'),
    'SLACK_TOKEN': RegExp(r'xox[baprs]-[A-Za-z0-9-]{10,}'),
    'SLACK_APP': RegExp(r'xapp-[A-Za-z0-9-]{10,}'),
    'STRIPE_KEY': RegExp(r'(sk|pk|rk)_(live|test)_[A-Za-z0-9]+'),
    'GOOGLE_API_KEY': RegExp(r'AIza[0-9A-Za-z\-_]{35}'),
    'HUGGINGFACE_TOKEN': RegExp(r'hf_[A-Za-z0-9]{34,}'),
    'NPM_TOKEN': RegExp(r'npm_[A-Za-z0-9]{36}'),
  };

  static int estimateTokens(String text) => TokenCounter.count(text);

  static SanitizeOutput process(
    String input, {
    ClipType? type,
    List<DenyRule> customRules = const [],
  }) {
    var text = input;
    final detected = <String>[];

    // 1. Strip ANSI
    text = text.replaceAll(_ansiPattern, '');

    // 2. Redact credentials (Bearer before JWT so "Bearer <jwt>" stays tagged)
    text = text.replaceAllMapped(_bearerPattern, (match) {
      detected.add('token');
      return 'Bearer [token]';
    });

    _secretPatterns.forEach((name, pattern) {
      final label = _secretPlaceholders[name] ?? 'api_key';
      text = text.replaceAllMapped(pattern, (match) {
        detected.add(label);
        return '[$label]';
      });
    });

    text = text.replaceAllMapped(_connectionUriPattern, (match) {
      detected.add('connection');
      return '[connection]';
    });

    text = text.replaceAllMapped(_envSecretLinePattern, (match) {
      detected.add('secret');
      return '${match.group(1)}=[secret]';
    });
    text = text.replaceAllMapped(_envSecretLineLoosePattern, (match) {
      if (match.group(0)!.contains('[secret]')) {
        return match.group(0)!;
      }
      detected.add('secret');
      return '${match.group(1)}=[secret]';
    });

    // 2b. User deny-list (after built-ins so custom can still catch leftovers)
    for (final rule in customRules) {
      if (!rule.enabled) continue;
      final re = rule.tryCompile();
      if (re == null) continue;
      final label = rule.label.trim().isEmpty ? 'secret' : rule.label.trim();
      text = text.replaceAllMapped(re, (match) {
        detected.add(label);
        return '[$label]';
      });
    }

    final clipType = type ?? ClipClassifier.classify(text);

    // 3. Type-aware compaction
    text = _compact(text, clipType);

    final origTokens = estimateTokens(input);
    final newTokens = estimateTokens(text);

    return SanitizeOutput(
      content: text,
      originalTokens: origTokens,
      sanitizedTokens: newTokens,
      redactionsFound: detected,
      clipType: clipType,
    );
  }

  /// Sanitize then fence using classifier type (or override).
  static SanitizeOutput wrapMarkdown(
    String input, {
    ClipType? type,
    List<DenyRule> customRules = const [],
  }) {
    final sanitized = process(input, type: type, customRules: customRules);
    final lang = sanitized.clipType.fenceLanguage;
    final fenced = '```$lang\n${sanitized.content}\n```';
    return SanitizeOutput(
      content: fenced,
      originalTokens: sanitized.originalTokens,
      sanitizedTokens: estimateTokens(fenced),
      redactionsFound: sanitized.redactionsFound,
      clipType: sanitized.clipType,
    );
  }

  static String _compact(String text, ClipType type) {
    switch (type) {
      case ClipType.jsonPayload:
        return _minifyJson(text);
      case ClipType.stackTrace:
        return _trimStackTrace(text);
      case ClipType.terminalLog:
        return _compactLog(text);
      case ClipType.envConfig:
        return _compactEnv(text);
      case ClipType.sourceCode:
      case ClipType.plainText:
        return text.replaceAll(_excessiveNewlines, '\n\n').trim();
    }
  }

  static String _minifyJson(String text) {
    try {
      final decoded = jsonDecode(text);
      return jsonEncode(decoded);
    } catch (_) {
      return text.replaceAll(_excessiveNewlines, '\n\n').trim();
    }
  }

  static String _trimStackTrace(String text) {
    final lines = text.split('\n');
    const keep = 8;
    if (lines.length <= keep * 2) {
      return text.replaceAll(_excessiveNewlines, '\n\n').trim();
    }
    final omitted = lines.length - (keep * 2);
    final head = lines.sublist(0, keep);
    final tail = lines.sublist(lines.length - keep);
    return [...head, '[… $omitted frames omitted …]', ...tail]
        .join('\n')
        .trim();
  }

  static String _compactLog(String text) {
    var result = text.replaceAll(_isoTimestampPattern, '');
    result = result
        .split('\n')
        .map((l) => l.replaceAll(_multiSpaces, ' ').trimRight())
        .join('\n');
    result = _collapseRepeatedLines(result);
    return result.replaceAll(_excessiveNewlines, '\n\n').trim();
  }

  static String _compactEnv(String text) {
    final lines = text.split('\n').where((line) {
      final t = line.trim();
      return t.isNotEmpty && !t.startsWith('#');
    });
    return lines.join('\n').trim();
  }

  static String _collapseRepeatedLines(String text) {
    final lines = text.split('\n');
    if (lines.isEmpty) return text;

    String norm(String l) => l.trimRight();

    final out = StringBuffer();
    var prev = lines.first;
    var count = 1;
    out.writeln(prev);

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (norm(line) == norm(prev) && norm(line).isNotEmpty) {
        count++;
        continue;
      }
      if (count > 1) {
        out.writeln('[Previous line repeated $count times]');
      }
      out.writeln(line);
      prev = line;
      count = 1;
    }
    if (count > 1) {
      out.writeln('[Previous line repeated $count times]');
    }

    var result = out.toString();
    if (result.endsWith('\n')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }
}
