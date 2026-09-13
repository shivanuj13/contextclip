import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:provider/provider.dart';

import '../../app/clipboard_controller.dart';
import '../theme/signal_desk.dart';
import '../widgets/feature_primer.dart';
import '../widgets/hud_panel.dart';

class AccessibilityOnboarding extends StatefulWidget {
  const AccessibilityOnboarding({super.key});

  @override
  State<AccessibilityOnboarding> createState() =>
      _AccessibilityOnboardingState();
}

class _AccessibilityOnboardingState extends State<AccessibilityOnboarding>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..forward();

  AppLifecycleListener? _lifecycle;
  String? _statusHint;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        context.read<ClipboardController>().refreshAccessibility();
      },
    );
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    _enter.dispose();
    super.dispose();
  }

  Future<void> _recheckPermission() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _statusHint = null;
    });
    final controller = context.read<ClipboardController>();

    // macOS can lag a beat after the toggle; poll briefly before giving up.
    for (var i = 0; i < 6; i++) {
      await controller.refreshAccessibility();
      if (controller.hasAccessibility) {
        if (mounted) {
          setState(() {
            _checking = false;
            _statusHint = null;
          });
        }
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    if (!mounted) return;
    setState(() {
      _checking = false;
      _statusHint =
          'Still not detected. Quit ContextClip from the menu bar '
          '(ContextClip → Quit), confirm only /Applications/ContextClip '
          'is enabled under Accessibility, then reopen the app.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClipboardController>();
    final fade = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(fade);

    return ColoredBox(
      color: const Color(0x00000000),
      child: HudPanel(
        padding: const EdgeInsets.fromLTRB(24, HudPanel.titleBarHeight, 24, 20),
        child: FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
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
                            Text(
                              'ONE PERMISSION',
                              style: SignalDesk.caption(
                                color: SignalDesk.signal,
                                weight: FontWeight.w700,
                              ).copyWith(letterSpacing: 2.0),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'ContextClip',
                              style: SignalDesk.display(size: 28),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'A clipboard desk for developers and agents. '
                              'macOS Accessibility is needed so global shortcuts '
                              'can paste sanitized context into other apps.',
                              style: SignalDesk.ui(
                                size: 14,
                                color: SignalDesk.muted,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'WHAT YOU GET',
                              style: SignalDesk.caption(
                                color: SignalDesk.dim,
                                weight: FontWeight.w700,
                              ).copyWith(letterSpacing: 1.2),
                            ),
                            const SizedBox(height: 10),
                            const FeaturePrimer(),
                            const SizedBox(height: 18),
                            const ShortcutPrimer(),
                            const SizedBox(height: 18),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: SignalDesk.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: SignalDesk.hairlineStrong,
                                  width: 0.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.lock_shield,
                                      size: 16,
                                      color: SignalDesk.signal,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Enable Accessibility',
                                            style: SignalDesk.ui(
                                              size: 13,
                                              weight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'System Settings → Privacy & Security → Accessibility\n'
                                            'Enable ContextClip, then quit and reopen the app.',
                                            style: SignalDesk.mono(
                                              size: 11.5,
                                              color: SignalDesk.muted,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_statusHint != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                _statusHint!,
                                style: SignalDesk.ui(
                                  size: 13,
                                  color: SignalDesk.warning,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          color: SignalDesk.signal,
                          borderRadius: BorderRadius.circular(6),
                          onPressed: () async {
                            await controller.requestAccessibility();
                          },
                          child: Text(
                            'Open Prompt',
                            style: SignalDesk.ui(
                              size: 14,
                              weight: FontWeight.w600,
                              color: SignalDesk.voidBg,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          onPressed: _checking ? null : _recheckPermission,
                          child: Text(
                            _checking ? 'Checking…' : 'I’ve Enabled It',
                            style: SignalDesk.ui(
                              size: 14,
                              weight: FontWeight.w500,
                              color: SignalDesk.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
