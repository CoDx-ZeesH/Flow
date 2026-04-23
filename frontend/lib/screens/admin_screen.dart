// lib/screens/admin_screen.dart
//
// NBBS v2 Lite rebuild:
//   ✅ 2 gradient heroes → solid semantic fills + hard 2px borders
//      (FOCUS SCORE → primary blue, BURNOUT FLAGS → drift red)
//   ✅ BEST MEETING WINDOW: Card → _AdminCard, DM Mono value, primary color
//   ✅ All Card → _AdminCard (soft border, 12px radius)
//   ✅ Insight pills: secondaryContainer/primaryContainer → NBBS soft state fills, 8px radius
//   ✅ _buildTag: pill radius → 6px square, FlowTheme colors (no primaryTintLight/Dark)
//   ✅ Dividers: theme.dividerColor → FlowTheme.borderSoftLight/Dark
//   ✅ Comment preserved: Break alert button intentionally absent here

import 'package:flutter/material.dart';
import '../core/theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context, theme, isDark),
            const SizedBox(height: 24),
            _buildHeroRow(context, theme, isDark),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildLiveStateGrid(context, theme, isDark)),
                const SizedBox(width: 14),
                Expanded(flex: 2, child: _buildSessionVolumeCard(context, theme, isDark)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildPerformanceTrend(context, theme, isDark)),
                const SizedBox(width: 14),
                Expanded(flex: 3, child: _buildPatternInsights(context, theme, isDark)),
              ],
            ),
            const SizedBox(height: 14),
            _buildEmployeeTable(context, theme, isDark),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMPANY ADMINISTRATOR · ERROR 011',
                style: theme.textTheme.labelMedium),
            const SizedBox(height: 2),
            Text('Team Cognitive Health', style: theme.textTheme.headlineLarge),
          ],
        ),
        // NOTE: Break alert button intentionally removed here.
        // Use the wired version in AdminShell's sidebar (notifications icon).
        _buildTag(context, 'LIVE DATA', state: SessionState.focus),
      ],
    );
  }

  // ── HERO ROW ──────────────────────────────────────────────────────────────

  Widget _buildHeroRow(BuildContext context, ThemeData theme, bool isDark) {
    return Row(
      children: [
        // TEAM FOCUS SCORE → solid primary
        Expanded(
          child: _buildSolidHero(
            isDark: isDark,
            label:  'TEAM FOCUS SCORE',
            value:  '71',
            sub:    '↑ +4 vs yesterday',
            color:  FlowTheme.stateColor(context, SessionState.focus),
          ),
        ),
        const SizedBox(width: 14),
        // BURNOUT RISK FLAGS → solid drift red
        Expanded(
          child: _buildSolidHero(
            isDark: isDark,
            label:  'BURNOUT RISK FLAGS',
            value:  '2',
            sub:    'Employees flagged this week',
            color:  FlowTheme.stateColor(context, SessionState.drift),
          ),
        ),
        const SizedBox(width: 14),
        // BEST MEETING WINDOW → info card (contrast with solid neighbors)
        Expanded(
          child: _AdminCard(
            isDark: isDark,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                Text('BEST MEETING WINDOW', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Text(
                  '14:30',
                  style: TextStyle(
                    fontFamily:    'DM Mono',
                    fontSize:      38,
                    fontWeight:    FontWeight.w800,
                    color:         theme.primaryColor,
                    letterSpacing: -2,
                    height:        1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Optimal slot in next 4 hours',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSolidHero({
    required bool   isDark,
    required String label,
    required String value,
    required String sub,
    required Color  color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily:    'DM Mono',
              fontSize:      10,
              color:         Colors.white70,
              letterSpacing: 1.5,
              fontWeight:    FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily:    'DM Mono',
              fontSize:      38,
              fontWeight:    FontWeight.w800,
              color:         Colors.white,
              letterSpacing: -2,
              height:        1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(sub,
              style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  // ── LIVE STATE GRID ───────────────────────────────────────────────────────

  Widget _buildLiveStateGrid(BuildContext context, ThemeData theme, bool isDark) {
    return _AdminCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Team States', style: theme.textTheme.headlineSmall),
              _buildTag(context, 'Updates 60s', state: SessionState.focus),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _stateCount(context, isDark, 'Deep Work',    '2', SessionState.focus)),
              Expanded(child: _stateCount(context, isDark, 'Shallow Work', '1', null)),
              Expanded(child: _stateCount(context, isDark, 'Break',        '0', null)),
              Expanded(child: _stateCount(context, isDark, 'Trough',       '1', SessionState.trough)),
              Expanded(child: _stateCount(context, isDark, 'Offline',      '2', null)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stateCount(BuildContext context, bool isDark, String label, String count,
      SessionState? state) {
    final color = state != null
        ? FlowTheme.stateColor(context, state)
        : (isDark ? FlowTheme.text3Dark : FlowTheme.text3Light);

    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize:   28,
            fontWeight: FontWeight.w800,
            color:      color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Mono',
            fontSize:   9,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── SESSION VOLUME ────────────────────────────────────────────────────────

  Widget _buildSessionVolumeCard(BuildContext context, ThemeData theme, bool isDark) {
    return _AdminCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session Volume', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          _volumeRow(context, theme, isDark, 'Sessions Today', '9'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              height: 1,
              color:  isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
            ),
          ),
          _volumeRow(context, theme, isDark, 'Avg Duration', '68 min'),
        ],
      ),
    );
  }

  Widget _volumeRow(BuildContext context, ThemeData theme, bool isDark,
      String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize:   13,
            fontWeight: FontWeight.w700,
            color:      theme.primaryColor,
          ),
        ),
      ],
    );
  }

  // ── 7-DAY TREND ───────────────────────────────────────────────────────────

  Widget _buildPerformanceTrend(BuildContext context, ThemeData theme, bool isDark) {
    final bars = [0.65, 0.70, 0.68, 0.75, 0.82, 0.71, 0.85];
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return _AdminCard(
      isDark: isDark,
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
                              color: theme.primaryColor
                                  .withValues(alpha: 0.8),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(3)),
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
    );
  }

  // ── PATTERN INSIGHTS ──────────────────────────────────────────────────────

  Widget _buildPatternInsights(BuildContext context, ThemeData theme, bool isDark) {
    return _AdminCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Team Pattern Insights', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _insightPill(context, isDark, '10–11 AM',
                  'Peak Focus Hour', SessionState.focus)),
              const SizedBox(width: 8),
              Expanded(child: _insightPill(context, isDark, '14:00',
                  'Common Stuck Time', SessionState.trough)),
              const SizedBox(width: 8),
              Expanded(child: _insightPill(context, isDark, '18 min',
                  'Best Break Length', SessionState.focus)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _insightPill(BuildContext context, bool isDark, String value,
      String label, SessionState state) {
    final accent = FlowTheme.stateColor(context, state);
    final soft   = FlowTheme.stateSoftColor(context, state);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color:        soft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize:   15,
              fontWeight: FontWeight.w800,
              color:      accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize:   9,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── EMPLOYEE TABLE ────────────────────────────────────────────────────────

  Widget _buildEmployeeTable(BuildContext context, ThemeData theme, bool isDark) {
    return _AdminCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Employee Overview (Anonymized)',
                  style: theme.textTheme.headlineSmall),
              Text(
                'Privacy Enforced',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize:   9,
                  fontWeight: FontWeight.w600,
                  color:      isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _tableRow(context, theme, isDark, 'ID',         'Focus Score', 'Sessions', null,  isHeader: true),
          _tableDivider(isDark),
          _tableRow(context, theme, isDark, 'Employee 1', '88', '12', false),
          _tableDivider(isDark),
          _tableRow(context, theme, isDark, 'Employee 2', '76', '9',  false),
          _tableDivider(isDark),
          _tableRow(context, theme, isDark, 'Employee 3', '42', '2',  true),
          _tableDivider(isDark),
          _tableRow(context, theme, isDark, 'Employee 4', '91', '14', false),
          _tableDivider(isDark),
          _tableRow(context, theme, isDark, 'Employee 5', '58', '6',  false),
        ],
      ),
    );
  }

  Widget _tableDivider(bool isDark) {
    return Container(
      height: 1,
      color:  isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
      margin: const EdgeInsets.symmetric(vertical: 1),
    );
  }

  Widget _tableRow(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String c1,
    String c2,
    String c3,
    bool? flagged, {
    bool isHeader = false,
  }) {
    final style = isHeader
        ? theme.textTheme.labelSmall
        : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    Widget lastCol;
    if (isHeader) {
      lastCol = Text('Burnout Flag', style: style);
    } else {
      final isFlagged = flagged ?? false;
      final dot = FlowTheme.stateColor(
          context, isFlagged ? SessionState.drift : SessionState.focus);
      lastCol = Container(
        width: 10, height: 10,
        decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
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

  // ── SHARED TAG ────────────────────────────────────────────────────────────

  Widget _buildTag(BuildContext context, String text,
      {required SessionState state}) {
    final accent = FlowTheme.stateColor(context, state);
    final soft   = FlowTheme.stateSoftColor(context, state);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        soft,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontSize:   10,
          fontWeight: FontWeight.w600,
          color:      accent,
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRIVATE COMPONENTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _AdminCard extends StatelessWidget {
  final Widget      child;
  final bool        isDark;
  final EdgeInsets? padding;

  const _AdminCard({required this.child, required this.isDark, this.padding});

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