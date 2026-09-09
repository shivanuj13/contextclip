import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/clipboard_controller.dart';
import '../../core/models/clip_type.dart';
import '../../data/history_store.dart';
import '../theme/signal_desk.dart';
import '../widgets/hud_panel.dart';

class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette>
    with SingleTickerProviderStateMixin {
  final _searchFocus = FocusNode();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  )..forward();

  static const _estimatedRowExtent = 74.0;
  static const _revealDuration = Duration(milliseconds: 200);
  static const _revealCurve = Curves.easeOutCubic;
  static const _revealAlignment = 0.42;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    _searchFocus.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  static Object _rowKey(int clipId) => 'palette-row-$clipId';

  bool _isFullyVisible(RenderObject renderObject) {
    final viewport = RenderAbstractViewport.maybeOf(renderObject);
    if (viewport == null || !_scrollController.hasClients) return true;

    final leading = viewport.getOffsetToReveal(renderObject, 0.0).offset;
    final trailing = viewport.getOffsetToReveal(renderObject, 1.0).offset;
    final pixels = _scrollController.position.pixels;
    return pixels <= leading + 1.0 && pixels >= trailing - 1.0;
  }

  void _revealIfNeeded(int index, List<DecryptedClip> clips) {
    if (index < 0 || index >= clips.length) return;
    final key = GlobalObjectKey(_rowKey(clips[index].id));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final ctx = key.currentContext;
      if (ctx != null) {
        final renderObject = ctx.findRenderObject();
        if (renderObject != null && _isFullyVisible(renderObject)) {
          return;
        }
        Scrollable.ensureVisible(
          ctx,
          alignment: _revealAlignment,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
          duration: _revealDuration,
          curve: _revealCurve,
        );
        return;
      }

      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      final centered = (index * _estimatedRowExtent -
              position.viewportDimension * _revealAlignment)
          .clamp(0.0, position.maxScrollExtent);
      _scrollController.animateTo(
        centered,
        duration: _revealDuration,
        curve: _revealCurve,
      );
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final controller = context.read<ClipboardController>();
    final isMeta = HardwareKeyboard.instance.isMetaPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    final isControl = HardwareKeyboard.instance.isControlPressed;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      controller.hidePalette();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        (isControl && event.logicalKey == LogicalKeyboardKey.keyN)) {
      controller.moveHighlight(1);
      _revealIfNeeded(controller.highlightedIndex, controller.clips);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        (isControl && event.logicalKey == LogicalKeyboardKey.keyP)) {
      controller.moveHighlight(-1);
      _revealIfNeeded(controller.highlightedIndex, controller.clips);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.space &&
        (_searchController.text.isEmpty || !_searchFocus.hasFocus)) {
      controller.toggleSelectionAtHighlight();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (isMeta) {
        controller.packAndPasteSelected();
      } else if (isShift) {
        controller.pasteHighlighted(sanitized: true);
      } else {
        controller.pasteHighlighted(sanitized: false);
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClipboardController>();

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
        child: HudPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: HudPanel.titleBarHeight),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: _SearchField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: controller.setSearch,
                ),
              ),
              const HudDivider(),
              Expanded(
                child: controller.clips.isEmpty
                    ? Center(
                        child: Text(
                          'No clips yet — copy something to begin',
                          style: SignalDesk.ui(
                            size: 13,
                            color: SignalDesk.muted,
                          ),
                        ),
                      )
                    : CupertinoScrollbar(
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          itemCount: controller.clips.length,
                          itemBuilder: (context, index) {
                            final clip = controller.clips[index];
                            return _ClipRow(
                              key: GlobalObjectKey(_rowKey(clip.id)),
                              clip: clip,
                              selected: index == controller.highlightedIndex,
                              badge: controller.selectionBadge(clip.id),
                              onTap: () async {
                                controller.setHighlightedIndex(index);
                                await controller.pasteHighlighted(
                                  sanitized: false,
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
              const HudDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 9, 16, 11),
                child: Text(
                  '↵ raw  ·  ⇧↵ sanitized  ·  ⌘↵ pack  ·  Space select  ·  Esc',
                  style: SignalDesk.mono(size: 10.5, color: SignalDesk.dim),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SignalDesk.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: SignalDesk.hairlineStrong, width: 0.5),
      ),
      child: CupertinoTextField(
        controller: controller,
        focusNode: focusNode,
        placeholder: 'Search clipboard',
        placeholderStyle: SignalDesk.ui(size: 15, color: SignalDesk.dim),
        style: SignalDesk.ui(size: 15, color: SignalDesk.ink),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        prefix: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Icon(
            CupertinoIcons.search,
            size: 14,
            color: SignalDesk.dim,
          ),
        ),
        decoration: const BoxDecoration(),
        clearButtonMode: OverlayVisibilityMode.editing,
        cursorColor: SignalDesk.signal,
        onChanged: onChanged,
      ),
    );
  }
}

class _ClipRow extends StatelessWidget {
  const _ClipRow({
    super.key,
    required this.clip,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final DecryptedClip clip;
  final bool selected;
  final int? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = clip.sanitizedContent.replaceAll('\n', ' ').trim();
    final short =
        preview.length > 110 ? '${preview.substring(0, 110)}…' : preview;
    final saved = clip.tokensSaved;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: selected ? SignalDesk.signalWash : const Color(0x00000000),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selected
                    ? SignalDesk.signal.withValues(alpha: 0.35)
                    : const Color(0x00000000),
                width: 0.5,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 3,
                    decoration: BoxDecoration(
                      color: selected
                          ? SignalDesk.signal
                          : const Color(0x00000000),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(6),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(11, 10, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (badge != null) ...[
                                Container(
                                  width: 18,
                                  height: 18,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: SignalDesk.signal,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '$badge',
                                    style: SignalDesk.mono(
                                      size: 10,
                                      weight: FontWeight.w600,
                                      color: SignalDesk.voidBg,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                clip.clipType.label.toUpperCase(),
                                style: SignalDesk.caption(
                                  color: selected
                                      ? SignalDesk.signal
                                      : SignalDesk.muted,
                                  weight: FontWeight.w600,
                                ).copyWith(letterSpacing: 0.6),
                              ),
                              if (clip.hadSecrets) ...[
                                Text(
                                  '  ·  ',
                                  style: SignalDesk.caption(
                                    color: SignalDesk.dim,
                                  ),
                                ),
                                Text(
                                  'REDACTED',
                                  style: SignalDesk.caption(
                                    color: SignalDesk.warning,
                                    weight: FontWeight.w600,
                                  ).copyWith(letterSpacing: 0.5),
                                ),
                              ],
                              if (saved > 0) ...[
                                Text(
                                  '  ·  ',
                                  style: SignalDesk.caption(
                                    color: SignalDesk.dim,
                                  ),
                                ),
                                Text(
                                  '−$saved',
                                  style: SignalDesk.caption(
                                    color: SignalDesk.signal,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Text(
                                '${clip.sanitizedTokens}',
                                style: SignalDesk.mono(
                                  size: 11,
                                  color: SignalDesk.dim,
                                  weight: FontWeight.w500,
                                ).copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            short.isEmpty ? '(empty)' : short,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: SignalDesk.mono(
                              size: 12.5,
                              color: selected
                                  ? SignalDesk.ink
                                  : SignalDesk.ink.withValues(alpha: 0.88),
                              height: 1.4,
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
      ),
    );
  }
}
