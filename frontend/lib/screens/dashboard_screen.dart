import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/count_up_text.dart';
import '../widgets/focus_ring.dart';
import '../widgets/meeting_countdown_pill.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/focus_sparkline.dart'; // Add this line!

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
    _ringEntry = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));

    // API teammate: replace this delay with your GET /user/dashboard call
    // After the call succeeds: appState.setDashboard(...); setState(() => _isLoading = false);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context, appState, isDark),
            const SizedBox(height: 24),
            _buildRow1(context, appState),
            const SizedBox(height: 14),
            _buildRow2(context),
            const SizedBox(height: 14),
            _buildRow3(context, appState),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    // ✅ Put const at the very top, and Flutter applies it to everything inside automatically!
    return const Padding(
      padding: EdgeInsets.all(28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 200, height: 40),
              SkeletonBox(width: 140, height: 32, borderRadius: 100.0),
            ],
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(flex: 3, child: SkeletonStatCard()),
              SizedBox(width: 14),
              Expanded(flex: 2, child: SkeletonStatCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppState appState, bool isDark) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} · ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateStr,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light)),
            const SizedBox(height: 2),
            Text(appState.greetingMessage.isNotEmpty
                ? '${appState.greetingMessage} 👋'
                : 'Good morning, ${appState.userFirstName ?? "there"} 👋',
              style: theme.textTheme.headlineLarge),
          ],
        ),
        MeetingCountdownPill(
          nextMeetingTime: DateTime.now().add(const Duration(minutes: 72)),
          meetingTitle: 'Team standup',
        ),
      ],
    );
  }

  Widget _buildRow1(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    final score = appState.focusScoreToday;
    final delta = appState.focusScoreDelta;
    final cycleMin = appState.ultradianCycleMinutes;
    final rhythmPos = appState.rhythmPositionMinutes;
    final trough = appState.minutesUntilTrough;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── UPGRADED FOCUS SCORE CARD ───
          Expanded(
            flex: 3,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: theme.dividerColor)),
              child: Padding(
                padding: const EdgeInsets.all(28), // ⬆️ Increased padding for a premium feel
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. SCORE ON LEFT
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FOCUS SCORE', style: theme.textTheme.labelMedium),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CountUpText(
                                  target: score,
                                  style: theme.textTheme.displayLarge?.copyWith(color: theme.primaryColor, fontSize: 64),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12, left: 4),
                                  child: Text('%', style: TextStyle(fontSize: 24, color: theme.primaryColor, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            if (delta != 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (delta > 0 ? theme.primaryColor : theme.colorScheme.error).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(100)
                                ),
                                child: Text(
                                  '${delta > 0 ? '↑ +$delta' : '↓ $delta'} vs yesterday',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: delta > 0 ? theme.primaryColor : theme.colorScheme.error),
                                ),
                              )
                            ],
                          ],
                        ),
                        
                        const SizedBox(width: 48), // Padding gap
                        
                        // 2. ✅ FILL THE VOID: MINI TREND GRAPH
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("TODAY'S TREND", style: theme.textTheme.labelSmall),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 45,
                                child: FocusSparkline(
                                  scores: const [40, 55, 60, 58, 70, 75, 75], // You can bind this to real data later!
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 48), // Padding gap

                        // 3. RING ON RIGHT
                        FocusRing(score: score.toDouble(), color: theme.primaryColor, trackColor: theme.dividerColor, size: 100, strokeWidth: 10),
                      ],
                    ),
                    const SizedBox(height: 32), // Breathing room
                    
                    // ─── ULTRADIAN BAR ───
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ULTRADIAN RHYTHM', style: theme.textTheme.labelSmall),
                            Text('${rhythmPos}min / ${cycleMin}min cycle',
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: cycleMin > 0 ? (rhythmPos / cycleMin).clamp(0.0, 1.0) : 0.5,
                            minHeight: 10,
                            backgroundColor: theme.dividerColor,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // ─── STAT PILLS ───
                    Row(
                      children: [
                        Expanded(child: _buildStatPill(context, rhythmPos, 'CURRENT CYCLE', 'min', isPrimary: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatPill(context, trough, 'NEXT BREAK', 'min', isFatigue: true, prefix: '~')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // ─── RIGHT COLUMN (SESSIONS, STREAK, QUICK START) ───
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildHeroCard(context, 'SESSIONS TODAY', '${appState.sessionsToday}',
                    '${appState.totalDurationMinutes}min total focus', isGreen: true),
                const SizedBox(height: 12),
                _buildHeroCard(context, 'STREAK', '7 🔥', 'days in a row', isOrange: true),
                const SizedBox(height: 12),
                // Quick start
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: theme.dividerColor)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('QUICK START', style: theme.textTheme.labelMedium),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: widget.onStartSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('＋ New session', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow2(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildCalendarCard(context)),
          const SizedBox(width: 14),
          Expanded(child: _buildAppFocusCard(context)),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's schedule", style: theme.textTheme.headlineSmall),
            const SizedBox(height: 14),
            // API teammate: replace with real calendar data from GET /calendar/context
            _buildTimelineItem(context, '📌', 'Deep work session', '${now.hour}:00 — ongoing · FLOW session', true, false),
            _buildTimelineItem(context, '📅', 'Team standup', '${(now.hour + 2) % 24}:00 · Google Meet', false, true),
            _buildTimelineItem(context, '💤', 'Afternoon deep work',
                'Recommended window', false, false, isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAppFocusCard(BuildContext context) {
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
                Text('App focus map', style: theme.textTheme.headlineSmall),
                _buildTag(context, 'Live', true),
              ],
            ),
            const SizedBox(height: 14),
            // API teammate: replace with real window tracking data from agent
            _buildAppRow(context, '💻', 'VS Code',  '47m', 0.82, const Color(0xFFE8F0EA), theme.primaryColor),
            _buildAppRow(context, '🌐', 'Chrome',   '12m', 0.21, const Color(0xFFFFF3E8), theme.colorScheme.secondary),
            _buildAppRow(context, '💬', 'Slack',     '8m', 0.14, const Color(0xFFF0E8F5), theme.colorScheme.error),
            _buildAppRow(context, '📋', 'Notion',    '5m', 0.09, const Color(0xFFE8EEF5), theme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildRow3(BuildContext context, AppState appState) {
    return Row(
      children: [
        Expanded(child: _buildBiometricCard(context, 'Heart Rate', appState.currentBpm, 'BPM', '↓ calm',
            isDrift: appState.isDrifting, heights: [0.4, 0.6, 0.5, 0.45, 0.48, 0.42, 0.44])),
        const SizedBox(width: 14),
        Expanded(child: _buildBiometricCard(context, 'HRV', 54, 'ms', '↑ high',
            heights: [0.55, 0.7, 0.8, 0.75, 0.85, 0.82, 0.88])),
        const SizedBox(width: 14),
        Expanded(child: _buildEarCard(context, appState)),
      ],
    );
  }

  Widget _buildEarCard(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EYE FATIGUE', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(appState.currentEar.toStringAsFixed(2),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: theme.primaryColor)),
            Text('EAR · Normal', style: theme.textTheme.labelSmall),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: appState.currentEar,
                minHeight: 8,
                backgroundColor: theme.dividerColor,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text('threshold 0.25', style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  Widget _buildStatPill(BuildContext context, int target, String label, String unit,
      {bool isPrimary = false, bool isFatigue = false, String prefix = ''}) {
    final theme = Theme.of(context);
    final bgColor  = isFatigue ? theme.colorScheme.secondaryContainer : theme.colorScheme.primaryContainer;
    final valColor = isFatigue ? theme.colorScheme.secondary : theme.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CountUpText(target: target, prefix: prefix,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: valColor, letterSpacing: -0.5)),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 2),
                child: Text(unit, style: TextStyle(fontSize: 11, color: valColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, String label, String value, String sub,
      {bool isGreen = false, bool isOrange = false}) {
    final colors = isGreen
        ? [const Color(0xFF4F6F57), const Color(0xFF6B8F71)]
        : [const Color(0xFF8B5E3A), const Color(0xFFC4845A)];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'DM Mono', letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -2, height: 1)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, String emoji, String title, String time,
      bool isGreen, bool isOrange, {bool isLast = false}) {
    final theme = Theme.of(context);
    final dotBg = isGreen ? theme.colorScheme.primaryContainer
        : (isOrange ? theme.colorScheme.secondaryContainer : theme.colorScheme.surface);
    final dotBorder = isGreen ? theme.primaryColor
        : (isOrange ? theme.colorScheme.secondary : theme.dividerColor);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: dotBg, border: Border.all(color: dotBorder, width: 2), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 14)),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: theme.dividerColor)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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

  Widget _buildAppRow(BuildContext context, String emoji, String name, String time,
      double progress, Color iconBg, Color barColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(time, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress, minHeight: 6,
                    backgroundColor: Theme.of(context).dividerColor,
                    color: barColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricCard(BuildContext context, String title, int target, String unit, String sub,
      {bool isDrift = false, required List<double> heights}) {
    final theme = Theme.of(context);
    final highlightColor = isDrift ? theme.colorScheme.error : theme.primaryColor;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                CountUpText(target: target,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: highlightColor, letterSpacing: -1.5)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unit, style: theme.textTheme.bodySmall),
                    Text(sub, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.primaryColor)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: heights.map((h) => Expanded(
                child: Container(
                  height: 48 * h,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: h > 0.6 ? 1.0 : (h > 0.45 ? 0.7 : 0.3)),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, bool isGreen) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isGreen
            ? (isDark ? FlowTheme.primaryTintDark : FlowTheme.primaryTintLight)
            : (isDark ? FlowTheme.fatigueBgDark : FlowTheme.fatigueBgLight),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: isGreen
              ? (isDark ? FlowTheme.primaryDark : FlowTheme.primaryLight)
              : (isDark ? FlowTheme.fatigueDark : FlowTheme.fatigueLight))),
    );
  }
}