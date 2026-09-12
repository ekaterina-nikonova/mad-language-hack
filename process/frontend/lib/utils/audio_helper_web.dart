import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class AudioHelper {
  static web.HTMLAudioElement? _currentAudio;
  static web.HTMLAudioElement? _recordedAudio;
  static web.MediaRecorder? _mediaRecorder;
  static web.MediaStream? _currentStream;
  static final List<web.Blob> _recordedChunks = [];
  static web.Blob? _lastRecordedBlob;
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

  /// Starts recording microphone audio via MediaRecorder with continuous timeslice chunks.
  static Future<bool> startRecording() async {
    _recordedChunks.clear();
    _lastRecordedBlob = null;
    if (_recordedBlobUrl != null) {
      web.URL.revokeObjectURL(_recordedBlobUrl!);
      _recordedBlobUrl = null;
    }

    try {
      final stream = await web.window.navigator.mediaDevices.getUserMedia(
        web.MediaStreamConstraints(audio: true.toJS),
      ).toDart;
      _currentStream = stream;

      // Select supported container format
      var mimeType = '';
      if (web.MediaRecorder.isTypeSupported('audio/webm;codecs=opus')) {
        mimeType = 'audio/webm;codecs=opus';
      } else if (web.MediaRecorder.isTypeSupported('audio/webm')) {
        mimeType = 'audio/webm';
      } else if (web.MediaRecorder.isTypeSupported('audio/mp4')) {
        mimeType = 'audio/mp4';
      }

      final options = mimeType.isNotEmpty
          ? web.MediaRecorderOptions(mimeType: mimeType)
          : web.MediaRecorderOptions();

      final recorder = web.MediaRecorder(stream, options);
      _mediaRecorder = recorder;

      recorder.ondataavailable = (web.BlobEvent e) {
        if (e.data.size > 0) {
          _recordedChunks.add(e.data);
        }
      }.toJS;

      // Request timeslice chunks every 100ms
      recorder.start(100);
      debugPrint('[AudioHelper] Microphone recording started ($mimeType)');
      return true;
    } catch (e) {
      debugPrint('[AudioHelper] Error accessing mic: $e');
      return false;
    }
  }

  /// Stops recording, waits for the onstop event so all audio data is captured, and returns the blob URL.
  static Future<String?> stopRecording() async {
    if (_mediaRecorder == null) return null;
    final completer = Completer<String?>();

    try {
      final recorder = _mediaRecorder!;

      recorder.onstop = (web.Event e) {
        // Release microphone hardware
        if (_currentStream != null) {
          final tracks = _currentStream!.getTracks().toDart;
          for (final track in tracks) {
            track.stop();
          }
          _currentStream = null;
        }

        if (_recordedChunks.isEmpty) {
          debugPrint('[AudioHelper] Warning: No recorded chunks captured');
          completer.complete(null);
          return;
        }

        final mimeType = recorder.mimeType.isNotEmpty ? recorder.mimeType : 'audio/webm';
        final blob = web.Blob(_recordedChunks.toJS, web.BlobPropertyBag(type: mimeType));
        _lastRecordedBlob = blob;
        _recordedBlobUrl = web.URL.createObjectURL(blob);
        debugPrint('[AudioHelper] Recording complete: ${blob.size} bytes, type: $mimeType, url: $_recordedBlobUrl');
        completer.complete(_recordedBlobUrl);
      }.toJS;

      recorder.stop();
    } catch (e) {
      debugPrint('[AudioHelper] Error stopping recorder: $e');
      if (_currentStream != null) {
        final tracks = _currentStream!.getTracks().toDart;
        for (final track in tracks) {
          track.stop();
        }
        _currentStream = null;
      }
      completer.complete(null);
    }

    return completer.future;
  }

  /// Plays back the user's recorded audio blob.
  static void playRecordedAudio({VoidCallback? onComplete, VoidCallback? onError}) {
    if (_recordedBlobUrl == null || _recordedBlobUrl!.isEmpty) {
      debugPrint('[AudioHelper] No recorded audio blob found');
      onError?.call();
      return;
    }

    try {
      stopAudio();
      final audio = web.HTMLAudioElement();
      audio.src = _recordedBlobUrl!;
      _recordedAudio = audio;

      audio.onended = (web.Event e) {
        _recordedAudio = null;
        onComplete?.call();
      }.toJS;

      audio.onerror = (web.Event e) {
        debugPrint('[AudioHelper] Error playing recorded audio: $e');
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

  /// Triggers a browser download of the recorded audio file to the local disk.
  static void downloadRecording([String filename = 'recording.webm']) {
    if (_recordedBlobUrl == null) {
      debugPrint('[AudioHelper] Cannot download: no recorded audio');
      return;
    }
    final anchor = web.HTMLAnchorElement();
    anchor.href = _recordedBlobUrl!;
    anchor.download = filename;
    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();
    debugPrint('[AudioHelper] Download triggered for $filename');
  }

  /// Encodes the recorded audio as a base64 string for embedding in API payloads.
  static Future<String?> getRecordedBase64() async {
    if (_lastRecordedBlob == null) return null;
    final completer = Completer<String?>();
    try {
      final reader = web.FileReader();
      reader.onloadend = (web.Event e) {
        final result = (reader.result as JSString?)?.toDart;
        if (result != null && result.contains(',')) {
          completer.complete(result.split(',').last);
        } else {
          completer.complete(result);
        }
      }.toJS;
      reader.onerror = (web.Event e) {
        completer.complete(null);
      }.toJS;
      reader.readAsDataURL(_lastRecordedBlob!);
    } catch (e) {
      debugPrint('[AudioHelper] Error reading blob as base64: $e');
      completer.complete(null);
    }
    return completer.future;
  }
}
