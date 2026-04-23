// lib/screens/intent_screen.dart
//
// NBBS v2 Lite rebuild:
//   ✅ Bento two-column layout preserved, card radius → 12px
//   ✅ Task chips: pill → square, hard border on selected
//   ✅ Intent textarea: hard 2px border, square corners
//   ✅ Duration + difficulty selectors: hard border selected state
//   ✅ Optimal window hero: gradient → solid primary fill + hard border
//   ✅ Right column info cards: soft-border _IntentCard
//   ✅ CTA: solid primary fill, hard 2px border, square 12px radius
//   ✅ All AppState wiring preserved

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';

class IntentScreen extends StatefulWidget {
  final VoidCallback? onStartSession;
  const IntentScreen({super.key, this.onStartSession});

  @override
  State<IntentScreen> createState() => _IntentScreenState();
}

class _IntentScreenState extends State<IntentScreen> {
  String _selectedTask       = 'Deep work';
  String _selectedDuration   = '50m';
  String _selectedDifficulty = 'moderate';
  final _intentController    = TextEditingController();

  final List<Map<String, String>> _taskChips = [
    {'emoji': '🧠', 'label': 'Deep work'},
    {'emoji': '📝', 'label': 'Writing'},
    {'emoji': '🐛', 'label': 'Debugging'},
    {'emoji': '📊', 'label': 'Review'},
    {'emoji': '📞', 'label': 'Meeting prep'},
    {'emoji': '🎨', 'label': 'Design'},
  ];

  final List<String> _durations = ['25m', '50m', '90m', 'Custom'];

  final Map<String, String> _difficulties = {
    'light':    'Light',
    'moderate': 'Moderate',
    'heavy':    'Heavy',
  };

  int get _durationMinutes {
    switch (_selectedDuration) {
      case '25m': return 25;
      case '50m': return 50;
      case '90m': return 90;
      default:    return 50;
    }
  }

  @override
  void dispose() {
    _intentController.dispose();
    super.dispose();
  }

  void _handleBeginSession() {
    final task = _intentController.text.trim().isNotEmpty
        ? _intentController.text.trim()
        : _selectedTask;

    context.read<AppState>().prepareSession(
      task:        task,
      difficulty:  _selectedDifficulty,
      durationMin: _durationMinutes,
    );

    // API teammate: call POST /session/start here, then appState.startSession(sessionId)
    widget.onStartSession?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Text(
              'STARTING A SESSION',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
              ),
            ),
            const SizedBox(height: 3),
            Text('What will you focus on?',
                style: theme.textTheme.headlineLarge),
            const SizedBox(height: 24),

            // ── Bento two-column layout ────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN — form
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTaskTypeCard(context, theme, isDark),
                      const SizedBox(height: 14),
                      _buildIntentCard(context, theme, isDark),
                      const SizedBox(height: 14),
                      _buildDurationCard(context, theme, isDark),
                      const SizedBox(height: 14),
                      _buildDifficultyCard(context, theme, isDark),
                      const SizedBox(height: 20),

