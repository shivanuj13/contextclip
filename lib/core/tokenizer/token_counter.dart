import 'package:tiktoken_tokenizer_gpt4o_o1/tiktoken_tokenizer_gpt4o_o1.dart';

/// GPT-4o / o200k_base BPE token counter for ContextClip metrics.
class TokenCounter {
  TokenCounter._();

  static Tiktoken? _tiktoken;

  static Tiktoken get _encoder {
    return _tiktoken ??= Tiktoken(OpenAiModel.gpt_4o);
  }

  /// Exact BPE token count. Falls back to char/4 only if encoder fails.
  static int count(String text) {
    if (text.isEmpty) return 0;
    try {
      return _encoder.count(text);
    } catch (_) {
      return (text.length / 4).ceil();
    }
  }
}
