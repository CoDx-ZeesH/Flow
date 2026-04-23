// lib/screens/admin_screen.dart
//
// Fix: removed the duplicate "Send Team Break Alert" ElevatedButton from _buildTopBar.
// The wired, confirmation-dialog version lives in AdminShell._sendBreakAlert().
// AdminShell passes that action through the sidebar button — having it duplicated here
// caused a second unconfirmed fire path and confused the breakAlertSent state.
//
// Everything else is pixel-identical to the pasted version.

import 'package:flutter/material.dart';
import '../core/theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 24),
            _buildHeroRow(context),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildLiveStateGrid(context)),
                const SizedBox(width: 14),
                Expanded(flex: 2, child: _buildSessionVolumeCard(context)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildPerformanceTrend(context)),
                const SizedBox(width: 14),
                Expanded(flex: 3, child: _buildPatternInsights(context)),
              ],
            ),
            const SizedBox(height: 24),
            _buildEmployeeTable(context),
          ],
        ),
      ),
    );
  }

  // ─── TOP BAR ─────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COMPANY ADMINISTRATOR · ERROR 011',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light),
            ),
            const SizedBox(height: 2),
            Text('Team Cognitive Health', style: theme.textTheme.headlineLarge),
          ],
        ),
        // NOTE: Break alert button intentionally removed here.
        // Use the wired version in AdminShell's sidebar (notifications icon).
        _buildTag(context, 'LIVE DATA', isGreen: true),
      ],
    );
  }

  // ─── HERO ROW ────────────────────────────────────────────────────────────
  Widget _buildHeroRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildGradientHero(context, 'TEAM FOCUS SCORE', '71',
            '↑ +4 vs yesterday', const [Color(0xFF4F6F57), Color(0xFF6B8F71)])),
        const SizedBox(width: 14),
        Expanded(child: _buildGradientHero(context, 'BURNOUT RISK FLAGS', '2',
            'Employees flagged this week', const [Color(0xFF5A1E28), Color(0xFF9E3D4A)])),
        const SizedBox(width: 14),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:  MainAxisAlignment.center,
                children: [
                  Text('BEST MEETING WINDOW', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Text('14:30',
                      style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800,
                          color: Theme.of(context).primaryColor, letterSpacing: -2, height: 1)),
                  const SizedBox(height: 6),
                  Text('Optimal slot in next 4 hours', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientHero(BuildContext context, String label, String value, String sub, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:     LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'DM Mono', letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -2, height: 1)),
          const SizedBox(height: 6),
          Text(sub, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }

  // ─── LIVE STATE GRID ─────────────────────────────────────────────────────
  Widget _buildLiveStateGrid(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Live Team States', style: theme.textTheme.headlineSmall),
                _buildTag(context, 'Updates 60s', isGreen: true),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _stateCount(context, 'Deep Work',    '2', theme.primaryColor)),
                Expanded(child: _stateCount(context, 'Shallow Work', '1', theme.textTheme.bodyMedium!.color!)),
                Expanded(child: _stateCount(context, 'Break',        '0', theme.colorScheme.primaryContainer)),
                Expanded(child: _stateCount(context, 'Trough',       '1', theme.colorScheme.secondary)),
                Expanded(child: _stateCount(context, 'Offline',      '2', theme.dividerColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stateCount(BuildContext context, String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 10, fontFamily: 'DM Mono', fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
      ],
    );
  }

  // ─── SESSION VOLUME ──────────────────────────────────────────────────────
  Widget _buildSessionVolumeCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session Volume', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            _volumeRow(context, 'Sessions Today', '9'),
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
            _volumeRow(context, 'Avg Duration', '68 min'),
          ],
        ),
      ),
    );
  }

  Widget _volumeRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.primaryColor)),
      ],
    );
  }

  // ─── 7-DAY TREND ─────────────────────────────────────────────────────────
  Widget _buildPerformanceTrend(BuildContext context) {
    final bars = [0.65, 0.70, 0.68, 0.75, 0.82, 0.71, 0.85];
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('7-Day Trend', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 14),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(bars.length, (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: bars[i],
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(alpha: 0.8),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(days[i], style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PATTERN INSIGHTS ────────────────────────────────────────────────────
  Widget _buildPatternInsights(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team Pattern Insights', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _insightPill(context, '10–11 AM', 'Peak Focus Hour')),
                const SizedBox(width: 8),
                Expanded(child: _insightPill(context, '14:00', 'Common Stuck Time', isWarning: true)),
                const SizedBox(width: 8),
                Expanded(child: _insightPill(context, '18 min', 'Best Break Length')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightPill(BuildContext context, String value, String label, {bool isWarning = false}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color:        isWarning ? theme.colorScheme.secondaryContainer : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                  color: isWarning ? theme.colorScheme.secondary : theme.primaryColor)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, fontFamily: 'DM Mono'), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ─── EMPLOYEE TABLE ──────────────────────────────────────────────────────
  Widget _buildEmployeeTable(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Employee Overview (Anonymized)', style: theme.textTheme.headlineSmall),
                Text('Privacy Enforced',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontFamily: 'DM Mono')),
              ],
            ),
            const SizedBox(height: 16),
            _tableRow(context, 'ID', 'Focus Score', 'Sessions', 'Burnout Flag', isHeader: true),
            const Divider(),
            _tableRow(context, 'Employee 1', '88', '12', false),
            const Divider(),
            _tableRow(context, 'Employee 2', '76', '9',  false),
            const Divider(),
            _tableRow(context, 'Employee 3', '42', '2',  true),
            const Divider(),
            _tableRow(context, 'Employee 4', '91', '14', false),
            const Divider(),
            _tableRow(context, 'Employee 5', '58', '6',  false),
          ],
        ),
      ),
    );
  }

  Widget _tableRow(BuildContext context, String c1, String c2, String c3, dynamic c4,
      {bool isHeader = false}) {
    final style = isHeader
        ? Theme.of(context).textTheme.labelSmall
        : Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    Widget lastCol;
    if (isHeader) {
      lastCol = Text(c4 as String, style: style);
    } else {
      final flagged = c4 as bool;
      lastCol = Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          color:  flagged ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
          shape:  BoxShape.circle,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(c1, style: style)),
          Expanded(flex: 2, child: Text(c2, style: style)),
          Expanded(flex: 2, child: Text(c3, style: style)),
          Expanded(flex: 1, child: lastCol),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, {bool isGreen = false}) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isGreen
            ? (isDark ? FlowTheme.primaryTintDark : FlowTheme.primaryTintLight)
            : theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isGreen ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
            fontSize: 10,
          )),
    );
  }
}