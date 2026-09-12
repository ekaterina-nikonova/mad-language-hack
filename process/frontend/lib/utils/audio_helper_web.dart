import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class AudioHelper {
  static web.HTMLAudioElement? _currentAudio;
  static web.HTMLAudioElement? _recordedAudio;
  static web.MediaRecorder? _mediaRecorder;
  static final List<web.Blob> _recordedChunks = [];
  static String? _recordedBlobUrl;

  /// Plays the audio file directly from the URL defined in the JSON contract.
  static void playAudio({
    required String url,
    double speed = 1.0,
    VoidCallback? onComplete,
    VoidCallback? onError,
  }) {
    stopAudio();

    if (url.isEmpty) {
      debugPrint('[AudioHelper] Empty audio URL');
      onError?.call();
      return;
    }

    try {
      final audio = web.HTMLAudioElement();
      audio.src = url;
      audio.playbackRate = speed;
      _currentAudio = audio;

      audio.onended = (web.Event e) {
        _currentAudio = null;
        onComplete?.call();
      }.toJS;

      audio.onerror = (web.Event e) {
        debugPrint('[AudioHelper] Error loading audio file at: $url');
        _currentAudio = null;
        onError?.call();
      }.toJS;

      audio.play();
    } catch (e) {
      debugPrint('[AudioHelper] Exception playing audio: $e');
      _currentAudio = null;
      onError?.call();
    }
  }

  /// Stops audio playback.
  static void stopAudio() {
    try {
      if (_currentAudio != null) {
        _currentAudio!.pause();
        _currentAudio!.currentTime = 0;
        _currentAudio = null;
      }
      if (_recordedAudio != null) {
        _recordedAudio!.pause();
        _recordedAudio!.currentTime = 0;
        _recordedAudio = null;
      }
    } catch (e) {
      debugPrint('[AudioHelper] Error stopping audio: $e');
    }
  }

  /// Updates playback speed for the currently playing audio track.
  static void setSpeed(double speed) {
    if (_currentAudio != null) {
      _currentAudio!.playbackRate = speed;
    }
  }

  /// Starts recording microphone audio via MediaRecorder.
  static Future<bool> startRecording() async {
    _recordedChunks.clear();
    try {
      final stream = await web.window.navigator.mediaDevices.getUserMedia(
        web.MediaStreamConstraints(audio: true.toJS),
      ).toDart;

      _mediaRecorder = web.MediaRecorder(stream);
      _mediaRecorder!.ondataavailable = (web.BlobEvent e) {
        if (e.data.size > 0) {
          _recordedChunks.add(e.data);
        }
      }.toJS;

      _mediaRecorder!.start();
      return true;
    } catch (e) {
      debugPrint('[AudioHelper] Error accessing mic: $e');
      return false;
    }
  }

  /// Stops recording and returns the blob URL.
  static Future<String?> stopRecording() async {
    if (_mediaRecorder == null) return null;
    try {
      _mediaRecorder!.stop();
      if (_recordedBlobUrl != null) {
        web.URL.revokeObjectURL(_recordedBlobUrl!);
      }
      final blob = web.Blob(_recordedChunks.toJS);
      _recordedBlobUrl = web.URL.createObjectURL(blob);
      return _recordedBlobUrl;
    } catch (e) {
      debugPrint('[AudioHelper] Error stopping recorder: $e');
      return null;
    }
  }

  /// Plays back the user's recorded audio blob.
  static void playRecordedAudio({VoidCallback? onComplete, VoidCallback? onError}) {
    if (_recordedBlobUrl == null || _recordedBlobUrl!.isEmpty) {
      debugPrint('[AudioHelper] No recorded audio blob found');
      onError?.call();
      return;
    }

    try {
      final audio = web.HTMLAudioElement();
      audio.src = _recordedBlobUrl!;
      _recordedAudio = audio;

      audio.onended = (web.Event e) {
        _recordedAudio = null;
        onComplete?.call();
      }.toJS;

      audio.onerror = (web.Event e) {
        debugPrint('[AudioHelper] Error playing recorded audio');
        _recordedAudio = null;
        onError?.call();
      }.toJS;

      audio.play();
    } catch (e) {
      debugPrint('[AudioHelper] Error playing recorded audio: $e');
      _recordedAudio = null;
      onError?.call();
    }
  }
}
