import 'package:flutter/services.dart';

typedef ClipCallback = void Function(String content);
typedef BridgeVoidCallback = void Function();

/// Typed MethodChannel bridge to the macOS native host.
class NativeBridge {
  NativeBridge({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.buffersync.contextclip/bridge');

  final MethodChannel _channel;

  ClipCallback? onNewClip;
  BridgeVoidCallback? onTriggerContextPaste;
  BridgeVoidCallback? onTriggerMarkdownPaste;
  BridgeVoidCallback? onTriggerShowPalette;
  BridgeVoidCallback? onTriggerShowSettings;

  void attach() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onNewClip':
        final content = call.arguments as String? ?? '';
        onNewClip?.call(content);
        return null;
      case 'triggerContextPaste':
        onTriggerContextPaste?.call();
        return null;
      case 'triggerMarkdownPaste':
        onTriggerMarkdownPaste?.call();
        return null;
      case 'triggerShowPalette':
        onTriggerShowPalette?.call();
        return null;
      case 'triggerShowSettings':
        onTriggerShowSettings?.call();
        return null;
      default:
        throw MissingPluginException(call.method);
    }
  }

  Future<String> getClipboard() async {
    final value = await _channel.invokeMethod<String>('getClipboard');
    return value ?? '';
  }

  Future<bool> setClipboard(String content) async {
    final ok = await _channel.invokeMethod<bool>('setClipboard', content);
    return ok ?? false;
  }

  Future<bool> injectPaste() async {
    final ok = await _channel.invokeMethod<bool>('injectPaste');
    return ok ?? false;
  }

  Future<bool> hideWindow() async {
    final ok = await _channel.invokeMethod<bool>('hideWindow');
    return ok ?? false;
  }

  Future<bool> showWindow() async {
    final ok = await _channel.invokeMethod<bool>('showWindow');
    return ok ?? false;
  }

  Future<bool> hasAccessibility() async {
    final ok = await _channel.invokeMethod<bool>('hasAccessibility');
    return ok ?? false;
  }

  Future<bool> requestAccessibility() async {
    final ok = await _channel.invokeMethod<bool>('requestAccessibility');
    return ok ?? false;
  }

  Future<String> getOrCreateDbKey() async {
    final key = await _channel.invokeMethod<String>('getOrCreateDbKey');
    return key ?? '';
  }

  Future<bool> showPasteFeedback({
    required String label,
    required int tokensSaved,
    required int redactionCount,
  }) async {
    final ok = await _channel.invokeMethod<bool>('showPasteFeedback', {
      'label': label,
      'tokensSaved': tokensSaved,
      'redactionCount': redactionCount,
    });
    return ok ?? false;
  }

  Future<bool> isLaunchAtLoginEnabled() async {
    final ok = await _channel.invokeMethod<bool>('isLaunchAtLoginEnabled');
    return ok ?? false;
  }

  Future<bool> setLaunchAtLogin(bool enabled) async {
    final ok = await _channel.invokeMethod<bool>('setLaunchAtLogin', enabled);
    return ok ?? false;
  }

  Future<bool> setHotkeys(List<Map<String, dynamic>> bindings) async {
    final ok = await _channel.invokeMethod<bool>('setHotkeys', bindings);
    return ok ?? false;
  }
}
