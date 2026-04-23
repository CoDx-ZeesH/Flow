import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import 'login_screen.dart';
import 'main_layout.dart';
import 'admin_shell.dart';

/// FlowRouter sits at the root of the app (instead of home: LoginScreen).
/// It listens to AppState and routes the user to the correct shell:
///
///   Not logged in      → LoginScreen
///   Logged in, admin   → AdminShell   (separate layout)
///   Logged in, other   → MainLayout   (sidebar with 5 tabs)
///
/// API teammate: just call appState.setUser(...) after login succeeds
/// and this widget automatically navigates without any pushNamed needed.

class FlowRouter extends StatelessWidget {
  const FlowRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.isLoggedIn) {
      return const LoginScreen();
    }

    if (appState.isAdmin) {
      return const AdminShell();
    }

    return const MainLayout();
  }
}