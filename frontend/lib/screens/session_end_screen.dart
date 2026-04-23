import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../widgets/count_up_text.dart';
import '../widgets/focus_ring.dart';
import '../widgets/focus_sparkline.dart';

class SessionEndScreen extends StatelessWidget {
  final VoidCallback onReturnToDashboard;

  const SessionEndScreen({super.key, required this.onReturnToDashboard});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    // Use AppState values if session ended, else show demo data
    final focusScore   = appState.endedFocusScore   > 0 ? appState.endedFocusScore   : 78;
    final durationMin  = appState.endedDurationMin  > 0 ? appState.endedDurationMin  : 52;
    final interventions = appState.endedInterventionsAccepted > 0
        ? appState.endedInterventionsAccepted : 1;
    final learned = appState.whatFlowLearned.isNotEmpty
        ? appState.whatFlowLearned
        : 'Your post-intervention recovery is strong. You accepted the suggested break and returned highly focused. Ultradian period estimated at 52 minutes.';
    final scoreHistory = appState.sessionScoreHistory.isNotEmpty
        ? appState.sessionScoreHistory
        : const [75.0, 82.0, 85.0, 38.0, 79.0, 55.0, 72.0, 78.0];

    // Build replay events from AppState or demo
    final events = appState.replayEvents.isNotEmpty
        ? appState.replayEvents
        : _demoEvents;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 60),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── HEADER ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SESSION COMPLETE',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6))),
                        const SizedBox(height: 4),
                        Text('Great work.', style: theme.textTheme.displayMedium),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: onReturnToDashboard,
                      icon: const Icon(Icons.grid_view_rounded, size: 18),
                      label: const Text('Return to Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.scaffoldBackgroundColor,
                        foregroundColor: theme.primaryColor,
                        side: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ─── TOP METRICS ROW ───
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: theme.dividerColor)),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('FINAL FOCUS SCORE', style: theme.textTheme.labelMedium),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      CountUpText(
                                        target: focusScore,
                                        style: theme.textTheme.displayLarge?.copyWith(
                                          color: theme.primaryColor, fontSize: 64),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12, left: 4),
                                        child: Text('%',
                                          style: TextStyle(
                                            fontSize: 28, color: theme.primaryColor,
                                            fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      focusScore >= 80 ? '↑ Top 10% this week' : '↑ Good session',
                                      style: theme.textTheme.labelLarge?.copyWith(color: theme.primaryColor)),
                                  ),
                                ],
                              ),
                              FocusRing(
                                score: focusScore.toDouble(),
                                color: theme.primaryColor,
                                trackColor: theme.dividerColor,
                                size: 120, strokeWidth: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildStatCard(context, 'TOTAL DURATION', durationMin, 'min'),
                          const SizedBox(height: 14),
                          _buildStatCard(context, 'INTERVENTIONS', interventions, 'accepted'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ─── SPARKLINE + LEARNED ───
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: theme.dividerColor)),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Session Telemetry Replay', style: theme.textTheme.headlineSmall),
                              const SizedBox(height: 24),
                              FocusSparkline(
                                scores: scoreHistory,
                                color: theme.primaryColor,
                                height: 140,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: theme.dividerColor)),
                        color: theme.colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome_rounded, color: theme.primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Text('WHAT FLOW LEARNED',
                                    style: theme.textTheme.labelMedium?.copyWith(color: theme.primaryColor)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(learned,
                                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ─── REPLAY TIMELINE ───
                Text('Session Event Log', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 20),
                ...events.asMap().entries.map((entry) {
                  final e = entry.value;
                  final isLast = entry.key == events.length - 1;
                  return _buildTimelineEvent(
                    context,
                    e['time'] as String? ?? '',
                    e['title'] as String? ?? '',
                    e['description'] as String? ?? '',
                    _colorForEventType(context, e['type'] as String? ?? 'info'),
                    isLast: isLast,
                  );
                }),

                const SizedBox(height: 32),

                // ─── RETURN BUTTON (bottom) ───
                Center(
                  child: ElevatedButton.icon(
                    onPressed: onReturnToDashboard,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back to Dashboard'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForEventType(BuildContext context, String type) {
    final theme = Theme.of(context);
    switch (type) {
      case 'success': return theme.primaryColor;
      case 'warning': return theme.colorScheme.secondary;
      case 'error':   return theme.colorScheme.error;
      default:        return theme.dividerColor;
    }
  }

  Widget _buildStatCard(BuildContext context, String label, int target, String unit) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CountUpText(target: target,
                  style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w800,
                    color: theme.textTheme.displayLarge?.color)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 4),
                  child: Text(unit,
                    style: TextStyle(
                      fontSize: 14, color: theme.textTheme.labelSmall?.color,
                      fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineEvent(BuildContext context, String time, String title,
      String description, Color color, {bool isLast = false}) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 70,
            child: Text(time,
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          Column(
            children: [
              Container(
                width: 14, height: 14,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: theme.dividerColor,
                  margin: const EdgeInsets.symmetric(vertical: 4))),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<Map<String, dynamic>> _demoEvents = [
    {'time': '10:00 AM', 'title': 'Session Started',         'description': 'Deep Work baseline established.',          'type': 'success'},
    {'time': '10:22 AM', 'title': 'Cognitive Loop Detected', 'description': 'Focus score dropped to 38%.',               'type': 'warning'},
    {'time': '10:24 AM', 'title': 'AI Strategy Deployed',    'description': 'Constraint Inversion strategy suggested.',  'type': 'success'},
    {'time': '10:35 AM', 'title': 'Flow Resumed',            'description': 'Focus score stabilized at 79%.',            'type': 'success'},
    {'time': '10:48 AM', 'title': 'Fatigue Detected',        'description': 'Intervention fired. 5m break accepted.',    'type': 'error'},
    {'time': '10:52 AM', 'title': 'Session Concluded',       'description': 'Ended manually.',                           'type': 'info'},
  ];
}