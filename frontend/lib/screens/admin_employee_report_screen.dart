import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';

/// Admin Employee Reports screen.
/// Shows anonymized employee rows with burnout flags, focus scores, session counts.
/// API teammate: populate via appState.setAdminDashboard() — burnoutFlags list drives this screen.

class AdminEmployeeReportScreen extends StatelessWidget {
  const AdminEmployeeReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use burnout flags from AppState if available, else demo data
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
            // ─── HEADER ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EMPLOYEE REPORTS',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light)),
                    const SizedBox(height: 2),
                    Text('Anonymized Cognitive Health', style: theme.textTheme.headlineLarge),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined, size: 14, color: theme.colorScheme.error),
                      const SizedBox(width: 6),
                      Text('Privacy enforced — no personal data',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ─── SUMMARY PILLS ───
            Row(
              children: [
                _buildSummaryPill(context, '${appState.adminTotalEmployees > 0 ? appState.adminTotalEmployees : 8}',
                    'Total Employees', theme.primaryColor),
                const SizedBox(width: 12),
                _buildSummaryPill(context, '${appState.adminBurnoutFlagsCount > 0 ? appState.adminBurnoutFlagsCount : 2}',
                    'Burnout Flagged', theme.colorScheme.error),
                const SizedBox(width: 12),
                _buildSummaryPill(context, '${appState.adminActiveRightNow > 0 ? appState.adminActiveRightNow : 5}',
                    'Active Now', theme.primaryColor),
              ],
            ),
            const SizedBox(height: 24),

            // ─── TABLE HEADER ───
            _buildTableHeader(context),
            const Divider(height: 1),

            // ─── EMPLOYEE ROWS ───
            ...employees.asMap().entries.map((entry) {
              final i = entry.key;
              final emp = entry.value;
              return Column(
                children: [
                  _buildEmployeeRow(context, i + 1, emp),
                  if (i < employees.length - 1) const Divider(height: 1),
                ],
              );
            }),

            const SizedBox(height: 32),

            // ─── BURNOUT DETAIL CARDS ───
            if (employees.any((e) => e['risk_level'] == 'high' || e['risk_level'] == 'medium')) ...[
              Text('At-Risk Employees', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...employees.where((e) => e['risk_level'] == 'high' || e['risk_level'] == 'medium')
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildBurnoutCard(context, entry.key + 1, entry.value),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPill(BuildContext context, String value, String label, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: color, letterSpacing: -1)),
            const SizedBox(height: 4),
            Text(label.toUpperCase(),
              style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('EMPLOYEE', style: theme.textTheme.labelSmall)),
          Expanded(flex: 2, child: Text('FOCUS SCORE (AVG)', style: theme.textTheme.labelSmall)),
          Expanded(flex: 2, child: Text('SESSIONS THIS WEEK', style: theme.textTheme.labelSmall)),
          Expanded(flex: 1, child: Text('RISK', style: theme.textTheme.labelSmall)),
          Expanded(flex: 2, child: Text('STATUS', style: theme.textTheme.labelSmall)),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(BuildContext context, int index, Map<String, dynamic> emp) {
    final theme = Theme.of(context);
    final risk = emp['risk_level'] as String? ?? 'low';
    final score = emp['avg_focus_score'] as int? ?? 75;
    final sessions = emp['sessions_this_week'] as int? ?? 5;

    Color riskColor;
    String riskLabel;
    switch (risk) {
      case 'high':
        riskColor = theme.colorScheme.error;
        riskLabel = 'High';
        break;
      case 'medium':
        riskColor = theme.colorScheme.secondary;
        riskLabel = 'Medium';
        break;
      default:
        riskColor = theme.primaryColor;
        riskLabel = 'Low';
    }

    Color scoreColor;
    if (score >= 70) {
      scoreColor = theme.primaryColor;
    } else if (score >= 50) scoreColor = theme.colorScheme.secondary;
    else                  scoreColor = theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          // Employee ID (anonymized)
          Expanded(flex: 2, child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('$index',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.primaryColor)),
              ),
              const SizedBox(width: 10),
              Text('Employee $index',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          )),

          // Focus score
          Expanded(flex: 2, child: Row(
            children: [
              Text('$score',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: scoreColor)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: theme.dividerColor,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          )),

          // Sessions
          Expanded(flex: 2,
            child: Text('$sessions sessions',
              style: theme.textTheme.bodyMedium)),

          // Risk dot
          Expanded(flex: 1,
            child: Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle),
            )),

          // Status badge
          Expanded(flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(riskLabel,
                style: theme.textTheme.labelLarge?.copyWith(color: riskColor, fontSize: 11)),
            )),
        ],
      ),
    );
  }

  Widget _buildBurnoutCard(BuildContext context, int index, Map<String, dynamic> emp) {
    final theme = Theme.of(context);
    final risk = emp['risk_level'] as String? ?? 'medium';
    final score = emp['avg_focus_score'] as int? ?? 50;
    final sessions = emp['sessions_this_week'] as int? ?? 2;

    final isHigh = risk == 'high';
    final color = isHigh ? theme.colorScheme.error : theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(isHigh ? Icons.warning_rounded : Icons.info_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Employee $index — ${isHigh ? "High" : "Medium"} Risk',
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 4),
                Text(
                  'Avg focus: $score/100 · $sessions sessions this week'
                  '${isHigh ? ' · Immediate HR attention recommended' : ' · Monitor closely'}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // HR action button for high risk
          if (isHigh)
            ElevatedButton(
              onPressed: () {
                // API teammate: POST /admin/send-break-alert or HR notification
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('HR Action', style: TextStyle(fontSize: 12)),
            ),
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