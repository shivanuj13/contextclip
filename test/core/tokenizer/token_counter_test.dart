import 'package:flutter_test/flutter_test.dart';
import 'package:context_clip/core/tokenizer/token_counter.dart';

void main() {
  group('TokenCounter', () {
    test('counts tokens for a short string', () {
      final n = TokenCounter.count('hello world');
      expect(n, greaterThan(0));
      expect(n, lessThan(10));
    });

    test('empty string is zero tokens', () {
      expect(TokenCounter.count(''), 0);
    });

    test('longer text has more tokens than shorter', () {
      final short = TokenCounter.count('hi');
      final long = TokenCounter.count('hi ' * 200);
      expect(long, greaterThan(short));
    });
  });
}
