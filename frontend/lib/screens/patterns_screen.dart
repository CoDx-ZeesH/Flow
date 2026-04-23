// lib/screens/patterns_screen.dart
//
// NBBS v2 Lite rebuild:
//   ✅ Card → Container + soft border (borderSoftLight/Dark), 12px radius
//   ✅ Cycle hero: gradient → solid primary fill + hard 2px border
//   ✅ Period selector: pill → 8px square toggle, hard border on selected
//   ✅ Tags: pill radius → 6px, semantic colors (blue/amber/red)
//   ✅ Stat pills: rounded → 8px radius, hard border, NBBS fill
//   ✅ Insight items: soft border, left accent bar instead of tinted fill
//   ✅ Heatmap: dividerColor → borderSoftLight/Dark borders
//   ✅ Bar chart: DM Mono labels, NBBS semantic bar colors
//   ✅ All AppState-safe patterns preserved

import 'package:flutter/material.dart';
import 'dart:math';
import '../core/theme.dart';

class PatternsScreen extends StatefulWidget {
  const PatternsScreen({super.key});

  @override
  State<PatternsScreen> createState() => _PatternsScreenState();
}

class _PatternsScreenState extends State<PatternsScreen> {
  String _selectedPeriod = 'Week';
  final List<double> _heatmapData =
      List.generate(28, (index) => Random().nextDouble());

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

