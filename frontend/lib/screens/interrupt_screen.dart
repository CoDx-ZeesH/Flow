// lib/screens/interrupt_screen.dart
//
// NBBS v2 Lite rebuild:
//   ✅ Left panel: full-height solid color fill (type accent) — brutalist split layout
//   ✅ Breathing ring centered in colored left panel
//   ✅ Right panel: soft surface, hard-border interactive elements
//   ✅ Duration buttons: NBBS hard-border selected state
//   ✅ Primary CTA: hard border + type color fill
//   ✅ AI chat sheet: NBBS card treatment, hard-border input
//   ✅ Tip card: left-edge accent bar (NBBS signature)
//   ✅ All routing preserved: Navigator.pop(context) throughout
//   ✅ All four InterruptType cases preserved with correct copy + colors

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
  int    _selectedMinutes = 5;
  bool   _timerStarted    = false;
  int    _secondsLeft     = 0;
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
      duration: const Duration(milliseconds: 450),
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
      builder: (ctx) {
        final theme  = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final copy   = _copy;
        return AlertDialog(
          backgroundColor: isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
              width: 2,
            ),
          ),
          title: Text('Break complete ✓', style: theme.textTheme.headlineMedium),
          content: Text(
            'Ready to resume your session?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
              child: Text(
                'Resume session →',
                style: TextStyle(
                  color: copy.color,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Mono',
                ),
              ),
            ),
          ],
        );
      },
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
      builder: (_) => _AiChatSheet(accentColor: _copy.color),
    );
  }

  _InterruptCopy get _copy {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (widget.type) {
      InterruptType.fatigue => _InterruptCopy(
        icon:    Icons.battery_alert_rounded,
        color:   isDark ? FlowTheme.fatigueDark : FlowTheme.fatigueLight,
        title:   'Your brain needs a reset',
        message: "You've been in deep focus for a while — your cognitive reserves are depleting. A break now will buy you 45 more minutes of quality work.",
        tag:     'AI DETECTED — FATIGUE',
        tip:     'Walk to a window. Let your visual focus relax to infinity for 20 seconds. It genuinely resets the visual cortex.',
      ),
      InterruptType.drift => _InterruptCopy(
        icon:    Icons.cloud_off_rounded,
        color:   isDark ? FlowTheme.driftDark : FlowTheme.driftLight,
        title:   "You've drifted from your intention",
        message: "Context drift is normal. Noticing it is the skill. FLOW paused your session to help you reset and return intentionally.",
        tag:     'AI DETECTED — DRIFT',
        tip:     'Before returning: write one sentence about exactly what you were trying to accomplish. Re-anchor your intention.',
      ),
      InterruptType.ultradianBreak => _InterruptCopy(
        icon:    Icons.waves_rounded,
        color:   isDark ? FlowTheme.primaryDark : FlowTheme.primaryLight,
        title:   'Natural break point reached',
        message: "You've completed a full ultradian focus cycle. This is the ideal moment for a 10–15 min break — not too early, not too late.",
        tag:     'ULTRADIAN RHYTHM',
        tip:     'Fully disengage now. Avoid screens and work-related thoughts. Your next cycle will be stronger.',
      ),
      InterruptType.userRequested => _InterruptCopy(
        icon:    Icons.self_improvement_rounded,
        color:   isDark ? FlowTheme.primaryDark : FlowTheme.primaryLight,
        title:   'Taking a break',
        message: "Good call. Step away, let your visual focus relax, and come back fresh. FLOW will keep your session warm.",
        tag:     'USER INITIATED',
        tip:     'Stretch, hydrate, or take 5 slow breaths. Physical micro-recovery directly improves cognitive performance.',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final copy   = _copy;

    return Scaffold(
      backgroundColor: isDark ? FlowTheme.bgDark : FlowTheme.bgLight,
      body: AnimatedBuilder(
        animation: _entryAnim,
        builder: (_, child) => Opacity(
          opacity: _entryAnim.value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - _entryAnim.value)),
            child: child,
          ),
        ),
        child: Row(
          children: [
            // ── LEFT PANEL: solid accent fill + breathing ring ─────────────
            Expanded(
              flex: 5,
              child: Container(
                color: copy.color,
                child: Stack(
                  children: [
                    // Subtle grid texture overlay for brutalist texture
                    Positioned.fill(
                      child: CustomPaint(painter: _GridPainter()),
                    ),
                    // Breathing ring centered
                    Center(
                      child: AnimatedBuilder(
                        animation: _breatheAnim,
                        builder: (_, __) => _BreathingRing(
                          breatheValue: _breatheAnim.value,
                          timerStarted: _timerStarted,
                          secondsLeft:  _secondsLeft,
                          totalSeconds: _selectedMinutes * 60,
                          fmt:          _fmt,
                        ),
                      ),
                    ),
                    // Type tag pinned bottom-left
                    Positioned(
                      left: 32, bottom: 32,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(copy.icon, size: 13, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              copy.tag,
                              style: const TextStyle(
                                fontFamily:    'DM Mono',
                                fontSize:      10,
                                fontWeight:    FontWeight.w700,
                                color:         Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hard vertical divider — NBBS structural border
            Container(
              width: 2,
              color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
            ),

            // ── RIGHT PANEL: controls ──────────────────────────────────────
            Expanded(
              flex: 4,
              child: Container(
                color: isDark ? FlowTheme.bgDark : FlowTheme.bgLight,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 56, vertical: 64),
                  child: Column(
                    mainAxisAlignment:  MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        copy.title,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Message
                      Text(
                        copy.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 36),

                      if (!_timerStarted) ...[
                        // Duration label
                        Text('HOW LONG?', style: theme.textTheme.labelMedium),
                        const SizedBox(height: 12),

                        // Duration buttons — NBBS hard border on selected
                        Row(
                          children: [5, 10, 15, 20].map((min) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _DurBtn(
                              label:    '$min min',
                              selected: _selectedMinutes == min,
                              color:    copy.color,
                              isDark:   isDark,
                              onTap:    () => setState(() => _selectedMinutes = min),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 28),

                        // Primary CTA — NBBS: solid fill, hard 2px border
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: _startBreak,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: copy.color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? FlowTheme.borderDark
                                      : FlowTheme.borderLight,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Start $_selectedMinutes-min break',
                                  style: const TextStyle(
                                    color:      Colors.white,
                                    fontSize:   15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // AI chat — drift type only
                        if (widget.type == InterruptType.drift) ...[
                          GestureDetector(
                            onTap: _openAiChat,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: copy.color,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome_rounded,
                                      size: 17, color: copy.color),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Discuss with AI',
                                    style: TextStyle(
                                      color:      copy.color,
                                      fontSize:   15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Dismiss
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Dismiss and resume session',
                              style: TextStyle(
                                color: isDark
                                    ? FlowTheme.text3Dark
                                    : FlowTheme.text3Light,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                      ] else ...[
                        // Active countdown state
                        Text('BREAK IN PROGRESS',
                            style: theme.textTheme.labelMedium),
                        const SizedBox(height: 24),

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: copy.color,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.stop_rounded,
                                    size: 17, color: copy.color),
                                const SizedBox(width: 8),
                                Text(
                                  'End break early',
                                  style: TextStyle(
                                    color:      copy.color,
                                    fontSize:   15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Tip card — NBBS: left accent bar instead of tinted fill
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? FlowTheme.surfaceDark
                              : FlowTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? FlowTheme.borderSoftDark
                                : FlowTheme.borderSoftLight,
                            width: 1.5,
                          ),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // NBBS accent bar
                              Container(
                                width: 4,
                                decoration: BoxDecoration(
                                  color: copy.color,
                                  borderRadius: const BorderRadius.only(
                                    topLeft:    Radius.circular(11),
                                    bottomLeft: Radius.circular(11),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline_rounded,
                                        color: copy.color,
                                        size: 17,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          copy.tip,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(height: 1.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREATHING RING — white on solid color panel
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _BreathingRing extends StatelessWidget {
  final double breatheValue;
  final bool   timerStarted;
  final int    secondsLeft;
  final int    totalSeconds;
  final String Function(int) fmt;

  const _BreathingRing({
    required this.breatheValue,
    required this.timerStarted,
    required this.secondsLeft,
    required this.totalSeconds,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final progress = timerStarted && totalSeconds > 0
        ? 1.0 - (secondsLeft / totalSeconds)
        : 0.0;

    final isInhaling   = breatheValue > 0.5;
    final breatheLabel = timerStarted
        ? 'REMAINING'
        : (isInhaling ? 'INHALE...' : 'EXHALE...');

    return Stack(
      alignment: Alignment.center,
      children: [
        // Ambient white glow — expands on inhale
        Container(
          width:  280 + breatheValue * 60,
          height: 280 + breatheValue * 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:        Colors.white.withValues(alpha: 0.08 + breatheValue * 0.10),
                blurRadius:   80,
                spreadRadius: 10 + breatheValue * 30,
              ),
            ],
          ),
        ),

        // Ring — white on colored background
        CustomPaint(
          size: const Size(300, 300),
          painter: _BreathRingPainter(
            progress: progress,
            breathe:  breatheValue,
          ),
        ),

        // Center content — white text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timerStarted ? fmt(secondsLeft) : fmt(totalSeconds),
              style: const TextStyle(
                fontSize:      72,
                fontWeight:    FontWeight.w800,
                color:         Colors.white,
                fontFamily:    'DM Mono',
                letterSpacing: -2,
                height:        1.0,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                breatheLabel,
                key: ValueKey(breatheLabel),
                style: const TextStyle(
                  fontFamily:    'DM Mono',
                  fontSize:      11,
                  fontWeight:    FontWeight.w700,
                  color:         Colors.white70,
                  letterSpacing: 3,
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
  final double progress;
  final double breathe;
  _BreathRingPainter({required this.progress, required this.breathe});

  @override
  void paint(Canvas canvas, Size size) {
    final center      = Offset(size.width / 2, size.height / 2);
    final radius      = (size.width / 2) - 24;
    final strokeWidth = 8.0 + breathe * 6.0;

    // Track ring — white at low opacity
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color       = Colors.white.withValues(alpha: 0.18)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc — solid white
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..color       = Colors.white
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUBTLE GRID TEXTURE (left panel background texture)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DURATION BUTTON — NBBS hard border on selected
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _DurBtn extends StatelessWidget {
  final String       label;
  final bool         selected;
  final Color        color;
  final bool         isDark;
  final VoidCallback onTap;

  const _DurBtn({
    required this.label,
    required this.selected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? (isDark ? FlowTheme.borderDark : FlowTheme.borderLight)
                : (isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected
                ? Colors.white
                : (isDark ? FlowTheme.text2Dark : FlowTheme.text2Light),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'DM Mono',
            fontSize:   13,
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AI CHAT BOTTOM SHEET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _AiChatSheet extends StatefulWidget {
  final Color accentColor;
  const _AiChatSheet({required this.accentColor});

  @override
  State<_AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<_AiChatSheet> {
  final _ctrl       = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Msg>  _msgs    = [];
  bool _loading  = false;
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
    setState(() {
      _msgs.add(_Msg(text: text, isUser: true));
      _ctrl.clear();
      _loading = true;
    });
    _scroll();
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _msgs.add(_Msg(
          text: _replies[_replyIdx % _replies.length], isUser: false));
      _replyIdx++;
    });
    _scroll();
  }

  void _scroll() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve:    Curves.easeOut,
      );
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
          color: isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          border: Border.all(
            color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color:         isDark ? FlowTheme.borderSoftDark : FlowTheme.borderSoftLight,
                  borderRadius:  BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
              child: Row(
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color:        widget.accentColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white, size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FLOW AI',
                        style: TextStyle(
                          fontFamily:    'DM Mono',
                          fontSize:      14,
                          fontWeight:    FontWeight.w800,
                          color:         widget.accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Helping you get unstuck',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
                  ),
                ],
              ),
            ),

            // Divider — NBBS hard line
            Container(
              height: 2,
              color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                itemCount: _msgs.length + (_loading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (_loading && i == _msgs.length) {
                    return _typingIndicator(theme, isDark);
                  }
                  return _bubble(_msgs[i], isDark);
                },
              ),
            ),

            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              decoration: BoxDecoration(
                color: isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? FlowTheme.borderSoftDark
                        : FlowTheme.borderSoftLight,
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:  _ctrl,
                      style:       theme.textTheme.bodyMedium,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: "Describe what you're stuck on…",
                        hintStyle: TextStyle(
                          color: isDark
                              ? FlowTheme.text3Dark
                              : FlowTheme.text3Light,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        // NBBS: hard border on input
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark
                                ? FlowTheme.borderDark
                                : FlowTheme.borderLight,
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
                            color: widget.accentColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Send button — NBBS: solid fill + hard border
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color:        widget.accentColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? FlowTheme.borderDark
                              : FlowTheme.borderLight,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white, size: 18,
                      ),
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

  Widget _bubble(_Msg m, bool isDark) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:  m.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!m.isUser) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color:        widget.accentColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white, size: 13,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: m.isUser
                    ? widget.accentColor
                    : (isDark ? FlowTheme.elevatedDark : FlowTheme.elevatedLight),
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(12),
                  topRight:    const Radius.circular(12),
                  bottomLeft:  Radius.circular(m.isUser ? 12 : 3),
                  bottomRight: Radius.circular(m.isUser ? 3 : 12),
                ),
                border: m.isUser
                    ? null
                    : Border.all(
                        color: isDark
                            ? FlowTheme.borderSoftDark
                            : FlowTheme.borderSoftLight,
                        width: 1,
                      ),
              ),
              child: Text(
                m.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:  m.isUser ? Colors.white : null,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (m.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _typingIndicator(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color:        widget.accentColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 13),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color:        isDark ? FlowTheme.elevatedDark : FlowTheme.elevatedLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? FlowTheme.borderSoftDark
                    : FlowTheme.borderSoftLight,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [0, 180, 360]
                  .map((d) => _TypingDot(
                        delayMs:     d,
                        accentColor: widget.accentColor,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPPORT CLASSES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _Msg {
  final String text;
  final bool   isUser;
  _Msg({required this.text, required this.isUser});
}

class _TypingDot extends StatefulWidget {
  final int   delayMs;
  final Color accentColor;
  const _TypingDot({required this.delayMs, required this.accentColor});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double>   _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync:    this,
        duration: const Duration(milliseconds: 600));
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.repeat(reverse: true);
    });
    _a = Tween<double>(begin: 0.3, end: 1.0).animate(_c);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) => Container(
        width:  7, height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color:  widget.accentColor.withValues(alpha: _a.value),
          shape:  BoxShape.circle,
        ),
      ),
    );
  }
}

class _InterruptCopy {
  final IconData icon;
  final Color    color;
  final String   title;
  final String   message;
  final String   tag;
  final String   tip;
  _InterruptCopy({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.tag,
    required this.tip,
  });
}