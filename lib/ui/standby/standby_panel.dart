import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/clipboard_controller.dart';
import '../theme/signal_desk.dart';
import '../widgets/brand_mark.dart';
import '../widgets/feature_primer.dart';
import '../widgets/hud_panel.dart';

/// Shown while the engine boots, and when the window is open without a palette.
class StandbyPanel extends StatefulWidget {
  const StandbyPanel({super.key, this.booting = false});

  final bool booting;

  @override
  State<StandbyPanel> createState() => _StandbyPanelState();
}

class _StandbyPanelState extends State<StandbyPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.booting
        ? null
        : context.watch<ClipboardController>();

    return Focus(
      autofocus: !widget.booting,
      onKeyEvent: (node, event) {
        if (controller == null || widget.booting) {
          return KeyEventResult.ignored;
        }
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          controller.hidePalette();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          controller.showPalette();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: HudPanel(
        padding: const EdgeInsets.fromLTRB(24, HudPanel.titleBarHeight, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            FadeTransition(
                              opacity: Tween<double>(begin: 0.35, end: 1)
                                  .animate(
                                    CurvedAnimation(
                                      parent: _pulse,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: SignalDesk.signal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.booting
                                  ? 'STARTING'
                                  : 'READY IN THE MENU BAR',
                              style: SignalDesk.caption(
                                color: SignalDesk.signal,
                                weight: FontWeight.w700,
                              ).copyWith(letterSpacing: 2.0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const BrandMark(size: 56),
                        const SizedBox(height: 14),
                        Text(
                          'ContextClip',
                          style: SignalDesk.display(size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.booting
                              ? 'A clipboard desk for developers and agents. '
                                    'Loading history and shortcuts…'
                              : 'Lives in the menu bar. Use it when you need '
                                    'clean context for a paste or an agent.',
                          style: SignalDesk.ui(
                            size: 14,
                            color: SignalDesk.muted,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'WHAT IT DOES',
                          style: SignalDesk.caption(
                            color: SignalDesk.dim,
                            weight: FontWeight.w700,
                          ).copyWith(letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 10),
                        const FeaturePrimer(compact: true),
                        const SizedBox(height: 18),
                        const ShortcutPrimer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (!widget.booting && controller != null) ...[
              const SizedBox(height: 8),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Row(
                    children: [
                      CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        onPressed: controller.showPalette,
                        child: Text(
                          'Open Palette',
                          style: SignalDesk.ui(
                            size: 14,
                            weight: FontWeight.w600,
                            color: SignalDesk.voidBg,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CupertinoButton(  
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        onPressed: controller.hidePalette,
                        child: Text(
                          'Dismiss · Esc',
                          style: SignalDesk.ui(
                            size: 13,
                            color: SignalDesk.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
