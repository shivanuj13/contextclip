import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/clipboard_controller.dart';
import '../theme/signal_desk.dart';
import '../widgets/brand_mark.dart';
import '../widgets/hud_panel.dart';

/// First-run gate: the GPLv3 text must be shown before the user can continue.
class LicenseOnboarding extends StatefulWidget {
  const LicenseOnboarding({super.key});

  @override
  State<LicenseOnboarding> createState() => _LicenseOnboardingState();
}

class _LicenseOnboardingState extends State<LicenseOnboarding> {
  final _scroll = ScrollController();
  String? _licenseText;
  String? _loadError;
  bool _readAndAccept = false;
  bool _accepting = false;

  @override
  void initState() {
    super.initState();
    _loadLicense();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadLicense() async {
    try {
      final text = await rootBundle.loadString('LICENSE');
      if (!mounted) return;
      setState(() => _licenseText = text);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.toString());
    }
  }

  Future<void> _accept() async {
    if (!_readAndAccept || _accepting) return;
    setState(() => _accepting = true);
    await context.read<ClipboardController>().acceptLicense();
    if (mounted) setState(() => _accepting = false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClipboardController>();

    return ColoredBox(
      color: const Color(0x00000000),
      child: HudPanel(
        padding: const EdgeInsets.fromLTRB(24, HudPanel.titleBarHeight, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'LICENSE',
              style: SignalDesk.caption(
                color: SignalDesk.signal,
                weight: FontWeight.w700,
              ).copyWith(letterSpacing: 2.0),
            ),
            const SizedBox(height: 12),
            const BrandMark(size: 48),
            const SizedBox(height: 12),
            Text('GNU GPLv3', style: SignalDesk.display(size: 28)),
            const SizedBox(height: 8),
            Text(
              'ContextClip is free software. Read the license below, then '
              'accept to continue. You can use and share it; if you distribute '
              'a modified build, you must keep it under GPLv3 and provide source.',
              style: SignalDesk.ui(
                size: 14,
                color: SignalDesk.muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: SignalDesk.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: SignalDesk.hairlineStrong,
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                  child: _licenseBody(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _readAndAccept = !_readAndAccept),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _readAndAccept
                        ? CupertinoIcons.checkmark_square_fill
                        : CupertinoIcons.square,
                    size: 18,
                    color: _readAndAccept
                        ? SignalDesk.signal
                        : SignalDesk.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'I have read the GNU General Public License v3 and accept these terms.',
                      style: SignalDesk.ui(size: 13, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  color: SignalDesk.signal,
                  borderRadius: BorderRadius.circular(6),
                  onPressed: _readAndAccept && !_accepting ? _accept : null,
                  child: Text(
                    _accepting ? 'Saving…' : 'Accept and continue',
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
                  onPressed: controller.hidePalette,
                  child: Text(
                    'Decline',
                    style: SignalDesk.ui(
                      size: 14,
                      weight: FontWeight.w500,
                      color: SignalDesk.muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _licenseBody() {
    if (_loadError != null) {
      return Center(
        child: Text(
          'Could not load LICENSE.\n$_loadError',
          style: SignalDesk.ui(size: 13, color: SignalDesk.warning),
        ),
      );
    }
    if (_licenseText == null) {
      return const Center(child: CupertinoActivityIndicator());
    }
    return CupertinoScrollbar(
      controller: _scroll,
      child: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.only(right: 8),
        child: Text(
          _licenseText!,
          style: SignalDesk.mono(
            size: 11,
            color: SignalDesk.ink,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}
