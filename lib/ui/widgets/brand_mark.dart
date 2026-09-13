import 'package:cupertino_ui/cupertino_ui.dart';

/// ContextClip mark — mint clipboard / redact lock on graphite.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});

  final double size;

  static const assetPath = 'assets/brand/contextclip-icon.png';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
