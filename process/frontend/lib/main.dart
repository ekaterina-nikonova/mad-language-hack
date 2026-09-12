import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/session_screen.dart';
import 'services/websocket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sessionService = SessionService();
  // Attempt to connect to local FastAPI agent server; if not running yet, gracefully activates generative UI fixtures
  await sessionService.connect();

  runApp(MADLanguageApp(sessionService: sessionService));
}

class MADLanguageApp extends StatelessWidget {
  final SessionService sessionService;

  const MADLanguageApp({super.key, required this.sessionService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FluencyOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SessionScreen(sessionService: sessionService),
    );
  }
}
