enum ClipType {
  stackTrace,
  terminalLog,
  sourceCode,
  jsonPayload,
  envConfig,
  plainText,
}

extension ClipTypeLabel on ClipType {
  String get label {
    switch (this) {
      case ClipType.stackTrace:
        return 'Stack Trace';
      case ClipType.terminalLog:
        return 'Terminal Log';
      case ClipType.sourceCode:
        return 'Source Code';
      case ClipType.jsonPayload:
        return 'JSON';
      case ClipType.envConfig:
        return 'Config';
      case ClipType.plainText:
        return 'Plain Text';
    }
  }

  String get fenceLanguage {
    switch (this) {
      case ClipType.stackTrace:
        return 'text';
      case ClipType.terminalLog:
        return 'bash';
      case ClipType.sourceCode:
        return 'text';
      case ClipType.jsonPayload:
        return 'json';
      case ClipType.envConfig:
        return 'dotenv';
      case ClipType.plainText:
        return 'text';
    }
  }
}
