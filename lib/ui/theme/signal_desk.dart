import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Signal Desk — precision instrument aesthetic for CLI / AI clipboard work.
///
/// Near-black panel + phosphor mint accent. Space Grotesk for chrome,
/// IBM Plex Mono for clip payloads.
abstract final class SignalDesk {
  static const Color voidBg = Color(0xFF0C0C0A);
  static const Color panel = Color(0xFF0C0C0A);
  static const Color surface = Color(0xFF161614);
  static const Color surfaceHover = Color(0xFF1E1E1C);
  static const Color hairline = Color(0xFF2A2A28);
  static const Color hairlineStrong = Color(0xFF3A3A38);

  static const Color signal = Color(0xFF3DDC97);
  static const Color signalDim = Color(0xFF1F6B4E);
  static const Color signalWash = Color(0x1A3DDC97);

  static const Color warning = Color(0xFFE8A54B);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color ink = Color(0xFFF0F0F0);
  static const Color muted = Color(0xFF9A9A9A);
  static const Color dim = Color(0xFF6B6B6B);

  static CupertinoThemeData get theme => CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: signal,
        scaffoldBackgroundColor: voidBg,
        barBackgroundColor: panel,
        textTheme: CupertinoTextThemeData(
          primaryColor: ink,
          textStyle: ui(size: 14),
          actionTextStyle: ui(size: 14, weight: FontWeight.w600),
          navTitleTextStyle: ui(size: 16, weight: FontWeight.w600),
          navLargeTitleTextStyle: display(size: 28),
          tabLabelTextStyle: mono(size: 11, color: muted),
          pickerTextStyle: ui(size: 14),
          dateTimePickerTextStyle: mono(size: 14),
        ),
      );

  static TextStyle display({
    double size = 24,
    FontWeight weight = FontWeight.w600,
    Color color = ink,
    double? height,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height ?? 1.15,
      letterSpacing: -0.6,
    );
  }

  static TextStyle ui({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = ink,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height ?? 1.3,
      letterSpacing: letterSpacing ?? -0.2,
    );
  }

  static TextStyle mono({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color color = ink,
    double? height,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height ?? 1.4,
      letterSpacing: -0.15,
    );
  }

  static TextStyle caption({
    Color color = muted,
    FontWeight weight = FontWeight.w500,
  }) =>
      ui(size: 11, weight: weight, color: color, letterSpacing: 0.2);
}

/// Solid panel behind HUD content (no decorative grid).
class SignalAtmosphere extends StatelessWidget {
  const SignalAtmosphere({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SignalDesk.panel,
      child: child,
    );
  }
}
