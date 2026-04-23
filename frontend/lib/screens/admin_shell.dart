import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import 'admin_screen.dart';
import 'admin_employee_report_screen.dart';

// ─── ADMIN TAB INDICES ────────────────────────────────────────────────────────
const kAdminTabDashboard = 0;
const kAdminTabReports   = 1;

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentTab = kAdminTabDashboard;

  void _switchTab(int index) => setState(() => _currentTab = index);

  Future<void> _sendBreakAlert(BuildContext context) async {
    final appState = context.read<AppState>();

    // Show confirmation first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Send team break alert?', style: Theme.of(context).textTheme.headlineMedium),
        content: Text(
          'This will notify all ${appState.adminActiveRightNow} active employees to take a break.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // API teammate: replace with POST /admin/send-break-alert
    // final res = await http.post(Uri.parse('$base/admin/send-break-alert'),
    //   headers: {'Authorization': 'Bearer ${appState.jwtToken}'});
    // if (res.statusCode == 200) { appState.setBreakAlertSent(true); }

    // TEMPORARY: optimistic UI
    appState.setBreakAlertSent(true);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✓ Break alert sent to all active employees'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Reset after 5 seconds so button can be sent again
    await Future.delayed(const Duration(seconds: 5));
    if (context.mounted) appState.setBreakAlertSent(false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.primaryColor;
    final primaryTint  = primaryColor.withValues(alpha: isDark ? 0.1 : 0.15);
    final text3Color   = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final errorColor   = theme.colorScheme.error;

    final screens = [
      const AdminScreen(key: ValueKey('admin-dash')),
      const AdminEmployeeReportScreen(key: ValueKey('admin-reports')),
    ];

    return Scaffold(
      body: Row(
        children: [
          // ─── ADMIN SIDEBAR ──────────────────────────────────────────────
          Container(
            width: 72,
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(right: BorderSide(color: theme.dividerColor, width: 1)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Logo — with admin indicator
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, isDark ? const Color(0xFF3A6B64) : const Color(0xFF3D7A72)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 8),
                Text('ADMIN',
                  style: TextStyle(
                    fontSize: 8, fontFamily: 'DM Mono',
                    color: primaryColor, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const SizedBox(height: 16),

                // Dashboard tab
                _buildNavItem(
                  Icons.dashboard_rounded,
                  kAdminTabDashboard,
                  'Overview',
                  primaryColor, primaryTint, text3Color,
                ),

                // Reports tab
                _buildNavItem(
                  Icons.people_alt_rounded,
                  kAdminTabReports,
                  'Reports',
                  primaryColor, primaryTint, text3Color,
                  badge: appState.adminBurnoutFlagsCount > 0
                      ? '${appState.adminBurnoutFlagsCount}'
                      : null,
                ),

                const Spacer(),

                // ── SEND BREAK ALERT BUTTON ──────────────────────────────
                Tooltip(
                  message: 'Send team break alert',
                  child: GestureDetector(
                    onTap: appState.breakAlertSent ? null : () => _sendBreakAlert(context),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: appState.breakAlertSent
                            ? primaryTint
                            : errorColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        appState.breakAlertSent
                            ? Icons.check_circle_rounded
                            : Icons.notifications_active_rounded,
                        color: appState.breakAlertSent ? primaryColor : errorColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Theme toggle
                GestureDetector(
                  onTap: () => appState.toggleTheme(),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: primaryTint, borderRadius: BorderRadius.circular(13)),
                    child: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: primaryColor, size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Avatar / logout
                GestureDetector(
                  onTap: () => _showLogoutDialog(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, isDark ? const Color(0xFF3A6B64) : const Color(0xFF3D7A72)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        appState.userFirstName?.substring(0, 1).toUpperCase() ?? 'A',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // ─── ADMIN CONTENT ──────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _currentTab,
              children: screens.asMap().entries.map((e) =>
                TickerMode(enabled: _currentTab == e.key, child: e.value)
              ).toList(),
            ),
          ),
        ],
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
        content: Text('You will be returned to the login screen.', style: Theme.of(context).textTheme.bodyMedium),
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

  Widget _buildNavItem(
    IconData icon, int index, String tooltip,
    Color primaryColor, Color primaryTint, Color text3Color,
    {String? badge}
  ) {
    final isActive = _currentTab == index;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => _switchTab(index),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: isActive ? primaryTint : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: isActive ? primaryColor : text3Color, size: 20),
              if (isActive)
                Positioned(
                  left: 0,
                  child: Container(
                    width: 3, height: 24,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(3), bottomRight: Radius.circular(3)),
                    ),
                  ),
                ),
              if (badge != null)
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(badge,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}