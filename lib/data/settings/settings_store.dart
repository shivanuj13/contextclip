import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_settings.dart';

class SettingsStore {
  SettingsStore();

  AppSettings _settings = AppSettings.defaults;
  File? _file;

  AppSettings get settings => _settings;

  Future<void> load() async {
    final dir = await getApplicationSupportDirectory();
    _file = File(p.join(dir.path, 'context_clip_settings.json'));
    if (await _file!.exists()) {
      _settings = AppSettings.decode(await _file!.readAsString());
    } else {
      _settings = AppSettings.defaults;
      await save(_settings);
    }
  }

  Future<void> save(AppSettings next) async {
    _settings = next;
    final file = _file;
    if (file == null) {
      final dir = await getApplicationSupportDirectory();
      _file = File(p.join(dir.path, 'context_clip_settings.json'));
    }
    await _file!.writeAsString(next.encode());
  }

  Future<void> reset() => save(AppSettings.defaults);
}
