import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/app_state.dart';
import 'screens/flow_router.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const FlowApp(),
    ),
  );
}

class FlowApp extends StatelessWidget {
  const FlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return MaterialApp(
      title: 'FLOW',
      debugShowCheckedModeBanner: false,
      theme: FlowTheme.lightTheme,
      darkTheme: FlowTheme.darkTheme,
      themeMode: appState.themeMode,
      home: const FlowRouter(),
    );
  }
}