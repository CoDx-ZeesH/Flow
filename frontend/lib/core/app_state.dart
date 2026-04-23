import 'package:flutter/material.dart';

// ─── USER ROLES ───────────────────────────────────────────────────────────────
enum UserRole { solo, employee, admin }

// ─── SESSION STATES ──────────────────────────────────────────────────────────
enum SessionPhase { idle, active, ended }

// ─── APP STATE (Single source of truth) ──────────────────────────────────────
// API teammate: call the setters below after your HTTP calls succeed.
// Example:
//   final state = context.read<AppState>();
//   state.setUser(id: res['user_id'], name: res['full_name'], role: 'admin', token: res['token']);
//   state.setDashboard(focusScore: res['focus_score_today'], ...);

class AppState extends ChangeNotifier {

  // ─── THEME ──────────────────────────────────────────────────────────────
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // ─── AUTH ────────────────────────────────────────────────────────────────
  String? userId;
  String? userName;
  String? userFirstName;
  String? jwtToken;
  String? teamId;
  UserRole role = UserRole.solo;
  bool get isLoggedIn => jwtToken != null;
  bool get isAdmin => role == UserRole.admin;

  /// API teammate calls this after POST /auth/login or /auth/register succeeds.
  void setUser({
    required String id,
    required String name,
    required String roleStr,   // 'solo' | 'employee' | 'admin'
    required String token,
    String? teamId,
  }) {
    userId = id;
    userName = name;
    userFirstName = name.split(' ').first;
    jwtToken = token;
    this.teamId = teamId;
    role = _parseRole(roleStr);
    notifyListeners();
  }

  void logout() {
    userId = null;
    userName = null;
    userFirstName = null;
    jwtToken = null;
    teamId = null;
    role = UserRole.solo;
    _sessionPhase = SessionPhase.idle;
    notifyListeners();
  }

  UserRole _parseRole(String r) {
    switch (r) {
      case 'admin':    return UserRole.admin;
      case 'employee': return UserRole.employee;
      default:         return UserRole.solo;
    }
  }

  // ─── DASHBOARD DATA ──────────────────────────────────────────────────────
  int focusScoreToday = 75;
  int focusScoreDelta = 0;
  int sessionsToday = 0;
  int totalDurationMinutes = 0;
  int rhythmPositionMinutes = 0;
  int minutesUntilTrough = 45;
  String greetingMessage = 'Good morning';

  /// API teammate calls this after GET /user/dashboard succeeds.
  void setDashboard({
    required int focusScore,
    required int delta,
    required int sessions,
    required int totalDuration,
    required int rhythmPosition,
    required int minutesTrough,
    required String greeting,
  }) {
    focusScoreToday = focusScore;
    focusScoreDelta = delta;
    sessionsToday = sessions;
    totalDurationMinutes = totalDuration;
    rhythmPositionMinutes = rhythmPosition;
    minutesUntilTrough = minutesTrough;
    greetingMessage = greeting;
    notifyListeners();
  }

  // ─── PATTERNS DATA ───────────────────────────────────────────────────────
  int ultradianCycleMinutes = 90;
  List<int> peakFocusHours = [9, 10, 14];
  List<Map<String, dynamic>> weeklyTrends = [];   // [{label, value}]
  List<Map<String, dynamic>> hourlyQuality = [];  // [{label, value}]

  /// API teammate calls this after GET /user/patterns succeeds.
  void setPatterns({
    required int cycleMinutes,
    required List<int> peakHours,
    required List<Map<String, dynamic>> weekly,
    required List<Map<String, dynamic>> hourly,
  }) {
    ultradianCycleMinutes = cycleMinutes;
    peakFocusHours = peakHours;
    weeklyTrends = weekly;
    hourlyQuality = hourly;
    notifyListeners();
  }

  // ─── ACTIVE SESSION ──────────────────────────────────────────────────────
  SessionPhase _sessionPhase = SessionPhase.idle;
  SessionPhase get sessionPhase => _sessionPhase;

  String? activeSessionId;
  String currentTask = '';
  String currentDifficulty = 'moderate';
  int plannedDurationMin = 50;

  // Live telemetry — API teammate updates these via updateTelemetry()
  int currentBpm = 74;
  double currentEar = 0.31;
  int focusScore = 75;
  bool isDrifting = false;
  String currentState = 'deep_work';  // deep_work | stuck | fatigue | passive
  Map<String, double> signals = {
    'ultradian': 0.8,
    'behavioral': 0.75,
    'biometric': 0.7,
    'ear': 0.82,
  };

  // Intervention
  bool hasIntervention = false;
  String? interventionTitle;
  String? interventionMessage;
  String? interventionAction;

  /// Called when user clicks Begin Focus (before API call).
  void prepareSession({
    required String task,
    required String difficulty,
    required int durationMin,
  }) {
    currentTask = task;
    currentDifficulty = difficulty;
    plannedDurationMin = durationMin;
    isDrifting = false;
    hasIntervention = false;
    notifyListeners();
  }

