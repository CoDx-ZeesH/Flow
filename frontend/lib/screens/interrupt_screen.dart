// lib/screens/interrupt_screen.dart
//
// Fixes vs previous:
//   ✅ Breathe in / breathe out text restored — animates with the ring cycle
//   ✅ "Discuss with AI" button on drift type opens an AI chat bottom sheet
//   ✅ AI chat wired to demo replies (API teammate: swap _simulateReply for POST /session/ai-discuss)
//   ✅ Tip card added for all types
//   ✅ Routing: Navigator.pop(context) throughout — works whether pushed from session or debug toggle

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';

enum InterruptType { fatigue, drift, ultradianBreak, userRequested }

class InterruptScreen extends StatefulWidget {
  final InterruptType type;
  const InterruptScreen({super.key, required this.type});

  @override
  State<InterruptScreen> createState() => _InterruptScreenState();
}

class _InterruptScreenState extends State<InterruptScreen>
    with TickerProviderStateMixin {
  int  _selectedMinutes = 5;
  bool _timerStarted    = false;
  int  _secondsLeft     = 0;
  Timer? _countdownTimer;

  late AnimationController _breatheCtrl;
  late Animation<double>   _breatheAnim;
  late AnimationController _entryCtrl;
  late Animation<double>   _entryAnim;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = switch (widget.type) {
      InterruptType.fatigue        => 5,
      InterruptType.ultradianBreak => 10,
      InterruptType.drift          => 5,
      InterruptType.userRequested  => 5,
    };

    _breatheCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _breatheAnim = CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut);

    _entryCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _breatheCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _startBreak() {
    setState(() {
      _timerStarted = true;
      _secondsLeft  = _selectedMinutes * 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) { t.cancel(); _onBreakComplete(); }
      });
    });
  }

  void _onBreakComplete() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Break complete ✓', style: Theme.of(context).textTheme.headlineMedium),
        content: Text('Ready to resume your session?', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: Text('Resume session →',
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }

  void _openAiChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AiChatSheet(),
    );
  }

  _InterruptCopy get _copy {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (widget.type) {
      InterruptType.fatigue => _InterruptCopy(
        icon: Icons.battery_alert_rounded,
        color: isDark ? FlowTheme.fatigueDark : FlowTheme.fatigueLight,
        title: 'Your brain needs a reset',
        message: "You've been in deep focus for a while — your cognitive reserves are depleting. A break now will buy you 45 more minutes of quality work.",
        tag: 'AI DETECTED — FATIGUE',
        tip: 'Walk to a window. Let your visual focus relax to infinity for 20 seconds. It genuinely resets the visual cortex.',
      ),
      InterruptType.drift => _InterruptCopy(
        icon: Icons.cloud_off_rounded,
        color: isDark ? FlowTheme.driftDark : FlowTheme.driftLight,
        title: "You've drifted from your intention",
        message: "Context drift is normal. Noticing it is the skill. FLOW paused your session to help you reset and return intentionally.",
        tag: 'AI DETECTED — DRIFT',
        tip: 'Before returning: write one sentence about exactly what you were trying to accomplish. Re-anchor your intention.',
      ),
      InterruptType.ultradianBreak => _InterruptCopy(
        icon: Icons.waves_rounded,
        color: isDark ? FlowTheme.primaryDark : FlowTheme.primaryLight,
        title: 'Natural break point reached',
        message: "You've completed a full ultradian focus cycle. This is the ideal moment for a 10–15 min break — not too early, not too late.",
        tag: 'ULTRADIAN RHYTHM',
        tip: 'Fully disengage now. Avoid screens and work-related thoughts. Your next cycle will be stronger.',
      ),
      InterruptType.userRequested => _InterruptCopy(
        icon: Icons.self_improvement_rounded,
        color: isDark ? FlowTheme.primaryDark : FlowTheme.primaryLight,
        title: 'Taking a break',
        message: "Good call. Step away, let your visual focus relax, and come back fresh. FLOW will keep your session warm.",
        tag: 'USER INITIATED',
        tip: 'Stretch, hydrate, or take 5 slow breaths. Physical micro-recovery directly improves cognitive performance.',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy  = _copy;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _entryAnim,
        builder: (_, child) => Opacity(
          opacity: _entryAnim.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _entryAnim.value)),
            child: child,
          ),
        ),
        child: Row(
          children: [
            // ── Left: breathing ring ──────────────────────────────────────
            Expanded(
              flex: 5,
              child: Center(
                child: AnimatedBuilder(
                  animation: _breatheAnim,
                  builder: (_, __) => _BreathingRing(
                    color:        copy.color,
                    breatheValue: _breatheAnim.value,
                    timerStarted: _timerStarted,
                    secondsLeft:  _secondsLeft,
                    totalSeconds: _selectedMinutes * 60,
                    fmt:          _fmt,
                  ),
                ),
              ),
            ),

            // ── Right: controls ───────────────────────────────────────────
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(64),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: copy.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: copy.color.withValues(alpha: 0.3)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(copy.icon, size: 14, color: copy.color),
                        const SizedBox(width: 8),
                        Text(copy.tag, style: theme.textTheme.labelSmall?.copyWith(color: copy.color)),
                      ]),
                    ),
                    const SizedBox(height: 24),

                    Text(copy.title, style: theme.textTheme.headlineLarge?.copyWith(height: 1.2)),
                    const SizedBox(height: 16),
                    Text(copy.message, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
                    const SizedBox(height: 32),

                    if (!_timerStarted) ...[
                      // Duration picker
                      Text('HOW LONG?', style: theme.textTheme.labelSmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [5, 10, 15, 20].map((min) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _DurBtn(
                            label: '$min min',
                            selected: _selectedMinutes == min,
                            color: copy.color,
                            theme: theme,
                            onTap: () => setState(() => _selectedMinutes = min),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 28),

                      // Start break
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: copy.color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _startBreak,
                          child: Text('Start $_selectedMinutes-min break',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // AI chat — only on drift type
                      if (widget.type == InterruptType.drift) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                            label: const Text('Discuss with AI'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: copy.color,
                              side: BorderSide(color: copy.color.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _openAiChat,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Dismiss
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Dismiss and resume session',
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                        ),
                      ),
                    ] else ...[
                      // Active countdown controls
                      Text('BREAK IN PROGRESS', style: theme.textTheme.labelSmall),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.stop_rounded, size: 18),
                          label: const Text('End break early'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: copy.color,
                            side: BorderSide(color: copy.color.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Tip card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: copy.color.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: copy.color.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: copy.color, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(copy.tip,
                                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Breathing ring ───────────────────────────────────────────────────────────

class _BreathingRing extends StatelessWidget {
  final Color  color;
  final double breatheValue;   // 0→1 inhale, 1→0 exhale (reverse: true)
  final bool   timerStarted;
  final int    secondsLeft;
  final int    totalSeconds;
  final String Function(int) fmt;

  const _BreathingRing({
    required this.color,
    required this.breatheValue,
    required this.timerStarted,
    required this.secondsLeft,
    required this.totalSeconds,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final progress = timerStarted && totalSeconds > 0
        ? 1.0 - (secondsLeft / totalSeconds)
        : 0.0;

    // breatheValue 0→1 = inhaling, 1→0 = exhaling
    final isInhaling   = breatheValue > 0.5;
    final breatheLabel = timerStarted
        ? 'REMAINING'
        : (isInhaling ? 'INHALE...' : 'EXHALE...');

    return Stack(
      alignment: Alignment.center,
      children: [
        // Ambient glow — expands on inhale
        Container(
          width:  320 + breatheValue * 60,
          height: 320 + breatheValue * 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:       color.withValues(alpha: 0.06 + breatheValue * 0.10),
                blurRadius:  80,
                spreadRadius: 10 + breatheValue * 30,
              ),
            ],
          ),
        ),

        // Painted ring
        CustomPaint(
          size: const Size(340, 340),
          painter: _BreathRingPainter(
            color:    color,
            progress: progress,
            breathe:  breatheValue,
          ),
        ),

        // Center content
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timerStarted ? fmt(secondsLeft) : fmt(totalSeconds),
              style: TextStyle(
                fontSize:      72,
                fontWeight:    FontWeight.w800,
                color:         color,
                fontFamily:    'DM Mono',
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 8),
            // Breathe in / out label — fades between states
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                breatheLabel,
                key: ValueKey(breatheLabel),
                style: theme.textTheme.labelSmall?.copyWith(
                  color:         color,
                  letterSpacing: 3,
                  fontSize:      11,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BreathRingPainter extends CustomPainter {
  final Color  color;
  final double progress;
  final double breathe;
  _BreathRingPainter({required this.color, required this.progress, required this.breathe});

  @override
  void paint(Canvas canvas, Size size) {
    final center      = Offset(size.width / 2, size.height / 2);
    final radius      = (size.width / 2) - 24;
    final strokeWidth = 8.0 + breathe * 5.0;

    canvas.drawCircle(center, radius,
        Paint()
          ..color       = color.withValues(alpha: 0.12)
          ..style       = PaintingStyle.stroke
          ..strokeWidth = strokeWidth);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..color       = color
          ..style       = PaintingStyle.stroke
          ..strokeCap   = StrokeCap.round
          ..strokeWidth = strokeWidth,
      );
    }
  }

  @override
  bool shouldRepaint(_BreathRingPainter old) =>
      old.progress != progress || old.breathe != breathe;
}

// ─── Duration button ──────────────────────────────────────────────────────────

class _DurBtn extends StatelessWidget {
  final String    label;
  final bool      selected;
  final Color     color;
  final ThemeData theme;
  final VoidCallback onTap;
  const _DurBtn({required this.label, required this.selected, required this.color,
      required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(color: selected ? color : theme.dividerColor, width: selected ? 1.5 : 1.0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:      selected ? color : theme.textTheme.labelSmall?.color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            )),
      ),
    );
  }
}

// ─── AI Chat bottom sheet ─────────────────────────────────────────────────────

class _AiChatSheet extends StatefulWidget {
  const _AiChatSheet();
  @override
  State<_AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<_AiChatSheet> {
  final _ctrl      = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Msg> _msgs = [];
  bool _loading = false;
  int  _replyIdx = 0;

  // API teammate: replace with POST /session/ai-discuss {message, session_id}
  static const _replies = [
    "What's the last thing you understood clearly before getting stuck?",
    "Try explaining the problem out loud — sometimes saying it exposes the flaw in the assumption.",
    "What are you assuming must be true that might not be? Flip your mental model.",
    "Break it into the smallest possible pieces. What's the tiniest thing you can verify right now?",
    "Sometimes being stuck means the approach is wrong, not you. What would a completely different approach look like?",
  ];

  @override
  void initState() {
    super.initState();
    // Opening message from AI
    _msgs.add(_Msg(
      text:   "I can see you're stuck. Tell me exactly what you're trying to do, and where the block is.",
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() { _msgs.add(_Msg(text: text, isUser: true)); _ctrl.clear(); _loading = true; });
    _scroll();
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _msgs.add(_Msg(text: _replies[_replyIdx % _replies.length], isUser: false));
      _replyIdx++;
    });
    _scroll();
  }

  void _scroll() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  });

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize:     0.4,
      maxChildSize:     0.92,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color:        theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border:       Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40, height: 4,
                decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color:        theme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.auto_awesome_rounded, color: theme.primaryColor, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FLOW AI', style: theme.textTheme.headlineSmall?.copyWith(color: theme.primaryColor)),
                      Text('Helping you get unstuck', style: theme.textTheme.labelSmall),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    color: theme.textTheme.labelSmall?.color,
                  ),
                ],
              ),
            ),
            Divider(color: theme.dividerColor),
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: _msgs.length + (_loading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (_loading && i == _msgs.length) return _typingIndicator(theme);
                  final m = _msgs[i];
                  return _bubble(m, theme, isDark);
                },
              ),
            ),
            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              decoration: BoxDecoration(
                color:  theme.cardColor,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style:      theme.textTheme.bodyMedium,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Describe what you\'re stuck on…',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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

  Widget _bubble(_Msg m, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: m.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!m.isUser) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(Icons.auto_awesome_rounded, color: theme.primaryColor, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: m.isUser ? theme.primaryColor
                    : (isDark ? FlowTheme.elevatedDark : FlowTheme.elevatedLight),
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(18),
                  topRight:    const Radius.circular(18),
                  bottomLeft:  Radius.circular(m.isUser ? 18 : 4),
                  bottomRight: Radius.circular(m.isUser ? 4 : 18),
                ),
              ),
              child: Text(m.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: m.isUser ? Colors.white : null, height: 1.5)),
            ),
          ),
          if (m.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _typingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.auto_awesome_rounded, color: theme.primaryColor, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color:        theme.dividerColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [0, 180, 360].map((d) => _TypingDot(delayMs: d)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool   isUser;
  _Msg({required this.text, required this.isUser});
}

class _TypingDot extends StatefulWidget {
  final int delayMs;
  const _TypingDot({required this.delayMs});
  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double>   _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.repeat(reverse: true);
    });
    _a = Tween<double>(begin: 0.3, end: 1.0).animate(_c);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) => Container(
        width: 7, height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color:  Theme.of(context).primaryColor.withValues(alpha: _a.value),
          shape:  BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Copy data class ──────────────────────────────────────────────────────────

class _InterruptCopy {
  final IconData icon;
  final Color    color;
  final String   title;
  final String   message;
  final String   tag;
  final String   tip;
  _InterruptCopy({required this.icon, required this.color, required this.title,
      required this.message, required this.tag, required this.tip});
}