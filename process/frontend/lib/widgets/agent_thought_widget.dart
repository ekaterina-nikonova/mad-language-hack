import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/websocket_service.dart';

class AgentThoughtWidget extends StatefulWidget {
  final SessionService sessionService;

  const AgentThoughtWidget({super.key, required this.sessionService});

  @override
  State<AgentThoughtWidget> createState() => _AgentThoughtWidgetState();
}

class _AgentThoughtWidgetState extends State<AgentThoughtWidget> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    widget.sessionService.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.sessionService.removeListener(_onUpdate);
    _scrollController.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) {
      setState(() {});
      // Scroll to bottom when new thoughts arrive
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        border: Border(
          left: BorderSide(color: AppTheme.border, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.border, width: 1.0),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.psychology, color: AppTheme.accent, size: 20),
                SizedBox(width: AppTheme.spacingSM),
                Text(
                  'Agent Thoughts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Terminal-like output
          Expanded(
            child: Container(
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.all(AppTheme.spacingSM),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.sessionService.agentThoughts.length,
                itemBuilder: (context, index) {
                  final thought = widget.sessionService.agentThoughts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '> ',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.greenAccent,
                            fontSize: 12,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            thought,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Plan Approval Card
          if (widget.sessionService.currentPlan != null)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  top: BorderSide(color: AppTheme.border, width: 1.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan Proposal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSM),
                  Text(
                    widget.sessionService.currentPlan!['plan'] ?? 'No description provided.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          widget.sessionService.submitPlanDecision(
                            'approve', 
                            skill: widget.sessionService.currentPlan!['skill']
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.correct,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Approve'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          widget.sessionService.submitPlanDecision('decline');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.incorrect,
                          side: const BorderSide(color: AppTheme.incorrect),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Decline'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          // Simple edit implementation (just sends edit, could open a dialog)
                          widget.sessionService.submitPlanDecision('edit');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accent,
                          side: const BorderSide(color: AppTheme.accent),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
