import 'package:flutter_test/flutter_test.dart';
import 'package:context_clip/core/models/clip_type.dart';
import 'package:context_clip/core/sanitizer/context_sanitizer.dart';

void main() {
  group('ContextSanitizer', () {
    test('strips ANSI escape codes', () {
      const input = '\x1B[31mERROR\x1B[0m failed';
      final out = ContextSanitizer.process(input);
      expect(out.content, 'ERROR failed');
      expect(out.tokensSaved, greaterThan(0));
    });

    test('redacts OpenAI and Anthropic keys as [api_key]', () {
      final openai = 'sk-${'a' * 40}';
      final anthropic = 'sk-ant-${'b' * 40}';
      final out = ContextSanitizer.process('key=$openai other=$anthropic');
      expect(out.content, contains('[api_key]'));
      expect(out.content, isNot(contains('OPENAI')));
      expect(out.content, isNot(contains('ANTHROPIC')));
      expect(out.redactionsFound, everyElement('api_key'));
    });

    test('redacts GitHub PAT, AWS key, bearer, private key generically', () {
      const github = 'ghp_abcdefghijklmnopqrstuvwxyz0123456789';
      const aws = 'AKIAIOSFODNN7EXAMPLE';
      const bearer = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.abc.def';
      const pem = '''
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA0Z3VS5JJcds3xfn/ygWyF6PZGFw
-----END RSA PRIVATE KEY-----
''';
      final out = ContextSanitizer.process('$github\n$aws\n$bearer\n$pem');
      expect(out.content, contains('[api_key]'));
      expect(out.content, contains('Bearer [token]'));
      expect(out.content, contains('[private_key]'));
    });

    test('redacts JWT, Slack, Stripe, Google, HF, npm generically', () {
      const jwt =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U';
      const slack = 'xoxb-1234567890-abcdefghij';
      const slackApp = 'xapp-1-A01234567890-1234567890123-abcdefabcdefabcdefabcdefabcdef';
      const stripe = 'sk_live_abc123XYZ';
      final google = 'AIza${'A' * 35}';
      final hf = 'hf_${'a' * 34}';
      final npm = 'npm_${'b' * 36}';
      final out = ContextSanitizer.process(
        '$jwt\n$slack\n$slackApp\n$stripe\n$google\n$hf\n$npm',
      );
      expect(out.content, contains('[token]'));
      expect(out.content, contains('[api_key]'));
      expect(out.content, isNot(contains('REDACTED_')));
      expect(out.content, isNot(contains('STRIPE')));
      expect(out.content, isNot(contains('SLACK')));
    });

    test('redacts connection URIs and env secret lines', () {
      const uri = 'postgres://user:s3cret@db.example.com:5432/app';
      const env = 'API_KEY=supersecret\nDEBUG=true\nPASSWORD=hunter2';
      final out = ContextSanitizer.process('$uri\n$env');
      expect(out.content, contains('[connection]'));
      expect(out.content, contains('API_KEY=[secret]'));
      expect(out.content, contains('PASSWORD=[secret]'));
      expect(out.content, isNot(contains('s3cret')));
      expect(out.content, isNot(contains('hunter2')));
    });

    test('collapses repeated lines and caps newlines for logs', () {
      const input = 'line\nline\nline\n\n\n\nnext';
      final out = ContextSanitizer.process(
        input,
        type: ClipType.terminalLog,
      );
      expect(out.content, contains('[Previous line repeated 3 times]'));
      expect(out.content.contains('\n\n\n'), isFalse);
    });

    test('minifies JSON payloads', () {
      const input = '{\n  "a": 1,\n  "b": true\n}';
      final out = ContextSanitizer.process(input, type: ClipType.jsonPayload);
      expect(out.content, '{"a":1,"b":true}');
      expect(out.tokensSaved, greaterThan(0));
    });

    test('trims long stack traces', () {
      final frames = List.generate(30, (i) => '  at frame$i.dart:$i:1');
      final input = 'Exception: boom\n${frames.join('\n')}';
      final out = ContextSanitizer.process(input, type: ClipType.stackTrace);
      expect(out.content, contains('frames omitted'));
      expect(out.content.split('\n').length, lessThan(frames.length));
    });

    test('wrapMarkdown uses classifier fence language', () {
      final out = ContextSanitizer.wrapMarkdown('{"a":1}');
      expect(out.content, startsWith('```json'));
      expect(out.clipType, ClipType.jsonPayload);
    });

    test('token estimate uses BPE tokenizer', () {
      final tokens = ContextSanitizer.estimateTokens('hello world');
      expect(tokens, greaterThan(0));
      expect(tokens, lessThan(10));
      // Sanitizing ANSI noise should not increase token count.
      final noisy = ContextSanitizer.process(
        '\x1B[31mhello world\x1B[0m',
      );
      expect(noisy.tokensSaved, greaterThanOrEqualTo(0));
      expect(noisy.sanitizedTokens, lessThanOrEqualTo(noisy.originalTokens));
    });
  });
}
