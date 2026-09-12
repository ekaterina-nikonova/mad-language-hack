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
  
  // New state for autonomous agent widget
  List<String> _agentThoughts = [];
  Map<String, dynamic>? _currentPlan;

  final StreamController<Artifact> _artifactController =
      StreamController<Artifact>.broadcast();

  ConnectionStatus get status => _status;
  Artifact? get currentArtifact => _currentArtifact;
  String get sessionId => _sessionId;
  Stream<Artifact> get artifactStream => _artifactController.stream;
  int get currentMockIndex => _currentMockIndex;
  int get totalMockCount => MockDataService.mockArtifactSequence.length;
  List<String> get agentThoughts => _agentThoughts;
  Map<String, dynamic>? get currentPlan => _currentPlan;

  Future<void> connect({String url = 'wss://mwjq8r10-8001.euw.devtunnels.ms/ws/session'}) async {
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
          debugPrint('WebSocket error: $error.');
          _status = ConnectionStatus.disconnected;
          notifyListeners();
        },
        onDone: () {
          debugPrint('WebSocket closed.');
          _status = ConnectionStatus.disconnected;
          notifyListeners();
        },
      );

      _status = ConnectionStatus.connected;
      notifyListeners();
    } catch (e) {
      debugPrint('Connection exception: $e.');
      _status = ConnectionStatus.disconnected;
      notifyListeners();
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
    debugPrint('DEBUG: Received raw message from WebSocket: $raw');
    try {
      final data = jsonDecode(raw.toString()) as Map<String, dynamic>;
      final msgType = data['type'] as String? ?? 'artifact';
      final payload = data['data'] ?? data;

      debugPrint('DEBUG: Parsed message type: $msgType');
      if (msgType == 'artifact' || msgType == 'feedback') {
        _currentArtifact = Artifact.fromJson(payload as Map<String, dynamic>);
        _currentPlan = null; // Clear plan when artifact arrives
        _artifactController.add(_currentArtifact!);
        debugPrint('DEBUG: Successfully parsed Artifact and added to stream.');
        notifyListeners();
      } else if (msgType == 'agent_thought') {
        _agentThoughts.add(payload.toString());
        // Keep only the last 50 thoughts to avoid memory issues
        if (_agentThoughts.length > 50) {
          _agentThoughts.removeAt(0);
        }
        notifyListeners();
      } else if (msgType == 'plan_proposal') {
        _currentPlan = payload as Map<String, dynamic>;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('DEBUG ERROR parsing message: $e');
    }
  }

  Future<void> submitPlanDecision(String action, {String? skill}) async {
    if (_status == ConnectionStatus.connected && _channel != null) {
      final jsonMsg = jsonEncode({
        'type': 'plan_approval',
        'action': action,
        'data': {
          if (skill != null) 'skill': skill,
        }
      });
      _channel!.sink.add(jsonMsg);
      if (action == 'approve') {
         _currentPlan = null;
         notifyListeners();
      }
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

  void continueToNextTurn() {
    if (_status == ConnectionStatus.connected && _channel != null) {
      final jsonMsg = jsonEncode({
        'type': 'continue',
      });
      _channel!.sink.add(jsonMsg);
    } else {
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
