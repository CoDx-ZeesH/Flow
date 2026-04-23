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
  String _selectedTask = 'Deep work';
  String _selectedDuration = '50m';
  String _selectedDifficulty = 'moderate';
  final _intentController = TextEditingController();

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
      case '25m':    return 25;
      case '50m':    return 50;
      case '90m':    return 90;
      default:       return 50;
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

    // Store intent in AppState before navigating — API teammate reads these
    context.read<AppState>().prepareSession(
      task: task,
      difficulty: _selectedDifficulty,
      durationMin: _durationMinutes,
    );

    // API teammate: call POST /session/start here, then call appState.startSession(sessionId)
    // For now, MainLayout's onStartSession handles the optimistic routing.
    widget.onStartSession?.call();
  }

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTaskTypeCard(context),
                      const SizedBox(height: 16),
                      _buildIntentDeclarationCard(context),
                      const SizedBox(height: 16),
                      _buildDurationCard(context),
                      const SizedBox(height: 16),
                      _buildDifficultyCard(context),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _handleBeginSession,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_fill_rounded, size: 22),
                            SizedBox(width: 8),
                            Text('Begin focus session', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildOptimalWindowHero(context),
                      const SizedBox(height: 12),
                      _buildCalendarCheckCard(context),
                      const SizedBox(height: 12),
                      _buildPatternInsightCard(context),
                      const SizedBox(height: 12),
                      _buildRecentIntentionsCard(context),
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

  Widget _buildTopBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STARTING A SESSION',
          style: theme.textTheme.labelMedium?.copyWith(
            color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light)),
        const SizedBox(height: 2),
        Text('What will you focus on?', style: theme.textTheme.headlineLarge),
      ],
    );
  }

  Widget _buildTaskTypeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task type', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _taskChips.map((chip) => _buildChip(
                context,
                emoji: chip['emoji']!,
                label: chip['label']!,
                isSelected: _selectedTask == chip['label'],
                onTap: () => setState(() => _selectedTask = chip['label']!),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntentDeclarationCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Declare your intention', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _intentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g. Fix the JWT token refresh bug in the auth module and write unit tests…',
                contentPadding: EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 10),
            Text('Be specific — FLOW will track drift against this intent.',
              style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target duration', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 12),
            Row(
              children: _durations.map((dur) {
                final isSelected = _selectedDuration == dur;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: dur != _durations.last ? 8.0 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDuration = dur),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).scaffoldBackgroundColor,
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(dur,
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                          )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cognitive demand', style: theme.textTheme.labelMedium),
            const SizedBox(height: 12),
            Row(
              children: _difficulties.entries.map((entry) {
                final isSelected = _selectedDifficulty == entry.key;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: entry.key != 'heavy' ? 8.0 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDifficulty = entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primaryContainer : theme.scaffoldBackgroundColor,
                          border: Border.all(
                            color: isSelected ? theme.primaryColor : theme.dividerColor, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(entry.value,
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
                          )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimalWindowHero(BuildContext context) {
    final appState = context.watch<AppState>();
    // API teammate: populate appState.peakFocusHours and this will update
    final peakHour = appState.peakFocusHours.isNotEmpty ? appState.peakFocusHours.first : 10;
    final now = DateTime.now();
    final isInPeak = appState.peakFocusHours.contains(now.hour);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F6F57), Color(0xFF6B8F71)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OPTIMAL WINDOW',
            style: TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'DM Mono', letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(isInPeak ? 'Right now ✓' : '$peakHour:00 today',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
          const SizedBox(height: 6),
          Text(
            isInPeak
                ? "You're in a peak ultradian phase. Best window starts immediately."
                : "Your peak window opens at $peakHour:00. Consider timing your session then.",
            style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildCalendarCheckCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calendar check', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            // API teammate: replace with real calendar context from GET /calendar/context
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                children: [
                  const TextSpan(text: 'Next meeting in '),
                  TextSpan(text: '2h 36m',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('✓ Plenty of uninterrupted time',
              style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternInsightCard(BuildContext context) {
    final appState = context.watch<AppState>();
    final peakHours = appState.peakFocusHours.isNotEmpty
        ? appState.peakFocusHours.take(2).map((h) => '$h:00').join('–')
        : '9:00–11:00';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your pattern says', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: const Text('🔬', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Peak hours: $peakHours',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.bodyLarge?.color)),
                        Text('${appState.ultradianCycleMinutes}min ultradian cycle',
                          style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentIntentionsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent intentions', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 10),
            // API teammate: populate from session history
            _buildRecentTaskItem(context, '🐛 Debug auth module'),
            const SizedBox(height: 6),
            _buildRecentTaskItem(context, '📝 Write engineering spec'),
            const SizedBox(height: 6),
            _buildRecentTaskItem(context, '🎨 UI component design'),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, {required String emoji, required String label,
      required bool isSelected, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : theme.scaffoldBackgroundColor,
          border: Border.all(color: isSelected ? theme.primaryColor : theme.dividerColor, width: 1.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label,
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTaskItem(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
    );
  }
}