            SizedBox(
              height: 320,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: _buildPeakHoursChart(context, theme, isDark)),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(child: _buildCycleHero(context, theme, isDark)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildStatPill(context, theme, isDark, '4.2', 'Daily sessions', state: SessionState.focus)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatPill(context, theme, isDark, '14%', 'Avg drift', state: SessionState.drift)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            _buildInsightsCard(context, theme, isDark),
            const SizedBox(height: 14),
            _buildHeatmapCard(context, theme, isDark),
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
            Text(
              'YOUR COGNITIVE PROFILE',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 2),
            Text('Patterns & Insights', style: theme.textTheme.headlineLarge),
          ],
        ),
        // Period toggle — NBBS: square 8px, hard border on selected
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color:        isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ['Week', 'Month', 'All'].map((period) {
              final isSelected = _selectedPeriod == period;
              return GestureDetector(
                onTap: () => setState(() => _selectedPeriod = period),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 130),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: isSelected
                        ? Border.all(
                            color: isDark
                                ? FlowTheme.borderDark
                                : FlowTheme.borderLight,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontFamily:  'DM Mono',
                      fontSize:    12,
                      fontWeight:  FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? FlowTheme.text2Dark : FlowTheme.text2Light),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── PEAK HOURS CHART ──────────────────────────────────────────────────────

  Widget _buildPeakHoursChart(BuildContext context, ThemeData theme, bool isDark) {
    final bars  = [0.30, 0.15, 0.10, 0.85, 0.92, 0.78, 0.50, 0.35, 0.70, 0.65, 0.40, 0.20];
    final hours = ['7',  '8',  '9',  '10', '11', '12', '13', '14', '15', '16', '17', '18'];

    return _PatternCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Focus by hour', style: theme.textTheme.headlineSmall),
              _buildTag(context, theme, isDark, 'Peak: 9–11 AM', state: SessionState.focus),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(bars.length, (index) {
                final h       = bars[index];
                final isTrough = index == 6;
                final color   = isTrough ? FlowTheme.stateColor(context, SessionState.trough)
                                         : FlowTheme.stateColor(context, SessionState.focus);
                final opacity = h > 0.7 ? 0.9 : (h > 0.4 ? 0.55 : 0.3);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: h,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: opacity),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(3)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hours[index],
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize:   9,
                            color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── CYCLE HERO — gradient → solid primary fill + hard 2px border ──────────

  Widget _buildCycleHero(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
          width: 2,
        ),
      ),
      child: const Column(
        crossAxisAlignment:  CrossAxisAlignment.start,
        mainAxisAlignment:   MainAxisAlignment.center,
        children: [
          Text(
            'PERSONAL CYCLE',
            style: TextStyle(
              fontFamily:    'DM Mono',
              fontSize:      10,
              color:         Colors.white70,
              letterSpacing: 1.5,
              fontWeight:    FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text.rich(TextSpan(children: [
            TextSpan(
              text:  '92 ',
              style: TextStyle(
                fontFamily:    'DM Mono',
                fontSize:      44,
                fontWeight:    FontWeight.w800,
                color:         Colors.white,
                letterSpacing: -2,
                height:        1.0,
              ),
            ),
            TextSpan(
              text:  'min',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize:   18,
                fontWeight: FontWeight.w800,
                color:      Colors.white,
              ),
            ),
          ])),
          SizedBox(height: 4),
          Text(
            'Your avg ultradian period',
            style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ── STAT PILL ─────────────────────────────────────────────────────────────

  Widget _buildStatPill(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String value,
    String label, {
    required SessionState state,
  }) {
    final accent = FlowTheme.stateColor(context, state);
    final soft   = FlowTheme.stateSoftColor(context, state);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color:        soft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily:    'DM Mono',
              fontSize:      22,
              fontWeight:    FontWeight.w800,
              color:         accent,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── INSIGHTS CARD ─────────────────────────────────────────────────────────

  Widget _buildInsightsCard(BuildContext context, ThemeData theme, bool isDark) {
    return _PatternCard(
      isDark: isDark,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('AI insights this week', style: theme.textTheme.headlineSmall),
              _buildTag(context, theme, isDark, '↑ 3 new', state: SessionState.focus),
            ],
          ),
          const SizedBox(height: 14),
          _buildInsightItem(context, theme, isDark, '🌅',
              'Morning dominance confirmed',
              '87% avg focus 9–11 AM · 7 consecutive days',
              'Pattern', SessionState.focus),
          const SizedBox(height: 8),
          _buildInsightItem(context, theme, isDark, '😴',
              'Post-lunch dip at 13:30',
              'Consistent trough, avg 41% focus · schedule breaks here',
              'Warning', SessionState.trough),
          const SizedBox(height: 8),
          _buildInsightItem(context, theme, isDark, '📱',
              'Slack causes 68% of drifts',
              'Avg 8.3 context switches per session via Slack',
              'Action needed', SessionState.drift),
          const SizedBox(height: 8),
          _buildInsightItem(context, theme, isDark, '💪',
              'Deep work up 23% this week',
              '2h 14m avg daily vs 1h 49m last week',
              'Progress', SessionState.focus),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String emoji,
    String title,
    String sub,
    String tag,
    SessionState state,
  ) {
    final accent = FlowTheme.stateColor(context, state);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        isDark ? FlowTheme.elevatedDark : FlowTheme.elevatedLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color:        accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color:        isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w700,
                    color:      isDark ? FlowTheme.text1Dark : FlowTheme.text1Light,
                  ),
                ),
                const SizedBox(height: 2),
                Text(sub, style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildTag(context, theme, isDark, tag, state: state),
        ],
      ),
    );
  }

  // ── HEATMAP CARD ──────────────────────────────────────────────────────────

  Widget _buildHeatmapCard(BuildContext context, ThemeData theme, bool isDark) {
    return _PatternCard(
      isDark: isDark,
      padding: const EdgeInsets.all(28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: heatmap grid
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Focus heatmap — last 28 days',
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: GridView.builder(
                    shrinkWrap:    true,
                    physics:       const NeverScrollableScrollPhysics(),
                    gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:   7,
                      crossAxisSpacing: 7,
                      mainAxisSpacing:  7,
                      childAspectRatio: 1,
                    ),
                    itemCount: 28,
                    itemBuilder: (context, index) {
                      final val = _heatmapData[index];
                      double opacity = 0.08;
                      if      (val > 0.8) opacity = 1.0;
                      else if (val > 0.6) opacity = 0.75;
                      else if (val > 0.4) opacity = 0.5;
                      else if (val > 0.2) opacity = 0.28;

                      return Tooltip(
                        message: 'Day ${index + 1}: ${(val * 100).toInt()}% Focus',
                        child: Container(
                          decoration: BoxDecoration(
                            color:        theme.primaryColor.withValues(alpha: opacity),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isDark
                                  ? FlowTheme.borderSoftDark
                                  : FlowTheme.borderSoftLight,
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Legend
                Row(
                  children: [
                    Text('LESS', style: theme.textTheme.labelSmall),
                    const SizedBox(width: 8),
                    ...[0.08, 0.28, 0.5, 0.75, 1.0].map((op) => Container(
                      width:  11,
                      height: 11,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        color:        theme.primaryColor.withValues(alpha: op),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: isDark
                              ? FlowTheme.borderSoftDark
                              : FlowTheme.borderSoftLight,
                          width: 1,
                        ),
                      ),
                    )),
                    const SizedBox(width: 8),
                    Text('MORE', style: theme.textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 40),

          // Right: consistency metrics
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONSISTENCY METRICS',
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 20),
                _buildHeatmapStatRow(theme, isDark, 'Best Day',       'Wednesday', 'Avg 88% focus'),
                _buildDivider(isDark),
                _buildHeatmapStatRow(theme, isDark, 'Deep Work',      '42 hrs',    'Top 5% of users'),
                _buildDivider(isDark),
                _buildHeatmapStatRow(theme, isDark, 'Longest Streak', '12 Days',   'Mar 12 – Mar 24'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(
        height: 1,
        color:  isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
      ),
    );
  }

  Widget _buildHeatmapStatRow(
      ThemeData theme, bool isDark, String label, String value, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily:    'DM Mono',
                fontSize:      16,
                fontWeight:    FontWeight.w800,
                color:         theme.primaryColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(sub, style: theme.textTheme.labelSmall),
          ],
        ),
      ],
    );
  }

  // ── SHARED TAG ────────────────────────────────────────────────────────────

  Widget _buildTag(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String text, {
    required SessionState state,
  }) {
    final accent = FlowTheme.stateColor(context, state);
    final soft   = FlowTheme.stateSoftColor(context, state);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        soft,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.3), width: 1),
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

/// Base informational card — soft border, 12px radius, surface color.
class _PatternCard extends StatelessWidget {
  final Widget   child;
  final bool     isDark;
  final EdgeInsets? padding;

  const _PatternCard({
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