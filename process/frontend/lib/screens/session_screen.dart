import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/artifact.dart';
import '../services/websocket_service.dart';
import '../utils/response_collector.dart';
import '../widgets/artifact_renderer.dart';

class SessionScreen extends StatefulWidget {
  final SessionService sessionService;

  const SessionScreen({super.key, required this.sessionService});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  ResponseCollector? _currentCollector;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    widget.sessionService.addListener(_onSessionUpdated);
    _setupCollector(widget.sessionService.currentArtifact);
  }

  @override
  void dispose() {
    widget.sessionService.removeListener(_onSessionUpdated);
    _currentCollector?.dispose();
    super.dispose();
  }

  void _onSessionUpdated() {
    setState(() {
      _setupCollector(widget.sessionService.currentArtifact);
    });
  }

  void _setupCollector(Artifact? artifact) {
    if (artifact == null) return;
    _currentCollector?.dispose();

    final inputIds = artifact.inputs.map((i) => i.id).toSet();
    _currentCollector = ResponseCollector(
      sessionId: artifact.sessionId,
      artifactId: artifact.artifactId,
      turnNumber: artifact.turnNumber,
      requiredInputs: inputIds,
    );
  }

  Future<void> _handleSubmit() async {
    if (_currentCollector == null || widget.sessionService.currentArtifact == null) return;

    setState(() => _isSubmitting = true);

    final response = _currentCollector!.buildUserResponse();
    await widget.sessionService.submitResponse(response);

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  String _getTurnTitle(int index) {
    switch (index) {
      case 0:
        return 'Mockup 1: Free Form Writing';
      case 1:
        return 'Mockup 2: Audio & Listening';
      case 2:
        return 'Mockup 3: Audio Speaking & Mic';
      case 3:
        return 'Mockup 4: Chatbot Dialogue + Free Form';
      case 4:
        return 'Mockup 5: Root Cause Diagnosis & Feedback';
      case 5:
        return 'Mockup 6: Reorder & Matching Pairs';
      default:
        return 'Turn ${index + 1}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final artifact = widget.sessionService.currentArtifact;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppTheme.border,
            height: 1.0,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentSubtle,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                border: Border.all(color: AppTheme.accent),
              ),
              child: Text(
                artifact?.level ?? 'A1',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    artifact?.topic ?? 'Language Learning',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Skill: ${artifact?.skill ?? "General"} • Turn ${artifact?.turnNumber ?? 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Scenario selector for browser evaluation
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: widget.sessionService.currentMockIndex,
                dropdownColor: AppTheme.surfaceElevated,
                icon: const Icon(Icons.tune_rounded, color: AppTheme.accent, size: 18),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                items: List.generate(
                  widget.sessionService.totalMockCount,
                  (index) => DropdownMenuItem(
                    value: index,
                    child: Text(_getTurnTitle(index)),
                  ),
                ),
                onChanged: (index) {
                  if (index != null) {
                    widget.sessionService.selectMockTurn(index);
                  }
                },
              ),
            ),
          ),
          // Connection status badge
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingMD),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.sessionService.status == ConnectionStatus.connected
                      ? AppTheme.correctSubtle
                      : AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  border: Border.all(
                    color: widget.sessionService.status == ConnectionStatus.connected
                        ? AppTheme.correct
                        : AppTheme.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.sessionService.status == ConnectionStatus.connected
                            ? AppTheme.correct
                            : AppTheme.accent,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.sessionService.status == ConnectionStatus.connected
                          ? 'Live'
                          : 'Generative UI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.sessionService.status == ConnectionStatus.connected
                            ? AppTheme.correct
                            : AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: artifact == null
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accent,
              ),
            )
          : Column(
              children: [
                // Top Progress Bar
                LinearProgressIndicator(
                  value: artifact.totalProgress > 0
                      ? artifact.currentProgress / artifact.totalProgress
                      : 0.2,
                  backgroundColor: AppTheme.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                  minHeight: 3,
                ),

                // Main Stage Canvas
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ArtifactRenderer(
                        artifact: artifact,
                        responseCollector: _currentCollector!,
                        isSubmitting: _isSubmitting,
                        onSubmit: _handleSubmit,
                        onContinueFromFeedback: () {
                          widget.sessionService.nextMockTurn();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
