import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/focus_sparkline.dart';
import '../widgets/meeting_countdown_pill.dart';
import 'interrupt_screen.dart';

class ActiveSessionScreen extends StatefulWidget {
  final VoidCallback? onEndSession;
  const ActiveSessionScreen({super.key, this.onEndSession});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen>
    with SingleTickerProviderStateMixin {
  int _secondsElapsed = 0;
  bool _isPaused = false;
  late Timer _timer;
  late AnimationController _blinkController;
  final List<double> _focusHistory = [72, 65, 78, 80, 76, 82, 85, 88];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) setState(() => _secondsElapsed++);
    });
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _blinkController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _blinkController.stop();
    _blinkController.dispose();
    super.dispose();
  }

  void _togglePause() => setState(() => _isPaused = !_isPaused);

  void _triggerBreak(InterruptType type) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => InterruptScreen(type: type),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final minSec =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$minSec' : minSec;
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final isDark  = theme.brightness == Brightness.dark;
    final appState = context.watch<AppState>();
    final isDrifting = appState.isDrifting;

    // Page background shifts on drift — NBBS state overlay
    final bgColor = isDrifting
        ? (isDark ? FlowTheme.driftSoftDark : FlowTheme.driftSoftLight)
        : Colors.transparent;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RepaintBoundary(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: bgColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              children: [
                _buildTopBar(context, appState, isDark, isDrifting, theme),
                const SizedBox(height: 20),
                _buildSessionHero(context, appState, isDark, isDrifting, theme),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── LEFT COLUMN: telemetry + drift meter ───────────────
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildTelemetryCard(context, appState, isDark, isDrifting, theme),
                          const SizedBox(height: 10),
                          _buildDriftMeterCard(context, appState, isDark, isDrifting, theme),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ── RIGHT COLUMN: ultradian + flow state + goal ────────
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildUltradianCard(context, isDark, theme),
                          const SizedBox(height: 10),
                          _buildFlowStateCard(context, appState, isDark, isDrifting, theme),
                          const SizedBox(height: 10),
                          _buildSessionGoalCard(context, appState, isDark, theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // Demo FAB — toggle drift for presentation
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<AppState>().toggleDrift(),
        backgroundColor: isDrifting
            ? theme.colorScheme.error
            : theme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
            width: 2,
          ),
        ),
        icon: Icon(
          isDrifting ? Icons.warning_amber_rounded : Icons.waves_rounded,
          color: Colors.white,
        ),
        label: Text(
          isDrifting ? 'STABILIZE' : 'SIMULATE DRIFT',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'DM Mono',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TOP BAR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildTopBar(BuildContext context, AppState appState, bool isDark,
      bool isDrifting, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SESSION IN PROGRESS',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
              ),
            ),
            const SizedBox(height: 3),
            Text('Stay in the zone.', style: theme.textTheme.headlineLarge),
          ],
        ),
        Row(
          children: [
            MeetingCountdownPill(
              nextMeetingTime:
                  DateTime.now().add(const Duration(minutes: 32)),
              meetingTitle: 'Team standup',
            ),
            const SizedBox(width: 12),
            // LIVE indicator — brutalist pill
            _LivePill(
              blinkController: _blinkController,
              color: theme.primaryColor,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SESSION HERO
  // The most prominent element — fills the width, NBBS brutalist treatment:
  // solid fill, hard border, no gradient, task + timer + action buttons
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildSessionHero(BuildContext context, AppState appState, bool isDark,
      bool isDrifting, ThemeData theme) {
    final heroColor =
        isDrifting ? theme.colorScheme.error : theme.primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 32),
      decoration: BoxDecoration(
        color: heroColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Timer
          Text(
            'TIME ELAPSED',
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 11,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(_secondsElapsed),
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 64,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -3,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),

          // Task label
          Text(
            appState.currentTask.isNotEmpty
                ? '🐛 ${appState.currentTask}'
                : '🧠 Focus session',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),

          // Privacy pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, color: Colors.white70, size: 13),
                SizedBox(width: 6),
                Text(
                  'Camera telemetry is monitored locally. No video is recorded.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons — NBBS hard border treatment on white
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroActionBtn(
                label: _isPaused ? 'Resume' : 'Pause',
                icon: _isPaused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                onTap: _togglePause,
              ),
              const SizedBox(width: 8),
              _HeroActionBtn(
                label: '5m break',
                icon: Icons.coffee_rounded,
                onTap: () => _triggerBreak(InterruptType.userRequested),
              ),
              const SizedBox(width: 8),
              _HeroActionBtn(
                label: 'Feeling stuck?',
                icon: Icons.psychology_alt_rounded,
                onTap: () => _triggerBreak(InterruptType.drift),
                isWarning: true,
              ),
              const SizedBox(width: 8),
              _HeroActionBtn(
                label: 'End session',
                icon: Icons.check_rounded,
                onTap: widget.onEndSession ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LIVE TELEMETRY CARD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildTelemetryCard(BuildContext context, AppState appState,
      bool isDark, bool isDrifting, ThemeData theme) {
    return _SessionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LIVE TELEMETRY', style: theme.textTheme.labelMedium),
              Text(
                '${appState.focusScore} now',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RepaintBoundary(
            child: FocusSparkline(
              scores: _focusHistory,
              color: theme.primaryColor,
              height: 56,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: isDark
                ? FlowTheme.borderSoftDark
                : FlowTheme.borderSoftLight,
          ),
          const SizedBox(height: 14),
          // BPM / EAR / DRIFT stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TelemetryStat(
                label: 'BPM',
                value: '${appState.currentBpm}',
                color: theme.textTheme.bodyLarge?.color ??
                    (isDark ? FlowTheme.text1Dark : FlowTheme.text1Light),
              ),
              _TelemetryStat(
                label: 'EAR',
                value: appState.currentEar.toStringAsFixed(2),
                color: theme.colorScheme.secondary,
              ),
              _TelemetryStat(
                label: 'DRIFT',
                value: isDrifting ? 'HIGH' : 'LOW',
                color: isDrifting
                    ? theme.colorScheme.error
                    : theme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DRIFT METER CARD
  // Border turns hard red on drift — the most visible NBBS brutalist moment
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildDriftMeterCard(BuildContext context, AppState appState,
      bool isDark, bool isDrifting, ThemeData theme) {
    final stateColor =
        isDrifting ? theme.colorScheme.error : theme.primaryColor;
    final borderColor = isDrifting
        ? theme.colorScheme.error
        : (isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isDrifting ? 2 : 1.5,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DRIFT METER', style: theme.textTheme.labelMedium),
              // Status badge — hard border when critical
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: stateColor.withValues(alpha: 0.4),
                    width: isDrifting ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  isDrifting ? 'CRITICAL' : 'LOW',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: stateColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Drift bar — thick, no rounded caps, hard brutalist feel
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  color: isDark
                      ? FlowTheme.borderSoftDark
                      : FlowTheme.borderSoftLight,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 10,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: isDrifting ? 0.85 : 0.14,
                    child: Container(color: stateColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ALIGNED',
                  style: theme.textTheme.labelSmall),
              Text(
                isDrifting ? '85%' : '14%',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: stateColor,
                ),
              ),
              Text('DRIFT',
                  style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ULTRADIAN CARD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildUltradianCard(
      BuildContext context, bool isDark, ThemeData theme) {
    return _SessionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ULTRADIAN POSITION', style: theme.textTheme.labelMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              _RhythmSegment(isTrough: true, theme: theme, isDark: isDark),
              const SizedBox(width: 5),
              _RhythmSegment(isPeak: true, theme: theme, isDark: isDark),
              const SizedBox(width: 5),
              _RhythmSegment(isPeak: true, theme: theme, isDark: isDark),
              const SizedBox(width: 5),
              _RhythmSegment(
                isCurrent: true,
                theme: theme,
                isDark: isDark,
                blinkController: _blinkController,
              ),
              const SizedBox(width: 5),
              _RhythmSegment(isUpcoming: true, theme: theme, isDark: isDark),
              const SizedBox(width: 5),
              _RhythmSegment(isUpcoming: true, theme: theme, isDark: isDark),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              children: [
                const TextSpan(text: 'Peak phase — '),
                TextSpan(
                  text: '~13 min',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                    fontFamily: 'DM Mono',
                  ),
                ),
                const TextSpan(text: ' until recommended break'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FLOW STATE CARD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildFlowStateCard(BuildContext context, AppState appState,
      bool isDark, bool isDrifting, ThemeData theme) {
    final stateColor =
        isDrifting ? theme.colorScheme.error : theme.primaryColor;
    final stateLabel = isDrifting ? 'Drifting' : 'Deep Focus';
    final stateSubtitle = isDrifting
        ? 'Cognitive misalignment detected'
        : 'Cognitive load nominal';

    return _SessionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FLOW STATE', style: theme.textTheme.labelMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              // Icon box — square for brutalist language
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: stateColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isDrifting
                      ? Icons.warning_amber_rounded
                      : Icons.waves_rounded,
                  color: stateColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stateLabel,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(color: stateColor)),
                    const SizedBox(height: 2),
                    Text(stateSubtitle,
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              // Score badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: stateColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${appState.focusScore} / 100',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: stateColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: appState.focusScore / 100,
              minHeight: 6,
              backgroundColor: isDark
                  ? FlowTheme.borderSoftDark
                  : FlowTheme.borderSoftLight,
              color: stateColor,
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SESSION GOAL CARD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildSessionGoalCard(
      BuildContext context, AppState appState, bool isDark, ThemeData theme) {
    final task = appState.currentTask.isNotEmpty
        ? appState.currentTask
        : 'Fix JWT token refresh & write unit tests';

    return _SessionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SESSION GOAL', style: theme.textTheme.labelMedium),
              Icon(Icons.flag_rounded,
                  color: theme.primaryColor, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: theme.primaryColor, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(task, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: 0.4,
                    minHeight: 5,
                    backgroundColor: isDark
                        ? FlowTheme.borderSoftDark
                        : FlowTheme.borderSoftLight,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('40%', style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRIVATE COMPONENT WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Base card for all session sub-panels — soft border, no elevation
class _SessionCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _SessionCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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

/// Blinking LIVE indicator pill
class _LivePill extends StatelessWidget {
  final AnimationController blinkController;
  final Color color;
  final bool isDark;

  const _LivePill({
    required this.blinkController,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: blinkController,
            child: Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero action button — white translucent, hard border, inside the colored hero
class _HeroActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isWarning;

  const _HeroActionBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isWarning
              ? Colors.white.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isWarning ? FlowTheme.driftLight : Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isWarning ? FlowTheme.driftLight : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single segment in the ultradian rhythm visualizer
class _RhythmSegment extends StatelessWidget {
  final bool isTrough;
  final bool isPeak;
  final bool isCurrent;
  final bool isUpcoming;
  final ThemeData theme;
  final bool isDark;
  final AnimationController? blinkController;

  const _RhythmSegment({
    required this.theme,
    required this.isDark,
    this.isTrough = false,
    this.isPeak = false,
    this.isCurrent = false,
    this.isUpcoming = false,
    this.blinkController,
  });

  @override
  Widget build(BuildContext context) {
    final Color base = isTrough
        ? theme.colorScheme.secondary
        : isPeak
            ? theme.primaryColor
            : (isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight);

    Widget box = Container(
      width: 28,
      height: 32,
      decoration: BoxDecoration(
        color: isCurrent
            ? base
            : base.withValues(alpha: isUpcoming ? 0.2 : 0.55),
        borderRadius: BorderRadius.circular(5),
        border: isCurrent
            ? Border.all(color: theme.primaryColor, width: 2)
            : null,
      ),
    );

    if (isCurrent && blinkController != null) {
      return FadeTransition(
        opacity: Tween<double>(begin: 0.35, end: 1.0).animate(
          CurvedAnimation(
            parent: blinkController!,
            curve: Curves.easeInOutSine,
          ),
        ),
        child: box,
      );
    }
    return box;
  }
}

/// Compact telemetry stat — label + value
class _TelemetryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TelemetryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}