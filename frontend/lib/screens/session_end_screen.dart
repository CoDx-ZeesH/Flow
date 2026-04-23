// lib/screens/session_end_screen.dart
//
// NBBS v2 Lite rebuild:
//   ✅ Card → Container + soft-border _EndCard, 12px radius
//   ✅ ElevatedButton → GestureDetector + Container, hard 2px border
//   ✅ "What FLOW Learned" hero: solid primary fill + hard border (not tinted card)
//   ✅ Focus score: DM Mono, primary color, CountUpText preserved
//   ✅ Timeline events: NBBS semantic colors (blue/amber/red)
//   ✅ Stat cards: DM Mono values, soft border
//   ✅ FocusRing + FocusSparkline widgets unchanged — already NBBS-compatible
//   ✅ All AppState wiring preserved

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/count_up_text.dart';
import '../widgets/focus_ring.dart';
import '../widgets/focus_sparkline.dart';

class SessionEndScreen extends StatelessWidget {
  final VoidCallback onReturnToDashboard;

  const SessionEndScreen({super.key, required this.onReturnToDashboard});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme    = Theme.of(context);
    final isDark   = theme.brightness == Brightness.dark;

    // Use real AppState values; fall back to demo data
    final focusScore    = appState.endedFocusScore    > 0 ? appState.endedFocusScore    : 78;
    final durationMin   = appState.endedDurationMin   > 0 ? appState.endedDurationMin   : 52;
    final interventions = appState.endedInterventionsAccepted > 0
        ? appState.endedInterventionsAccepted : 1;
    final learned = appState.whatFlowLearned.isNotEmpty
        ? appState.whatFlowLearned
        : 'Your post-intervention recovery is strong. You accepted the suggested break and returned highly focused. Ultradian period estimated at 52 minutes.';
    final scoreHistory = appState.sessionScoreHistory.isNotEmpty
        ? appState.sessionScoreHistory
        : const [75.0, 82.0, 85.0, 38.0, 79.0, 55.0, 72.0, 78.0];
    final events = appState.replayEvents.isNotEmpty
        ? appState.replayEvents
        : _demoEvents;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 60),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SESSION COMPLETE',
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Text('Great work.', style: theme.textTheme.displayMedium),
                      ],
                    ),
                    // Return button — NBBS: transparent bg, hard 2px border, primary text
                    GestureDetector(
                      onTap: onReturnToDashboard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color:        Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? FlowTheme.borderDark
                                : FlowTheme.borderLight,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.grid_view_rounded,
                              size:  16,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Return to Dashboard',
                              style: TextStyle(
                                fontSize:   13,
                                fontWeight: FontWeight.w700,
                                color:      theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── TOP METRICS ROW ───────────────────────────────────────
                Row(
                  children: [
                    // Focus score hero card
                    Expanded(
                      flex: 3,
                      child: _EndCard(
                        isDark: isDark,
                        padding: const EdgeInsets.all(28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('FINAL FOCUS SCORE',
                                    style: theme.textTheme.labelMedium),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    CountUpText(
                                      target: focusScore,
                                      style:  TextStyle(
                                        fontFamily:    'DM Mono',
                                        fontSize:      64,
                                        fontWeight:    FontWeight.w800,
                                        color:         theme.primaryColor,
                                        letterSpacing: -2,
                                        height:        1.0,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 12, left: 4),
                                      child: Text(
                                        '%',
                                        style: TextStyle(
                                          fontFamily: 'DM Mono',
                                          fontSize:   28,
                                          fontWeight: FontWeight.w700,
                                          color:      theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Score badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color:        FlowTheme.stateSoftColor(
                                        context, SessionState.focus),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: theme.primaryColor
                                          .withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    focusScore >= 80
                                        ? '↑ Top 10% this week'
                                        : '↑ Good session',
                                    style: TextStyle(
                                      fontFamily: 'DM Mono',
                                      fontSize:   10,
                                      fontWeight: FontWeight.w600,
                                      color:      theme.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            FocusRing(
                              score:       focusScore.toDouble(),
                              color:       theme.primaryColor,
                              trackColor:  isDark
                                  ? FlowTheme.borderSoftDark
                                  : FlowTheme.borderSoftLight,
                              size:        120,
                              strokeWidth: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Stat pills column
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildStatCard(context, theme, isDark,
                              'TOTAL DURATION', durationMin, 'min'),
                          const SizedBox(height: 14),
                          _buildStatCard(context, theme, isDark,
                              'INTERVENTIONS', interventions, 'accepted'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── SPARKLINE + LEARNED ───────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Telemetry sparkline
                    Expanded(
                      flex: 3,
                      child: _EndCard(
                        isDark: isDark,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Session Telemetry Replay',
                                style: theme.textTheme.headlineSmall),
                            const SizedBox(height: 20),
                            FocusSparkline(
                              scores: scoreHistory,
                              color:  theme.primaryColor,
                              height: 140,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // "What FLOW Learned" — solid primary hero, not a tinted card
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:        theme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? FlowTheme.borderDark
                                : FlowTheme.borderLight,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_awesome_rounded,
                                    color: Colors.white70, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'WHAT FLOW LEARNED',
                                  style: TextStyle(
                                    fontFamily:    'DM Mono',
                                    fontSize:      10,
                                    color:         Colors.white70,
                                    letterSpacing: 1.2,
                                    fontWeight:    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              learned,
                              style: const TextStyle(
                                fontSize:   13,
                                color:      Colors.white,
                                height:     1.6,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── REPLAY TIMELINE ───────────────────────────────────────
                Text('Session Event Log',
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),
                ...events.asMap().entries.map((entry) {
                  final e      = entry.value;
                  final isLast = entry.key == events.length - 1;
                  return _buildTimelineEvent(
                    context, theme, isDark,
                    e['time']        as String? ?? '',
                    e['title']       as String? ?? '',
                    e['description'] as String? ?? '',
                    _colorForEventType(context, e['type'] as String? ?? 'info'),
                    isLast: isLast,
                  );
                }),

                const SizedBox(height: 40),

                // ── BOTTOM CTA — solid primary, hard 2px border ───────────
                Center(
                  child: GestureDetector(
                    onTap: onReturnToDashboard,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 16),
                      decoration: BoxDecoration(
                        color:        theme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? FlowTheme.borderDark
                              : FlowTheme.borderLight,
                          width: 2,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 10),
                          Text(
                            'Back to Dashboard',
                            style: TextStyle(
                              color:      Colors.white,
                              fontSize:   15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  Color _colorForEventType(BuildContext context, String type) {
    switch (type) {
      case 'success': return FlowTheme.stateColor(context, SessionState.focus);
      case 'warning': return FlowTheme.stateColor(context, SessionState.trough);
      case 'error':   return FlowTheme.stateColor(context, SessionState.drift);
      default:
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight;
    }
  }

  Widget _buildStatCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String label,
    int target,
    String unit,
  ) {
    return _EndCard(
      isDark: isDark,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CountUpText(
                target: target,
                style: TextStyle(
                  fontFamily:    'DM Mono',
                  fontSize:      32,
                  fontWeight:    FontWeight.w800,
                  color:         isDark ? FlowTheme.text1Dark : FlowTheme.text1Light,
                  letterSpacing: -1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                    color:      isDark ? FlowTheme.text2Dark : FlowTheme.text2Light,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String time,
    String title,
    String description,
    Color color, {
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timestamp
          SizedBox(
            width: 80,
            child: Text(
              time,
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize:   10,
                fontWeight: FontWeight.w600,
                color:      isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
              ),
            ),
          ),
          // Timeline spine
          Column(
            children: [
              Container(
                width: 12, height: 12,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color:  isDark ? FlowTheme.bgDark : FlowTheme.bgLight,
                  shape:  BoxShape.circle,
                  border: Border.all(color: color, width: 2.5),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width:  1.5,
                    color:  isDark
                        ? FlowTheme.borderSoftDark
                        : FlowTheme.borderSoftLight,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22, top: 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? FlowTheme.borderSoftDark
                        : FlowTheme.borderSoftLight,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left accent bar + title row
                    Row(
                      children: [
                        Container(
                          width: 3, height: 14,
                          decoration: BoxDecoration(
                            color:        color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize:   12,
                            fontWeight: FontWeight.w700,
                            color:      isDark
                                ? FlowTheme.text1Dark
                                : FlowTheme.text1Light,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 11),
                      child: Text(description, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRIVATE COMPONENTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Base informational card — soft border, 12px radius.
class _EndCard extends StatelessWidget {
  final Widget      child;
  final bool        isDark;
  final EdgeInsets? padding;

  const _EndCard({
    required this.child,
    required this.isDark,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}