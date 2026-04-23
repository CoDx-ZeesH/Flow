// lib/screens/team_screen.dart
//
// NBBS v2 Lite rebuild:
//   ✅ 3 gradient hero cards → solid semantic fills + hard 2px borders
//      (ALIGNMENT → primary blue, ACTIVE NODES → trough amber, COLLECTIVE FLOW → elevated card)
//   ✅ Card → _TeamCard container + soft border, 12px radius
//   ✅ Team node avatars: gradient circles → solid semantic fill circles
//   ✅ Node cards: borderRadius(20) → 12px, hard semantic border
//   ✅ Tags: pill radius(100) → 6px square, FlowTheme semantic colors
//   ✅ ERR011 badge: pill → 6px square
//   ✅ Progress bars: clip radius(100) → clip radius(3)
//   ✅ Bar chart: NBBS semantic colors
//   ✅ IntrinsicHeight layout fix preserved

import 'package:flutter/material.dart';
import '../core/theme.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

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
            _buildTeamStatsGrid(context, theme, isDark),
            const SizedBox(height: 14),
            _buildTeamNodesCard(context, theme, isDark),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildTeamFocusWindow(context, theme, isDark)),
                  const SizedBox(width: 14),
                  Expanded(child: _buildCollectiveDrift(context, theme, isDark)),
                ],
              ),
            ),
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
            Text('DEPARTMENT TELEMETRY', style: theme.textTheme.labelMedium),
            const SizedBox(height: 2),
            Text('Team node map', style: theme.textTheme.headlineLarge),
          ],
        ),
        // ERR011 badge — NBBS: 6px square, hard border
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color:        FlowTheme.stateSoftColor(context, SessionState.focus),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Text(
            'ERR011',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize:   11,
              fontWeight: FontWeight.w700,
              color:      theme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // ── HERO STATS — gradient → solid fills ───────────────────────────────────

  Widget _buildTeamStatsGrid(BuildContext context, ThemeData theme, bool isDark) {
    return Row(
      children: [
        // AVG ALIGNMENT → solid primary (focus blue)
        Expanded(
          child: _buildSolidHero(
            isDark: isDark,
            label:  'AVG ALIGNMENT',
            value:  '74%',
            color:  FlowTheme.stateColor(context, SessionState.focus),
          ),
        ),
        const SizedBox(width: 14),
        // ACTIVE NODES → solid amber (trough)
        Expanded(
          child: _buildSolidHero(
            isDark: isDark,
            label:  'ACTIVE NODES',
            value:  '12',
            color:  FlowTheme.stateColor(context, SessionState.trough),
          ),
        ),
        const SizedBox(width: 14),
        // COLLECTIVE FLOW → elevated info card (contrast with solid neighbors)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:        isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COLLECTIVE FLOW',
                  style: TextStyle(
                    fontFamily:    'DM Mono',
                    fontSize:      10,
                    letterSpacing: 1.5,
                    fontWeight:    FontWeight.w700,
                    color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '2.4h',
                  style: TextStyle(
                    fontFamily:    'DM Mono',
                    fontSize:      38,
                    fontWeight:    FontWeight.w800,
                    color:         theme.primaryColor,
                    letterSpacing: -2,
                    height:        1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Collective deep work today',
                  style: TextStyle(
                    fontSize: 11,
                    color:    isDark ? FlowTheme.text2Dark : FlowTheme.text2Light,
                  ),
                ),
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
        ],
      ),
    );
  }

  // ── TEAM NODES CARD ───────────────────────────────────────────────────────

  Widget _buildTeamNodesCard(BuildContext context, ThemeData theme, bool isDark) {
    return _TeamCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your team', style: theme.textTheme.headlineSmall),
              Text(
                'Full view',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize:   11,
                  fontWeight: FontWeight.w600,
                  color:      theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildTeamNode(context, theme, isDark,
                  'Amaan',  'A', '● Deep Work', '92% focus', SessionState.focus)),
              const SizedBox(width: 10),
              Expanded(child: _buildTeamNode(context, theme, isDark,
                  'Nehal',  'N', '● Focus',     '78% focus', SessionState.focus)),
              const SizedBox(width: 10),
              Expanded(child: _buildTeamNode(context, theme, isDark,
                  'Laraib', 'L', '◎ Trough',    '43% focus', SessionState.trough)),
              const SizedBox(width: 10),
              Expanded(child: _buildTeamNode(context, theme, isDark,
                  'Shreya', 'S', '● Deep Work', '88% focus', SessionState.focus)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamNode(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String name,
    String initial,
    String status,
    String focusScore,
    SessionState state,
  ) {
    final accent = FlowTheme.stateColor(context, state);
    final soft   = FlowTheme.stateSoftColor(context, state);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color:        soft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        children: [
          // Avatar — solid fill circle, no gradient
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'DM Mono',
                color:      Colors.white,
                fontSize:   16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w700,
              color:      isDark ? FlowTheme.text1Dark : FlowTheme.text1Light,
            ),
          ),
          const SizedBox(height: 2),
          Text(status, style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          // Score tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:        isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: accent.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              focusScore,
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize:   9,
                fontWeight: FontWeight.w700,
                color:      accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TEAM FOCUS WINDOW ─────────────────────────────────────────────────────

  Widget _buildTeamFocusWindow(BuildContext context, ThemeData theme, bool isDark) {
    final bars = [0.20, 0.15, 0.80, 0.90, 0.55, 0.30, 0.65, 0.25];

    return _TeamCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Team focus window', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 14),
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(bars.length, (index) {
                final h       = bars[index];
                final isTrough = index == 4;
                final color   = isTrough
                    ? FlowTheme.stateColor(context, SessionState.trough)
                    : FlowTheme.stateColor(context, SessionState.focus);
                final opacity = h > 0.7 ? 0.9 : (h > 0.4 ? 0.55 : 0.3);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: FractionallySizedBox(
                      heightFactor: h,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: opacity),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3)),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Text('Best meeting slots: Tue/Thu 14–15h',
              style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }

  // ── COLLECTIVE DRIFT ──────────────────────────────────────────────────────

  Widget _buildCollectiveDrift(BuildContext context, ThemeData theme, bool isDark) {
    return _TeamCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Collective drift events', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),

          // Slack row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Slack notifications', style: theme.textTheme.bodyMedium),
              _buildTag(context, '47 today', state: SessionState.drift),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value:           0.72,
              minHeight:       7,
              backgroundColor: isDark
                  ? FlowTheme.borderSoftDark
                  : FlowTheme.borderSoftLight,
              color: FlowTheme.stateColor(context, SessionState.drift),
            ),
          ),
          const SizedBox(height: 18),

          // Ad-hoc row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ad-hoc meetings', style: theme.textTheme.bodyMedium),
              _buildTag(context, '3 today', state: SessionState.trough),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value:           0.34,
              minHeight:       7,
              backgroundColor: isDark
                  ? FlowTheme.borderSoftDark
                  : FlowTheme.borderSoftLight,
              color: FlowTheme.stateColor(context, SessionState.trough),
            ),
          ),
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
          fontSize:   9,
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

class _TeamCard extends StatelessWidget {
  final Widget      child;
  final bool        isDark;
  final EdgeInsets? padding;

  const _TeamCard({required this.child, required this.isDark, this.padding});

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