  /// API teammate calls this after POST /session/start succeeds.
  void startSession(String sessionId) {
    activeSessionId = sessionId;
    _sessionPhase = SessionPhase.active;
    isDrifting = false;
    hasIntervention = false;
    notifyListeners();
  }

  /// API teammate calls this every 8s after GET /session/status.
  void updateTelemetry({
    required int bpm,
    required double ear,
    required int score,
    required bool drifting,
    required String state,
    required Map<String, double> signalMap,
    bool intervention = false,
    String? iTitle,
    String? iMessage,
    String? iAction,
  }) {
    currentBpm = bpm;
    currentEar = ear;
    focusScore = score;
    isDrifting = drifting;
    currentState = state;
    signals = signalMap;
    hasIntervention = intervention;
    interventionTitle = iTitle;
    interventionMessage = iMessage;
    interventionAction = iAction;
    notifyListeners();
  }

  // For demo FAB only — remove once API is wired
  void toggleDrift() {
    isDrifting = !isDrifting;
    notifyListeners();
  }

  // ─── SESSION END DATA ────────────────────────────────────────────────────
  int endedFocusScore = 0;
  int endedDurationMin = 0;
  int endedInterventionsTotal = 0;
  int endedInterventionsAccepted = 0;
  List<Map<String, dynamic>> replayEvents = [];
  String whatFlowLearned = '';
  List<double> sessionScoreHistory = [];

  /// API teammate calls this after POST /session/end succeeds.
  void endSession({
    required int focusScore,
    required int durationMin,
    required int interventionsTotal,
    required int interventionsAccepted,
    required List<Map<String, dynamic>> events,
    required String learned,
    required List<double> scoreHistory,
  }) {
    endedFocusScore = focusScore;
    endedDurationMin = durationMin;
    endedInterventionsTotal = interventionsTotal;
    endedInterventionsAccepted = interventionsAccepted;
    replayEvents = events;
    whatFlowLearned = learned;
    sessionScoreHistory = scoreHistory;
    _sessionPhase = SessionPhase.ended;
    activeSessionId = null;
    notifyListeners();
  }

  /// Called after user views session end screen and returns to dashboard.
  void clearSession() {
    _sessionPhase = SessionPhase.idle;
    endedFocusScore = 0;
    endedDurationMin = 0;
    replayEvents = [];
    whatFlowLearned = '';
    sessionScoreHistory = [];
    notifyListeners();
  }

  // ─── TEAM DATA ───────────────────────────────────────────────────────────
  String teamName = 'Your Team';
  int teamAvgFocusScore = 0;
  int teamActiveSessions = 0;
  int teamTotalEmployees = 0;
  List<Map<String, dynamic>> teamEmployees = [];

  /// API teammate calls this after GET /team/summary succeeds.
  void setTeamData({
    required String name,
    required int avgScore,
    required int activeSessions,
    required int total,
    required List<Map<String, dynamic>> employees,
  }) {
    teamName = name;
    teamAvgFocusScore = avgScore;
    teamActiveSessions = activeSessions;
    teamTotalEmployees = total;
    teamEmployees = employees;
    notifyListeners();
  }

  // ─── ADMIN DATA ──────────────────────────────────────────────────────────
  int adminTotalEmployees = 0;
  int adminActiveRightNow = 0;
  int adminAvgFocusScore = 0;
  int adminBurnoutFlagsCount = 0;
  String adminBestMeetingWindow = '--:--';
  List<Map<String, dynamic>> adminTrend7Days = [];
  List<Map<String, dynamic>> adminBurnoutFlags = [];
  Map<String, int> adminStateDistribution = {};

  /// API teammate calls this after GET /admin/dashboard succeeds.
  void setAdminDashboard({
    required int totalEmployees,
    required int activeRightNow,
    required int avgFocusScore,
    required int burnoutFlagsCount,
    required String bestMeetingWindow,
    required List<Map<String, dynamic>> trend7Days,
    required List<Map<String, dynamic>> burnoutFlags,
    required Map<String, int> stateDistribution,
  }) {
    adminTotalEmployees = totalEmployees;
    adminActiveRightNow = activeRightNow;
    adminAvgFocusScore = avgFocusScore;
    adminBurnoutFlagsCount = burnoutFlagsCount;
    adminBestMeetingWindow = bestMeetingWindow;
    adminTrend7Days = trend7Days;
    adminBurnoutFlags = burnoutFlags;
    adminStateDistribution = stateDistribution;
    notifyListeners();
  }

  // Break alert sent status (for admin UI feedback)
  bool breakAlertSent = false;

  void setBreakAlertSent(bool val) {
    breakAlertSent = val;
    notifyListeners();
  }
}