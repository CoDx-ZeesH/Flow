import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/count_up_text.dart';
import '../widgets/focus_ring.dart';
import '../widgets/meeting_countdown_pill.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/focus_sparkline.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onStartSession;
  const DashboardScreen({super.key, this.onStartSession});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _ringEntry;

  @override
  void initState() {
    super.initState();
    _ringEntry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    // API teammate: replace this delay with GET /user/dashboard
    // After success: appState.setDashboard(...); setState(() => _isLoading = false);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _ringEntry.forward();
      }
    });
  }

  @override
  void dispose() {
    _ringEntry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildSkeleton();

    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP BAR ──────────────────────────────────────────────────────
            _buildTopBar(context, appState, isDark),
            const SizedBox(height: 20),

            // ── BENTO ROW 1: Focus Score (large) + Quick Stats (right col) ──
            _buildBentoRow1(context, appState, theme),
            const SizedBox(height: 12),

            // ── BENTO ROW 2: Schedule + App Focus ────────────────────────────
            _buildBentoRow2(context, appState, theme),
            const SizedBox(height: 12),

            // ── BENTO ROW 3: Biometrics (3 equal cards) ──────────────────────
            _buildBentoRow3(context, appState, theme),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SKELETON
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildSkeleton() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 200, height: 40),
              SkeletonBox(width: 140, height: 32, borderRadius: 12.0),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(flex: 3, child: SkeletonStatCard()),
              SizedBox(width: 12),
              Expanded(flex: 2, child: SkeletonStatCard()),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SkeletonStatCard()),
              SizedBox(width: 12),
              Expanded(child: SkeletonStatCard()),
            ],
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TOP BAR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildTopBar(BuildContext context, AppState appState, bool isDark) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr =
        '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} · '
        '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              appState.greetingMessage.isNotEmpty
                  ? '${appState.greetingMessage} 👋'
                  : 'Good morning, ${appState.userFirstName ?? "there"} 👋',
              style: theme.textTheme.headlineLarge,
            ),
          ],
        ),
        MeetingCountdownPill(
          nextMeetingTime: DateTime.now().add(const Duration(minutes: 72)),
          meetingTitle: 'Team standup',
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BENTO ROW 1 — Focus Score hero (flex 3) + right column (flex 2)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildBentoRow1(BuildContext context, AppState appState, ThemeData theme) {
    final isDark  = theme.brightness == Brightness.dark;
    final score   = appState.focusScoreToday;
    final delta   = appState.focusScoreDelta;
    final cycleMin   = appState.ultradianCycleMinutes;
    final rhythmPos  = appState.rhythmPositionMinutes;
    final trough     = appState.minutesUntilTrough;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── FOCUS SCORE CARD (large bento tile) ──────────────────────────
          Expanded(
            flex: 3,
            child: _BentoCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('FOCUS SCORE', style: theme.textTheme.labelMedium),
                      _StatusBadge(
                        label: score >= 70 ? 'ON TRACK' : score >= 50 ? 'DRIFTING' : 'LOW',
                        color: score >= 70
                            ? theme.primaryColor
                            : score >= 50
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.error,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Score + sparkline + ring in a row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Big number
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CountUpText(
                                target: score,
                                style: theme.textTheme.displayLarge?.copyWith(
                                  color: theme.primaryColor,
                                  fontSize: 72,
                                  letterSpacing: -3,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14, left: 2),
                                child: Text('%',
                                  style: TextStyle(
                                    fontSize: 26, color: theme.primaryColor,
                                    fontWeight: FontWeight.w700,
                                  )),
                              ),
                            ],
                          ),
                          if (delta != 0) ...[
                            const SizedBox(height: 6),
                            _DeltaBadge(delta: delta, theme: theme),
                          ],
                        ],
                      ),

                      const SizedBox(width: 32),

                      // Sparkline
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("TODAY'S TREND", style: theme.textTheme.labelSmall),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 48,
                              child: FocusSparkline(
                                scores: const [40, 55, 60, 58, 70, 75, 75],
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 32),

                      // Focus ring
                      FocusRing(
                        score: score.toDouble(),
                        color: theme.primaryColor,
                        trackColor: isDark
                            ? FlowTheme.borderSoftDark
                            : FlowTheme.borderSoftLight,
                        size: 96,
                        strokeWidth: 9,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── ULTRADIAN BAR ─────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ULTRADIAN RHYTHM', style: theme.textTheme.labelSmall),
                      Text('${rhythmPos}min / ${cycleMin}min cycle',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.primaryColor,
                        )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: cycleMin > 0
                          ? (rhythmPos / cycleMin).clamp(0.0, 1.0)
                          : 0.5,
                      minHeight: 8,
                      backgroundColor: isDark
                          ? FlowTheme.borderSoftDark
                          : FlowTheme.borderSoftLight,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── STAT PILLS ────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatPill(
                          target: rhythmPos,
                          label: 'CURRENT CYCLE',
                          unit: 'min',
                          color: theme.primaryColor,
                          bgColor: theme.colorScheme.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatPill(
                          target: trough,
                          label: 'NEXT BREAK',
                          unit: 'min',
                          prefix: '~',
                          color: theme.colorScheme.secondary,
                          bgColor: theme.colorScheme.secondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── RIGHT COLUMN ──────────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Column(
              children: [

                // Sessions today
                _BrutalistHeroTile(
                  label: 'SESSIONS TODAY',
                  value: '${appState.sessionsToday}',
                  sub: '${appState.totalDurationMinutes}min total focus',
                  accentColor: theme.primaryColor,
                  bgColor: theme.colorScheme.primaryContainer,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),

                // Streak
                _BrutalistHeroTile(
                  label: 'STREAK',
                  value: '7',
                  sub: 'days in a row 🔥',
                  accentColor: theme.colorScheme.secondary,
                  bgColor: theme.colorScheme.secondaryContainer,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),

                // Quick Start — brutalist CTA card
                _BentoCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('QUICK START', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: widget.onStartSession,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('New session'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BENTO ROW 2 — Today's Schedule + App Focus Map
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildBentoRow2(BuildContext context, AppState appState, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── SCHEDULE CARD ─────────────────────────────────────────────────
          Expanded(
            child: _BentoCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("TODAY'S SCHEDULE", style: theme.textTheme.labelMedium),
                      _StatusBadge(label: 'LIVE', color: theme.primaryColor, isDark: isDark),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _TimelineItem(
                    emoji: '📌',
                    title: 'Deep work session',
                    time: '${now.hour}:00 — ongoing · FLOW',
                    isActive: true,
                    theme: theme,
                  ),
                  _TimelineItem(
                    emoji: '📅',
                    title: 'Team standup',
                    time: '${(now.hour + 2) % 24}:00 · Google Meet',
                    isNext: true,
                    theme: theme,
                  ),
                  _TimelineItem(
                    emoji: '🧠',
                    title: 'Afternoon deep work',
                    time: 'Recommended window',
                    isLast: true,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── APP FOCUS MAP ─────────────────────────────────────────────────
          Expanded(
            child: _BentoCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('APP FOCUS MAP', style: theme.textTheme.labelMedium),
                      _StatusBadge(label: 'LIVE', color: theme.primaryColor, isDark: isDark),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // API teammate: replace with real window tracking data
                  _AppFocusRow(
                    emoji: '💻', name: 'VS Code', time: '47m', progress: 0.82,
                    color: theme.primaryColor, theme: theme,
                  ),
                  _AppFocusRow(
                    emoji: '🌐', name: 'Chrome', time: '12m', progress: 0.21,
                    color: theme.colorScheme.secondary, theme: theme,
                  ),
                  _AppFocusRow(
                    emoji: '💬', name: 'Slack', time: '8m', progress: 0.14,
                    color: theme.colorScheme.error, theme: theme,
                  ),
                  _AppFocusRow(
                    emoji: '📋', name: 'Notion', time: '5m', progress: 0.09,
                    color: theme.primaryColor, theme: theme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BENTO ROW 3 — Biometrics (3 equal tiles)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildBentoRow3(BuildContext context, AppState appState, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _BiometricCard(
            title: 'HEART RATE',
            target: appState.currentBpm,
            unit: 'BPM',
            sub: '↓ calm',
            isDrift: appState.isDrifting,
            heights: const [0.4, 0.6, 0.5, 0.45, 0.48, 0.42, 0.44],
            theme: theme,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BiometricCard(
            title: 'HRV',
            target: 54,
            unit: 'ms',
            sub: '↑ high',
            heights: const [0.55, 0.7, 0.8, 0.75, 0.85, 0.82, 0.88],
            theme: theme,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _EarCard(appState: appState, theme: theme, isDark: isDark),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRIVATE COMPONENT WIDGETS
// Extracted for cleanliness — all stateless, all theme-aware
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Base bento card — white/dark surface, soft border, 12px radius (NBBS spec)
class _BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _BentoCard({required this.child, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
          width: 1.5,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Small status badge — DM Mono, tinted background
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Delta badge — shows score change vs yesterday
class _DeltaBadge extends StatelessWidget {
  final int delta;
  final ThemeData theme;

  const _DeltaBadge({required this.delta, required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = delta > 0 ? theme.primaryColor : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Text(
        '${delta > 0 ? '↑ +$delta' : '↓ $delta'} vs yesterday',
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Brutalist hero tile — hard accent border on left edge, bold number
class _BrutalistHeroTile extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color accentColor;
  final Color bgColor;
  final bool isDark;

  const _BrutalistHeroTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.accentColor,
    required this.bgColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Left accent bar — the brutalist signature
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                      letterSpacing: 1.0,
                    )),
                  const SizedBox(height: 4),
                  Text(value,
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                      letterSpacing: -1,
                      height: 1,
                    )),
                  const SizedBox(height: 2),
                  Text(sub, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat pill — colored number + label in a soft tinted box
class _StatPill extends StatelessWidget {
  final int target;
  final String label;
  final String unit;
  final String prefix;
  final Color color;
  final Color bgColor;

  const _StatPill({
    required this.target,
    required this.label,
    required this.unit,
    required this.color,
    required this.bgColor,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CountUpText(
                target: target,
                prefix: prefix,
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 2),
                child: Text(unit,
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.bold,
                  )),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// Timeline item for the schedule card
class _TimelineItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String time;
  final bool isActive;
  final bool isNext;
  final bool isLast;
  final ThemeData theme;

  const _TimelineItem({
    required this.emoji,
    required this.title,
    required this.time,
    required this.theme,
    this.isActive = false,
    this.isNext = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final dotColor = isActive
        ? theme.primaryColor
        : isNext
            ? theme.colorScheme.secondary
            : (isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight);
    final lineColor = isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: 0.12),
                    border: Border.all(color: dotColor, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 13)),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(width: 1.5, color: lineColor),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? theme.primaryColor
                          : theme.textTheme.bodyMedium?.color,
                    )),
                  const SizedBox(height: 2),
                  Text(time, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// App focus row — progress bar with app name + time
class _AppFocusRow extends StatelessWidget {
  final String emoji;
  final String name;
  final String time;
  final double progress;
  final Color color;
  final ThemeData theme;

  const _AppFocusRow({
    required this.emoji,
    required this.name,
    required this.time,
    required this.progress,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                    Text(time,
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 10,
                        color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
                      )),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: isDark
                        ? FlowTheme.borderSoftDark
                        : FlowTheme.borderSoftLight,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Biometric card — bar chart + countup number
class _BiometricCard extends StatelessWidget {
  final String title;
  final int target;
  final String unit;
  final String sub;
  final bool isDrift;
  final List<double> heights;
  final ThemeData theme;
  final bool isDark;

  const _BiometricCard({
    required this.title,
    required this.target,
    required this.unit,
    required this.sub,
    required this.heights,
    required this.theme,
    required this.isDark,
    this.isDrift = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDrift ? theme.colorScheme.error : theme.primaryColor;
    return _BentoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelMedium),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CountUpText(
                target: target,
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unit, style: theme.textTheme.bodySmall),
                    Text(sub,
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Mini bar chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: heights.map((h) => Expanded(
              child: Container(
                height: 44 * h,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: h > 0.6 ? 1.0 : (h > 0.45 ? 0.6 : 0.25),
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

/// EAR (Eye Aspect Ratio) fatigue card
class _EarCard extends StatelessWidget {
  final AppState appState;
  final ThemeData theme;
  final bool isDark;

  const _EarCard({
    required this.appState,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = theme.primaryColor;
    return _BentoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EYE FATIGUE', style: theme.textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(
            appState.currentEar.toStringAsFixed(2),
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -1.5,
            ),
          ),
          Text('EAR · Normal', style: theme.textTheme.labelSmall),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: appState.currentEar.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: isDark
                  ? FlowTheme.borderSoftDark
                  : FlowTheme.borderSoftLight,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'threshold 0.25',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 9,
              color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
            ),
          ),
        ],
      ),
    );
  }
}