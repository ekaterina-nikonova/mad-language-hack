import 'package:flutter/foundation.dart';

class AudioHelper {
  static void playAudio({
    required String url,
    double speed = 1.0,
    VoidCallback? onComplete,
    VoidCallback? onError,
  }) {
    debugPrint('[Stub AudioHelper] playAudio from contract URL: $url (speed: $speed)');
    if (onComplete != null) {
      Future.delayed(const Duration(milliseconds: 500), onComplete);
    }
  }

  static void stopAudio() {
    debugPrint('[Stub AudioHelper] stopAudio');
  }

  static void setSpeed(double speed) {
    debugPrint('[Stub AudioHelper] setSpeed: $speed');
  }

  static Future<bool> startRecording() async {
    debugPrint('[Stub AudioHelper] startRecording');
    return true;
  }

  static Future<String?> stopRecording() async {
    debugPrint('[Stub AudioHelper] stopRecording');
    return 'blob:mock-recorded-audio';
  }

  static void playRecordedAudio({VoidCallback? onComplete, VoidCallback? onError}) {
    debugPrint('[Stub AudioHelper] playRecordedAudio');
    if (onComplete != null) {
      Future.delayed(const Duration(milliseconds: 500), onComplete);
    }
  }
}
