// lib/screens/admin_employee_report_screen.dart
//
// NBBS v2 Lite rebuild:
//   ✅ Summary pills: borderRadius(20) → 8px, hard accent border
//   ✅ Privacy badge: pill → 6px square, hard drift-red border
//   ✅ Table header: scaffoldBackgroundColor bg → elevated surface
//   ✅ Table status badges: pill radius → 6px square tags
//   ✅ Score progress bars: clip radius(4) → clip radius(3), NBBS semantic colors
//   ✅ Burnout alert cards: borderRadius(20) → 12px, left accent bar pattern
//   ✅ ElevatedButton "HR Action" → GestureDetector + Container, hard 2px border
//   ✅ Employee avatar: circle → kept circle (identity), solid primary fill
//   ✅ All AppState wiring preserved

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';

class AdminEmployeeReportScreen extends StatelessWidget {
  const AdminEmployeeReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme    = Theme.of(context);
    final isDark   = theme.brightness == Brightness.dark;

    final employees = appState.adminBurnoutFlags.isNotEmpty
        ? appState.adminBurnoutFlags
        : _demoEmployees;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
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
                    Text('EMPLOYEE REPORTS', style: theme.textTheme.labelMedium),
                    const SizedBox(height: 2),
                    Text('Anonymized Cognitive Health',
                        style: theme.textTheme.headlineLarge),
                  ],
                ),
                // Privacy badge — hard drift-red border, 6px square
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color:        FlowTheme.stateSoftColor(
                        context, SessionState.drift),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: FlowTheme.stateColor(context, SessionState.drift)
                          .withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.privacy_tip_outlined,
                          size:  13,
                          color: FlowTheme.stateColor(
                              context, SessionState.drift)),
                      const SizedBox(width: 6),
                      Text(
                        'Privacy enforced — no personal data',
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize:   9,
                          fontWeight: FontWeight.w600,
                          color: FlowTheme.stateColor(
                              context, SessionState.drift),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── SUMMARY PILLS ─────────────────────────────────────────
            Row(
              children: [
                _buildSummaryPill(
                  context, isDark,
                  '${appState.adminTotalEmployees > 0 ? appState.adminTotalEmployees : 8}',
                  'Total Employees',
                  SessionState.focus,
                ),
                const SizedBox(width: 12),
                _buildSummaryPill(
                  context, isDark,
                  '${appState.adminBurnoutFlagsCount > 0 ? appState.adminBurnoutFlagsCount : 2}',
                  'Burnout Flagged',
                  SessionState.drift,
                ),
                const SizedBox(width: 12),
                _buildSummaryPill(
                  context, isDark,
                  '${appState.adminActiveRightNow > 0 ? appState.adminActiveRightNow : 5}',
                  'Active Now',
                  SessionState.focus,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── TABLE ─────────────────────────────────────────────────
            _buildTableHeader(context, theme, isDark),
            Container(
              height: 1,
              color:  isDark
                  ? FlowTheme.borderSoftDark
                  : FlowTheme.borderSoftLight,
            ),
            ...employees.asMap().entries.map((entry) {
              final i   = entry.key;
              final emp = entry.value;
              return Column(
                children: [
                  _buildEmployeeRow(context, theme, isDark, i + 1, emp),
                  if (i < employees.length - 1)
                    Container(
                      height: 1,
                      color:  isDark
                          ? FlowTheme.borderSoftDark
                          : FlowTheme.borderSoftLight,
                    ),
                ],
              );
            }),

            const SizedBox(height: 32),

            // ── BURNOUT DETAIL CARDS ──────────────────────────────────
            if (employees.any((e) =>
                e['risk_level'] == 'high' ||
                e['risk_level'] == 'medium')) ...[
              Text('At-Risk Employees', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...employees
                  .where((e) =>
                      e['risk_level'] == 'high' ||
                      e['risk_level'] == 'medium')
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildBurnoutCard(
                            context, theme, isDark, entry.key + 1,
                            entry.value),
                      )),
            ],
          ],
        ),
      ),
    );
  }

  // ── SUMMARY PILL ─────────────────────────────────────────────────────────

  Widget _buildSummaryPill(BuildContext context, bool isDark, String value,
      String label, SessionState state) {
    final accent = FlowTheme.stateColor(context, state);
    final soft   = FlowTheme.stateSoftColor(context, state);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:        soft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accent.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily:    'DM Mono',
                fontSize:      32,
                fontWeight:    FontWeight.w800,
                color:         accent,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  // ── TABLE HEADER ─────────────────────────────────────────────────────────

  Widget _buildTableHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? FlowTheme.elevatedDark : FlowTheme.elevatedLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('EMPLOYEE',           style: theme.textTheme.labelSmall)),
          Expanded(flex: 2, child: Text('FOCUS SCORE (AVG)',  style: theme.textTheme.labelSmall)),
          Expanded(flex: 2, child: Text('SESSIONS THIS WEEK', style: theme.textTheme.labelSmall)),
          Expanded(flex: 1, child: Text('RISK',               style: theme.textTheme.labelSmall)),
          Expanded(flex: 2, child: Text('STATUS',             style: theme.textTheme.labelSmall)),
        ],
      ),
    );
  }

  // ── EMPLOYEE ROW ─────────────────────────────────────────────────────────

  Widget _buildEmployeeRow(BuildContext context, ThemeData theme, bool isDark,
      int index, Map<String, dynamic> emp) {
    final risk     = emp['risk_level']        as String? ?? 'low';
    final score    = emp['avg_focus_score']   as int?    ?? 75;
    final sessions = emp['sessions_this_week'] as int?   ?? 5;

    final state = risk == 'high'
        ? SessionState.drift
        : risk == 'medium'
            ? SessionState.trough
            : SessionState.focus;

    final accent     = FlowTheme.stateColor(context, state);
    final riskLabel  = risk == 'high' ? 'High' : risk == 'medium' ? 'Medium' : 'Low';
    final scoreColor = score >= 70
        ? FlowTheme.stateColor(context, SessionState.focus)
        : score >= 50
            ? FlowTheme.stateColor(context, SessionState.trough)
            : FlowTheme.stateColor(context, SessionState.drift);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          // Employee avatar + ID
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: FlowTheme.stateSoftColor(context, SessionState.focus),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize:   11,
                      fontWeight: FontWeight.w800,
                      color:      theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Employee $index',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Focus score + progress bar
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize:   16,
                    fontWeight: FontWeight.w800,
                    color:      scoreColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value:           score / 100,
                      minHeight:       5,
                      backgroundColor: isDark
                          ? FlowTheme.borderSoftDark
                          : FlowTheme.borderSoftLight,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sessions
          Expanded(
            flex: 2,
            child: Text('$sessions sessions', style: theme.textTheme.bodyMedium),
          ),

          // Risk dot
          Expanded(
            flex: 1,
            child: Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          ),

          // Status tag — 6px square
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:        FlowTheme.stateSoftColor(context, state),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: accent.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Text(
                riskLabel,
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize:   10,
                  fontWeight: FontWeight.w600,
                  color:      accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BURNOUT CARD ─────────────────────────────────────────────────────────

  Widget _buildBurnoutCard(BuildContext context, ThemeData theme, bool isDark,
      int index, Map<String, dynamic> emp) {
    final risk     = emp['risk_level']         as String? ?? 'medium';
    final score    = emp['avg_focus_score']    as int?    ?? 50;
    final sessions = emp['sessions_this_week'] as int?    ?? 2;

    final isHigh = risk == 'high';
    final state  = isHigh ? SessionState.drift : SessionState.trough;
    final accent = FlowTheme.stateColor(context, state);
    final soft   = FlowTheme.stateSoftColor(context, state);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 3,
            height: 52,
            decoration: BoxDecoration(
              color:        accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          // Icon
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(
              isHigh ? Icons.warning_rounded : Icons.info_rounded,
              color: accent,
              size:  20,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee $index — ${isHigh ? "High" : "Medium"} Risk',
                  style: TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Avg focus: $score/100 · $sessions sessions this week'
                  '${isHigh ? ' · Immediate HR attention recommended' : ' · Monitor closely'}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // HR Action button — NBBS: hard 2px border, no ElevatedButton
          if (isHigh) ...[
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                // API teammate: POST /admin/send-break-alert or HR notification
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color:        accent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? FlowTheme.borderDark
                        : FlowTheme.borderLight,
                    width: 2,
                  ),
                ),
                child: const Text(
                  'HR Action',
                  style: TextStyle(
                    color:      Colors.white,
                    fontSize:   12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Demo data — replaced by AppState.adminBurnoutFlags once API is wired
  static const List<Map<String, dynamic>> _demoEmployees = [
    {'risk_level': 'low',    'avg_focus_score': 88, 'sessions_this_week': 12},
    {'risk_level': 'low',    'avg_focus_score': 76, 'sessions_this_week': 9},
    {'risk_level': 'high',   'avg_focus_score': 38, 'sessions_this_week': 1},
    {'risk_level': 'low',    'avg_focus_score': 91, 'sessions_this_week': 14},
    {'risk_level': 'medium', 'avg_focus_score': 51, 'sessions_this_week': 3},
    {'risk_level': 'low',    'avg_focus_score': 82, 'sessions_this_week': 8},
    {'risk_level': 'low',    'avg_focus_score': 79, 'sessions_this_week': 11},
    {'risk_level': 'medium', 'avg_focus_score': 55, 'sessions_this_week': 4},
  ];
}