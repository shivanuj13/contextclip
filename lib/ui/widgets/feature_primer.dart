import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/signal_desk.dart';

/// Calm, factual overview of what ContextClip does — no marketing tone.
class FeaturePrimer extends StatelessWidget {
  const FeaturePrimer({
    super.key,
    this.compact = false,
  });

  /// Slightly denser layout for the boot / standby panel.
  final bool compact;

  static const features = <({String title, String body})>[
    (
      title: 'Clipboard history',
      body: 'Keeps recent copies locally, encrypted on disk.',
    ),
    (
      title: 'Secret redaction',
      body: 'Strips API keys, tokens, and similar secrets before paste or pack. '
          'You can add your own deny-list patterns in Settings.',
    ),
    (
      title: 'Token-aware cleanup',
      body: 'Trims noise from logs, stacks, and JSON so agent context stays smaller.',
    ),
    (
      title: 'Command palette',
      body: 'Search history, multi-select clips, and paste raw or sanitized.',
    ),
    (
      title: 'Context pack',
      body: 'Combine several clips into one Markdown block for an agent or terminal.',
    ),
    (
      title: 'Global shortcuts',
      body: '⌥V opens the palette. ⌘⇧V pastes sanitized. ⌘⌥V pastes fenced Markdown. '
          'Plain ⌘V is never intercepted. Shortcuts are rebindable in Settings.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final gap = compact ? 8.0 : 10.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < features.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          _FeatureLine(
            title: features[i].title,
            body: features[i].body,
            compact: compact,
          ),
        ],
      ],
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({
    required this.title,
    required this.body,
    required this.compact,
  });

  final String title;
  final String body;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: compact ? 5 : 6),
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: SignalDesk.signal,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: SignalDesk.ui(
                  size: compact ? 12.5 : 13,
                  weight: FontWeight.w600,
                  color: SignalDesk.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: SignalDesk.ui(
                  size: compact ? 12 : 12.5,
                  color: SignalDesk.muted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shortcut reference strip used under the primer.
class ShortcutPrimer extends StatelessWidget {
  const ShortcutPrimer({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SignalDesk.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: SignalDesk.hairlineStrong, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DEFAULT SHORTCUTS',
              style: SignalDesk.caption(
                color: SignalDesk.dim,
                weight: FontWeight.w700,
              ).copyWith(letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),
            const _ShortcutRow(keys: '⌥V', label: 'Open command palette'),
            const SizedBox(height: 7),
            const _ShortcutRow(keys: '⌘⇧V', label: 'Paste sanitized context'),
            const SizedBox(height: 7),
            const _ShortcutRow(keys: '⌘⌥V', label: 'Paste fenced Markdown pack'),
            const SizedBox(height: 7),
            const _ShortcutRow(keys: '⌘V', label: 'System paste — left alone'),
          ],
        ),
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.keys, required this.label});

  final String keys;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            keys,
            style: SignalDesk.mono(
              size: 12,
              weight: FontWeight.w600,
              color: SignalDesk.signal,
            ),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: SignalDesk.ui(size: 12.5, color: SignalDesk.ink),
          ),
        ),
      ],
    );
  }
}
