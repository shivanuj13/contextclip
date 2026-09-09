import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/signal_desk.dart';

/// Shared floating HUD chrome — fills the native window.
class HudPanel extends StatelessWidget {
  const HudPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  /// Clearance for macOS traffic lights under `fullSizeContentView`.
  static const double trafficLightInset = 78;

  /// Height reserved at the top so traffic lights don't overlap content.
  static const double titleBarHeight = 28;

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: SignalDesk.panel,
        child: SignalAtmosphere(
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class HudDivider extends StatelessWidget {
  const HudDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: SignalDesk.hairline,
      child: SizedBox(height: 0.5, width: double.infinity),
    );
  }
}

class HudChip extends StatelessWidget {
  const HudChip({
    super.key,
    required this.label,
    this.tone = HudChipTone.neutral,
  });

  final String label;
  final HudChipTone tone;

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    switch (tone) {
      case HudChipTone.accent:
        bg = SignalDesk.signalWash;
        fg = SignalDesk.signal;
      case HudChipTone.warning:
        bg = SignalDesk.warning.withValues(alpha: 0.16);
        fg = SignalDesk.warning;
      case HudChipTone.success:
        bg = SignalDesk.signalWash;
        fg = SignalDesk.signal;
      case HudChipTone.neutral:
        bg = SignalDesk.surface;
        fg = SignalDesk.muted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: fg.withValues(alpha: 0.28),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: SignalDesk.caption(color: fg, weight: FontWeight.w600),
      ),
    );
  }
}

enum HudChipTone { accent, warning, success, neutral }
