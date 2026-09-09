import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:provider/provider.dart';

import 'app/clipboard_controller.dart';
import 'bridge/native_bridge.dart';
import 'data/clip_crypto.dart';
import 'data/database/database.dart';
import 'data/history_store.dart';
import 'data/settings/settings_store.dart';
import 'ui/onboarding/accessibility_onboarding.dart';
import 'ui/palette/command_palette.dart';
import 'ui/settings/settings_panel.dart';
import 'ui/standby/standby_panel.dart';
import 'ui/theme/signal_desk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Paint boot UI first, then reveal the window before any heavy native work.
  runApp(
    CupertinoApp(
      title: 'ContextClip',
      debugShowCheckedModeBanner: false,
      theme: SignalDesk.theme,
      home: const StandbyPanel(booting: true),
    ),
  );
  await WidgetsBinding.instance.endOfFrame;
  await Future<void>.delayed(const Duration(milliseconds: 16));

  final bridge = NativeBridge();
  await bridge.showWindow();
  await WidgetsBinding.instance.endOfFrame;

  final dbKey = await bridge.getOrCreateDbKey();
  final crypto = ClipCrypto.fromBase64Key(dbKey);
  final db = await AppDatabase.open();
  final store = HistoryStore(db: db, crypto: crypto);
  final settingsStore = SettingsStore();
  final controller = ClipboardController(
    bridge: bridge,
    store: store,
    settingsStore: settingsStore,
  );
  await controller.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: controller,
      child: const ContextClipApp(),
    ),
  );
}

class ContextClipApp extends StatelessWidget {
  const ContextClipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'ContextClip',
      debugShowCheckedModeBanner: false,
      theme: SignalDesk.theme,
      home: const _RootShell(),
    );
  }
}

class _RootShell extends StatelessWidget {
  const _RootShell();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClipboardController>();

    if (!controller.ready) {
      return const StandbyPanel(booting: true);
    }

    if (!controller.hasAccessibility) {
      return const AccessibilityOnboarding();
    }

    if (controller.settingsVisible) {
      return const SettingsPanel();
    }
    if (controller.paletteVisible) {
      return const CommandPalette();
    }

    return const StandbyPanel();
  }
}
