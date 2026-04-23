// lib/screens/main_layout.dart
//
// Changes vs pasted version:
//   ✅ Debug interrupt toggle: a persistent FAB (shown on non-session tabs only)
//      lets you open InterruptScreen from anywhere during hackathon demo
//   ✅ Active session FAB (simulate drift) is already on ActiveSessionScreen —
//      the layout FAB is only visible on Dashboard/Intent/Patterns/Team tabs
//   ✅ SessionEnd routing unchanged
//   ✅ All existing callback wiring preserved exactly

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import 'dashboard_screen.dart';
import 'intent_screen.dart';
import 'active_session_screen.dart';
import 'session_end_screen.dart';
import 'patterns_screen.dart';
import 'team_screen.dart';
import 'interrupt_screen.dart';

const kTabDashboard = 0;
const kTabIntent    = 1;
const kTabActive    = 2;
const kTabPatterns  = 3;
const kTabTeam      = 4;

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int  _currentIndex    = kTabDashboard;
  bool _showingSessionEnd = false;

  // ── Debug only — remove before production ─────────────────────────────────
  final bool _showDebugFab = true; // set false to hide
  // ────────────────────────────────────────────────────────────────────────────

  void _switchTab(int index) => setState(() {
    _currentIndex       = index;
    _showingSessionEnd  = false;
  });

  void _goToActiveSession() => setState(() => _currentIndex = kTabActive);

  void _onSessionEnded() => setState(() => _showingSessionEnd = true);

  void _onReturnToDashboard() {
    context.read<AppState>().clearSession();
    setState(() {
      _showingSessionEnd = false;
      _currentIndex      = kTabDashboard;
    });
  }

  // Open an interrupt type for demo/testing from any tab
  void _openInterrupt(InterruptType type) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => InterruptScreen(type: type),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme    = Theme.of(context);
    final isDark   = theme.brightness == Brightness.dark;

    final primaryColor = theme.primaryColor;
    final primaryTint  = primaryColor.withValues(alpha: isDark ? 0.1 : 0.15);
    final text3Color   = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final driftColor   = theme.colorScheme.error;

    Widget body;
    if (_showingSessionEnd) {
      body = SessionEndScreen(onReturnToDashboard: _onReturnToDashboard);
    } else {
      final screens = [
        DashboardScreen(
          key: const ValueKey('dash'),
          onStartSession: () => _switchTab(kTabIntent),
        ),
        IntentScreen(
          key: const ValueKey('intent'),
          onStartSession: () {
            context.read<AppState>().startSession('demo-session-temp');
            _goToActiveSession();
          },
        ),
        ActiveSessionScreen(
          key: const ValueKey('active'),
          onEndSession: _onSessionEnded,
        ),
        const PatternsScreen(key: ValueKey('patterns')),
        const TeamScreen(key: ValueKey('team')),
      ];

      body = IndexedStack(
        index: _currentIndex,
        children: screens.asMap().entries.map((e) => TickerMode(
          enabled: _currentIndex == e.key,
          child: e.value,
        )).toList(),
      );
    }

    // Only show debug FAB on non-session, non-sessionEnd tabs
    final showFab = _showDebugFab &&
        !_showingSessionEnd &&
        _currentIndex != kTabActive;

    return Scaffold(
      floatingActionButton: showFab ? _buildDebugFab(theme) : null,
      body: Row(
        children: [
          // ─── SIDEBAR ───────────────────────────────────────────────────
          Container(
            width: 72,
            decoration: BoxDecoration(
              color:  theme.cardColor,
              border: Border(right: BorderSide(color: theme.dividerColor)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo
                GestureDetector(
                  onTap: () => _switchTab(kTabDashboard),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.blur_circular_rounded, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(height: 16),

                // Nav items
                _navItem(Icons.grid_view_rounded,   kTabDashboard, primaryColor, primaryTint, text3Color),
                _navItem(Icons.adjust_rounded,      kTabIntent,    primaryColor, primaryTint, text3Color),
                _navItem(Icons.access_time_rounded, kTabActive,    primaryColor, primaryTint, text3Color,
                    isNotif: appState.sessionPhase == SessionPhase.active,
                    notifColor: driftColor),
                _navItem(Icons.show_chart_rounded,  kTabPatterns,  primaryColor, primaryTint, text3Color),
                _navItem(Icons.people_alt_rounded,  kTabTeam,      primaryColor, primaryTint, text3Color),

                const Spacer(),

                // Theme toggle
                GestureDetector(
                  onTap: () => appState.toggleTheme(),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: primaryTint, borderRadius: BorderRadius.circular(13)),
                    child: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: primaryColor, size: 20),
                  ),
                ),
                const SizedBox(height: 8),

                // Avatar
                GestureDetector(
                  onTap: () => _showLogoutDialog(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        primaryColor,
                        isDark ? const Color(0xFF3A6B64) : const Color(0xFF3D7A72),
                      ]),
                      shape:  BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        appState.userFirstName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // ─── MAIN CONTENT ───────────────────────────────────────────────
          Expanded(child: body),
        ],
      ),
    );
  }

  // ── Debug FAB — lets judges/team trigger any interrupt screen instantly ─────
  Widget _buildDebugFab(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Small label above the FAB group
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color:        theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border:       Border.all(color: theme.dividerColor),
          ),
          child: Text('DEBUG', style: theme.textTheme.labelSmall),
        ),
        const SizedBox(height: 8),

        // Fatigue
        FloatingActionButton.small(
          heroTag:         'fab_fatigue',
          backgroundColor: theme.colorScheme.secondary,
          onPressed:       () => _openInterrupt(InterruptType.fatigue),
          tooltip:         'Simulate Fatigue',
          child:           const Icon(Icons.battery_alert_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 6),

        // Drift → with AI chat
        FloatingActionButton.small(
          heroTag:         'fab_drift',
          backgroundColor: theme.colorScheme.error,
          onPressed:       () => _openInterrupt(InterruptType.drift),
          tooltip:         'Simulate Drift (with AI chat)',
          child:           const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 6),

        // Ultradian
        FloatingActionButton.small(
          heroTag:         'fab_ultradian',
          backgroundColor: theme.primaryColor,
          onPressed:       () => _openInterrupt(InterruptType.ultradianBreak),
          tooltip:         'Simulate Ultradian Break',
          child:           const Icon(Icons.waves_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 6),

        // User requested
        FloatingActionButton(
          heroTag:         'fab_user',
          backgroundColor: theme.primaryColor,
          onPressed:       () => _openInterrupt(InterruptType.userRequested),
          tooltip:         'Open Take-a-Break screen',
          child:           const Icon(Icons.self_improvement_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _navItem(IconData icon, int index, Color primary, Color tint, Color text3,
      {bool isNotif = false, Color? notifColor}) {
    final isActive = !_showingSessionEnd && _currentIndex == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        width: 44, height: 44,
        decoration: BoxDecoration(
          color:        isActive ? tint : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: isActive ? primary : text3, size: 20),
            if (isActive)
              Positioned(
                left: 0,
                child: Container(
                  width: 3, height: 24,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(3), bottomRight: Radius.circular(3)),
                  ),
                ),
              ),
            if (isNotif)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    color:  notifColor ?? Colors.red,
                    shape:  BoxShape.circle,
                    border: Border.all(color: Theme.of(context).cardColor, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign out?', style: Theme.of(context).textTheme.headlineMedium),
        content: Text('Your session data is saved.', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppState>().logout();
            },
            child: Text('Sign out', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}