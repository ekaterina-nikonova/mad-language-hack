import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/artifact.dart';
import '../models/user_response.dart';
import 'mock_data.dart';

enum ConnectionStatus { disconnected, connecting, connected, simulated }

class SessionService extends ChangeNotifier {
  WebSocketChannel? _channel;
  ConnectionStatus _status = ConnectionStatus.disconnected;
  Artifact? _currentArtifact;
  int _currentMockIndex = 0;
  String _sessionId = 'sess-default';

  final StreamController<Artifact> _artifactController =
      StreamController<Artifact>.broadcast();

  ConnectionStatus get status => _status;
  Artifact? get currentArtifact => _currentArtifact;
  String get sessionId => _sessionId;
  Stream<Artifact> get artifactStream => _artifactController.stream;
  int get currentMockIndex => _currentMockIndex;
  int get totalMockCount => MockDataService.mockArtifactSequence.length;

  Future<void> connect({String url = 'ws://localhost:8000/ws/session'}) async {
    _status = ConnectionStatus.connecting;
    notifyListeners();

    try {
      final uri = Uri.parse(url);
      _channel = WebSocketChannel.connect(uri);

      // Listen for incoming messages
      _channel!.stream.listen(
        (message) {
          _handleIncomingMessage(message);
        },
        onError: (error) {
          debugPrint('WebSocket error: $error. Falling back to local generative simulation.');
          _fallbackToSimulated();
        },
        onDone: () {
          debugPrint('WebSocket closed. Falling back to local simulation.');
          _fallbackToSimulated();
        },
      );

      _status = ConnectionStatus.connected;
      notifyListeners();
    } catch (e) {
      debugPrint('Connection exception: $e. Falling back to simulation.');
      _fallbackToSimulated();
    }
  }

  void _fallbackToSimulated() {
    _status = ConnectionStatus.simulated;
    _currentMockIndex = 0;
    _currentArtifact = MockDataService.mockArtifactSequence.first;
    _sessionId = _currentArtifact!.sessionId;
    _artifactController.add(_currentArtifact!);
    notifyListeners();
  }

  void _handleIncomingMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw.toString()) as Map<String, dynamic>;
      final msgType = data['type'] as String? ?? 'artifact';
      final payload = data['data'] as Map<String, dynamic>? ?? data;

      if (msgType == 'artifact' || msgType == 'feedback') {
        _currentArtifact = Artifact.fromJson(payload);
        _artifactController.add(_currentArtifact!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
  }

  Future<void> submitResponse(UserResponse response) async {
    if (_status == ConnectionStatus.connected && _channel != null) {
      final jsonMsg = jsonEncode({
        'type': 'response',
        'data': response.toJson(),
      });
      _channel!.sink.add(jsonMsg);
    } else {
      // In simulated mode, advance to next step in sequence
      await Future.delayed(const Duration(milliseconds: 400));
      nextMockTurn();
    }
  }

  void nextMockTurn() {
    if (_currentMockIndex < MockDataService.mockArtifactSequence.length - 1) {
      _currentMockIndex++;
      _currentArtifact = MockDataService.mockArtifactSequence[_currentMockIndex];
      _artifactController.add(_currentArtifact!);
      notifyListeners();
    } else {
      // Wrap around or restart sequence
      _currentMockIndex = 0;
      _currentArtifact = MockDataService.mockArtifactSequence.first;
      _artifactController.add(_currentArtifact!);
      notifyListeners();
    }
  }

  void previousMockTurn() {
    if (_currentMockIndex > 0) {
      _currentMockIndex--;
      _currentArtifact = MockDataService.mockArtifactSequence[_currentMockIndex];
      _artifactController.add(_currentArtifact!);
      notifyListeners();
    }
  }

  void selectMockTurn(int index) {
    if (index >= 0 && index < MockDataService.mockArtifactSequence.length) {
      _currentMockIndex = index;
      _currentArtifact = MockDataService.mockArtifactSequence[index];
      _artifactController.add(_currentArtifact!);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _artifactController.close();
    super.dispose();
  }
}
