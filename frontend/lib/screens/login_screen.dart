// lib/screens/login_screen.dart
//
// NBBS v2 Lite rebuild:
//   ✅ Card → Container + soft border, 12px radius
//   ✅ Mode tabs: shadow toggle → hard border on selected, DM Mono, 8px radius
//   ✅ Logo mark: pill → 12px square, hard 2px border, focusSoft fill
//   ✅ Text fields: radius 12→8, FlowTheme border constants, hard focus border
//   ✅ ElevatedButton → GestureDetector + Container, solid primary, hard 2px border
//   ✅ primaryTintLight/Dark → focusSoftLight/Dark
//   ✅ All auth routing logic preserved

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _loginMode  = 'solo'; // 'solo' | 'company' | 'admin'
  bool   _isObscured = true;
  bool   _isLoading  = false;

  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyController  = TextEditingController();
  final _adminKeyController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    _adminKeyController.dispose();
    super.dispose();
  }

  // ─── ROUTING ─────────────────────────────────────────────────────────────
  // API teammate: replace body with real login call.
  // Keep setState(_isLoading) wrappers.
  // After success: context.read<AppState>().setUser(...) — FlowRouter auto-navigates.
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300)); // remove when API added
    if (!mounted) return;

    final appState = context.read<AppState>();

    // TEMPORARY: route by tab until API teammate wires real auth.
    switch (_loginMode) {
      case 'admin':
        appState.setUser(id: 'demo-admin-001', name: 'Admin User',
            roleStr: 'admin', token: 'demo-token-admin', teamId: 'team-err011');
        break;
      case 'company':
        appState.setUser(id: 'demo-emp-001', name: 'Demo Employee',
            roleStr: 'employee', token: 'demo-token-emp', teamId: 'team-err011');
        break;
      default:
        appState.setUser(id: 'demo-solo-001', name: 'Demo User',
            roleStr: 'solo', token: 'demo-token-solo');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FlowTheme.bgDark : FlowTheme.bgLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 420,
            // ── Login card — NBBS: soft border, 12px radius ──────────────
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color:        isDark ? FlowTheme.surfaceDark : FlowTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? FlowTheme.borderSoftDark
                      : FlowTheme.borderSoftLight,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize:     MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── Logo mark ─────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: isDark
                            ? FlowTheme.focusSoftDark
                            : FlowTheme.focusSoftLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? FlowTheme.borderDark
                              : FlowTheme.borderLight,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'F',
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize:   28,
                          fontWeight: FontWeight.w800,
                          color:      theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Welcome back',
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(
                    'Log in to sync your cognitive state.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // ── Mode tabs — NBBS: hard border on selected ──────────
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color:        isDark
                          ? FlowTheme.elevatedDark
                          : FlowTheme.elevatedLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? FlowTheme.borderSoftDark
                            : FlowTheme.borderSoftLight,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildTab('Solo',    'solo',    theme, isDark)),
                        Expanded(child: _buildTab('Company', 'company', theme, isDark)),
                        Expanded(child: _buildTab('Admin',   'admin',   theme, isDark)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Fields ────────────────────────────────────────────
                  _buildTextField(context, 'Email address',
                      Icons.email_outlined, _emailController, false, theme, isDark),
                  const SizedBox(height: 14),

                  if (_loginMode == 'company') ...[
                    _buildTextField(context, 'Company Code',
                        Icons.business_rounded, _companyController, false, theme, isDark),
                    const SizedBox(height: 14),
                  ],

                  if (_loginMode == 'admin') ...[
                    _buildTextField(context, 'Company Code',
                        Icons.business_rounded, _companyController, false, theme, isDark),
                    const SizedBox(height: 14),
                    _buildTextField(context, 'Admin Key',
                        Icons.admin_panel_settings_outlined, _adminKeyController, true, theme, isDark),
                    const SizedBox(height: 14),
                  ],

                  _buildTextField(context, 'Password',
                      Icons.lock_outline_rounded, _passwordController, true, theme, isDark),
                  const SizedBox(height: 32),

                  // ── Submit — solid primary, hard 2px border ────────────
                  GestureDetector(
                    onTap: _isLoading ? null : _handleLogin,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? theme.primaryColor.withValues(alpha: 0.6)
                            : theme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? FlowTheme.borderDark
                              : FlowTheme.borderLight,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(
                              height: 18, width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _loginMode == 'admin'
                                  ? 'Admin Sign In →'
                                  : 'Sign In →',
                              style: const TextStyle(
                                color:      Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize:   14,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Footer ────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: theme.textTheme.bodyMedium),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Create one',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:      theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── MODE TAB ──────────────────────────────────────────────────────────────

  Widget _buildTab(String title, String value, ThemeData theme, bool isDark) {
    final isSelected = _loginMode == value;
    return GestureDetector(
      onTap: () => setState(() => _loginMode = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: isSelected
              ? Border.all(
                  color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
                  width: 2,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize:   12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? FlowTheme.text2Dark : FlowTheme.text2Light),
          ),
        ),
      ),
    );
  }

  // ── TEXT FIELD ────────────────────────────────────────────────────────────

  Widget _buildTextField(
    BuildContext context,
    String label,
    IconData icon,
    TextEditingController ctrl,
    bool isPassword,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 8),
        TextField(
          controller:  ctrl,
          obscureText: isPassword && _isObscured,
          style:       theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            filled:    true,
            fillColor: isDark ? FlowTheme.elevatedDark : FlowTheme.elevatedLight,
            prefixIcon: Icon(
              icon,
              color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
              size:  20,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    color: isDark ? FlowTheme.text3Dark : FlowTheme.text3Light,
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark
                    ? FlowTheme.borderSoftDark
                    : FlowTheme.borderSoftLight,
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
                color: isDark ? FlowTheme.borderDark : FlowTheme.borderLight,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}