                      // ── CTA — NBBS: solid primary, hard 2px border ──────
                      GestureDetector(
                        onTap: _handleBeginSession,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? FlowTheme.borderDark
                                  : FlowTheme.borderLight,
                              width: 2,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_circle_fill_rounded,
                                  size: 20, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Begin focus session',
                                style: TextStyle(
                                  color:      Colors.white,
                                  fontSize:   15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // RIGHT COLUMN — context cards
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildOptimalWindowHero(context, theme, isDark),
                      const SizedBox(height: 12),
                      _buildCalendarCheckCard(context, theme, isDark),
                      const SizedBox(height: 12),
                      _buildPatternInsightCard(context, theme, isDark),
                      const SizedBox(height: 12),
                      _buildRecentIntentionsCard(context, theme, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── TASK TYPE CARD ────────────────────────────────────────────────────────

  Widget _buildTaskTypeCard(BuildContext context, ThemeData theme, bool isDark) {
    return _IntentCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TASK TYPE', style: theme.textTheme.labelMedium),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _taskChips.map((chip) => _TaskChip(
              emoji:      chip['emoji']!,
              label:      chip['label']!,
              isSelected: _selectedTask == chip['label'],
              isDark:     isDark,
              color:      theme.primaryColor,
              onTap:      () => setState(() => _selectedTask = chip['label']!),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ── INTENT DECLARATION CARD ───────────────────────────────────────────────

  Widget _buildIntentCard(BuildContext context, ThemeData theme, bool isDark) {
    return _IntentCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DECLARE YOUR INTENTION', style: theme.textTheme.labelMedium),
          const SizedBox(height: 14),
          // NBBS: hard-border textarea
          TextField(
            controller: _intentController,
            maxLines:   4,
            style:      theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'e.g. Fix the JWT token refresh bug and write unit tests…',
              hintStyle: TextStyle(
                color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark
                      ? FlowTheme.borderSoftDark
                      : FlowTheme.borderSoftLight,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Be specific — FLOW will track drift against this intent.',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  // ── DURATION CARD ─────────────────────────────────────────────────────────

  Widget _buildDurationCard(BuildContext context, ThemeData theme, bool isDark) {
    return _IntentCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TARGET DURATION', style: theme.textTheme.labelMedium),
          const SizedBox(height: 14),
          Row(
            children: _durations.map((dur) {
              final isSelected = _selectedDuration == dur;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: dur != _durations.last ? 8.0 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDuration = dur),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 130),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? (isDark
                                  ? FlowTheme.borderDark
                                  : FlowTheme.borderLight)
                              : (isDark
                                  ? FlowTheme.borderSoftDark
                                  : FlowTheme.borderSoftLight),
                          width: isSelected ? 2 : 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dur,
                        style: TextStyle(
                          fontFamily:  'DM Mono',
                          fontSize:    13,
                          fontWeight:  FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? FlowTheme.text2Dark
                                  : FlowTheme.text2Light),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── DIFFICULTY CARD ───────────────────────────────────────────────────────

  Widget _buildDifficultyCard(BuildContext context, ThemeData theme, bool isDark) {
    return _IntentCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COGNITIVE LOAD', style: theme.textTheme.labelMedium),
          const SizedBox(height: 14),
          Row(
            children: _difficulties.entries.map((entry) {
              final isSelected = _selectedDifficulty == entry.key;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: entry.key != 'heavy' ? 8.0 : 0),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedDifficulty = entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 130),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? (isDark
                                  ? FlowTheme.borderDark
                                  : FlowTheme.borderLight)
                              : (isDark
                                  ? FlowTheme.borderSoftDark
                                  : FlowTheme.borderSoftLight),
                          width: isSelected ? 2 : 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize:   13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? FlowTheme.text2Dark
                                  : FlowTheme.text2Light),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── OPTIMAL WINDOW HERO ───────────────────────────────────────────────────
  // Gradient → solid primary fill + hard border (NBBS)

  Widget _buildOptimalWindowHero(BuildContext context, ThemeData theme, bool isDark) {
    final appState  = context.watch<AppState>();
    final peakHour  = appState.peakFocusHours.isNotEmpty
        ? appState.peakFocusHours.first
        : 10;
    final now       = DateTime.now();
    final isInPeak  = appState.peakFocusHours.contains(now.hour);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OPTIMAL WINDOW',
            style: TextStyle(
              fontFamily:    'DM Mono',
              fontSize:      10,
              color:         Colors.white70,
              letterSpacing: 1.5,
              fontWeight:    FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isInPeak ? 'Right now ✓' : '$peakHour:00 today',
            style: const TextStyle(
              fontFamily:    'DM Mono',
              fontSize:      32,
              fontWeight:    FontWeight.w800,
              color:         Colors.white,
              letterSpacing: -1.5,
              height:        1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isInPeak
                ? "You're in a peak ultradian phase. Best window starts immediately."
                : "Your peak window opens at $peakHour:00. Consider timing your session then.",
            style: const TextStyle(
              fontSize: 13,
              color:    Colors.white,
              height:   1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ── RIGHT COLUMN CARDS ────────────────────────────────────────────────────

  Widget _buildCalendarCheckCard(BuildContext context, ThemeData theme, bool isDark) {
    return _IntentCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CALENDAR CHECK', style: theme.textTheme.labelMedium),
          const SizedBox(height: 10),
          // API teammate: replace with GET /calendar/context
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
              children: [
                const TextSpan(text: 'Next meeting in '),
                TextSpan(
                  text: '2h 36m',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontFamily: 'DM Mono',
                    color:      isDark ? FlowTheme.text1Dark : FlowTheme.text1Light,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color:  theme.primaryColor,
                  shape:  BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Plenty of uninterrupted time',
                style: TextStyle(
                  fontSize:   11,
                  fontWeight: FontWeight.w600,
                  color:      theme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternInsightCard(BuildContext context, ThemeData theme, bool isDark) {
    final appState  = context.watch<AppState>();
    final peakHours = appState.peakFocusHours.isNotEmpty
        ? appState.peakFocusHours.take(2).map((h) => '$h:00').join('–')
        : '9:00–11:00';

    return _IntentCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR PATTERN SAYS', style: theme.textTheme.labelMedium),
          const SizedBox(height: 12),
          // Accent bar row — NBBS structural detail
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color:         isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
                    borderRadius:  BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? FlowTheme.borderSoftDark
                          : FlowTheme.borderSoftLight,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🔬', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peak hours: $peakHours',
                        style: TextStyle(
                          fontSize:   12,
                          fontWeight: FontWeight.w700,
                          color:      isDark
                              ? FlowTheme.text1Dark
                              : FlowTheme.text1Light,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${appState.ultradianCycleMinutes}min ultradian cycle',
                        style: theme.textTheme.labelSmall,
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

  Widget _buildRecentIntentionsCard(BuildContext context, ThemeData theme, bool isDark) {
    return _IntentCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECENT INTENTIONS', style: theme.textTheme.labelMedium),
          const SizedBox(height: 12),
          // API teammate: populate from session history
          _RecentTaskItem(
              text: '🐛 Debug auth module', isDark: isDark, theme: theme),
          const SizedBox(height: 6),
          _RecentTaskItem(
              text: '📝 Write engineering spec', isDark: isDark, theme: theme),
          const SizedBox(height: 6),
          _RecentTaskItem(
              text: '🎨 UI component design', isDark: isDark, theme: theme),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRIVATE COMPONENTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Base card — soft border, 12px radius
class _IntentCard extends StatelessWidget {
  final Widget child;
  final bool   isDark;

  const _IntentCard({required this.child, required this.isDark});

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

/// Task chip — NBBS: hard border on selected, no pill radius
class _TaskChip extends StatelessWidget {
  final String       emoji;
  final String       label;
  final bool         isSelected;
  final bool         isDark;
  final Color        color;
  final VoidCallback onTap;

  const _TaskChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (isDark ? FlowTheme.borderDark : FlowTheme.borderLight)
                : (isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? FlowTheme.text2Dark : FlowTheme.text2Light),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent task row — soft tinted background
class _RecentTaskItem extends StatelessWidget {
  final String    text;
  final bool      isDark;
  final ThemeData theme;

  const _RecentTaskItem({
    required this.text,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? FlowTheme.elevatedDark : FlowTheme.elevatedLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color:    isDark ? FlowTheme.text2Dark : FlowTheme.text2Light,
        ),
      ),
    );
  }
}