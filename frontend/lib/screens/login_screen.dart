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
  String _loginMode = 'solo'; // 'solo' | 'company' | 'admin'
  bool _isObscured = true;
  bool _isLoading = false;

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
  // API teammate: replace the body of this method with your real login call.
  // Keep the setState(_isLoading) wrappers.
  // After success, call: context.read<AppState>().setUser(...) — the FlowRouter
  // will automatically navigate to the right shell.
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 300)); // remove when real API added

    if (!mounted) return;

    final appState = context.read<AppState>();

    // TEMPORARY: route by selected tab until API teammate wires real auth.
    // API teammate: delete this block and replace with your HTTP call.
    switch (_loginMode) {
      case 'admin':
        appState.setUser(
          id: 'demo-admin-001',
          name: 'Admin User',
          roleStr: 'admin',
          token: 'demo-token-admin',
          teamId: 'team-err011',
        );
        break;
      case 'company':
        appState.setUser(
          id: 'demo-emp-001',
          name: 'Demo Employee',
          roleStr: 'employee',
          token: 'demo-token-emp',
          teamId: 'team-err011',
        );
        break;
      default:
        appState.setUser(
          id: 'demo-solo-001',
          name: 'Demo User',
          roleStr: 'solo',
          token: 'demo-token-solo',
        );
    }
    // END TEMPORARY BLOCK

    setState(() => _isLoading = false);
    // FlowRouter listens to AppState and navigates automatically — no push needed.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 420,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── LOGO ───
                    Center(
                      child: Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: isDark ? FlowTheme.primaryTintDark : FlowTheme.primaryTintLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                        ),
                        alignment: Alignment.center,
                        child: Text('F',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: theme.primaryColor, fontSize: 32)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Welcome back', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('Log in to sync your cognitive state.',
                      style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 32),

                    // ─── MODE TABS ───
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildTab('Solo',    'solo',    theme)),
                          Expanded(child: _buildTab('Company', 'company', theme)),
                          Expanded(child: _buildTab('Admin',   'admin',   theme)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ─── FIELDS ───
                    _buildTextField('Email address', Icons.email_outlined, _emailController, false, theme),
                    const SizedBox(height: 16),

                    if (_loginMode == 'company') ...[
                      _buildTextField('Company Code', Icons.business_rounded, _companyController, false, theme),
                      const SizedBox(height: 16),
                    ],

                    if (_loginMode == 'admin') ...[
                      _buildTextField('Company Code', Icons.business_rounded, _companyController, false, theme),
                      const SizedBox(height: 16),
                      _buildTextField('Admin Key', Icons.admin_panel_settings_outlined, _adminKeyController, true, theme),
                      const SizedBox(height: 16),
                    ],

                    _buildTextField('Password', Icons.lock_outline_rounded, _passwordController, true, theme),
                    const SizedBox(height: 32),

                    // ─── SUBMIT ───
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(
                                _loginMode == 'admin' ? 'Admin Sign In →' : 'Sign In →',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── FOOTER ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: theme.textTheme.bodyMedium),
                        InkWell(
                          onTap: () {},
                          child: Text('Create one',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.primaryColor, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, String value, ThemeData theme) {
    final isSelected = _loginMode == value;
    return InkWell(
      onTap: () => setState(() => _loginMode = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? theme.textTheme.headlineMedium?.color : theme.textTheme.labelSmall?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          )),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController ctrl, bool isPassword, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: isPassword && _isObscured,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            prefixIcon: Icon(icon, color: theme.textTheme.labelSmall?.color, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    color: theme.textTheme.labelSmall?.color,
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}